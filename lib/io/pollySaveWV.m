function pollySaveWV(data)
% POLLYSAVEWV save water vapor products.
%
% USAGE:
%    pollySaveWV(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2019-03-15: First Edition by Zhenping
%    - 2019-05-16: Extended the attributes for all the variables and comply with the ACTRIS convention.
%    - 2019-09-27: Turn on the netCDF4 compression.
%
% .. Authors: - zhenping@tropos.de

missing_value = -999;

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_WVMR_RH.nc', rmext(PollyDataInfo.pollyDataFile)));

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
varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_tilt_angle = netcdf.defVar(ncID, 'tilt_angle', 'NC_FLOAT', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_WVMR_no_QC = netcdf.defVar(ncID, 'WVMR_no_QC', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_uncertainty_WVMR = netcdf.defVar(ncID, 'uncertainty_WVMR', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_WVMR_rel_error = netcdf.defVar(ncID, 'WVMR_rel_error', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_RH = netcdf.defVar(ncID, 'RH', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_SNR_387 = netcdf.defVar(ncID, 'SNR_387nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_SNR_407 = netcdf.defVar(ncID, 'SNR_407nm', 'NC_FLOAT', [dimID_height, dimID_time]);
if isfield(data, 'quality_mask_WVMR')
    varID_QM_WVMR = netcdf.defVar(ncID, 'QM_WVMR', 'NC_BYTE', [dimID_height, dimID_time]);
end
if isfield(data, 'quality_mask_RH')
    varID_QM_RH = netcdf.defVar(ncID, 'QM_RH', 'NC_BYTE', [dimID_height, dimID_time]);
end
% define the filling value
netcdf.defVarFill(ncID, varID_WVMR, false, missing_value);
netcdf.defVarFill(ncID, varID_WVMR_no_QC, false, missing_value);
netcdf.defVarFill(ncID, varID_uncertainty_WVMR, false, missing_value);
netcdf.defVarFill(ncID, varID_WVMR_rel_error, false, missing_value);
netcdf.defVarFill(ncID, varID_RH, false, missing_value);
netcdf.defVarFill(ncID, varID_SNR_387, false, missing_value);
netcdf.defVarFill(ncID, varID_SNR_407, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_WVMR, true, true, 5);
netcdf.defVarDeflate(ncID, varID_uncertainty_WVMR, true, true, 5);
netcdf.defVarDeflate(ncID, varID_WVMR_rel_error, true, true, 5);
netcdf.defVarDeflate(ncID, varID_RH, true, true, 5);
netcdf.defVarDeflate(ncID, varID_SNR_387, true, true, 5);
netcdf.defVarDeflate(ncID, varID_SNR_407, true, true, 5);
% leave define mode
netcdf.endDef(ncID);

flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag407 = data.flagFarRangeChannel & data.flag407nmChannel;
% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_tilt_angle, single(data.angle));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));
netcdf.putVar(ncID, varID_WVMR, single(fillmissing(data.WVMR, missing_value)));	
netcdf.putVar(ncID, varID_WVMR_no_QC, single(fillmissing(data.WVMR_no_QC, missing_value)));	
netcdf.putVar(ncID, varID_uncertainty_WVMR, single(fillmissing(data.WVMR_error, missing_value)));	%temporarily stored relative error for validation
netcdf.putVar(ncID, varID_WVMR_rel_error, single(fillmissing(data.WVMR_rel_error, missing_value)));
netcdf.putVar(ncID, varID_RH, single(fillmissing(data.RH, missing_value)));

if sum(flag387) == 1
    netcdf.putVar(ncID, varID_SNR_387, single(fillmissing(squeeze(data.SNR(flag387, :, :)), missing_value)));
else
    netcdf.putVar(ncID, varID_SNR_387, single(missing_value * ones(length(data.height), length(data.mTime))));
end
if sum(flag407) == 1
    netcdf.putVar(ncID, varID_SNR_407, single(fillmissing(squeeze(data.SNR(flag407, :, :)), missing_value)));
else
    netcdf.putVar(ncID, varID_SNR_407, single(missing_value * ones(length(data.height), length(data.mTime))));
end


% Quality_mask_WVMR
netcdf.putVar(ncID, varID_QM_WVMR, int8(fillmissing(data.quality_mask_WVMR, missing_value)));
% Quality_mask_RH
netcdf.putVar(ncID, varID_QM_RH, int8(fillmissing(data.quality_mask_RH, missing_value)));

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

% tilt_angle
netcdf.putAtt(ncID, varID_tilt_angle, 'unit', 'degrees');
netcdf.putAtt(ncID, varID_tilt_angle, 'long_name', 'Tilt angle of lidar device');
netcdf.putAtt(ncID, varID_tilt_angle, 'standard_name', 'tilt_angle');

% WVMR
netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g kg^-1');
netcdf.putAtt(ncID, varID_WVMR, 'unit_html', 'g kg<sup>-1</sup>');
netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'water vapor mixing ratio with Quality mask applied');
netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
netcdf.putAtt(ncID, varID_WVMR, 'plot_range', PollyConfig.xLim_Profi_WV_RH);
netcdf.putAtt(ncID, varID_WVMR, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_WVMR, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_WVMR, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_WVMR, 'error_variable', 'uncertainty_WVMR');
% netcdf.putAtt(ncID, varID_WVMR, 'bias_variable', 'WVMR_bias');
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_WVMR, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));

% WVMR_no_QC
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'unit', 'g kg^-1');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'unit_html', 'g kg<sup>-1</sup>');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'long_name', 'water vapor mixing ratio without Quality Checks');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'standard_name', 'WVMR_no_QC');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'plot_range', PollyConfig.xLim_Profi_WVMR);
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_WVMR_no_QC, 'error_variable', 'uncertainty_WVMR_no_QC');
% netcdf.putAtt(ncID, varID_WVMR_no_QC, 'bias_variable', 'WVMR_no_QC_bias');
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_WVMR_no_QC, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));

