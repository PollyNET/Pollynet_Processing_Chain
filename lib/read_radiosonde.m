function [alt, temp, pres, relh, datetime] = read_radiosonde(file, ...
    readMode, missingValue)
%READ_RADIOSONDE read the radiosonde data from netCDF file.
%   Example:
%       [alt, temp, pres, relh, datetime] = read_radiosonde(file, readMode)
%   Inputs:
%       file: str
%           filename of radiosonde data file. 
%       readMode: integer
%           reading mode for parsing the file. Only accept 1 for standard nc 
%           format.
%       missingValue: double
%           missing value for filling the empty bins. These values need to be 
%           replaced with NaN to be compatible with the processing program.
%   Outputs:
%       alt: array
%           altitute for each range bin. [m]
%       temp: array
%           temperature for each range bin. If no valid data, NaN will be 
%           filled. [C]
%       pres: array
%           pressure for each range bin. If no valid data, NaN will be filled. 
%           [hPa]
%       rh: array
%           relative humidity for each range bin. If no valid data, NaN will be 
%           filled. [%]
%       datetime: datenum
%           datetime for the radiosonde data.
%   Note:
%       The radiosonde file should be in netCDF and must contain the variable of 
%       'altitude', 'temperature', 'pressure' and 'RH'. Below is the description 
%       of each variable. (detailed information please see example in 
%       '..\example\convert_radiosonde_data\')
%         variables:
%           double altitude(altitude=6728);
%             :unit = "m";
%             :long_name = "Height of lidar above mean sea level";
%             :standard_name = "altitude";
%             :axis = "Z";
%           double pressure(altitude=6728);
%             :unit = "hPa";
%             :long_name = "air pressure";
%             :standard_name = "pressure";
%             :_FillValue = -999.0; // double
%           double temperature(altitude=6728);
%             :unit = "degree celsius";
%             :long_name = "air temperature";
%             :standard_name = "temperature";
%             :_FillValue = -999.0; // double
%           double RH(altitude=6728);
%             :unit = "%";
%             :long_name = "relative humidity";
%             :standard_name = "RH";
%             :_FillValue = -999.0; // double
%   History:
%       2019-07-19. First Edition by Zhenping
%		2019-07-28. Add the criteria for empty file.
%   Contact:
%       zhenping@tropos.de

temp = [];
pres = [];
relh = [];
alt = [];
datetime = [];

if ~ exist('readMode', 'var')
    readMode = 1;
end

if ~ exist(file, 'file')
	warning('radiosonde file does not exist. Please check it.\n%s', file);
	return;
end

switch readMode
case 1
    thisFilename = basename(file);
    datetime = datenum(thisFilename(12:26), 'yyyymmdd_HHMMSS');
    
    alt = ncread(file, 'altitude'); 
    temp = ncread(file, 'temperature');
    pres = ncread(file, 'pressure'); 
    relh = ncread(file, 'RH');

    % replace missing value with NaN
    temp(abs(temp - missingValue) < 1e-5) = NaN;
    pres(abs(pres - missingValue) < 1e-5) = NaN;
    relh(abs(relh - missingValue) < 1e-5) = NaN;
end

end
