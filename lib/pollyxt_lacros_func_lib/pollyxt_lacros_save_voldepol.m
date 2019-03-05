function [] = pollyxt_lacros_save_voldepol(data, taskInfo, config)
%pollyxt_lacros_save_voldepol save the attenuated backscatter.
%   Example:
%       [] = pollyxt_lacros_save_voldepol(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-10. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_vol_depol.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_voldepol_355 = netcdf.defVar(ncID, 'volume_depolarization_ratio_355nm', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_voldepol_532 = netcdf.defVar(ncID, 'volume_depolarization_ratio_532nm', 'NC_DOUBLE', [dimID_altitude, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt);
netcdf.putVar(ncID, varID_time, data.mTime);
netcdf.putVar(ncID, varID_voldepol_355, data.volDepol_355);
netcdf.putVar(ncID, varID_voldepol_532, data.volDepol_532);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height (above surface)');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

netcdf.putAtt(ncID, varID_time, 'unit', 'days after Jan 0000');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');

netcdf.putAtt(ncID, varID_voldepol_355, 'unit', '');
netcdf.putAtt(ncID, varID_voldepol_355, 'long_name', 'volume depolarization ratio at 355 nm');
netcdf.putAtt(ncID, varID_voldepol_355, 'standard_name', 'voldepol_355');
netcdf.putAtt(ncID, varID_voldepol_355, 'comment', 'The depolarized channel was calibrated with \pm 45\circ method.');

netcdf.putAtt(ncID, varID_voldepol_532, 'unit', '');
netcdf.putAtt(ncID, varID_voldepol_532, 'long_name', 'volume depolarization ratio at 532 nm');
netcdf.putAtt(ncID, varID_voldepol_532, 'standard_name', 'voldepol_532');
netcdf.putAtt(ncID, varID_voldepol_532, 'comment', 'The depolarized channel was calibrated with \pm 45\circ method.');

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