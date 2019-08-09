function [processInfo] = polly_processInfo(task, processInfo_history)
%POLLY_PROCESSINFO find the polly process info for the current task.
%   Example:
%       [processInfo] = polly_processInfo(task, processInfo_history)
%   Inputs:
%       task: struct
%           todoPath: char
%           dataPath: char
%           dataFilename: char
%           dataFullpath: char
%           dataSize: integer
%           pollyVersion: char
%           dataTime: datenum
%       processInfo_history: struct
%           More detailed info can be found in doc/pollynet.md and doc/polly_overviews.xlsx
%   Outputs:
%       processInfo: struct
%           pollyVersion: char
%           startTime: datenum
%           endTime: datenum
%           pollyConfigFile: char
%           pollyProcessFunc: char
%           pollyUpdateInfo: char
%           pollyLoadDefaultsFunc: char
%   History:
%       2018-12-17. First edition by Zhenping
%   Contact:
%       zhenping@tropos.de


processInfo = struct();
processInfo.pollyVersion = '';
processInfo.startTime = [];
processInfo.endTime = [];
processInfo.pollyConfigFile = '';
processInfo.pollyProcessFunc = '';
processInfo.pollyUpdateInfo = '';
processInfo.pollyLoadDefaultsFunc = '';

dataTime = polly_parsetime(task.dataFilename, '(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc');
isCurrentPolly = strcmpi(task.pollyVersion, processInfo_history.pollyVersion);
isWithinTimePeriod = (dataTime < processInfo_history.endTime) & (dataTime >= processInfo_history.startTime);

if (sum(isCurrentPolly) == 0) || (sum(isWithinTimePeriod) == 0) || (sum(isCurrentPolly & isWithinTimePeriod) == 0)
    warning('Failure in searching the process info for %s.\nPlease check the pollynet processing config history file.\n', task.dataFilename);
    return;
elseif sum(isWithinTimePeriod & isCurrentPolly) > 1
    lineOutputStr = sprintf('%d, ', find(isWithinTimePeriod & isCurrentPolly) + 1);
    warning('More than one process info was found.\nSee line %s\nPlease check the pollynet_processing_config_history file.\nOr check the data file: %s\n', lineOutputStr, task.dataFilename);
    return;
elseif sum(isCurrentPolly & isWithinTimePeriod) == 1
    flag = isCurrentPolly & isWithinTimePeriod;
    processInfo.pollyVersion = processInfo_history.pollyVersion{flag};
    processInfo.startTime = processInfo_history.startTime(flag);
    processInfo.endTime = processInfo_history.endTime(flag);
    processInfo.pollyConfigFile = processInfo_history.pollyConfigFile{flag};
    processInfo.pollyProcessFunc = processInfo_history.pollyProcessFunc{flag}(1:(end-2));
    processInfo.pollyUpdateInfo = processInfo_history.pollyUpdateInfo{flag};
    processInfo.pollyLoadDefaultsFunc = processInfo_history.pollyLoadDefaultsFunc{flag}(1:(end-2));
else
    warning('Unknown error in searching the polly processing config info for %s.\n', task.dataFilename);
    return;
end

end