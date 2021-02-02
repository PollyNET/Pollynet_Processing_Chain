function report = pollynet_processing_chain_main(pollynetConfigFile)
%POLLYNET_PROCESSING_CHAIN_MAIN read polly tasks from todo_filelist and assign
%the processing module for each task.
%Example:
%   [report] = pollynet_processing_chain_main(pollynetConfigFile)
%Inputs:
%   pollynetConfigFile: char
%       the absolute path of the pollynet configuration file.
%       e.g., '/Pollynet_Prcessing_Chain/config/pollynet_processing_chain_config.json'
%Outputs:
%   report: cell
%       logs for each task.
%History:
%   2019-08-12. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

% declare global variables
global processInfo campaignInfo defaults

clc;

%% get the project directory
projectDir = fileparts(mfilename('fullpath'));

if ~ exist('pollynetConfigFile', 'var')
    pollynetConfigFile = fullfile(projectDir, 'config', ...
                                  'pollynet_processing_chain_config.json');
end

fprintf('\n%%------------------------------------------------------%%');
fprintf('\nStart the pollynet processing chain\n');
tStart = now();
fprintf('pollynet_config_file: %s\n', pollynetConfigFile);
fprintf('%%------------------------------------------------------%%\n');

%------------------------------------------------------------------------------%
% add lib path
run(fullfile(projectDir, 'lib', 'addlibpath.m'));
run(fullfile(projectDir, 'lib', 'addincludepath.m'));
[USER, HOME, OS] = getsysinfo();

if exist(pollynetConfigFile, 'file') ~= 2
    error('Unrecognizable configuration file\n%s\n', pollynetConfigFile);
