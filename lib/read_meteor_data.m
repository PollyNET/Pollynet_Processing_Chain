function [alt, temp, pres, relh, attri] = read_meteor_data(measTime, altitude, meteorAttri)
%read_meteor_data Read the meteorological data according the input meteorological data type.
%   Example:
%       [alt, temp, pres, relh, attri] = read_meteor_data(measTime, altitude, meteorAttri)
%   Inputs:
%       measTime: datenum
%           the measurement time.
%       altitude: array
%           height above the mean sea level. [m]
%       meteorAttri: struct
%           meteorDataSource: str
%               meteorological data type.
%               e.g., 'gdas1', 'standard_atmosphere', 'websonde', 'radiosonde'
%           gdas1Site: str
%               the GDAS1 site for the current campaign.
%           gdas1_folder: str
%               the main folder of the GDAS1 profiles.
%           radiosondeSitenum: integer
%               site number, which can be found in doc/radiosonde-station-list.txt. You can update the list with using download_radiosonde_list.m
%          radiosondeFolder: str
%               the folder of the sonding files. 
%   Outputs:
%       alt: array
%           height above the mean sea surface. [m]
%       temp: array
%           temperature for each range bin. [C]
%       pres: array
%           pressure for each range bin. [hPa]
%       relh: array
%           relative humidity for each range bin. [%]
%       attri: struct
%           dataSource: cell
%               The data source used in the data processing for each cloud-free group.
%           URL: cell
%               The data file info for each cloud-free group.
%           datetime: array
%               datetime label for the meteorlogical data.
%   History:
%       2019-07-20. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

alt = [];
temp = [];
pres = [];
relh = [];
attri = struct();
attri.dataSource = '';
attri.URL = '';
attri.datetime = [];

switch lower(meteorAttri.meteorDataSource)
case 'gdas1'
    [alt, temp, pres, relh, gdas1File] = read_gdas1(measTime, meteorAttri.gdas1Site, meteorAttri.gdas1_folder);

    if isnan(alt(1))
    else
        attri.dataSource = meteorAttri.meteorDataSource;
        attri.URL = gdas1File;
        attri.datetime = gdas1FileTimestamp(basename(gdas1File));
    end
case 'standard_atmosphere'
    [alt, ~, ~, temp, pres] = atmo(max(altitude/1000)+1, 0.03, 1);
    relh = NaN(size(temp));
    pres = pres / 1e2;
    alt = alt * 1e3;   % convert to [m]
    temp = temp - 273.17;   % convert to [\circC]
    attri.dataSource = meteorAttri.meteorDataSource;
    attri.URL = '';
    attri.datetime = datenum(0,1,0,0,0,0);
case 'websonde'
    searchTRange = [floor(measTime), ceil(measTime)];
    [alt, temp, pres, relh, webSondeInfo] = read_websonde(measTime, searchTRange, meteorAttri.radiosondeSitenum);
    
    if ~ isempty(alt)
        attri.dataSource = meteorAttri.meteorDataSource;
        attri.URL = webSondeInfo.URL;
        attri.datetime = webSondeInfo.datetime;
    end
case 'radiosonde'
    % define your read function here for reading collocated radiosonde data
    if ~ isfield(meteorAttri, 'radiosondeFolder')
        warning('"radiosondeFolder" in the polly config file needs to be set to search the radiosonde file.');
    else
        sondeFile = radiosonde_search(meteorAttri.radiosondeFolder, measTime);
        [thisAlt, thisTemp, thisPres, thisRelh, datetime] = read_radiosonde(sondeFile, 1, -999);
        
        % sort the measurements as the ascending order of altitude
        [alt, sortIndxAlt] = sort(thisAlt);
        temp = thisTemp(sortIndxAlt);
        pres = thisPres(sortIndxAlt);
        relh = thisRelh(sortIndxAlt);
        
        % remove the duplicated measurements at the same altitude
        [alt, iUniq, ~] = unique(alt);
        temp = temp(iUniq);
        pres = pres(iUniq);
        relh = relh(iUniq);
        
        attri.dataSource = meteorAttri.meteorDataSource;
        attri.URL = sondeFile;
        attri.datetime = datetime;
    end

otherwise
    error('Unknown meteorological data source.\n%s\n', meteorAttri.meteorDataSource)
end

% if predefined data source is not available, go to standard atmosphere.
if isempty(alt)
    fprintf('The meteorological data of websonde or gdas1 is not ready.\nUse standard_atmosphere data as a replacement.\n');
    attri.dataSource = 'standard_atmosphere';
    attri.URL = '';
    attri.datetime = datenum(0, 1, 0, 0, 0, 0);
    % read standard_atmosphere data as the default values.
    [alt, ~, ~, temp, pres] = atmo(max(altitude/1000)+1, 0.03, 1);
    alt = alt * 1e3;
    pres = pres / 1e2;
    temp = temp - 273.17;   % convert to [\circC]
    relh = NaN(size(temp));
end

end