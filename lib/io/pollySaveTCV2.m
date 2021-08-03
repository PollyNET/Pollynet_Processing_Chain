function pollySaveTCV2(data)
% POLLYSAVETCV2 save target classification results (V2)
% USAGE:
%    pollySaveTCV2(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2018-12-30: First Edition by Zhenping
%    2019-05-16: Extended the attributes for all the variables and comply with the ACTRIS convention.
%    2019-09-27: Turn on the netCDF4 compression.
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_target_classification_V2.nc', rmext(PollyDataInfo.pollyDataFile)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_tc_mask = netcdf.defVar(ncID, 'target_classification', 'NC_BYTE', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_tc_mask, false, 0);

% define the data compression
netcdf.defVarDeflate(ncID, varID_tc_mask, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_tc_mask, int8(data.tcMaskV2));

% re enter define mode
netcdf.reDef(ncID);

%% write attributes to the variables

% altitude
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'Height of lidar above mean sea level');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

% longitude
netcdf.putAtt(ncID, varID_longitude, 'unit', 'degrees_east');
netcdf.putAtt(ncID, varID_longitude, 'long_name', 'Longitude of the site');
netcdf.putAtt(ncID, varID_longitude, 'standard_name', 'longitude');
netcdf.putAtt(ncID, varID_longitude, 'axis', 'X');

% latitude
netcdf.putAtt(ncID, varID_latitude, 'unit', 'degrees_north');
netcdf.putAtt(ncID, varID_latitude, 'long_name', 'Latitude of the site');
netcdf.putAtt(ncID, varID_latitude, 'standard_name', 'latitude');
netcdf.putAtt(ncID, varID_latitude, 'axis', 'Y');

% time
netcdf.putAtt(ncID, varID_time, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_time, 'axis', 'T');
netcdf.putAtt(ncID, varID_time, 'calendar', 'julian');

% height
netcdf.putAtt(ncID, varID_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_height, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');
netcdf.putAtt(ncID, varID_height, 'axis', 'Z');

% tc_mask
netcdf.putAtt(ncID, varID_tc_mask, 'unit', '');
netcdf.putAtt(ncID, varID_tc_mask, 'long_name', 'Target classification');
netcdf.putAtt(ncID, varID_tc_mask, 'standard_name', 'tc_mask');
netcdf.putAtt(ncID, varID_tc_mask, 'plot_range', [0, 11]);
netcdf.putAtt(ncID, varID_tc_mask, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_tc_mask, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_tc_mask, 'comment', 'This variable provides 11 atmospheric target classifications that can be distinguished by multiwavelength raman lidar.');
netcdf.putAtt(ncID, varID_tc_mask, 'definition', '\"0: No signal\"\n\"1: Clean atmosphere\"\n\"2: Non-typed particles/low conc.\"\n\"3: Aerosol: small\"\n\"4: Aerosol: large, spherical\"\n\"5: Aerosol: mixture, partly non-spherical\"\n\"6: Aerosol: large, non-spherical\"\n\"7: Cloud: non-typed\"\n\"8: Cloud: water droplets\"\n\"9: Cloud: likely water droplets\"\n\"10: Cloud: ice crystals\"\n\"11: Cloud: likely ice crystals');
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_red', [1.0000, 0.9000, 0.6000, 0.8667, 0.9059, 0.5333, 0, 0.4706, 0.2275, 0.7059, 0.0667, 0.5255]);
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_green', [1.00, 0.90, 0.60, 0.80, 0.43, 0.13, 0.00, 0.11, 0.54, 0.87, 0.47, 0.73]);
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_blue', [1.00, 0.90, 0.60, 0.47, 0.18, 0.00, 0.00, 0.51, 0.79, 0.97, 0.20, 0.42]);

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID, varID_global, 'PI', PollyConfig.PI);
netcdf.putAtt(ncID, varID_global, 'PI_affiliation', PollyConfig.PI_affiliation);
netcdf.putAtt(ncID, varID_global, 'PI_affiliation_acronym', PollyConfig.PI_affiliation_acronym);
netcdf.putAtt(ncID, varID_global, 'PI_address', PollyConfig.PI_address);
netcdf.putAtt(ncID, varID_global, 'PI_phone', PollyConfig.PI_phone);
netcdf.putAtt(ncID, varID_global, 'PI_email', PollyConfig.PI_email);
netcdf.putAtt(ncID, varID_global, 'Data_Originator', PollyConfig.Data_Originator);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation', PollyConfig.Data_Originator_affiliation);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation_acronym', PollyConfig.Data_Originator_affiliation_acronym);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_address', PollyConfig.Data_Originator_address);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_phone', PollyConfig.Data_Originator_phone);
netcdf.putAtt(ncID, varID_global, 'Data_Originator_email', PollyConfig.Data_Originator_email);
netcdf.putAtt(ncID, varID_global, 'title', 'aerosol/cloud target classifications (V2)');
netcdf.putAtt(ncID, varID_global, 'comment', PollyConfig.comment);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end