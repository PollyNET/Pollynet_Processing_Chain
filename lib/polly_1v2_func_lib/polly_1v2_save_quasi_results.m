function [] = polly_1v2_save_quasi_results(data, taskInfo, config)
%polly_1v2_save_quasi_results Saving the target classification results to netcdf file.
%   Example:
%       [] = polly_1v2_save_quasi_results(data, config)
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
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_quasi_results.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_quasi_bsc_532 = netcdf.defVar(ncID, 'quasi_bsc_532', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_quasi_pardepol_532 = netcdf.defVar(ncID, 'quasi_pardepol_532', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_quality_mask_532 = netcdf.defVar(ncID, 'quality_mask_532', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_quality_mask_voldepol_532 = netcdf.defVar(ncID, 'quality_mask_voldepol_532', 'NC_DOUBLE', [dimID_altitude, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt);
netcdf.putVar(ncID, varID_time, data.mTime);
netcdf.putVar(ncID, varID_quasi_bsc_532, data.quasi_par_beta_532);
netcdf.putVar(ncID, varID_quasi_pardepol_532, data.quasi_parDepol_532);
netcdf.putVar(ncID, varID_quality_mask_532, data.quality_mask_532);
netcdf.putVar(ncID, varID_quality_mask_voldepol_532, data.quality_mask_volDepol_532);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height (above surface)');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

netcdf.putAtt(ncID, varID_time, 'unit', 'days after Jan 0000');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');

netcdf.putAtt(ncID, varID_quasi_bsc_532, 'unit', 'm^{-1}*Sr^{-1}');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'long_name', 'quasi aerosol backscatter coefficients at 532 nm');
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]', config.LR532));
netcdf.putAtt(ncID, varID_quasi_bsc_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin. If the AOD is greater than 0.2, the relative uncertainty can be as large as 20%. Be careful about that!');

netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'unit', '');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'long_name', 'quasi particle depolarization ratio at 532 nm');
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'retrieved_info', sprintf('Fixed Lidar ratio: %5.1f[Sr]; Depolarization calibration factor is %f.', config.LR532, data.depol_cal_fac_532));
netcdf.putAtt(ncID, varID_quasi_pardepol_532, 'comment', 'This parameter is retrieved by the method demonstrated in (Holger, ATM, 2017). The retrieved results are dependent on the lidar constants and the AOD below the current bin.');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
    
% close file
netcdf.close(ncID);

end