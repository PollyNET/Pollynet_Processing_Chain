function [campaign_info] = search_campaigninfo(task, pollynetHistory)
%SEARCH_CAMPAIGNINFO search for the history information from pollynet_history_places_new.txt
%    Example:
%        [campaign_info] = search_campaigninfo(task, pollynetHistory)
%    Inputs:
%        task: struct
%            todoPath: char
%            dataPath: char
%            dataFilename: char
%            dataFullpath: char
%            dataSize: integer
%            pollyVersion: char
%            dataTime: datenum
%        pollynetHistory: struct
%           name: cell
%           location: cell
%           startTime: array (datenum)
%           endTime: array (datenum)
%           lon: array (double)
%           lat: array (double)
%           asl: array (double)
%           depolConst: array (double)
%           molDepol: array (double)
%           caption: cell
%    Outputs:
%        campaign_info: struct
%            name: char
%            location: char
%            startTime: datenum
%            endTime: datenum
%            lon: double
%            lat: double
%            asl: double
%            depolConst: double
%            molDepol: double 
%            caption: char
%    History:
%        2018-12-17. First edition by Zhenping
%        2019-08-15. Change the function name
%    Contact:
%        zhenping@tropos.de

campaign_info = struct();
campaign_info.name = '';
campaign_info.location = '';
campaign_info.startTime = [];
campaign_info.endTime = [];
campaign_info.lon = [];
campaign_info.lat = [];
campaign_info.asl = [];
campaign_info.depolConst = [];
campaign_info.molDepol = [];
campaign_info.caption = '';

dataTime = polly_parsetime(task.dataFilename, ...
'(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc');
isCurrentPolly = strcmpi(task.pollyVersion, pollynetHistory.name);
isWithinMeasPeriod = (dataTime < pollynetHistory.endTime) & ...
                     (dataTime >= pollynetHistory.startTime);

if (sum(isCurrentPolly) == 0) || (sum(isWithinMeasPeriod) == 0) || ...
   (sum(isCurrentPolly & isWithinMeasPeriod) == 0)
    warning(['Failure in searching the history info for %s.\n' ...
             'Please check the pollynet history file.\n'], task.dataFilename);
    return;
elseif sum(isWithinMeasPeriod & isCurrentPolly) > 1
    lineOutputStr = sprintf('%d, ', ...
                            find(isWithinMeasPeriod & isCurrentPolly) + 1);
    warning(['More than one history info was found.\nSee line %s\n' ...
             'Please check the pollynet_history file.\n' ...
            'Or check the data file: %s\n'], lineOutputStr, task.dataFilename);
    return;
elseif sum(isCurrentPolly & isWithinMeasPeriod) == 1
    flag = isCurrentPolly & isWithinMeasPeriod;
    campaign_info.name = pollynetHistory.name{flag};
    campaign_info.location = pollynetHistory.location{flag};
    campaign_info.startTime = pollynetHistory.startTime(flag);
    campaign_info.endTime = pollynetHistory.endTime(flag);
    campaign_info.lon = pollynetHistory.lon(flag);
    campaign_info.lat = pollynetHistory.lat(flag);
    campaign_info.asl = pollynetHistory.asl(flag);
    campaign_info.depolConst = pollynetHistory.depolConst(flag);
    campaign_info.molDepol = pollynetHistory.molDepol(flag);
    campaign_info.caption = pollynetHistory.caption{flag}(3:end);
else
    warning('Unknown error in searching the history info for %s.\n', ...
            task.dataFilename);
    return;
end

end