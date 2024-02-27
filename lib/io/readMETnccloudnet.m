function [alt, temp, pres, relh, wins, wind, fname] = readMETnccloudnet(tRange, site, folder, varargin)
% readMETnccloudnet read the cloudnet ecmwf netcdf file
%
% EXAMPLE:
%    [alt, temp, pres, relh] = readMETnccloudnet(tRange, site, folder)
%
% INPUTS:
%    tRange: 2-element array
%        search range. 
%    site: char
%        the location for gdas1. Our server will automatically produce the 
%        gdas1 products for all our pollynet location. You can find it in 
%        /lacroshome/cloudnet/data/model/gdas1
%
% KEYWORDS:
%    isUseLatestGDAS: logical
%        whether to search the latest available GDAS profile (default: false).
%
% OUTPUTS:
%    alt: array
%        altitute (above ground) for each range bin. [m]
%    temp: array
%        temperature for each range bin. If no valid data, NaN will be 
%        filled. [C]
%    pres: array
%        pressure for each range bin. If no valid data, NaN will be filled. 
%        [hPa]
%    rh: array
%        relative humidity for each range bin. If no valid data, NaN will be 
%        filled. [%]
%    wins: array
%        wind speed [m/s]
%    wind: array
%        wind direction. [degree]
%    fname: char
%        filename (for legacy reasons the name is not changed). 
%
% HISTORY:
%    - 2023-05-13.:First implementation by martin-rdz
%
% .. Authors: - radenz@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'tRange', @isnumeric);
addRequired(p, 'site', @ischar);
addRequired(p, 'folder', @ischar);

parse(p, tRange, site, folder, varargin{:});

midTime = mean(tRange);

[thisyear, thismonth, thisday, thishour, ~, ~] = ...
            datevec(round(midTime / datenum(0, 1, 0, 3, 0, 0)) * ...
            datenum(0, 1, 0, 3, 0, 0));
% /oceanethome/model/ecmwf/profiles/ecmwf/2023/20230512_neumayer_ecmwf.nc
fname = fullfile(folder, sprintf('%04d', thisyear), ...
            sprintf('%04d%02d%02d_%s_ecmwf.nc', ...
            thisyear, thismonth, thisday, site));

disp(fname);
%disp(tRange);

% Open the netCDF file
ncid = netcdf.open(fname, 'NOWRITE');


% Get information about the netCDF file
nc_info = ncinfo(fname);
% Extract the variable names
var_names = {nc_info.Variables.Name};
% Display the variable names
%disp(var_names);

% Get the variable ID for the time variable and the variable of interest
%time_varid = netcdf.inqVarID(ncid, 'time');
%data_varid = netcdf.inqVarID(ncid, 'variable_name');

% Read in the time variable and the variable of interest
time = ncread(fname, 'time');
[~, ~, ~, hour, minute, second] = datevec(midTime);
hour_fraction = hour + minute/60 + second/3600;

disp(hour_fraction);

% Find the index of the time value closest to the specified time
[~, index] = min(abs(time - hour_fraction));

height = ncread(fname, 'height');
alt = height(:, index);

% Extract the corresponding data
data = ncread(fname, 'pressure');
pres = data(:, index) ./ 100.;

data = ncread(fname, 'temperature');
temp = data(:, index) - 273.15;

data = ncread(fname, 'rh');
relh = data(:, index) .* 100;

data = ncread(fname, 'uwind');
uwd = data(:, index);

data = ncread(fname, 'vwind');
vwd = data(:, index);

wins = sqrt(uwd.^2 + vwd.^2);
wind = atan2(vwd,uwd)*(180/pi);

% Close the netCDF file
netcdf.close(ncid);

%#[pres, alt, temp, relh, wind, wins] = ceilo_bsc_ModelSonde(gdas1file);

%pres    = NaN;
%alt     = NaN;
%temp    = NaN;
%relh    = NaN;
%wind    = NaN;
%wins    = NaN;

end
