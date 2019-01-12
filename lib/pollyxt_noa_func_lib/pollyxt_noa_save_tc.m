function [] = pollyxt_noa_save_tc(data, taskInfo, config)
%pollyxt_noa_save_tc Saving the target classification results to netcdf file.
%   Example:
%       [] = pollyxt_noa_save_tc(data, config)
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
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_target_classification.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_tc_mask = netcdf.defVar(ncID, 'target_classification', 'NC_DOUBLE', [dimID_altitude, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt);
netcdf.putVar(ncID, varID_time, data.mTime);
netcdf.putVar(ncID, varID_tc_mask, data.tc_mask);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height (above surface)');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

netcdf.putAtt(ncID, varID_time, 'unit', 'days after Jan 0000');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');

netcdf.putAtt(ncID, varID_tc_mask, 'long_name', 'Target classification');
netcdf.putAtt(ncID, varID_tc_mask, 'comment', 'This variable provides 11 atmospheric target classifications that can be distinguished by multiwavelength raman lidar.');
netcdf.putAtt(ncID, varID_tc_mask, 'definition', '\"0: No signal\"\n\"1: Clean atmosphere\"\n\"2: Non-typed particles/low conc.\"\n\"3: Aerosol: small\"\n\"4: Aerosol: large, spherical\"\n\"5: Aerosol: mixture, partly non-spherical\"\n\"6: Aerosol: large, non-spherical\"\n\"7: Cloud: non-typed\"\n\"8: Cloud: water droplets\"\n\"9: Cloud: likely water droplets\"\n\"10: Cloud: ice crystals\"\n\"11: Cloud: likely ice crystals');
netcdf.putAtt(ncID, varID_tc_mask, 'color_red', [1.0000, 0.9000, 0.6000, 0.8667, 0.9059, 0.5333, 0, 0.4706, 0.2275, 0.7059, 0.0667, 0.5255]);
netcdf.putAtt(ncID, varID_tc_mask, 'color_green', [1.00, 0.90, 0.60, 0.80, 0.43, 0.13, 0.00, 0.11, 0.54, 0.87, 0.47, 0.73]);
netcdf.putAtt(ncID, varID_tc_mask, 'color_blue', [1.00, 0.90, 0.60, 0.47, 0.18, 0.00, 0.00, 0.51, 0.79, 0.97, 0.20, 0.42]);

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
 
% close file
netcdf.close(ncID);

end