else
    processInfo = loadjson(pollynetConfigFile);
    processInfo.projectDir = projectDir;

    if isfield(processInfo, 'programVersion')
        warning('''programVersion'' was deprecated.');
    end
    processInfo.programVersion = '2.0';
end

% reduce the dependence on additionable toolboxes to get rid of license problems
% after the turndown of usage of matlab toolbox, we need to replace the applied
% function with user defined functions
if processInfo.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'disable');
    fprintf('Disable the usage of matlab statistics_toolbox\n');
end
%------------------------------------------------------------------------------%

%% Parameter definition
report = cell(0);

%% read todo task
fileinfo_new = read_fileinfo_new(processInfo.fileinfo_new);

%% start the processing chain
for iTask = 1:length(fileinfo_new.dataFilename)

    fprintf('\n[%s] Start task %d. There are still %d tasks in quene!\n', ...
            tNow(), iTask, length(fileinfo_new.dataFilename) - iTask);

    taskInfo = struct();
    taskInfo.todoPath = fileinfo_new.todoPath{iTask};
    taskInfo.dataPath = fileinfo_new.dataPath{iTask};
    taskInfo.dataFilename = fileinfo_new.dataFilename{iTask};
    taskInfo.zipFile = fileinfo_new.zipFile{iTask};
    taskInfo.dataSize = fileinfo_new.dataSize(iTask);
    taskInfo.pollyVersion = lower(fileinfo_new.pollyVersion{iTask});
    taskInfo.startTime = now();

    %% turn on the diary to log all the command output for debugging
    if ~ exist(processInfo.log_folder, 'dir')
        fprintf('Create the log folder: %s.\n', processInfo.log_folder);
        mkdir(processInfo.log_folder);
    end
    logFile = fullfile(processInfo.log_folder, ...
                       sprintf('%s-%s.log', ...
                               rmext(taskInfo.dataFilename), ...
                               taskInfo.pollyVersion));
    fprintf('[%s] Turn on the Diary to record the execution results\n', tNow());

    diaryon(logFile);

    %% print the PC info for debugging
    fprintf('## PC Info\n')
    fprintf('USER: %s\n', USER);
    fprintf('HOME: %s\n', HOME);
    fprintf('OS: %s\n', OS);
    fprintf('MATLAB: %s\n', version);

    %% determine the data size
    if taskInfo.dataSize <= processInfo.minDataSize
        fprintf(['The current data size is not large enough\n%s\n. ', ...
                 'Jump over the task.\n'], taskInfo.dataFilename);
        diaryoff;
        continue;
    end

    %% search for polly history info
    fprintf('\n[%s] Start to search for polly history info.\n', tNow());
    try
        [pollyProcessInfo, campaignInfo] = search_camp_and_config(taskInfo, ...
            processInfo.pollynet_config_link_file);
    catch ErrMsg
        if strcmp(ErrMsg.identifier, 'MATLAB:polly_parsetime:InvaliFile')
            continue;
        else
            rethrow(ErrMsg);
        end
    end

    taskInfo.pollyVersion = campaignInfo.name;   % keep the same naming of polly
    if isempty(campaignInfo.location) || isempty(campaignInfo.name)
        continue;
    end

    if isempty(pollyProcessInfo.startTime) || isempty(pollyProcessInfo.endTime)
        continue;
    end

    fprintf(['%s campaign info:\nlocation: %s\n', ...
             'Lat: %f\n', ...
             'Lon: %f\n', ...
             'asl(m): %f\n', ...
             'startTime: %s\n', ...
             'caption: %s\n'], ...
             campaignInfo.name, ...
             campaignInfo.location, ...
             campaignInfo.lon, ...
             campaignInfo.lat, ...
             campaignInfo.asl, ...
             datestr(campaignInfo.startTime, 'yyyy-mm-dd HH:MM'), ...
             campaignInfo.caption);
    fprintf(['%s process info:\n', ...
             'config file: %s\n', ...
             'process func: %s\n', ...
             'Instrument info: %s\n', ...
             'polly defaults file: %s\n'], ...
             pollyProcessInfo.pollyVersion, ...
             pollyProcessInfo.pollyConfigFile, ...
             pollyProcessInfo.pollyProcessFunc, ...
             pollyProcessInfo.pollyUpdateInfo, ...
             pollyProcessInfo.pollyDefaultsFile);
    fprintf('[%s] Finish.\n', tNow());

    %% create folder for saving the results (if not exists)
    results_folder = fullfile(processInfo.results_folder, campaignInfo.name);
    pic_folder = fullfile(processInfo.pic_folder, campaignInfo.name);
    log_folder = fullfile(processInfo.log_folder);
    if ~ exist(results_folder, 'dir')
        fprintf('Create a new folder to saving the results for %s\n%s\n', ...
                campaignInfo.name, results_folder);
        mkdir(results_folder);
    end
    if ~ exist(pic_folder, 'dir')
        fprintf('Create a new folder to saving the plots for %s\n%s\n', ...
                campaignInfo.name, pic_folder);
        mkdir(pic_folder);
    end
    if ~ exist(log_folder, 'dir')
        fprintf('Create a new folder to saving the plots for %s\n%s\n', ...
                campaignInfo.name, log_folder);
        mkdir(log_folder);
    end

    %% load polly configuration
    fprintf('\n[%s] Start to load the polly config.\n', tNow());
    pollyConfig = load_polly_config(pollyProcessInfo.pollyConfigFile, ...
                                    processInfo.polly_config_folder);
    if ~ isstruct(pollyConfig)
        fprintf('Failure in loading %s for %s.\n', ...
                pollyProcessInfo.pollyConfigFile, campaignInfo.name);
        continue;
    end
    pollyConfig.pollyVersion = campaignInfo.name;
    try
        taskInfo.dataTime = polly_parsetime(taskInfo.dataFilename, ...
                                            pollyConfig.dataFileFormat);
    catch ErrMsg
        if strcmp(ErrMsg.identifier, 'MATLAB:polly_parsetime:InvaliFile')
            continue;
        else
            rethrow(ErrMsg);
        end
    end

    %% load polly defaults
    fprintf('\n[%s] Start to load the polly defaults.\n', tNow());
    defaultsFilepath = fullfile(projectDir, 'config', 'pollyDefaults', ...
                                pollyProcessInfo.pollyDefaultsFile);
    defaults = polly_read_defaults(defaultsFilepath);
    if ~ isstruct(defaults)
        fprintf('Failure in loading %s for %s.\n', ...
                pollyProcessInfo.pollyDefaultsFile, campaignInfo.name);
        continue;
    end
    fprintf('[%s] Finish.\n', tNow());

    %% realtime process
    fprintf('\n[%s] Start to process the %s data.\ndata source: %s\n', ...
            tNow(), campaignInfo.name, ...
            fullfile(taskInfo.todoPath, taskInfo.dataPath, ...
                     taskInfo.dataFilename));
    [reportTmp] = eval(sprintf('%s(taskInfo, pollyConfig);', ...
                       pollyProcessInfo.pollyProcessFunc));
    report = cat(2, report, reportTmp);
    fprintf('[%s] Finish.\n', tNow());

    %% cleanup
    diaryoff;
end

%% cleanup
fprintf('\n%%------------------------------------------------------%%\n');
fprintf('Finish the pollynet processing\n');
tUsage = (now() - tStart) * 24 * 3600;
report{end + 1} = tStart;
report{end + 1} = tUsage;
fprintf('Time Usage: %fs\n', tUsage);
fprintf('%%------------------------------------------------------%%\n');

%% publish the report
if processInfo.flagSendNotificationEmail
    system(sprintf('%s %s %s %s "%s" "%s" "%s"', ...
           fullfile(processInfo.pyBinDir, 'python'), ...
           fullfile(projectDir, 'lib', 'sendmail_msg.py'), ...
           'sender@email.com', 'recipient@email.com', ...
           sprintf('[%s] PollyNET Processing Report', tNow()), ...
           'Have an overview', processInfo.fileinfo_new));
end

% enable the usage of matlab toolbox
if processInfo.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'enable');
    fprintf('Enable the usage of matlab statistics_toolbox\n');
end

end
