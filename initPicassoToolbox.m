function initPicassoToolbox(updateToolbox)
%           ____  _                               _____  ____
%          / __ \(_)________ _______________     |__  / / __ \
%         / /_/ / / ___/ __ `/ ___/ ___/ __ \     /_ < / / / /
%        / ____/ / /__/ /_/ (__  |__  ) /_/ /   ___/ // /_/ /
%       /_/   /_/\___/\__,_/____/____/\____/   /____(_)____/
%
% Setup Picasso toolbox and install all dependencies.
% Maintained by Zhenping Yin & Holger Baars
% HISTORY:
%   2021-06-22: first edition.
%

% define GLOBAL variables
global PicassoConfig
global ENV_VARS;

%% print header
if ~ isfield(ENV_VARS, 'printLevel') || ENV_VARS.printLevel
    fprintf('%s\n', '    ____  _                               _____  ____');
    fprintf('%s\n', '   / __ \(_)________ _______________     |__  / / __ \');
    fprintf('%s\n', '  / /_/ / / ___/ __ `/ ___/ ___/ __ \     /_ < / / / /');
    fprintf('%s\n', ' / ____/ / /__/ /_/ (__  |__  ) /_/ /   ___/ // /_/ /');
    fprintf('%s\n', '/_/   /_/\___/\__,_/____/____/\____/   /____(_)____/');

    ENV_VARS.printLevel = true;
end

if ~ exist('updateToolbox', 'var')
    updateToolbox = false;
end

%% add search paths
% retrieve the current directory
currentDir = pwd;

% define the root path of The Picasso Toolbox and change to it.
PicassoDir = fileparts(which('initPicassoToolbox'));
PicassoConfig.PicassoDir = PicassoDir;
cd(PicassoDir);

addpath(genpath(fullfile(PicassoDir, 'lib')));
addpath(genpath(fullfile(PicassoDir, 'include')));

%% add SQLite driver
pathJDBC = fullfile(PicassoDir, 'include', 'sqlite-jdbc-3.30.1.jar');
if ~ testSQLiteJDBC()
    addSQLiteJDBC(pathJDBC);
end

%% check if git is installed
[installedGit, versionGit] = checkGit();
if ~ installedGit
    warning('Failure in setting up Picasso toolbox.');
    return;
end

% set the depth flag if the version of git is higher than 2.10.0
depthFlag = '';
if installedGit && (versionGit > 2100)
    depthFlag = '--depth=1';
end

% change to the root of The Picasso Tooolbox
cd(PicassoDir);

% configure a remote tracking repository
if ENV_VARS.printLevel
    fprintf(' > Checking if the repository is tracked using git ... \n');
end

% check if the directory is a git-tracked folder
if exist(fullfile(PicassoDir, '.git'), 'dir') ~= 7
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

if ENV_VARS.printLevel
    fprintf(' > Adding all the files of Picasso Toolbox ... \n')
end

% check if a new update exists
if ENV_VARS.printLevel && status_curl == 0 && (~ isempty(strfind(result_curl, ' 200'))) && updateToolbox
    warning('Update functionality is not ready. Please check the link below for how to update Picasso toolbox manually\nhttps://github.com/PollyNET/Pollynet_Processing_Chain\n');
else
    if ~ updateToolbox && ENV_VARS.printLevel
        fprintf('> Checking for available updates ... skipped\n')
    end
end

% restore global configuration by unsetting http.sslVerify
[status_setSSLVerify, result_setSSLVerify] = system('git config --global --unset http.sslVerify');

if status_setSSLVerify ~= 0
    fprintf(strrep(result_setSSLVerify, '\', '\\'));
    warning('Your global git configuration could not be restored.');
end

% change back to the current directory
cd(currentDir);

% cleanup at the end of the successful run

% clear all temporary variables
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
    fprintf(' > Checking if git is installed ... \n')
end

% check if git is properly installed
[status_gitVersion, result_gitVersion] = system('git --version');

% get index of the version string
searchStr = 'git version';
index = strfind(result_gitVersion, searchStr);

if status_gitVersion == 0 && (~ isempty(index))

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
    fprintf('(not installed).\n');
    versionGit = '';
    fprintf(' > Please install git: https://git-scm.com/downloads.\n');
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
    fprintf(' > Checking if curl is installed ... \n')
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
            fprintf(' > Please install git where curl was built-in: https://git-scm.com/downloads.\n');
            error(' > curl is not installed.');
        else
            if ENV_VARS.printLevel
                fprintf(' (not installed).\n');
            end
        end
    end
else
    if throwError
        fprintf(' > Please install git where curl was built-in: https://git-scm.com/downloads.\n');
        error(' > curl is not installed.');
    else
        if ENV_VARS.printLevel
            fprintf(' (not installed).\n');
        end
    end
end

if ENV_VARS.printLevel
    fprintf(' > Checking if remote can be reached ... \n')
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