% WVMR_error
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'unit', 'g kg^-1');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'unit_html', 'g kg<sup>-1</sup>');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'long_name', 'absolute error of the water vapor mixing ratio');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'standard_name', 'uncertainty_WVMR');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'plot_range', PollyConfig.xLim_Profi_WV_RH/10);
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_WVMR, 'error_variable', 'WVMR_error');
% netcdf.putAtt(ncID, varID_WVMR, 'bias_variable', 'WVMR_bias');
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_uncertainty_WVMR, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));

% WVMR_rel_error
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'unit', '1');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'unit_html', '1');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'long_name', 'relative error of the water vapor mixing ratio');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'standard_name', 'WVMR_rel_error');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'plot_range', [0, 1]);
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_WVMR, 'error_variable', 'WVMR_error');
% netcdf.putAtt(ncID, varID_WVMR, 'bias_variable', 'WVMR_bias');
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_WVMR_rel_error, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));


% RH
netcdf.putAtt(ncID, varID_RH, 'unit', '%');
netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
netcdf.putAtt(ncID, varID_RH, 'plot_range', [0, 100]);
netcdf.putAtt(ncID, varID_RH, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_RH, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_RH, 'wv_calibration_constant_used', data.wvconstUsed);
% netcdf.putAtt(ncID, varID_RH, 'error_variable', 'RH_error');
% netcdf.putAtt(ncID, varID_RH, 'bias_variable', 'RH_bias');
netcdf.putAtt(ncID, varID_RH, 'retrieving_info', sprintf('flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));

% SNR 387 nm
netcdf.putAtt(ncID, varID_SNR_387, 'unit', '');
netcdf.putAtt(ncID, varID_SNR_387, 'long_name', 'SNR at 387 nm');
netcdf.putAtt(ncID, varID_SNR_387, 'standard_name', 'signal-noise-ratio 387 nm');
netcdf.putAtt(ncID, varID_SNR_387, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_SNR_387, 'comment', '');

% SNR 407 nm
netcdf.putAtt(ncID, varID_SNR_407, 'unit', '');
netcdf.putAtt(ncID, varID_SNR_407, 'long_name', 'SNR at 407 nm');
netcdf.putAtt(ncID, varID_SNR_407, 'standard_name', 'signal-noise-ratio 407 nm');
netcdf.putAtt(ncID, varID_SNR_407, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_SNR_407, 'comment', '');

% Quality_mask_WVMR
netcdf.putAtt(ncID, varID_QM_WVMR, 'unit', 'flag');
netcdf.putAtt(ncID, varID_QM_WVMR, 'unit_html', 'flag');
netcdf.putAtt(ncID, varID_QM_WVMR, 'long_name', 'Quality mask for WVMR ratio retrieval. 0=ok,1=SNR too low,2=depol calibation');
netcdf.putAtt(ncID, varID_QM_WVMR, 'standard_name', 'QM_WVMR');
netcdf.putAtt(ncID, varID_QM_WVMR, 'plot_range', PollyConfig.xLim_Profi_WV_RH);
netcdf.putAtt(ncID, varID_QM_WVMR, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_QM_WVMR, 'source', CampaignConfig.name);

% Quality_mask_RH
netcdf.putAtt(ncID, varID_QM_RH, 'unit', 'flag');
netcdf.putAtt(ncID, varID_QM_RH, 'unit_html', 'flag');
netcdf.putAtt(ncID, varID_QM_RH, 'long_name', 'Quality mask for RH ratio retrieval. 0=ok,1=SNR too low,2=depol calibation');
netcdf.putAtt(ncID, varID_QM_RH, 'standard_name', 'QM_RH');
netcdf.putAtt(ncID, varID_QM_RH, 'plot_range', PollyConfig.xLim_Profi_WV_RH);
netcdf.putAtt(ncID, varID_QM_RH, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_QM_RH, 'source', CampaignConfig.name);

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'Licence', 'Creative Commons Attribution Share Alike 4.0 International (CC BY-SA 4.0)');
netcdf.putAtt(ncID, varID_global, 'Data Policy', 'Each PollyNET site has Principal Investigator(s) (PI), responsible for deployment, maintenance and data collection. Information on which PI is responsible can be gathered via polly@tropos.de. The PI has priority use of the data collected at the site. The PI is entitled to be informed of any use of that data. Mandatory guidelines for data use and publication: Using PollyNET data or plots (also for presentations/workshops): Please consult with the PI or the PollyNET team (see contact_mail contact) before using data or plots! This will help to avoid misinterpretations of the lidar data and avoid the use of data from periods of malfunction of the instrument. Using PollyNET images/data on external websites: PIs and PollyNET must be asked for agreement and a link directed to polly.tropos.de must be included. Publishing PollyNET data and/or plots data: Offer authorship for the PI(s)! Acknowledge projects which have made the measurements possible according to PI(s) recommendation. PollyNET requests a notification of any published papers or reports or a brief description of other uses (e.g., posters, oral presentations, etc.) of data/plots used from PollyNET. This will help us determine the use of PollyNET data, which is helpful in optimizing product development and acquire new funding for future measurements. It also helps us to keep our product-related references up-to-date.');
netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', PicassoConfig.contact);
netcdf.putAtt(ncID, varID_global, 'wv_calibration_constant_used', data.wvconstUsed);
netcdf.putAtt(ncID, varID_global, 'wv_calibration_constant_std', data.wvconstUsedStd);
thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
netcdf.putAtt(ncID, varID_global, 'retrieving_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', data.hRes, thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));
netcdf.putAtt(ncID, varID_global, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end