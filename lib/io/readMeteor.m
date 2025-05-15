function [alt, temp, pres, relh, wins, wind, attri] = readMeteor(measTime, varargin)
% READMETEOR Read meteorological data according the input meteorological data type.
%
% USAGE:
%    [alt, temp, pres, relh, attri] = readMeteor(measTime)
%
% INPUTS:
%    measTime: datenum
%        the measurement time.
%
% KEYWORDS:
%    meteorDataSource: str
%        meteorological data type.
%        e.g., 'gdas1'(default), 'standard_atmosphere', 'websonde', 'radiosonde'
%    gdas1Site: str
%        the GDAS1 site for the current campaign.
%    meteo_folder: str
%        the main folder of the GDAS1 profiles.
%    radiosondeSitenum: integer
%        site number, which can be found in 
%        doc/radiosonde-station-list.txt.
%    radiosondeFolder: str
%        the folder of the sonding files.
%    radiosondeType: integer
%        file type of the radiosonde file.
%        - 1: radiosonde file for MOSAiC (default)
%        - 2: radiosonde file for MUA
%    isUseLatestGDAS: logical
%        whether to search the latest available GDAS profile (default: false).
%
% OUTPUTS:
%    alt: array
%        height above the mean sea surface. [m]
%    temp: array
%        temperature for each range bin. [C]
%    pres: array
%        pressure for each range bin. [hPa]
%    relh: array
%        relative humidity for each range bin. [%]
%    wins: array
%        wind speed. [m/s]
%    wind: array
%        wind direction. [°]
%    attri: struct
%        dataSource: cell
%            meteorological data used in the data processing for each
%            cloud-free group.
%        URL: cell
%            data file info for each cloud-free group.
%        datetime: array
%            datetime label for the meteorlogical data.
%
% HISTORY:
%    - 2019-07-20: First Edition by Zhenping
%    - 2020-04-16: rewrite the function interface
%
% .. Authors: - zhenping@tropos.de

%% parse arguments
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'measTime', @isnumeric);
addParameter(p, 'meteorDataSource', 'gdas1', @ischar);
addParameter(p, 'gdas1Site', 'leipzig', @ischar);
addParameter(p, 'meteo_folder', '', @ischar);
addParameter(p, 'radiosondeSitenum', 0, @isnumeric);
addParameter(p, 'radiosondeFolder', '', @ischar);
addParameter(p, 'radiosondeType', 1, @isnumeric);
addParameter(p, 'isUseLatestGDAS', true, @islogical);

parse(p, measTime, varargin{:});

%% initialize the returned results
alt = [];
temp = [];
pres = [];
relh = [];
wind = [];
wins = [];
attri = struct();
attri.dataSource = '';
attri.URL = '';
attri.datetime = [];

switch lower(p.Results.meteorDataSource)
case 'gdas1'
    [alt, temp, pres, relh, wins, wind, gdas1File] = readGDAS1(measTime, ...
        p.Results.gdas1Site, p.Results.meteo_folder, ...
        'isUseLatestGDAS', p.Results.isUseLatestGDAS);

    if isempty(alt)
        alt = [];
        temp = [];
        pres = [];
        relh = [];
        wins = [];
        wind = [];
    else
        attri.dataSource = p.Results.meteorDataSource;
        attri.URL = gdas1File;
        attri.datetime = gdas1FileTimestamp(basename(gdas1File));
    end

case 'standard_atmosphere'
    [alt, ~, ~, temp, pres] = atmo(60, 0.03, 1);
    relh = NaN(size(temp));
    pres = pres / 1e2;
    wind = NaN(size(temp));
    wins = NaN(size(temp));
    alt = alt * 1e3;   % convert to [m]
    temp = temp - 273.15;   % convert to [\circC]
    attri.dataSource = p.Results.meteorDataSource;
    attri.URL = '';
    attri.datetime = datenum(0,1,0,0,0,0);

case 'websonde'
    searchTRange = [floor(measTime), ceil(measTime)];
    [alt, temp, pres, relh, wins, wind, webSondeInfo] = readWebsonde(measTime, ...
        searchTRange, p.Results.radiosondeSitenum);

    if ~ isempty(alt)
        attri.dataSource = p.Results.meteorDataSource;
        attri.URL = webSondeInfo.URL;
        attri.datetime = webSondeInfo.datetime;
    end

