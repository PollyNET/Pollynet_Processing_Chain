function [pollyConfig, campaign_info] = search_camp_and_config(task, pollynetConfigFile)
%SEARCH_CAMP_AND_CONFIG search the campaign information and polly
%configuration file from pollynet_processing_chain_config_links.xlsx
%Example:
%   [campaign_info] = search_camp_and_config(task, pollynetConfigFile)
%Inputs:
%   task: struct
%       todoPath: char
%       dataPath: char
%       dataFilename: char
%       dataFullpath: char
%       dataSize: integer
%       pollyVersion: char
%       dataTime: datenum
%   pollynetConfigFile: char
%       pollynet config link file.
%Outputs:
%   pollyConfig: struct
%       startTime: datenum
%       endTime: datenum
%       pollyVersion: char
%       pollyConfigFile: char
%       pollyProcessFunc: char
%       pollyUpdateInfo: char
%       pollyDefaultsFile: char
%   campaign_info: struct
%       name: char
%       location: char
%       startTime: datenum
%       endTime: datenum
%       lon: double
%       lat: double
%       asl: double
%       caption: char
%History:
%   2018-12-17. First edition by Zhenping
%   2019-08-15. Change the function name
%   2021-02-01. Merge `pollynet_history_and_places_new.txt` and
%               `pollynet_processing_chain_link.txt`.
%Contact:
%   zhenping@tropos.de

campaign_info = struct();
campaign_info.name = '';
campaign_info.location = '';
campaign_info.startTime = [];
campaign_info.endTime = [];
campaign_info.lon = [];
campaign_info.lat = [];
campaign_info.asl = [];
campaign_info.caption = '';

pollyConfig = struct();
pollyConfig.startTime = [];
pollyConfig.endTime = [];
pollyConfig.pollyVersion = '';
pollyConfig.pollyConfigFile = '';
pollyConfig.pollyProcessFunc = '';
pollyConfig.pollyUpdateInfo = '';
pollyConfig.pollyDefaultsFile = '';

dataTime = polly_parsetime(task.dataFilename, ...
                           ['(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})', ...
                            '_\w*_(?<hour>\d{2})_(?<minute>\d{2})_', ...
                            '(?<second>\d{2})\w*.nc']);

%% read pollynetConfigFile
pollynetConfigLinks = read_camp_and_config(pollynetConfigFile);

isCurrentPolly = strcmpi(task.pollyVersion, pollynetConfigLinks.instrument);
isWithinMeasPeriod = (dataTime < pollynetConfigLinks.camp_stoptime) & ...
                     (dataTime >= pollynetConfigLinks.camp_starttime);
isWithinConfigPeriod = (dataTime < pollynetConfigLinks.config_stoptime) & ...
                       (dataTime >= pollynetConfigLinks.config_starttime);

if (~ any(isCurrentPolly)) || (~ any(isWithinMeasPeriod)) || ...
   (~ any(isWithinConfigPeriod)) || ...
   (~ any(isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod))

    % empty result
    warning(['Failure in searching the link file for %s.\n' ...
             'Please check the pollynet link file.\n'], task.dataFilename);
    return;

elseif sum(isWithinMeasPeriod & isCurrentPolly & isWithinConfigPeriod) > 1

    % multiple result
    lineOutputStr = sprintf('%d, ', ...
        find(isWithinMeasPeriod & isCurrentPolly & isWithinConfigPeriod) + 1);
    warning(['More than one link entry was found.\nSee line %s\n' ...
             'Please check the pollynet link file.\n' ...
             'Or check the data file: %s\n'], ...
            lineOutputStr, task.dataFilename);
    return;

elseif sum(isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod) == 1

    flag = isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod;
    campaign_info.name = pollynetConfigLinks.instrument{flag};
    campaign_info.location = pollynetConfigLinks.location{flag};
    campaign_info.startTime = pollynetConfigLinks.camp_starttime(flag);
    campaign_info.endTime = pollynetConfigLinks.camp_stoptime(flag);
    campaign_info.lon = pollynetConfigLinks.longitude(flag);
    campaign_info.lat = pollynetConfigLinks.latitude(flag);
    campaign_info.asl = pollynetConfigLinks.asl(flag);

    % trick to be compatible with MAT -v6
    campaign_info.caption = strrep(pollynetConfigLinks.caption{flag}, ...
                                   char(160), ' ');
    pollyConfig.startTime = pollynetConfigLinks.config_starttime(flag);
    pollyConfig.endTime = pollynetConfigLinks.config_stoptime(flag);
    pollyConfig.pollyVersion = pollynetConfigLinks.instrument{flag};
    pollyConfig.pollyConfigFile = pollynetConfigLinks.config_file{flag};
    pollyConfig.pollyProcessFunc = pollynetConfigLinks.process_func{flag}(1:(end-2));
    pollyConfig.pollyUpdateInfo = pollynetConfigLinks.caption{flag};
    pollyConfig.pollyDefaultsFile = pollynetConfigLinks.default_file{flag};

else

    warning('Unknown error in searching the link entry for %s.\n', ...
            task.dataFilename);
    return;

end

end