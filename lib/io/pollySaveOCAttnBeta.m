function pollySaveOCAttnBeta(data)
% POLLYSAVEOCATTNBETA save overlap corrected attenuated backscatter.
%
% USAGE:
%    pollySaveOCAttnBeta(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-09: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

missing_value = -999;

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_OC_att_bsc.nc', rmext(PollyDataInfo.pollyDataFile)));

mode = netcdf.getConstant('NETCDF4');
mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
mode = bitor(mode, netcdf.getConstant('CLOBBER'));
ncID = netcdf.create(ncfile, mode);

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
varID_tilt_angle = netcdf.defVar(ncID, 'tilt_angle', 'NC_FLOAT', dimID_constant);
varID_att_bsc_355 = netcdf.defVar(ncID, 'attenuated_backscatter_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_att_bsc_532 = netcdf.defVar(ncID, 'attenuated_backscatter_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_att_bsc_1064 = netcdf.defVar(ncID, 'attenuated_backscatter_1064nm', 'NC_FLOAT', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_att_bsc_355, false, missing_value);
netcdf.defVarFill(ncID, varID_att_bsc_532, false, missing_value);
netcdf.defVarFill(ncID, varID_att_bsc_1064, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_att_bsc_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_att_bsc_532, true, true, 5);
netcdf.defVarDeflate(ncID, varID_att_bsc_1064, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_tilt_angle, single(data.angle));
netcdf.putVar(ncID, varID_att_bsc_355, single(fillmissing(data.att_beta_OC_355, missing_value)));
netcdf.putVar(ncID, varID_att_bsc_532, single(fillmissing(data.att_beta_OC_532, missing_value)));
netcdf.putVar(ncID, varID_att_bsc_1064, single(fillmissing(data.att_beta_OC_1064, missing_value)));

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

% att_bsc_355
netcdf.putAtt(ncID, varID_att_bsc_355, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_355, 'long_name', 'overlap corrected attenuated backscatter at 355 nm');
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
netcdf.putAtt(ncID, varID_att_bsc_532, 'long_name', 'overlap corrected attenuated backscatter at 532 nm');
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
netcdf.putAtt(ncID, varID_att_bsc_1064, 'long_name', 'overlap corrected attenuated backscatter at 1064 nm');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'standard_name', 'att_beta_1064');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_range', PollyConfig.zLim_att_beta_1064/1e6);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed1064);
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'error_variable', 'att_beta_1064_error');
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'bias_variable', 'att_beta_1064_bias');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

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
netcdf.putAtt(ncID, varID_global, 'PicassoConfig_Info', data.PicassoConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'PollyConfig_Info', data.PollyConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'CampaignConfig_Info', data.CampaignConfig_saving_info);
netcdf.putAtt(ncID, varID_global, 'PollyData_Info', data.PollyDataInfo_saving_info);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end