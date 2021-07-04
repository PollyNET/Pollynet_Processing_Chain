function [] = convert_radiosonde_ascii_2_netCDF_example(rsFile, ncFile)

projectDir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(projectDir)), 'lib'));

%% parameter definitions
% rsFile = '2018111511_pangaea.txt';
% ncFile = 'radiosonde_20181115_110000.nc';
missing_value = -999;

%% read radiosonde data
rsFullfile = fullfile(projectDir, rsFile);
pres = []; 
hght = []; 
temp =[]; 
relh= [];
if exist(rsFullfile, 'file') ~= 2
    warning('Radiosonde file does not exist. \n %s', rsFullfile);
    return;
end

fid = fopen(rsFullfile, 'r');
textspec = '%s %s %s %s %s %s';
res = textscan(fid, textspec, 'HeaderLines', 16);
fclose(fid);

% convert the cell to an array
hght = zeros(1, length(res{1}));
pres = zeros(1, length(res{1}));
temp = zeros(1, length(res{1}));
relh = zeros(1, length(res{1}));
wind = zeros(1, length(res{1}));
wins = zeros(1, length(res{1}));
for iRow = 1:length(res{1})
    hght(iRow) = str2double(res{1}{iRow});
    pres(iRow) = str2double(res{2}{iRow});
    temp(iRow) = str2double(res{3}{iRow});
    relh(iRow) = str2double(res{4}{iRow});
    wind(iRow) = str2double(res{5}{iRow});
    wins(iRow) = str2double(res{6}{iRow});
end

%% save to nc file
ncFullfile = fullfile(projectDir, ncFile);
mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncFullfile, mode);

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(hght));

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_DOUBLE', dimID_altitude);
varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_DOUBLE', dimID_altitude);
varID_RH = netcdf.defVar(ncID, 'RH', 'NC_DOUBLE', dimID_altitude);
varID_wind_direction = netcdf.defVar(ncID, 'wind_direction', 'NC_DOUBLE', dimID_altitude);
varID_wind_speed = netcdf.defVar(ncID, 'wind_speed', 'NC_DOUBLE', dimID_altitude);

% define the filling value
netcdf.defVarFill(ncID, varID_pressure, false, missing_value);
netcdf.defVarFill(ncID, varID_temperature, false, missing_value);
netcdf.defVarFill(ncID, varID_wind_speed, false, missing_value);
netcdf.defVarFill(ncID, varID_wind_direction, false, missing_value);
netcdf.defVarFill(ncID, varID_RH, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_pressure, true, true, 5);
netcdf.defVarDeflate(ncID, varID_temperature, true, true, 5);
netcdf.defVarDeflate(ncID, varID_wind_speed, true, true, 5);
netcdf.defVarDeflate(ncID, varID_wind_direction, true, true, 5);
netcdf.defVarDeflate(ncID, varID_RH, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, hght);
netcdf.putVar(ncID, varID_pressure, fillmissing(pres, missing_value));
netcdf.putVar(ncID, varID_temperature, fillmissing(temp, missing_value));
netcdf.putVar(ncID, varID_RH, fillmissing(relh, missing_value));
netcdf.putVar(ncID, varID_wind_direction, fillmissing(wind, missing_value));
netcdf.putVar(ncID, varID_wind_speed, fillmissing(wins, missing_value));

% re enter define mode
netcdf.reDef(ncID);

%% write attributes to the variables

% altitude
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'Height of lidar above mean sea level');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');
netcdf.putAtt(ncID, varID_altitude, 'axis', 'Y');

% pressure
netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
netcdf.putAtt(ncID, varID_pressure, 'long_name', 'air pressure');
netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'pressure');
netcdf.putAtt(ncID, varID_altitude, 'axis', 'X');

% temperature
netcdf.putAtt(ncID, varID_temperature, 'unit', 'degree celsius');
netcdf.putAtt(ncID, varID_temperature, 'long_name', 'air temperature');
netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'temperature');
netcdf.putAtt(ncID, varID_temperature, 'axis', 'X');

% RH
netcdf.putAtt(ncID, varID_RH, 'unit', '%');
netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
netcdf.putAtt(ncID, varID_RH, 'axis', 'X');

% wind_direction
netcdf.putAtt(ncID, varID_wind_direction, 'unit', 'degree');
netcdf.putAtt(ncID, varID_wind_direction, 'long_name', 'wind direction clockwise from north');
netcdf.putAtt(ncID, varID_wind_direction, 'standard_name', 'wind_direction');
netcdf.putAtt(ncID, varID_wind_direction, 'axis', 'X');

% wind_speed
netcdf.putAtt(ncID, varID_wind_speed, 'unit', 'm/s');
netcdf.putAtt(ncID, varID_wind_speed, 'long_name', 'wind speed');
netcdf.putAtt(ncID, varID_wind_speed, 'standard_name', 'wind_speed');
netcdf.putAtt(ncID, varID_wind_speed, 'axis', 'X');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', 'Atlantic Ocean');
netcdf.putAtt(ncID, varID_global, 'institute', 'AWI');
netcdf.putAtt(ncID, varID_global, 'contact', 'Alina Herzog');
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s', tNow, mfilename));

% close file
netcdf.close(ncID);

end
