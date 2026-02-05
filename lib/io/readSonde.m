function [alt, temp, pres, relh, wins, wind, datetime] = readSonde(file, fileType, missingValue)
% READSONDE read radiosonde data from netCDF file.
%
% USAGE:
%    [alt, temp, pres, relh, datetime] = readSonde(file, fileType)
%
% INPUTS:
%    file: str
%        filename of radiosonde data file. 
%    fileType: integer
%        file type of the radiosonde file.
%        - 1: radiosonde file for MOSAiC (default)
%        - 2: radiosonde file for MUA
%    missingValue: double
%        missing value for filling the empty bins. These values need to be 
%        replaced with NaN to be compatible with the processing program.
%
% OUTPUTS:
%    alt: array
%        altitute for each range bin. [m]
%    temp: array
%        temperature for each range bin. If no valid data, NaN will be 
%        filled. [C]
%    pres: array
%        pressure for each range bin. If no valid data, NaN will be filled. 
%        [hPa]
%    relh: array
%        relative humidity for each range bin. If no valid data, NaN will be 
%        filled. [%]
%    wins: array
%        wind speed [m/s]
%    wind: array
%        wind direction. [degree]
%    datetime: datenum
%        datetime for the radiosonde data.
%
% NOTE:
%    The radiosonde file should be in netCDF and must contain the variable of 
%    'altitude', 'temperature', 'pressure' and 'RH'. Below is the description 
%    of each variable. (detailed information please see example in 
%    '..\example\convert_radiosonde_data\')
%
%    variables:
%        double altitude(altitude=6728);
%          :unit = "m";
%          :long_name = "Height of lidar above mean sea level";
%          :standard_name = "altitude";
%          :axis = "Z";
%        double pressure(altitude=6728);
%          :unit = "hPa";
%          :long_name = "air pressure";
%          :standard_name = "pressure";
%          :_FillValue = -999.0; // double
%        double temperature(altitude=6728);
%          :unit = "degree celsius";
%          :long_name = "air temperature";
%          :standard_name = "temperature";
%          :_FillValue = -999.0; // double
%        double RH(altitude=6728);
%          :unit = "%";
%          :long_name = "relative humidity";
%          :standard_name = "RH";
%          :_FillValue = -999.0; // double
%
% HISTORY:
%    - 2019-07-19: First Edition by Zhenping
%    - 2019-07-28: Add the criteria for empty file.
%    - 2019-12-18: Add `fileType` to specify the type of the radiosonde file.
%
% .. Authors: - zhenping@tropos.de

temp = [];
pres = [];
relh = [];
wins = [];
wind = [];
alt = [];
datetime = [];

if ~ exist('fileType', 'var')
    fileType = 1;
end

if ~ exist('missingValue', 'var')
    missingValue = -999;
end

if exist(file, 'file') ~= 2
    warning('radiosonde file does not exist. Please check it.\n%s', file);
    return;
end

switch fileType
case 1   % MOSAiC

    thisFilename = basename(file);
    datetime = datenum(thisFilename(12:26), 'yyyymmdd_HHMMSS');

    alt = ncread(file, 'altitude'); 
    temp = ncread(file, 'temperature');
    pres = ncread(file, 'pressure'); 
    relh = ncread(file, 'RH');
    wins = ncread(file, 'wind_speed');
    wind = ncread(file, 'wind_direction');

    % replace missing value with NaN
    temp(abs(temp - missingValue) < 1e-5) = NaN;
    pres(abs(pres - missingValue) < 1e-5) = NaN;
    relh(abs(relh - missingValue) < 1e-5) = NaN;
    wins(abs(wins - missingValue) < 1e-5) = NaN;
    wind(abs(wind - missingValue) < 1e-5) = NaN;

case 2   % MUA radiosonde standard file

    thisFilename = basename(file);
    datetime = datenum(thisFilename(end-15:end-3), 'yyyymmdd_HHMMSS');

    alt = ncread(file, 'altitude'); 
    temp = ncread(file, 'temperature');
    pres = ncread(file, 'pressure'); 
    relh = ncread(file, 'relative_humidity');
    wind = ncread(file, 'wind_direction');
    wins = ncread(file, 'wind_speed');
case 3 %Mosaic new
        
        thisFilename = basename(file);
        datetime = datenum(thisFilename(11:20), 'yyyymmddHH');
        
        fid = fopen(strcat(file));
        strData = textscan(fid,'%s %s %s %s %s %s %s');
        fclose(fid);
        alt = str2num(char(strData{1,1}(22:end)));
        pres = str2num(char(strData{1,3}(22:end)));
        temp = str2num(char(strData{1,4}(22:end)));
        relh = str2num(char(strData{1,5}(22:end)));
        wind = str2num(char(strData{1,6}(22:end)));
        wins = str2num(char(strData{1,7}(22:end)));
case 4   % Meteor radiosonde standard file

    thisFilename = basename(file);
    datetime = datenum(thisFilename(end-15:end-3), 'yyyymmdd_HHMMSS');

    alt = ncread(file, 'altitude'); 
    temp = ncread(file, 'temperature');
    pres = ncread(file, 'pressure'); 
    relh = ncread(file, 'RH');
    wind = ncread(file, 'wind_direction');
    wins = ncread(file, 'wind_speed');    
    
otherwise
    error('Unknown fileType %d', fileType);
end

end
