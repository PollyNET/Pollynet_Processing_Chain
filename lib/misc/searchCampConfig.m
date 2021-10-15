function [pollyConfig, campaign_info] = searchCampConfig(pollyDataFile, pollyType, PicassoLinkFile)
% SEARCHCAMPCONFIG search campaign information and polly
% configuration file from pollynet_processing_chain_config_links.xlsx
%
% USAGE:
%   [campaign_info] = searchCampConfig(pollyDataFile, pollyType, PicassoLinkFile)
%
% INPUTS:
%    pollyDataFile: char
%        absolute path of polly data file.
%    pollyType: char
%        polly type.
%    PicassoLinkFile: char
%        Picasso campaign link file.
%
% OUTPUTS:
%    pollyConfig: struct
%        startTime: datenum
%        endTime: datenum
%        pollyType: char
%        pollyConfigFile: char
%        pollyProcessFunc: char
%        pollyUpdateInfo: char
%        pollyDefaultsFile: char
%    campaign_info: struct
%        name: char
%        location: char
%        startTime: datenum
%        endTime: datenum
%        lon: double
%        lat: double
%        asl: double
%        caption: char
%
% HISTORY:
%    - 2018-12-17: First edition by Zhenping
%    - 2019-08-15: Change the function name
%    - 2021-02-01: Merge `pollynet_history_and_places_new.txt` and `pollynet_processing_chain_link.txt`.
%
% .. Authors: - zhenping@tropos.de

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
pollyConfig.pollyType = '';
pollyConfig.pollyConfigFile = '';
pollyConfig.pollyProcessFunc = '';
pollyConfig.pollyUpdateInfo = '';
pollyConfig.pollyDefaultsFile = '';

dataTime = pollyParseFiletime(pollyDataFile, ...
                           ['(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})', ...
                            '_\w*_(?<hour>\d{2})_(?<minute>\d{2})_', ...
                            '(?<second>\d{2})\w*.nc']);

%% read PicassoLinkFile
PicassoCampLinks = read_camp_and_config(PicassoLinkFile);

isCurrentPolly = strcmpi(pollyType, PicassoCampLinks.instrument);
isWithinMeasPeriod = (dataTime < PicassoCampLinks.camp_stoptime) & ...
                     (dataTime >= PicassoCampLinks.camp_starttime);
isWithinConfigPeriod = (dataTime < PicassoCampLinks.config_stoptime) & ...
                       (dataTime >= PicassoCampLinks.config_starttime);

if (~ any(isCurrentPolly)) || (~ any(isWithinMeasPeriod)) || ...
   (~ any(isWithinConfigPeriod)) || ...
   (~ any(isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod))

    % empty result
    warning('PICASSO:MissingData', ['Failure in searching the link file for %s.\n' ...
             'Please check the pollynet link file.\n'], pollyDataFile);
    return;

elseif sum(isWithinMeasPeriod & isCurrentPolly & isWithinConfigPeriod) > 1

    % multiple result
    lineOutputStr = sprintf('%d, ', ...
        find(isWithinMeasPeriod & isCurrentPolly & isWithinConfigPeriod) + 1);
    warning('PICASSO:DuplicatedData', ['More than one link entry was found.\nSee line %s\n' ...
             'Please check the pollynet link file.\n' ...
             'Or check the data file: %s\n'], ...
            lineOutputStr, pollyDataFile);
    return;

elseif sum(isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod) == 1

    flag = isCurrentPolly & isWithinMeasPeriod & isWithinConfigPeriod;
    campaign_info.name = PicassoCampLinks.instrument{flag};
    campaign_info.location = PicassoCampLinks.location{flag};
    campaign_info.startTime = PicassoCampLinks.camp_starttime(flag);
    campaign_info.endTime = PicassoCampLinks.camp_stoptime(flag);
    campaign_info.lon = PicassoCampLinks.longitude(flag);
    campaign_info.lat = PicassoCampLinks.latitude(flag);
    campaign_info.asl = PicassoCampLinks.asl(flag);

    % trick to be compatible with MAT -v6
    campaign_info.caption = strrep(PicassoCampLinks.caption{flag}, ...
                                   char(160), ' ');
    pollyConfig.startTime = PicassoCampLinks.config_starttime(flag);
    pollyConfig.endTime = PicassoCampLinks.config_stoptime(flag);
    pollyConfig.pollyType = PicassoCampLinks.instrument{flag};
    pollyConfig.pollyConfigFile = PicassoCampLinks.config_file{flag};
    pollyConfig.pollyProcessFunc = PicassoCampLinks.process_func{flag}(1:(end-2));
    pollyConfig.pollyUpdateInfo = PicassoCampLinks.caption{flag};
    pollyConfig.pollyDefaultsFile = PicassoCampLinks.default_file{flag};

else

    warning('PICASSO:MissingData', 'Failure in searching the link entry for %s.\n', ...
            pollyDataFile);
    return;

end

end