function pollyxt_save_WVMR_RH(data, taskInfo, config)
%POLLYXT_SAVE_WVMR_RH save the water vapor mixing ratio and relative humidity.
%Example:
%   pollyxt_save_WVMR_RH(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%History:
%   2019-03-15. First Edition by Zhenping
%   2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   2019-09-27. Turn on the netCDF4 compression.
%Contact:
%   zhenping@tropos.de

missing_value = -999;

global processInfo campaignInfo

ncfile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_WVMR_RH.nc', rmext(taskInfo.dataFilename)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

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
if isfield(data, 'quality_mask_WVMR')
    varID_QM_WVMR = netcdf.defVar(ncID, 'QM_WVMR', 'NC_DOUBLE', [dimID_height, dimID_time]);
end
if isfield(data, 'quality_mask_RH')
    varID_QM_RH = netcdf.defVar(ncID, 'QM_RH', 'NC_DOUBLE', [dimID_height, dimID_time]);
end
% define the filling value
netcdf.defVarFill(ncID, varID_WVMR, false, missing_value);
netcdf.defVarFill(ncID, varID_RH, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_WVMR, true, true, 5);
netcdf.defVarDeflate(ncID, varID_RH, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));
netcdf.putVar(ncID, varID_WVMR, fillmissing(data.WVMR, missing_value));	
netcdf.putVar(ncID, varID_RH, fillmissing(data.RH, missing_value));

% Quality_mask_WVMR
if isfield(data, 'quality_mask_WVMR')
    netcdf.putVar(ncID, varID_QM_WVMR, fillmissing(data.quality_mask_WVMR, missing_value));
end
% Quality_mask_RH
if isfield(data, 'quality_mask_RH')
    netcdf.putVar(ncID, varID_QM_RH, fillmissing(data.quality_mask_RH, missing_value));
end

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
netcdf.putAtt(ncID, varID_WVMR, 'plot_range', config.xLim_Profi_WV_RH);
netcdf.putAtt(ncID, varID_WVMR, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_WVMR, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_WVMR, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_WVMR, 'error_variable', 'WVMR_error');
% netcdf.putAtt(ncID, varID_WVMR, 'bias_variable', 'WVMR_bias');
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_WVMR, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));

% RH
netcdf.putAtt(ncID, varID_RH, 'unit', '%');
netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
netcdf.putAtt(ncID, varID_RH, 'plot_range', [0, 100]);
netcdf.putAtt(ncID, varID_RH, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_RH, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_RH, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_RH, 'error_variable', 'RH_error');
% netcdf.putAtt(ncID, varID_RH, 'bias_variable', 'RH_bias');
netcdf.putAtt(ncID, varID_RH, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));


% Quality_mask_WVMR
if isfield(data, 'quality_mask_WVMR')
    netcdf.putAtt(ncID, varID_QM_WVMR, 'unit', 'flag');
    netcdf.putAtt(ncID, varID_QM_WVMR, 'unit_html', 'flag');
    netcdf.putAtt(ncID, varID_QM_WVMR, 'long_name', 'Quality mask for WVMR ratio retrieval. 0=ok,1=SNR too low,2=depol calibation');
    netcdf.putAtt(ncID, varID_QM_WVMR, 'standard_name', 'QM_WVMR');
    netcdf.putAtt(ncID, varID_QM_WVMR, 'plot_range', config.xLim_Profi_WV_RH);
    netcdf.putAtt(ncID, varID_QM_WVMR, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_QM_WVMR, 'source', campaignInfo.name);
end
% Quality_mask_RH
if isfield(data, 'quality_mask_RH')
    netcdf.putAtt(ncID, varID_QM_RH, 'unit', 'flag');
    netcdf.putAtt(ncID, varID_QM_RH, 'unit_html', 'flag');
    netcdf.putAtt(ncID, varID_QM_RH, 'long_name', 'Quality mask for RH ratio retrieval. 0=ok,1=SNR too low,2=depol calibation');
    netcdf.putAtt(ncID, varID_QM_RH, 'standard_name', 'QM_RH');
    netcdf.putAtt(ncID, varID_QM_RH, 'plot_range', config.xLim_Profi_WV_RH);
    netcdf.putAtt(ncID, varID_QM_RH, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_QM_RH, 'source', campaignInfo.name);
end

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