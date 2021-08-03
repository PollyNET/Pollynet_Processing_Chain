function pollySaveQsiV1(data)
% POLLYSAVEQSIV1 save quasi-retrieving (V1) results.
% USAGE:
%    pollySaveQsiV1(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2018-12-30: First Edition by Zhenping
%    2019-05-16: Extended the attributes for all the variables and comply with the ACTRIS convention.
%    2019-09-27: Turn on the netCDF4 compression.
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_quasi_results.nc', rmext(PollyDataInfo.pollyDataFile)));

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
varID_quasi_bsc_532 = netcdf.defVar(ncID, 'quasi_bsc_532', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_quasi_bsc_1064 = netcdf.defVar(ncID, 'quasi_bsc_1064', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_quasi_pardepol_532 = netcdf.defVar(ncID, 'quasi_pardepol_532', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_quasi_ang_532_1064 = netcdf.defVar(ncID, 'quasi_ang_532_1064', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_quality_mask_532 = netcdf.defVar(ncID, 'quality_mask_532', 'NC_BYTE', [dimID_height, dimID_time]);
varID_quality_mask_1064 = netcdf.defVar(ncID, 'quality_mask_1064', 'NC_BYTE', [dimID_height, dimID_time]);
varID_quality_mask_voldepol_532 = netcdf.defVar(ncID, 'quality_mask_voldepol_532', 'NC_BYTE', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_quasi_bsc_532, false, -999);
netcdf.defVarFill(ncID, varID_quasi_bsc_1064, false, -999);
netcdf.defVarFill(ncID, varID_quasi_pardepol_532, false, -999);
netcdf.defVarFill(ncID, varID_quasi_ang_532_1064, false, -999);
netcdf.defVarFill(ncID, varID_quality_mask_532, false, 1);
netcdf.defVarFill(ncID, varID_quality_mask_1064, false, 1);
netcdf.defVarFill(ncID, varID_quality_mask_voldepol_532, false, 1);

% define the data compression
netcdf.defVarDeflate(ncID, varID_quasi_bsc_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quasi_bsc_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quasi_pardepol_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quasi_ang_532_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_1064, true, true, 5);
netcdf.defVarDeflate(ncID, varID_quality_mask_voldepol_532, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_quasi_bsc_532, single(data.qsiBsc532V1));
netcdf.putVar(ncID, varID_quasi_bsc_1064, single(data.qsiBsc1064V1));
netcdf.putVar(ncID, varID_quasi_pardepol_532, single(data.qsiPDR532V1));
netcdf.putVar(ncID, varID_quasi_ang_532_1064, single(data.qsiAE_532_1064_V1));
netcdf.putVar(ncID, varID_quality_mask_532, int8(data.quality_mask_532));
netcdf.putVar(ncID, varID_quality_mask_1064, int8(data.quality_mask_1064));
netcdf.putVar(ncID, varID_quality_mask_voldepol_532, int8(data.quality_mask_vdr_532));

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

% quasi_bsc_532
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'long_name', 'quasi aerosol backscatter coefficients at 532 nm');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'standard_name', 'quasi_bsc_532');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'plot_range', PollyConfig.zLim_quasi_beta_355/1e6);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'error_variable', 'quasi_beta_532_error');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'bias_variable', 'quasi_beta_532_bias');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed532);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'Lidar_ratio_used', PollyConfig.LR532);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]', PollyConfig.LR532));
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. If the AOD is greater than 0.2, the relative uncertainty can be as large as 20%. Be careful about that!');

% quasi_bsc_1064
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'long_name', 'quasi aerosol backscatter coefficients at 1064 nm');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'standard_name', 'quasi_bsc_1064');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'plot_range', PollyConfig.zLim_quasi_beta_1064/1e6);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'error_variable', 'quasi_beta_1064_error');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'bias_variable', 'quasi_beta_1064_bias');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed1064);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'Lidar_ratio_used', PollyConfig.LR1064);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]', PollyConfig.LR1064));
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. If the AOD is greater than 0.2, the relative uncertainty can be as large as 20%. Be careful about that!');

% quasi_pardepol_532
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'unit', '');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'long_name', 'quasi particle depolarization ratio at 532 nm');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'standard_name', 'quasi_pardepol_532');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'plot_range', PollyConfig.zLim_quasi_Par_DR_532);
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'error_variable', 'quasi_pardepol_532_error');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'bias_variable', 'quasi_pardepol_532_bias');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]; Depolarization calibration factor is %f.', PollyConfig.LR532, data.polCaliFac532));
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin.');

% quasi_ang_532_1064
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'unit', '');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'long_name', 'quasi backscatter-related angstroem exponent at 532-1064');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'standard_name', 'quasi_ang_532_1064');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'plot_range', [0, 2]);
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'error_variable', 'quasi_ang_532_1064_error');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'bias_variable', 'quasi_ang_532_1064_bias');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr] at 532 nm, %5.1f[Sr] at 1064 nm.', PollyConfig.LR532, PollyConfig.LR1064));
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. Be careful about that!');

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
netcdf.putAtt(ncID, varID_global, 'title', 'quasi-retrieved aerosol optical properties (V1)');
netcdf.putAtt(ncID, varID_global, 'comment', PollyConfig.comment);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end