function [] = polly_1v2_save_overlap(data, taskInfo, config, globalAttri, file)
%polly_1v2_save_overlap Save the overlap file.
%   Example:
%       [] = polly_1v2_save_overlap(data, taskInfo, config, globalAttri, file);
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%       globalAttri: struct
%           overlap532: array
%               calculated overlap for 532 nm far range total channel.
%           overlap532Defaults: array
%               default overlap for 532 nm far range total channel.
%       file: char
%           netcdf file to save the overlap parameters.
%   Outputs:
%       
%   History:
%       2018-12-21. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%       2019-09-27. Turn on the netCDF4 compression.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

if isempty(data.rawSignal)
    return;
end

% convert empty array to defaults
overlap532 = globalAttri.overlap532;
overlap532Defaults = globalAttri.overlap532DefaultInterp;
if isempty(overlap532)
    overlap532 = -999 * ones(size(data.height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = -999 * ones(size(data.height));
end

% Create .nc file by overwriting any existing file with the name filename
mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(file, mode);

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
varID_overlap532Defaults = netcdf.defVar(ncID, 'overlap532Defaults', 'NC_DOUBLE', dimID_height);
varID_overlapCalMethod = netcdf.defVar(ncID, 'method', 'NC_SHORT', dimID_method);

% define the filling value
netcdf.defVarFill(ncID, varID_overlap532, false, -999);
netcdf.defVarFill(ncID, varID_overlap532Defaults, false, -999);

% define the data compression
netcdf.defVarDeflate(ncID, varID_overlap532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_overlap532Defaults, true, true, 5);

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
netcdf.putVar(ncID, varID_overlap532Defaults, overlap532Defaults);
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
netcdf.putAtt(ncID, varID_overlap532, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532, 'valid_max', 100);
netcdf.putAtt(ncID, varID_overlap532, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap532, 'comment', 'This variable is not quality-assured. Only use with instructions from the PollyNET develop team.');

% Default overlap 532
netcdf.putAtt(ncID, varID_overlap532Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'long_name', 'Default overlap function for 532nm far-range channel');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_min', 0.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'valid_max', 1.0);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_range', [0, 1.1]);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_overlap532Defaults, 'comment', 'This is the theoretical overlap function which is not identical to the real overlap function. Do not use it to correct the signal.');

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
cwd = pwd;
cd(processInfo.projectDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end
