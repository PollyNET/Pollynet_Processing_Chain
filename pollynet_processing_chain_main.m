clc; clear all;

fprintf('\n%%------------------------------------------------------%%');
fprintf('\nStart the pollynet processing chain\n');
tStart = cputime();
fprintf('%%------------------------------------------------------%%\n');

%------------------------------------------------------%
[USER, HOME, OS] = getsysinfo();
projectDir = fileparts(mfilename('fullpath'));
% add lib path
run(fullfile(projectDir, 'lib', 'addlibpath.m'));

configFile = fullfile(projectDir, 'config', 'pollynet_processing_chain_config.json');
if ~ exist(configFile, 'file')
	error('Error in pollynet_processing_main: Unrecognizable configuration file\n%s\n', configFile);
else
	config = loadjson(configFile);
end

% declare global variables
global processInfo campaignInfo defaults
processInfo = config;
%------------------------------------------------------%

%% Parameter definition
report = cell(0);

%% read todo task
fileinfo_new = read_fileinfo_new(config.fileinfo_new);

%% read campaign history and polly configuration history info
pollynet_history = read_pollynet_history(config.pollynet_history_of_places_new);
pollynet_config_history = read_pollynet_processing_configs(config.pollynet_config_history_file);   

%% start the processing chain
for iTask = 1:length(fileinfo_new.dataFilename)

	fprintf('\n[%s] Start task %d. There are still %d tasks in quene!\n', tNow(), iTask, length(fileinfo_new.dataFilename) - iTask);

	%% set the taskInfo struct
	taskInfo = struct();
	taskInfo.todoPath = fileinfo_new.todoPath{iTask};
	taskInfo.dataPath = fileinfo_new.dataPath{iTask};
	taskInfo.dataFilename = fileinfo_new.dataFilename{iTask};
	taskInfo.zipFile = fileinfo_new.zipFile{iTask};
	taskInfo.dataSize = fileinfo_new.dataSize(iTask);
	taskInfo.pollyVersion = fileinfo_new.pollyVersion{iTask};

	%% turn on the diary to log all the command output for future debugging
	logFile = fullfile(config.log_folder, sprintf('%s-%s.log', taskInfo.dataFilename(1:end-3), taskInfo.pollyVersion));
	fprintf('[%s] Turn on the Diary to record the execution results\n', tNow());
	
    diaryon(logFile);

	%% search for polly history info
	fprintf('\n[%s] Start to search for polly history info.\n', tNow());
	campaignInfo = polly_history(taskInfo, pollynet_history);
	if isempty(campaignInfo.location) || isempty(campaignInfo.name)
		continue;
	end
	fprintf('%s campaign info:\nlocation: %s\nLat: %f\nLon: %f\nasl(m): %f\ncaption: %s\n', campaignInfo.name, campaignInfo.location, campaignInfo.lon, campaignInfo.lat, campaignInfo.asl, campaignInfo.caption);
	fprintf('[%s] Finish.\n', tNow());

	%% search for polly config, process func and load defaults function
	fprintf('\n[%s] Start to search for polly config, process function and polly defaults.\n', tNow());
	pollyProcessInfo = polly_processInfo(taskInfo, pollynet_config_history);
	if isempty(pollyProcessInfo.startTime) || isempty(pollyProcessInfo.endTime)
		continue;
	end
	fprintf('%s process info:\nconfig file: %s\nprocess func: %s\nInstrument info: %s\npolly load defaults function: %s\n', pollyProcessInfo.pollyVersion, pollyProcessInfo.pollyConfigFile, pollyProcessInfo.pollyProcessFunc, pollyProcessInfo.pollyUpdateInfo, pollyProcessInfo.pollyLoadDefaultsFunc);
	fprintf('[%s] Finish.\n', tNow());

	%% load polly configuration
	fprintf('\n[%s] Start to load the polly config.\n', tNow());
	pollyConfig = load_polly_config(pollyProcessInfo.pollyConfigFile, config.polly_config_folder);
	if ~ isstruct(pollyConfig)
		fprintf('Failure in loading %s for %s.\n', pollyProcessInfo.pollyConfigFile, taskInfo.pollyVersion);
		continue;
	end
	pollyConfig.pollyVersion = taskInfo.pollyVersion;
	taskInfo.dataTime = polly_parsetime(taskInfo.dataFilename, pollyConfig.dataFileFormat);
	fprintf('[%s] Finish.\n', tNow());

	%% load polly defaults
	fprintf('\n[%s] Start to load the polly defaults.\n', tNow());
	defaults = eval(sprintf('%s();', pollyProcessInfo.pollyLoadDefaultsFunc));
	if ~ isstruct(defaults)
		fprintf('Failure in running %s for %s.\n', pollyProcessInfo.pollyLoadDefaultsFunc, taskInfo.pollyVersion);
		continue;
	end
	fprintf('[%s] Finish.\n', tNow());

	%% realtime process
	fprintf('\n[%s] Stasktart to process the %s data.\ndata source: %s\n', tNow(), taskInfo.pollyVersion, fullfile(taskInfo.todoPath, taskInfo.dataPath, taskInfo.dataFilename));
	eval(sprintf('%s(taskInfo, pollyConfig);', pollyProcessInfo.pollyProcessFunc));
	fprintf('[%s]Finish.\n', tNow());

	%% get report
	report{iTask} = pollynet_processing_chain_report(taskInfo, pollyConfig);

	%% cleanup
	diaryoff;
	
end

%% cleanup
fprintf('\n%%------------------------------------------------------%%\n');
fprintf('Finish the pollynet processing\n');
tUsage = cputime() - tStart;
report{end + 1} = tStart;
report{end + 1} = tUsage;
fprintf('Time Usage: %fs\n', tUsage);
fprintf('%%------------------------------------------------------%%\n');

%% publish the report
publish_report(report, config);