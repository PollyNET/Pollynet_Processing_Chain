function [] = pollyxt_uw_save_voldepol(data, taskInfo, config)
%pollyxt_uw_save_voldepol save the attenuated backscatter.
%   Example:
%       [] = pollyxt_uw_save_voldepol(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-10. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_vol_depol.nc', rmext(taskInfo.dataFilename)));

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
varID_voldepol_355 = netcdf.defVar(ncID, 'volume_depolarization_ratio_355nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_voldepol_532 = netcdf.defVar(ncID, 'volume_depolarization_ratio_532nm', 'NC_DOUBLE', [dimID_height, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_voldepol_355, data.volDepol_355);
netcdf.putVar(ncID, varID_voldepol_532, data.volDepol_532);

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

% voldepol_355
netcdf.putAtt(ncID, varID_voldepol_355, 'unit', '');
netcdf.putAtt(ncID, varID_voldepol_355, 'long_name', 'volume depolarization ratio at 355 nm');
netcdf.putAtt(ncID, varID_voldepol_355, 'standard_name', 'voldepol_355');
netcdf.putAtt(ncID, varID_voldepol_355, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_voldepol_355, 'plot_range', [0, 0.3]);
netcdf.putAtt(ncID, varID_voldepol_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_voldepol_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_voldepol_355, 'error_variable', 'voldepol_355_error');
netcdf.putAtt(ncID, varID_voldepol_355, 'bias_variable', 'voldepol_355_bias');
netcdf.putAtt(ncID, varID_voldepol_355, 'comment', 'The depolarized channel was calibrated with \pm 45\circ method.');

% voldepol_532
netcdf.putAtt(ncID, varID_voldepol_532, 'unit', '');
netcdf.putAtt(ncID, varID_voldepol_532, 'long_name', 'volume depolarization ratio at 532 nm');
netcdf.putAtt(ncID, varID_voldepol_532, 'standard_name', 'voldepol_532');
netcdf.putAtt(ncID, varID_voldepol_532, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_voldepol_532, 'plot_range', [0, 0.3]);
netcdf.putAtt(ncID, varID_voldepol_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_voldepol_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_voldepol_532, 'error_variable', 'voldepol_532_error');
netcdf.putAtt(ncID, varID_voldepol_532, 'bias_variable', 'voldepol_532_bias');
netcdf.putAtt(ncID, varID_voldepol_532, 'comment', 'The depolarized channel was calibrated with \pm 45\circ method.');

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