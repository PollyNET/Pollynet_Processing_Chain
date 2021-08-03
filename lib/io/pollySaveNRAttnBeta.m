function pollySaveNRAttnBeta(data)
% POLLYSAVENRATTNBETA save near-field attenuated backscatter.
% USAGE:
%    pollySaveNRAttnBeta(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-09: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

missing_value = -999;

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

ncfile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_NR_att_bsc.nc', rmext(PollyDataInfo.pollyDataFile)));

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
varID_att_bsc_355 = netcdf.defVar(ncID, 'NR_attenuated_backscatter_355nm', 'NC_FLOAT', [dimID_height, dimID_time]);
varID_att_bsc_532 = netcdf.defVar(ncID, 'NR_attenuated_backscatter_532nm', 'NC_FLOAT', [dimID_height, dimID_time]);

% define the filling value
netcdf.defVarFill(ncID, varID_att_bsc_355, false, missing_value);
netcdf.defVarFill(ncID, varID_att_bsc_532, false, missing_value);

% define the data compression
netcdf.defVarDeflate(ncID, varID_att_bsc_355, true, true, 5);
netcdf.defVarDeflate(ncID, varID_att_bsc_532, true, true, 5);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, single(data.alt0));
netcdf.putVar(ncID, varID_longitude, single(data.lon));
netcdf.putVar(ncID, varID_latitude, single(data.lat));
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, single(data.height));
netcdf.putVar(ncID, varID_att_bsc_355, single(fillmissing(data.att_beta_NR_355, missing_value)));
netcdf.putVar(ncID, varID_att_bsc_532, single(fillmissing(data.att_beta_NR_532, missing_value)));

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
netcdf.putAtt(ncID, varID_att_bsc_355, 'long_name', 'near-field attenuated backscatter at 355 nm');
netcdf.putAtt(ncID, varID_att_bsc_355, 'standard_name', 'att_beta_355');
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_range', PollyConfig.zLim_att_beta_355/1e6);
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_355, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_355, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed355NR);
% netcdf.putAtt(ncID, varID_att_bsc_355, 'error_variable', 'att_beta_355_error');
% netcdf.putAtt(ncID, varID_att_bsc_355, 'bias_variable', 'att_beta_355_bias');
netcdf.putAtt(ncID, varID_att_bsc_355, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

% att_bsc_532
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_532, 'long_name', 'near-field attenuated backscatter at 532 nm');
netcdf.putAtt(ncID, varID_att_bsc_532, 'standard_name', 'att_beta_532');
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_range', PollyConfig.zLim_att_beta_532/1e6);
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_532, 'source', CampaignConfig.name);
netcdf.putAtt(ncID, varID_att_bsc_532, 'Lidar_calibration_constant_used', data.LCUsed.LCUsed532NR);
% netcdf.putAtt(ncID, varID_att_bsc_532, 'error_variable', 'att_beta_532_error');
% netcdf.putAtt(ncID, varID_att_bsc_532, 'bias_variable', 'att_beta_532_bias');
netcdf.putAtt(ncID, varID_att_bsc_532, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the concentration of aerosol and molecule backscatter.');

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
netcdf.putAtt(ncID, varID_global, 'title', 'near-field attenuated backscatter');
netcdf.putAtt(ncID, varID_global, 'comment', PollyConfig.comment);
cwd = pwd;
cd(PicassoConfig.PicassoRootDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

% close file
netcdf.close(ncID);

end