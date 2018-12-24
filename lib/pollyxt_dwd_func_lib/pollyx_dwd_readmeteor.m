function [temp, pres, relh, meteorAttri] = pollyx_dwd_readmeteor(data, config)
%pollyx_dwd_readmeteor Read meteorological data.
%   Example:
%       [temp, pres, relh, meteorAttri] = pollyx_dwd_readmeteor(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       temp: matrix (cloudfreegroups * height)
%           temperature for each range bin. [C]
%       pres: matrix (cloudfreegroups * height)
%           pressure for each range bin. [hPa]
%       rh: matrix (cloudfreegroups * height)
%           relative humidity for each range bin. [%]
%       meteorAttri: struct
%           dataSource: char
%               The data source used in the data processing.
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo, campaignInfo, defaults

temp = [];
pres = [];
relh = [];

if isempty(data.rawSignal)
    return;
end

%% read meteorological data for each cloud-free group
alt = data.height + campaignInfo.asl;

for iGroup = 1:size(data.cloudFreeGroups, 1)
    switch lower(config.meteorDataSource)
    case 'gdas1'
        [altRaw, tempRaw, presRaw, relhRaw] = read_gdas1(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), config.gdas1Site, processInfo.gdas1_folder);
        meteorAttri.dataSource = config.meteorDataSource;
    case 'standard_atmosphere'
        [altRaw, ~, ~, tempRaw, presRaw] = atmo(max(data.height)+1, 0.03, 1);;
        relhRaw = NaN(size(tempRaw));
        altRaw = altRaw * 1e3;   % convert to [m]
        meteorAttri.dataSource = config.meteorDataSource;
    case 'websonde'
        searchTRange = [floor(data.mTime(data.cloudFreeGroups(iGroup, 1))), ceil(data.mTime(data.cloudFreeGroups(iGroup, 2)))];
        measTime = mean([data.mTime(data.cloudFreeGroups(iGroup, :))]);
        [altRaw, tempRaw, presRaw, ~, globalAttri] = read_websonde(measTime, searchTRange, config.radiosondeSitenum);
    case 'radiosonde'
        % define your read function here for reading local launching radiosonde data
        % [altRaw, tempRaw, presRaw, relhRaw] = read_radiosonde(file);
    else
        error('Unknown meteorological data source.\n%s\n', config.meteorDataSource)
    end

    % if predefined data source is not available, go to standard atmosphere.
    if isempty(altRaw)
        fprintf('The meteorological data of websonde or gdas1 is not ready.\nUse standard_atmosphere data as a replacement.\n');
        meteorAttri.dataSource = 'standard_atmosphere';
        % read standard_atmosphere data as the default values.
        [altRaw, ~, ~, tempRaw, presRaw] = atmo(max(data.height)+1, 0.03, 1);
        altRaw = altRaw * 1e3;
        relhRaw = NaN(size(tempRaw));
    end

    % interp the parameters
    thistemp = interp_meteor(altRaw, tempRaw, alt);
    thispres = interp_meteor(altRaw, presRaw, alt);
    thisrelh = interp_meteor(altRaw, relhRaw, alt);

    % concatenate the parameters
    temp = cat(1, temp, thistemp);
    pres = cat(1, pres, thispres);
    relh = cat(1, relh, thisrelh);
end

end