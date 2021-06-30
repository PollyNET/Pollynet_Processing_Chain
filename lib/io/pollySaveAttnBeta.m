function pollySaveAttnBeta(data)
% POLLYSAVEATTNBETA save attenuated backscatter.
% USAGE:
%    pollySaveAttnBeta(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2019-01-10: First Edition by Zhenping
%    2019-05-16: Extended the attributes for all the variables and comply with the ACTRIS convention.
%    2019-09-27: Turn on the netCDF4 compression.
% .. Authors: - zhenping@tropos.de

missing_value = -999;

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_att_bsc.nc', rmext(PollyDataInfo.pollyDataFile)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_att_bsc_355 = netcdf.defVar(ncID, 'attenuated_backscatter_355nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_att_bsc_532 = netcdf.defVar(ncID, 'attenuated_backscatter_532nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_att_bsc_1064 = netcdf.defVar(ncID, 'attenuated_backscatter_1064nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_355 = netcdf.defVar(ncID, 'quality_mask_355nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_532 = netcdf.defVar(ncID, 'quality_mask_532nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_1064 = netcdf.defVar(ncID, 'quality_mask_1064nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_SNR_355 = netcdf.defVar(ncID, 'SNR_355nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_SNR_532 = netcdf.defVar(ncID, 'SNR_532nm', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_SNR_1064 = netcdf.defVar(ncID, 'SNR_1064nm', 'NC_DOUBLE', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_att_bsc_355, false, missing_value);
netcdf.defVarFill(ncID, varID_att_bsc_532, false, missing_value);
netcdf.defVarFill(ncID, varID_att_bsc_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_quality_mask_355, false, missing_value);
netcdf.defVarFill(ncID, varID_quality_mask_532, false, missing_value);
netcdf.defVarFill(ncID, varID_quality_mask_1064, false, missing_value);
netcdf.defVarFill(ncID, varID_SNR_355, false, missing_value);
netcdf.defVarFill(ncID, varID_SNR_532, false, missing_value);
netcdf.defVarFill(ncID, varID_SNR_1064, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_att_bsc_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_att_bsc_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_att_bsc_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_SNR_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_SNR_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_SNR_1064, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% re-generate SNR and quality mask for attenuated backscatter
% (temporary solution to be compatible with Cloudnet)

%calculate the quality mask to filter the points with high SNR
flag355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_att_bsc_355, fillmissing(data.att_beta_355, missing_value));
netcdf.putVar(ncID, varID_att_bsc_532, fillmissing(data.att_beta_532, missing_value));
netcdf.putVar(ncID, varID_att_bsc_1064, fillmissing(data.att_beta_1064, missing_value));
netcdf.putVar(ncID, varID_quality_mask_355, fillmissing(data.quality_mask_355, missing_value));
netcdf.putVar(ncID, varID_quality_mask_532, fillmissing(data.quality_mask_532, missing_value));
netcdf.putVar(ncID, varID_quality_mask_1064, fillmissing(data.quality_mask_1064, missing_value));
if sum(flag355) == 1
    netcdf.putVar(ncID, varID_SNR_355, fillmissing(squeeze(data.SNR(flag355, :, :)), missing_value));
else
    netcdf.putVar(ncID, varID_SNR_355, missing_value * ones(length(data.height), length(data.mTime)));
end
if sum(flag532) == 1
    netcdf.putVar(ncID, varID_SNR_532, fillmissing(squeeze(data.SNR(flag532, :, :)), missing_value));
else
    netcdf.putVar(ncID, varID_SNR_532, missing_value * ones(length(data.height), length(data.mTime)));
end
if sum(flag1064) == 1
    netcdf.putVar(ncID, varID_SNR_1064, fillmissing(squeeze(data.SNR(flag1064, :, :)), missing_value));
else
    netcdf.putVar(ncID, varID_SNR_1064, missing_value * ones(length(data.height), length(data.mTime)));
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

% att_bsc_355
netcdf.putAtt(ncID, varID_att_bsc_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_355, 'long_name', 'attenuated backscatter at 355 nm');
netcdf.putAtt(ncID, varID_att_bsc_355, 'standard_name', 'att_beta_355');
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_range', PollyConfig.zLim_att_beta_355/1e6);
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_355, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed355);
% netcdf.putAtt(ncID, varID_att_bsc_355, 'error_variable', 'att_beta_355_error');
% netcdf.putAtt(ncID, varID_att_bsc_355, 'bias_variable', 'att_beta_355_bias');
netcdf.putAtt(ncID, varID_att_bsc_355, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

% att_bsc_532
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_532, 'long_name', 'attenuated backscatter at 532 nm');
netcdf.putAtt(ncID, varID_att_bsc_532, 'standard_name', 'att_beta_532');
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_range', PollyConfig.zLim_att_beta_532/1e6);
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_532, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed532);
% netcdf.putAtt(ncID, varID_att_bsc_532, 'error_variable', 'att_beta_532_error');
% netcdf.putAtt(ncID, varID_att_bsc_532, 'bias_variable', 'att_beta_532_bias');
netcdf.putAtt(ncID, varID_att_bsc_532, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

% att_bsc_1064
netcdf.putAtt(ncID, varID_att_bsc_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'long_name', 'attenuated backscatter at 1064 nm');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'standard_name', 'att_beta_1064');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_range', PollyConfig.zLim_att_beta_1064/1e6);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed1064);
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'error_variable', 'att_beta_1064_error');
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'bias_variable', 'att_beta_1064_bias');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

% quality_mask_355
netcdf.putAtt(ncID, varID_quality_mask_355, 'unit', '');
netcdf.putAtt(ncID, varID_quality_mask_355, 'long_name', 'quality mask for attenuated backscatter at 355 nm');
netcdf.putAtt(ncID, varID_quality_mask_355, 'standard_name', 'quality_mask_355');
netcdf.putAtt(ncID, varID_quality_mask_355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quality_mask_355, 'comment', 'This variable can be used to filter noisy pixels of attenuated backscatter at 355 nm. (0: good data; 1: low SNR; 2: depolarization calibration periods; 3: shutter on; 4: fog)');

% quality_mask_532
netcdf.putAtt(ncID, varID_quality_mask_532, 'unit', '');
netcdf.putAtt(ncID, varID_quality_mask_532, 'long_name', 'quality mask for attenuated backscatter at 532 nm');
netcdf.putAtt(ncID, varID_quality_mask_532, 'standard_name', 'quality_mask_532');
netcdf.putAtt(ncID, varID_quality_mask_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quality_mask_532, 'comment', 'This variable can be used to filter noisy pixels of attenuated backscatter at 532 nm. (0: good data; 1: low SNR; 2: depolarization calibration periods; 3: shutter on; 4: fog)');

% quality_mask_1064
netcdf.putAtt(ncID, varID_quality_mask_1064, 'unit', '');
netcdf.putAtt(ncID, varID_quality_mask_1064, 'long_name', 'quality mask for attenuated backscatter at 1064 nm');
netcdf.putAtt(ncID, varID_quality_mask_1064, 'standard_name', 'quality_mask_1064');
netcdf.putAtt(ncID, varID_quality_mask_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quality_mask_1064, 'comment', 'This variable can be used to filter noisy pixels of attenuated backscatter at 1064 nm. (0: good data; 1: low SNR; 2: depolarization calibration periods; 3: shutter on; 4: fog)');

% SNR 355 nm
netcdf.putAtt(ncID, varID_SNR_355, 'unit', '');
netcdf.putAtt(ncID, varID_SNR_355, 'long_name', 'SNR at 355 nm');
netcdf.putAtt(ncID, varID_SNR_355, 'standard_name', 'signal-noise-ratio 355 nm');
netcdf.putAtt(ncID, varID_SNR_355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_SNR_355, 'comment', '');

% SNR 532 nm
netcdf.putAtt(ncID, varID_SNR_532, 'unit', '');
netcdf.putAtt(ncID, varID_SNR_532, 'long_name', 'SNR at 532 nm');
netcdf.putAtt(ncID, varID_SNR_532, 'standard_name', 'signal-noise-ratio 532 nm');
netcdf.putAtt(ncID, varID_SNR_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_SNR_532, 'comment', '');

% SNR 1064 nm
netcdf.putAtt(ncID, varID_SNR_1064, 'unit', '');
netcdf.putAtt(ncID, varID_SNR_1064, 'long_name', 'SNR at 1064 nm');
netcdf.putAtt(ncID, varID_SNR_1064, 'standard_name', 'signal-noise-ratio 1064 nm');
netcdf.putAtt(ncID, varID_SNR_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_SNR_1064, 'comment', '');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', PicassoConfig.contact);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end