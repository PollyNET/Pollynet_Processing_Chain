function [] = pollyxt_noa_save_att_bsc(data, taskInfo, config)
%pollyxt_noa_save_att_bsc save the attenuated backscatter.
%   Example:
%       [] = pollyxt_noa_save_att_bsc(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-10. First Edition by Zhenping
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

missing_value = -999;

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_att_bsc.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

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

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_att_bsc_355, fillmissing(data.att_beta_355, missing_value));
netcdf.putVar(ncID, varID_att_bsc_532, fillmissing(data.att_beta_532, missing_value));
netcdf.putVar(ncID, varID_att_bsc_1064, fillmissing(data.att_beta_1064, missing_value));

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
netcdf.putAtt(ncID, varID_att_bsc_355, '_FillValue', missing_value);
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_range', config.att_beta_cRange_355/1e6);
netcdf.putAtt(ncID, varID_att_bsc_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_355, 'source', campaignInfo.name);
% netcdf.putAtt(ncID, varID_att_bsc_355, 'error_variable', 'att_beta_355_error');
% netcdf.putAtt(ncID, varID_att_bsc_355, 'bias_variable', 'att_beta_355_bias');
netcdf.putAtt(ncID, varID_att_bsc_355, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

% att_bsc_532
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_532, 'long_name', 'attenuated backscatter at 532 nm');
netcdf.putAtt(ncID, varID_att_bsc_532, 'standard_name', 'att_beta_532');
netcdf.putAtt(ncID, varID_att_bsc_532, '_FillValue', missing_value);
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_range', config.att_beta_cRange_532/1e6);
netcdf.putAtt(ncID, varID_att_bsc_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_532, 'source', campaignInfo.name);
% netcdf.putAtt(ncID, varID_att_bsc_532, 'error_variable', 'att_beta_532_error');
% netcdf.putAtt(ncID, varID_att_bsc_532, 'bias_variable', 'att_beta_532_bias');
netcdf.putAtt(ncID, varID_att_bsc_532, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

% att_bsc_1064
netcdf.putAtt(ncID, varID_att_bsc_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'long_name', 'attenuated backscatter at 1064 nm');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'standard_name', 'att_beta_1064');
netcdf.putAtt(ncID, varID_att_bsc_1064, '_FillValue', missing_value);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_range', config.att_beta_cRange_1064/1e6);
netcdf.putAtt(ncID, varID_att_bsc_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'source', campaignInfo.name);
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'error_variable', 'att_beta_1064_error');
% netcdf.putAtt(ncID, varID_att_bsc_1064, 'bias_variable', 'att_beta_1064_bias');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'comment', 'This parameter is calculated with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'reference', processInfo.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
cwd = pwd;
cd(config.projectDir);
gitInfo = getGitInfo();
cd(cwd);
netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));
    
% close file
netcdf.close(ncID);

end