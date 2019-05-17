function [] = pollyxt_noa_save_WVMR_RH(data, taskInfo, config)
%pollyxt_noa_save_WVMR_RH save the water vapor mixing ratio and relative humidity.
%   Example:
%       [] = pollyxt_noa_save_WVMR_RH(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-03-15. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_WVMR_RH.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_RH = netcdf.defVar(ncID, 'RH', 'NC_DOUBLE', [dimID_height, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));
netcdf.putVar(ncID, varID_WVMR, data.WVMR);
netcdf.putVar(ncID, varID_RH, data.RH);

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

% WVMR
netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g kg^-1');
netcdf.putAtt(ncID, varID_WVMR, 'unit_html', 'g kg<sup>-1</sup>');
netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'water vapor mixing ratio');
netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
netcdf.putAtt(ncID, varID_WVMR, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_WVMR, 'plot_range', config.WVMRProfileRange);
netcdf.putAtt(ncID, varID_WVMR, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_WVMR, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_WVMR, 'error_variable', 'WVMR_error');
netcdf.putAtt(ncID, varID_WVMR, 'bias_variable', 'WVMR_bias');
netcdf.putAtt(ncID, varID_WVMR, 'comment', sprintf('The water vapor channel was calibrated using IWV from %s.', config.IWV_instrument));

% WVMR
netcdf.putAtt(ncID, varID_RH, 'unit', '%');
netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
netcdf.putAtt(ncID, varID_RH, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_RH, 'plot_range', [0, 100]);
netcdf.putAtt(ncID, varID_RH, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_RH, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_RH, 'error_variable', 'RH_error');
netcdf.putAtt(ncID, varID_RH, 'bias_variable', 'RH_bias');
netcdf.putAtt(ncID, varID_RH, 'comment', sprintf('The water vapor channel was calibrated using IWV from %s.', config.IWV_instrument));

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'reference', processInfo.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
    
% close file
netcdf.close(ncID);

end