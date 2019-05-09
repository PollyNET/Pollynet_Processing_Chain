function [] = pollyxt_fmi_save_WVMR_RH(data, taskInfo, config)
%pollyxt_fmi_save_WVMR_RH save the water vapor mixing ratio and relative humidity.
%   Example:
%       [] = pollyxt_fmi_save_WVMR_RH(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-03-15. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_WVMR_RH.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_RH = netcdf.defVar(ncID, 'RH', 'NC_DOUBLE', [dimID_altitude, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt);
netcdf.putVar(ncID, varID_time, data.mTime);
netcdf.putVar(ncID, varID_WVMR, data.WVMR);
netcdf.putVar(ncID, varID_RH, data.RH);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height (above surface)');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

netcdf.putAtt(ncID, varID_time, 'unit', 'days after Jan 0000');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');

netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g*kg^{-1}');
netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'water vapor mixing ratio');
netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
netcdf.putAtt(ncID, varID_WVMR, 'comment', sprintf('The water vapor channel was calibrated using IWV from %s.', config.IWV_instrument));

netcdf.putAtt(ncID, varID_RH, 'unit', '%');
netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
netcdf.putAtt(ncID, varID_RH, 'comment', sprintf('The water vapor channel was calibrated using IWV from %s.', config.IWV_instrument));

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