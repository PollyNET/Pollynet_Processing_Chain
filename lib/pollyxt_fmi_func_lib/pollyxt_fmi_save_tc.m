function [] = pollyxt_fmi_save_tc(data, taskInfo, config)
%pollyxt_fmi_save_tc Saving the target classification results to netcdf file.
%   Example:
%       [] = pollyxt_fmi_save_tc(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_target_classification.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_tc_mask = netcdf.defVar(ncID, 'target_classification', 'NC_DOUBLE', [dimID_height, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_tc_mask, data.tc_mask);

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
netcdf.putAtt(ncID, varID_tc_mask, '_FillValue', 'None');
netcdf.putAtt(ncID, varID_tc_mask, 'plot_range', [0, 11]);
netcdf.putAtt(ncID, varID_tc_mask, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_tc_mask, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_tc_mask, 'comment', 'This variable provides 11 atmospheric target classifications that can be distinguished by multiwavelength raman lidar.');
netcdf.putAtt(ncID, varID_tc_mask, 'definition', '\"0: No signal\"\n\"1: Clean atmosphere\"\n\"2: Non-typed particles/low conc.\"\n\"3: Aerosol: small\"\n\"4: Aerosol: large, spherical\"\n\"5: Aerosol: mixture, partly non-spherical\"\n\"6: Aerosol: large, non-spherical\"\n\"7: Cloud: non-typed\"\n\"8: Cloud: water droplets\"\n\"9: Cloud: likely water droplets\"\n\"10: Cloud: ice crystals\"\n\"11: Cloud: likely ice crystals');
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_red', [1.0000, 0.9000, 0.6000, 0.8667, 0.9059, 0.5333, 0, 0.4706, 0.2275, 0.7059, 0.0667, 0.5255]);
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_green', [1.00, 0.90, 0.60, 0.80, 0.43, 0.13, 0.00, 0.11, 0.54, 0.87, 0.47, 0.73]);
netcdf.putAtt(ncID, varID_tc_mask, 'legend_key_blue', [1.00, 0.90, 0.60, 0.47, 0.18, 0.00, 0.00, 0.51, 0.79, 0.97, 0.20, 0.42]);

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'reference', processInfo.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
cwd = pwd;
cd(processInfo.projectDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));
    
% close file
netcdf.close(ncID);

end