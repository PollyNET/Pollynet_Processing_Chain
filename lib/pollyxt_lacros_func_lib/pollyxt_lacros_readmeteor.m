function [temp, pres, relh, meteorAttri] = pollyxt_lacros_readmeteor(data, config)
%pollyxt_lacros_readmeteor Read meteorological data.
%   Example:
%       [temp, pres, relh, meteorAttri] = pollyx_lacros_readmeteor(data, config)
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
%           URL: char
%               The data file info.
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo 

temp = [];
pres = [];
relh = [];
meteorAttri.dataSource = cell(0);
meteorAttri.URL = cell(0);

if isempty(data.rawSignal)
    return;
end

%% read meteorological data for each cloud-free group
for iGroup = 1:size(data.cloudFreeGroups, 1)
    switch lower(config.meteorDataSource)
    case 'gdas1'
        [altRaw, tempRaw, presRaw, relhRaw, gdas1File] = read_gdas1(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), config.gdas1Site, processInfo.gdas1_folder);
        meteorAttri.dataSource{end + 1} = config.meteorDataSource;
        meteorAttri.URL{end + 1} = gdas1File;
    case 'standard_atmosphere'
        [altRaw, ~, ~, tempRaw, presRaw] = atmo(max(data.height)+1, 0.03, 1);;
        relhRaw = NaN(size(tempRaw));
        altRaw = altRaw * 1e3;   % convert to [m]
        meteorAttri.dataSource{end + 1} = config.meteorDataSource;
        meteorAttri.URL{end + 1} = '';
    case 'websonde'
        searchTRange = [floor(data.mTime(data.cloudFreeGroups(iGroup, 1))), ceil(data.mTime(data.cloudFreeGroups(iGroup, 2)))];
        measTime = mean([data.mTime(data.cloudFreeGroups(iGroup, :))]);
        [altRaw, tempRaw, presRaw, relhRaw, webSondeInfo] = read_websonde(measTime, searchTRange, config.radiosondeSitenum);
        meteorAttri.dataSource{end + 1} = config.meteorDataSource;
        meteorAttri.URL{end + 1} = webSondeInfo.URL;
    case 'radiosonde'
        % define your read function here for reading local launching radiosonde data
        % [altRaw, tempRaw, presRaw, relhRaw] = read_radiosonde(file);
    otherwise
        error('Unknown meteorological data source.\n%s\n', config.meteorDataSource)
    end

    % if predefined data source is not available, go to standard atmosphere.
    if isempty(altRaw)
        fprintf('The meteorological data of websonde or gdas1 is not ready.\nUse standard_atmosphere data as a replacement.\n');
        meteorAttri.dataSource{end + 1} = 'standard_atmosphere';
        meteorAttri.URL{end + 1} = '';
        % read standard_atmosphere data as the default values.
        [altRaw, ~, ~, tempRaw, presRaw] = atmo(max(data.height)+1, 0.03, 1);
        altRaw = altRaw * 1e3;
        relhRaw = NaN(size(tempRaw));
    end

    % interp the parameters
    thistemp = interp_meteor(altRaw, tempRaw, data.alt);
    thispres = interp_meteor(altRaw, presRaw, data.alt);
    thisrelh = interp_meteor(altRaw, relhRaw, data.alt);

    % concatenate the parameters
    temp = cat(1, temp, thistemp);
    pres = cat(1, pres, thispres);
    relh = cat(1, relh, thisrelh);
end

end