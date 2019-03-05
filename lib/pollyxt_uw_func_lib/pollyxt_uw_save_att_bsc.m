function [] = pollyxt_uw_save_att_bsc(data, taskInfo, config)
%pollyxt_uw_save_att_bsc save the attenuated backscatter.
%   Example:
%       [] = pollyxt_uw_save_att_bsc(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-10. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

ncfile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_att_bsc.nc', rmext(taskInfo.dataFilename)));

ncID = netcdf.create(ncfile, 'clobber');

% define dimensions
dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
dimID_time = netcdf.defDim(ncID, 'time', length(data.mTime));

% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
varID_time = netcdf.defVar(ncID, 'time', 'NC_DOUBLE', dimID_time);
varID_att_bsc_355 = netcdf.defVar(ncID, 'attenuated_backscatter_355nm', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_att_bsc_532 = netcdf.defVar(ncID, 'attenuated_backscatter_532nm', 'NC_DOUBLE', [dimID_altitude, dimID_time]);
varID_att_bsc_1064 = netcdf.defVar(ncID, 'attenuated_backscatter_1064nm', 'NC_DOUBLE', [dimID_altitude, dimID_time]);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_altitude, data.alt);
netcdf.putVar(ncID, varID_time, data.mTime);
netcdf.putVar(ncID, varID_att_bsc_355, data.att_beta_355);
netcdf.putVar(ncID, varID_att_bsc_532, data.att_beta_532);
netcdf.putVar(ncID, varID_att_bsc_1064, data.att_beta_1064);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height (above surface)');
netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

netcdf.putAtt(ncID, varID_time, 'unit', 'days after Jan 0000');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');

netcdf.putAtt(ncID, varID_att_bsc_355, 'unit', 'Mm^{-1}*Sr^{-1}');
netcdf.putAtt(ncID, varID_att_bsc_355, 'long_name', 'attenuated backscatter coefficient at 355 nm');
netcdf.putAtt(ncID, varID_att_bsc_355, 'standard_name', 'att_beta_355');
netcdf.putAtt(ncID, varID_att_bsc_355, 'comment', 'This parameter is calculate with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

netcdf.putAtt(ncID, varID_att_bsc_532, 'unit', 'Mm^{-1}*Sr^{-1}');
netcdf.putAtt(ncID, varID_att_bsc_532, 'long_name', 'attenuated backscatter coefficient at 532 nm');
netcdf.putAtt(ncID, varID_att_bsc_532, 'standard_name', 'att_beta_532');
netcdf.putAtt(ncID, varID_att_bsc_532, 'comment', 'This parameter is calculate with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

netcdf.putAtt(ncID, varID_att_bsc_1064, 'unit', 'Mm^{-1}*Sr^{-1}');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'long_name', 'attenuated backscatter coefficient at 1064 nm');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'standard_name', 'att_beta_1064');
netcdf.putAtt(ncID, varID_att_bsc_1064, 'comment', 'This parameter is calculate with taking into account of the effects of lidar constants. Therefore, it reflects the strength of aerosol and molecule backscatter.');

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