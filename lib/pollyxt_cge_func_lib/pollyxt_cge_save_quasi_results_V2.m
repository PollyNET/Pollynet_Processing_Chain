function [] = pollyxt_cge_save_quasi_results_V2(data, taskInfo, config)
%pollyxt_cge_save_quasi_results_V2 Saving the quasi retrieving results (V2) to netcdf file.
%   Example:
%       [] = pollyxt_cge_save_quasi_results_V2(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       
%   History:
%       2019-08-03. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_quasi_results_V2.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_quasi_bsc_532 = netcdf.defVar(ncID, 'quasi_bsc_532', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quasi_bsc_1064 = netcdf.defVar(ncID, 'quasi_bsc_1064', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quasi_pardepol_532 = netcdf.defVar(ncID, 'quasi_pardepol_532', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quasi_ang_532_1064 = netcdf.defVar(ncID, 'quasi_ang_532_1064', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_532 = netcdf.defVar(ncID, 'quality_mask_532', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_1064 = netcdf.defVar(ncID, 'quality_mask_1064', 'NC_DOUBLE', [dimID_height, dimID_time]);
varID_quality_mask_voldepol_532 = netcdf.defVar(ncID, 'quality_mask_voldepol_532', 'NC_DOUBLE', [dimID_height, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_time, datenum_2_unix_timestamp(data.mTime));   % do the conversion
netcdf.putVar(ncID, varID_height, data.height);
netcdf.putVar(ncID, varID_quasi_bsc_532, data.quasi_par_beta_532_V2);
netcdf.putVar(ncID, varID_quasi_bsc_1064, data.quasi_par_beta_1064_V2);
netcdf.putVar(ncID, varID_quasi_pardepol_532, data.quasi_parDepol_532_V2);
netcdf.putVar(ncID, varID_quasi_ang_532_1064, data.quasi_ang_532_1064_V2);
netcdf.putVar(ncID, varID_quality_mask_532, data.quality_mask_532_V2);
netcdf.putVar(ncID, varID_quality_mask_1064, data.quality_mask_1064_V2);
netcdf.putVar(ncID, varID_quality_mask_voldepol_532, data.quality_mask_volDepol_532_V2);

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
netcdf.putAtt(ncID, varID_quasi_bsc_532, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'plot_range', config.quasi_beta_cRange_532/1e6);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'error_variable', 'quasi_beta_532_error');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'bias_variable', 'quasi_beta_532_bias');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]', config.LR532));
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. If the AOD is greater than 0.2, the relative uncertainty can be as large as 20%. Be careful about that!');

% quasi_bsc_1064
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'unit', 'sr^-1 m^-1');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'long_name', 'quasi aerosol backscatter coefficients at 1064 nm');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'standard_name', 'quasi_bsc_1064');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'plot_range', config.quasi_beta_cRange_1064/1e6);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'error_variable', 'quasi_beta_1064_error');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'bias_variable', 'quasi_beta_1064_bias');
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]', config.LR1064));
netcdf.putAtt(ncID, varID_quasi_bsc_1064, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. If the AOD is greater than 0.2, the relative uncertainty can be as large as 20%. Be careful about that!');

% quasi_pardepol_532
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'unit', '');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'long_name', 'quasi particle depolarization ratio at 532 nm');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'standard_name', 'quasi_pardepol_532');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'plot_range', config.quasi_Par_DR_cRange_532);
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'error_variable', 'quasi_pardepol_532_error');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'bias_variable', 'quasi_pardepol_532_bias');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]; Depolarization calibration factor is %f.', config.LR532, data.depol_cal_fac_532));
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin.');

% quasi_ang_532_1064
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'unit', '');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'long_name', 'quasi backscatter-related angstroem exponent at 532-1064');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'standard_name', 'quasi_ang_532_1064');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, '_FillValue', -999.0);
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'plot_range', [0, 2]);
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'source', campaignInfo.name);
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'error_variable', 'quasi_ang_532_1064_error');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'bias_variable', 'quasi_ang_532_1064_bias');
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr] at 532 nm, %5.1f[Sr] at 1064 nm.', config.LR532, config.LR1064));
netcdf.putAtt(ncID, varID_quasi_ang_532_1064, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. Be careful about that!');

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