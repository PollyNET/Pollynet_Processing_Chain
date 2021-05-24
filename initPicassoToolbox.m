function initPicassoToolbox(updateToolbox)
%      _____   _____   _____   _____     _____     |
%     /  ___| /  _  \ |  _  \ |  _  \   / ___ \    |   COnstraint-Based Reconstruction and Analysis
%     | |     | | | | | |_| | | |_| |  | |___| |   |   The COBRA Toolbox verson 3.1 
%     | |     | | | | |  _  { |  _  /  |  ___  |   |
%     | |___  | |_| | | |_| | | | \ \  | |   | |   |   Documentation:
%     \_____| \_____/ |_____/ |_|  \_\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox
%                                                  |
%
%     setup_PollyNET_processing_toolbox Setup the toolbox for 
%
%     Defines default solvers and paths, tests SBML io functionality.
%     Function only needs to be called once per installation. Saves paths afer script terminates.
%
%     In addition add either of the following into startup.m (generally in MATLAB_DIRECTORY/toolbox/local/startup.m)
%
%     initCobraToolbox
%           -or-
%     changeCobraSolver('gurobi');
%     changeCobraSolver('gurobi', 'MILP');
%     changeCobraSolver('tomlab_cplex', 'QP');
%     changeCobraSolver('tomlab_cplex', 'MIQP');
%     changeCbMapOutput('svg');
%
%     Maintained by Ronan M.T. Fleming, Laurent Heirendt

% define GLOBAL variables
global PicassoConfig
global CampaignConfig
global PollyConfig
global RetConfig;
global VisConfig
global ENV_VARS;
global gitBashVersion;

%% print header
if ~ isfield(ENV_VARS, 'printLevel') || ENV_VARS.printLevel
    fprintf('%s\n', '    ____  _                               _____  ____');
    fprintf('%s\n', '   / __ \(_)________ _______________     |__  / / __ \');
    fprintf('%s\n', '  / /_/ / / ___/ __ `/ ___/ ___/ __ \     /_ < / / / /');
    fprintf('%s\n', ' / ____/ / /__/ /_/ (__  |__  ) /_/ /   ___/ // /_/ /');
    fprintf('%s\n', '/_/   /_/\___/\__,_/____/____/\____/   /____(_)____/');
end

%% add search paths
% retrieve the current directory
currentDir = pwd;

% define the root path of The COBRA Toolbox and change to it.
picassoDir = fileparts(which('initPicassoToolbox'));
cd(picassoDir);

addpath(genpath(fullfile(picassoDir, 'lib')));
addpath(genpath(fullfile(picassoDir, 'include')));

%% check if git is installed
[installedGit, versionGit] = checkGit();

% set the depth flag if the version of git is higher than 2.10.0
depthFlag = '';
if installedGit && versionGit > 2100
    depthFlag = '--depth=1';
end

% change to the root of The Picasso Tooolbox
cd(picassoDir);

% configure a remote tracking repository
if ENV_VARS.printLevel
    fprintf(' > Checking if the repository is tracked using git ... ');
end

% check if the directory is a git-tracked folder
if exist(fullfile(picassoDir, '.git'), 'dir') ~= 7
    % initialize the directory
    [status_gitInit, result_gitInit] = system('git init');
    
    if status_gitInit ~= 0
        fprintf(result_gitInit);
        error(' > This directory is not a git repository.\n');
    end
    
    % set the remote origin
    [status_setOrigin, result_setOrigin] = system('git remote add origin https://github.com/PollyNET/Pollynet_Processing_Chain.git');
    
    if status_setOrigin ~= 0
        fprintf(result_setOrigin);
        error(' > The remote tracking origin could not be set.');
    end
    
    % check curl
    [status_curl, result_curl] = checkCurlAndRemote();
    
    if status_curl == 0
        % set the remote origin
        [status_fetch, result_fetch] = system(['git fetch origin master ' depthFlag]);
        if status_fetch ~= 0
            fprintf(result_fetch);
            error(' > The files could not be fetched.');
        end
        
        [status_resetMixed, result_resetMixed] = system('git reset --mixed origin/master');
        
        if status_resetMixed ~= 0
            fprintf(result_resetMixed);
            error(' > The remote tracking origin could not be set.');
        end
    end
end

if ENV_VARS.printLevel
    fprintf(' Done.\n');
end

% temporary disable ssl verification
[status_setSSLVerify, result_setSSLVerify] = system('git config --global http.sslVerify false');

if status_setSSLVerify ~= 0
    fprintf(strrep(result_setSSLVerify, '\', '\\'));
    warning('Your global git configuration could not be changed.');
end

% check curl
[status_curl, result_curl] = checkCurlAndRemote(false);

submoduleWarning=0;
% check if the URL exists
if exist([CBTDIR filesep 'binary' filesep 'README.md'], 'file') && status_curl ~= 0
    fprintf(' > Submodules exist but cannot be updated (remote cannot be reached).\n');
elseif status_curl == 0
    if ENV_VARS.printLevel
        fprintf(' > Initializing and updating submodules (this may take a while)...');
    end
    
    % Clean the test/models folder
    [status, result] = system('git submodule status models');
    if status == 0 && strcmp(result(1), '-')
        [status, message, messageid] = rmdir([CBTDIR filesep 'test' filesep 'models'], 's');
    end
    
    %Check for changes to submodules
    [status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git status');
    if status_gitSubmodule==0
        if contains(result_gitSubmodule,'modified') || contains(result_gitSubmodule,'Untracked files')
            submoduleWarning = 1;
            [status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git stash push -u');
            if status_gitSubmodule==0
                fprintf('\n%s\n','***Local changes to submodules have been stashed. See https://git-scm.com/docs/git-stash.')
                disp(result_gitSubmodule)
            end
        end
    end
    
    % Update/initialize submodules
    %By default your submodules repository is in a state called 'detached HEAD'. 
    %This means that the checked-out commit -- which is the one that the super-project (core) needs -- is not associated with a local branch name.
    [status_gitSubmodule, result_gitSubmodule] = system(['git submodule update --init --remote --no-fetch ' depthFlag]);
    
    if status_gitSubmodule ~= 0
        fprintf(strrep(result_gitSubmodule, '\', '\\'));
        error('The submodules could not be initialized.');
    end
    
    % reset each submodule
    %https://github.com/bazelbuild/continuous-integration/issues/727
    %[status_gitReset, result_gitReset] = system('git submodule foreach --recursive git reset --hard');
    %[status_gitReset, result_gitReset] = system('git submodule foreach --recursive --git reset --hard');%old
    
%     if status_gitReset ~= 0
%         fprintf(strrep(result_gitReset, '\', '\\'));
%         warning('The submodules could not be reset.');
%     end
    
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
end

%get the current content of the init Folder
dirContent = getFilesInDir('type','all');

% add the folders of The COBRA Toolbox
folders = {'tutorials', 'papers', 'binary', 'deprecated', 'src', 'test', '.tmp'};

if ENV_VARS.printLevel
    fprintf(' > Adding all the files of The COBRA Toolbox ... ')
end

% add the root folder
addpath(CBTDIR);

% add the external folder
addpath(genpath([CBTDIR filesep 'external']));

% add specific subfolders
for k = 1:length(folders)
    tmpDir = [CBTDIR, filesep, folders{k}];
    if exist(tmpDir, 'dir') == 7
        addpath(genpath(tmpDir));
    end
end

%Adapt the mac path depending on the mac version.
if ismac
    adaptMacPath()
end

% add the docs/source/notes folder
addpath(genpath([CBTDIR filesep 'docs' filesep 'source' filesep 'notes']));

% print a success message
if ENV_VARS.printLevel
    fprintf(' Done.\n');
end

% check if a new update exists
if ENV_VARS.printLevel && status_curl == 0 && contains(result_curl, ' 200') && updateToolbox
    updateCobraToolbox(true); % only check
else
    if ~updateToolbox && ENV_VARS.printLevel
        fprintf('> Checking for available updates ... skipped\n')
    end
end

% restore global configuration by unsetting http.sslVerify
[status_setSSLVerify, result_setSSLVerify] = system('git config --global --unset http.sslVerify');

if status_setSSLVerify ~= 0
    fprintf(strrep(result_setSSLVerify, '\', '\\'));
    warning('Your global git configuration could not be restored.');
end

% set up the COBRA System path
addCOBRABinaryPathToSystemPath();

% change back to the current directory
cd(currentDir);

% cleanup at the end of the successful run
removeTempFiles(CBTDIR, dirContent);

if submoduleWarning
    warning('Local changes have been made to submodules\n%s\n%s\n%s','Local changes have been stashed. See ***Local changes ... above for details.','Such changes should ideally be made to separate forks.', 'See, e.g., https://github.com/opencobra/COBRA.tutorials#contribute-a-new-tutorial-or-modify-an-existing-tutorial')
end

% clear all temporary variables
% Note: global variables are kept in memory - DO NOT clear all the variables!
if ENV_VARS.printLevel
    clearvars
end
end

function [installed, versionGit] = checkGit()
% Checks if git is installed on the system and throws an error if not
%
% USAGE:
%     versionGit = checkGit();
%
% OUTPUT:
%     installed:      boolean to determine whether git is installed or not
%     versionGit:     version of git installed
%

global ENV_VARS

% set the boolean as false (not installed)
installed = false;

if ENV_VARS.printLevel
    fprintf(' > Checking if git is installed ... ')
end

% check if git is properly installed
[status_gitVersion, result_gitVersion] = system('git --version');

% get index of the version string
searchStr = 'git version';
index = strfind(result_gitVersion, searchStr);

if status_gitVersion == 0 && ~isempty(index)
    
    % determine the version of git
    versionGitStr = result_gitVersion(length(searchStr)+1:end);
    
    % replace line breaks and white spaces
    versionGitStr = regexprep(versionGitStr(1:7),'\s+','');
    
    % replace the dots in the version number
    tmp = strrep(versionGitStr, '.', '');
    
    % convert the string of the version number to a number
    versionGit = str2num(tmp);
    
    % set the boolean to true
    installed = true;
    
    if ENV_VARS.printLevel
        fprintf([' Done (version: ' versionGitStr ').\n']);
    end
else
    if ispc
        fprintf('(not installed).\n');
        installGitBash();
    else
        fprintf(result_gitVersion);
        fprintf(' > Please follow the guidelines on how to install git: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');
        error(' > git is not installed.');
    end
end
end

function [status_curl, result_curl] = checkCurlAndRemote(throwError)
% Checks if curl is installed on the system, can connect to the Picasso URL, and throws an error if not
%
% USAGE:
%     status_curl = checkCurlAndRemote(throwError)
%
% INPUT:
%     throwError:   boolean variable that specifies if an error is thrown or a message is displayed
%

global ENV_VARS

if nargin < 1
    throwError = true;
end

if ENV_VARS.printLevel
    fprintf(' > Checking if curl is installed ... ')
end

origLD = getenv('LD_LIBRARY_PATH');
newLD = regexprep(getenv('LD_LIBRARY_PATH'), [matlabroot '/bin/' computer('arch') ':'], '');

% check if curl is properly installed
[status_curl, result_curl] = system('curl --version');

if (status_curl == 0) && (~ isempty(strfind(result_curl, 'curl'))) && (~ isempty(strfind(result_curl, 'http')))
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
elseif ((status_curl == 127 || status_curl == 48) && isunix)
    % status_curl of 48 is "An unknown option was passed in to libcurl"
    % status_curl of 127 is a bash/shell error for "command not found"
    % You can get either if there is mismatch between the library
    % libcurl and the curl program, which happens with matlab's
    % distributed libcurl. In order to avoid library mismatch we
    % temporarily fchange LD_LIBRARY_PATH
    setenv('LD_LIBRARY_PATH', newLD);
    [status_curl, result_curl] = system('curl --version');
    setenv('LD_LIBRARY_PATH', origLD);
    if status_curl == 0 && (~ isempty(strfind(result_curl, 'curl'))) && (~ isempty(strfind(result_curl, 'http')))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        if throwError
            fprintf(result_curl);
            fprintf(' > Please follow the guidelines on how to install curl: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');
            error(' > curl is not installed.');
        else
            if ENV_VARS.printLevel
                fprintf(' (not installed).\n');
            end
        end
    end
else
    if throwError
        if ispc
            fprintf('(not installed).\n');
            installGitBash();
        else
            fprintf(result_curl);
            fprintf(' > Please follow the guidelines on how to install curl: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');
            error(' > curl is not installed.');
        end
    else
        if ENV_VARS.printLevel
            fprintf(' (not installed).\n');
        end
    end
end

if ENV_VARS.printLevel
    fprintf(' > Checking if remote can be reached ... ')
end

% check if the remote repository can be reached
[status_curl, result_curl] = system('curl -s -k --head https://github.com/PollyNET/Pollynet_Processing_Chain');

% check if the URL exists
if status_curl == 0 && (~ isempty(strfind(result_curl, ' 200')))
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
elseif ((status_curl == 127 || status_curl == 48) && isunix)
    setenv('LD_LIBRARY_PATH', newLD);
    [status_curl, result_curl] = system('curl -s -k --head https://github.com/PollyNET/Pollynet_Processing_Chain');
    setenv('LD_LIBRARY_PATH', origLD);
    if status_curl == 0 && (~ isempty(strfind(result_curl, ' 200')))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        if throwError
            fprintf(result_curl);
            error('The remote repository cannot be reached. Please check your internet connection.');
        else
            if ENV_VARS.printLevel
                fprintf(' (unsuccessful - no internet connection).\n');
            end
        end
    end
else
    if throwError
        fprintf(result_curl);
        error('The remote repository cannot be reached. Please check your internet connection.');
    else
        if ENV_VARS.printLevel
            fprintf(' (unsuccessful - no internet connection).\n');
        end
    end
end
end
