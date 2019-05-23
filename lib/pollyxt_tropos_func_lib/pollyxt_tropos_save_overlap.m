function [] = pollyxt_tropos_save_overlap(data, taskInfo, config, globalAttri, file)
%pollyxt_tropos_save_overlap Save the overlap file.
%   Example:
%       [] = pollyxt_tropos_save_overlap(data, taskInfo, config, globalAttri, file);
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%       globalAttri: struct
%           overlap532: array
%               calculated overlap for 532 nm far range total channel.
%           overlap355: array
%               calculated overlap for 355 nm far range total channel.
%           overlap532Defaults: array
%               default overlap for 532 nm far range total channel.
%           overlap355Defaults: array
%               default overlap for 355 nm far range total channel.
%       file: char
%           netcdf file to save the overlap parameters.
%   Outputs:
%       
%   History:
%       2018-12-21. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

if isempty(data.rawSignal)
    return;
end

% convert empty array to defaults
overlap355 = globalAttri.overlap355;
overlap532 = globalAttri.overlap532;
overlap355Defaults = globalAttri.overlap355DefaultInterp;
overlap532Defaults = globalAttri.overlap532DefaultInterp;
if isempty(overlap532)
    overlap532 = -999 * ones(size(data.height));
end
if isempty(overlap355)
    overlap355 = -999 * ones(size(data.height));
end
if isempty(overlap355Defaults)
    overlap355Defaults = -999 * ones(size(data.height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = -999 * ones(size(data.height));
end

% Create .nc file by overwriting any existing file with the name filename
ncID = netcdf.create(file, 'CLOBBER');

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_method = netcdf.defDim(ncID, 'method', 1);
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_constant);
varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_constant);
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_overlap532 = netcdf.defVar(ncID, 'overlap532', 'NC_DOUBLE', dimID_height);
varID_overlap355 = netcdf.defVar(ncID, 'overlap355', 'NC_DOUBLE', dimID_height);
varID_overlap532Defaults = netcdf.defVar(ncID, 'overlap532Defaults', 'NC_DOUBLE', dimID_height);
varID_overlap355Defaults = netcdf.defVar(ncID, 'overlap355Defaults', 'NC_DOUBLE', dimID_height);
varID_overlapCalMethod = netcdf.defVar(ncID, 'method', 'NC_SHORT', dimID_method);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(data.mTime(1)));
netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(data.mTime(end)));
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_overlap532, overlap532);
netcdf.putVar(ncID, varID_overlap355, overlap355);
netcdf.putVar(ncID, varID_overlap532Defaults, overlap532Defaults);
netcdf.putVar(ncID, varID_overlap355Defaults, overlap355Defaults);
netcdf.putVar(ncID, varID_overlapCalMethod, config.overlapCalMode);

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

% start_time
netcdf.putAtt(ncID, varID_startTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_startTime, 'long_name', 'Time UTC to start the current measurement');
netcdf.putAtt(ncID, varID_startTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_startTime, 'calendar', 'julian');

% end_time
netcdf.putAtt(ncID, varID_endTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_endTime, 'long_name', 'Time UTC to finish the current measurement');
netcdf.putAtt(ncID, varID_endTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_endTime, 'calendar', 'julian');

% height
netcdf.putAtt(ncID, varID_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_height, 'long_name', 'Height above the ground');
netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');
netcdf.putAtt(ncID, varID_height, 'axis', 'Z');

% overlap 532
netcdf.putAtt(ncID, varID_overlap532, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532, 'long_name', 'overlap function for 532nm far-range channel');
netcdf.putAtt(ncID, varID_overlap532, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_overlap532, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap532, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap532, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% overlap 355
netcdf.putAtt(ncID, varID_overlap355, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355, 'long_name', 'overlap function for 355nm far-range channel');
netcdf.putAtt(ncID, varID_overlap355, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_overlap355, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap355, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap355, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% Default overlap 532
netcdf.putAtt(ncID, varID_overlap532Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'long_name', 'Default overlap function for 532nm far-range channel');
netcdf.putAtt(ncID, varID_overlap532Defaults, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'comment', 'This is the theoretical overlap function which is not identical to the real overlap function. Do not use it to correct the signal.');

% Default overlap 355
netcdf.putAtt(ncID, varID_overlap355Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'long_name', 'Default overlap function for 355nm far-range channel');
netcdf.putAtt(ncID, varID_overlap355Defaults, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap355Defaults, 'comment', 'This is the theoretical overlap function which is not identical to the real overlap function. Do not use it to correct the signal.');

% overlap calibration method
netcdf.putAtt(ncID, varID_overlapCalMethod, 'unit', '');
netcdf.putAtt(ncID, varID_overlapCalMethod, 'long_name', 'Overlap calibration method');
netcdf.putAtt(ncID, varID_overlapCalMethod, 'definition', '1: signal ratio of near and far range signal; 2: Raman method (Ulla Wandinger 2002)');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'reference', processInfo.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);

% close file
netcdf.close(ncID);

end