case 'radiosonde'
    % define your read function here for reading radiosonde data
    if ~ isfield(p.Results, 'radiosondeFolder')
        warning('"radiosondeFolder" in the config file needs to be configed');
    else
        if ~ isfield(p.Results, 'radiosondeType')
            p.Results.radiosondeType = 1;
        end
        sondeFile = sondeSearch(p.Results.radiosondeFolder, measTime, ...
                                      p.Results.radiosondeType);
        [thisAlt, thisTemp, thisPres, thisRelh, thisWins, thisWind, datetime] = ...
            readSonde(sondeFile, p.Results.radiosondeType);

        if ~ isempty(thisAlt) 
            % determine whether the radiosonde data was retrieved successfully

            % sort the measurements as ascending order of altitude
            [alt, sortIndxAlt] = sort(thisAlt);
            temp = thisTemp(sortIndxAlt);
            pres = thisPres(sortIndxAlt);
            relh = thisRelh(sortIndxAlt);
            wins = thisWins(sortIndxAlt);
            wind = thisWind(sortIndxAlt);

            % remove the duplicated measurements at the same altitude
            [alt, iUniq, ~] = unique(alt);
            temp = temp(iUniq);
            pres = pres(iUniq);
            relh = relh(iUniq);
            wins = wins(iUniq);
            wind = wind(iUniq);

            attri.dataSource = p.Results.meteorDataSource;
            attri.URL = sondeFile;
            attri.datetime = datetime;
        else
            % if there is no radiosodne data
            alt = thisAlt;
            temp = thisTemp;
            pres = thisPres;
            relh = thisRelh;
            wins = thisWins;
            wind = thisWind;
        end
    end

case 'nc_cloudnet'
    [alt, temp, pres, relh, wins, wind, gdas1File] = readMETnccloudnet(measTime, ...
        p.Results.gdas1Site, p.Results.meteo_folder, ...
        'isUseLatestGDAS', p.Results.isUseLatestGDAS);

    if isempty(alt)
        alt = [];
        temp = [];
        pres = [];
        relh = [];
        wins = [];
        wind = [];
    else
        attri.dataSource = p.Results.meteorDataSource;
        attri.URL = gdas1File;
        attri.datetime = measTime;
    end

case 'ERA5'
    [alt, temp, pres, relh, wins, wind, gdas1File] = readMETncERA5(measTime, ...
        p.Results.gdas1Site, p.Results.meteo_folder, ...
        'isUseLatestGDAS', p.Results.isUseLatestGDAS);

    if isempty(alt)
        alt = [];
        temp = [];
        pres = [];
        relh = [];
        wins = [];
        wind = [];
    else
        attri.dataSource = p.Results.meteorDataSource;
        attri.URL = gdas1File;
        attri.datetime = measTime;
    end
    
otherwise
    error('Unknown meteorological data source.\n%s\n', ...
          p.Results.meteorDataSource)
end

% check if derivation of height values in alt is always positiv
alt_diff_is_pos=1;
for h = 1:length(alt)-1
    alt_diff = alt(h+1) - alt(h);
    if alt_diff <= 0
        alt_diff_is_pos=0;
        break
    end
end

%disp(alt)
% if predefined data source is not available (empty, NaN, only 1 height level or derivation of alt is negativ), choose standard atmosphere.
if isempty(alt) || (all(isnan(alt))) || (length(unique(alt)) < 2 || alt_diff_is_pos == 0)
    fprintf(['The meteorological data of %s is not ready.\n' ...
             'Use standard_atmosphere data as a replacement.\n'], ...
             p.Results.meteorDataSource);
    attri.dataSource = 'standard_atmosphere';
    attri.URL = '';
    attri.datetime = datenum(0, 1, 0, 0, 0, 0);
    % read standard_atmosphere data as default values.
    [alt, ~, ~, temp, pres] = atmo(60, 0.03, 1);
    alt = alt * 1e3;
    pres = pres / 1e2;
    temp = temp - 273.15;   % convert to [\circC]
    relh = NaN(size(temp));
    wins = NaN(size(temp));
    wind = NaN(size(temp));
end

end
