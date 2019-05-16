function [] = pollyxt_lacros_save_LC_nc(data, taskInfo, config)
%pollyxt_lacros_save_LC_nc save the lidar constants.
%   Example:
%       pollyxt_lacros_save_LC_nc(data, LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064, file, globalAttri)
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
%       2018-12-24. First Edition by Zhenping
%       2019-01-28. Add support for 387 and 607 channels.
%       2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS convention.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

saveFile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_lc.nc', datestr(taskInfo.dataTime, 'yyyy_mm_dd_HH_MM_SS'), taskInfo.pollyVersion));
globalAttri = struct();
globalAttri.location = campaignInfo.location;
globalAttri.institute = processInfo.institute;
globalAttri.contact = processInfo.contact;
globalAttri.version = processInfo.programVersion;

missingValue = -999;

LC_klett_355 = data.LC.LC_klett_355;
LC_klett_355(isnan(LC_klett_355)) = missingValue;
LC_klett_532 = data.LC.LC_klett_532;
LC_klett_532(isnan(LC_klett_532)) = missingValue;
LC_klett_1064 = data.LC.LC_klett_1064;
LC_klett_1064(isnan(LC_klett_1064)) = missingValue;
LC_raman_355 = data.LC.LC_raman_355;
LC_raman_355(isnan(LC_raman_355)) = missingValue;
LC_raman_532 = data.LC.LC_raman_532;
LC_raman_532(isnan(LC_raman_532)) = missingValue;
LC_raman_1064 = data.LC.LC_raman_1064;
LC_raman_1064(isnan(LC_raman_1064)) = missingValue;
LC_aeronet_355 = data.LC.LC_aeronet_355;
LC_aeronet_355(isnan(LC_aeronet_355)) = missingValue;
LC_aeronet_532 = data.LC.LC_aeronet_532;
LC_aeronet_532(isnan(LC_aeronet_532)) = missingValue;
LC_aeronet_1064 = data.LC.LC_aeronet_1064;
LC_aeronet_1064(isnan(LC_aeronet_1064)) = missingValue; 
LC_raman_387 = data.LC.LC_raman_387;
LC_raman_387(isnan(LC_raman_387)) = missingValue;
LC_raman_607 = data.LC.LC_raman_607;
LC_raman_607(isnan(LC_raman_607)) = missingValue;

if isempty(data.cloudFreeGroups)
    return;
end

% Create .nc file by overwriting any existing file with the name filename
ncID = netcdf.create(saveFile, 'CLOBBER');

% define dimensions
dimID_time = netcdf.defDim(ncID, 'time', numel(LC_klett_355));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

%% define variables
varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_constant);
varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_constant);
varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_constant);
varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_constant);
varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_constant);
varID_datetime = netcdf.defVar(ncID, 'datetime', 'NC_DOUBLE', dimID_time);
varID_LC_klett_355 = netcdf.defVar(ncID, 'LC_klett_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_klett_532 = netcdf.defVar(ncID, 'LC_klett_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_klett_1064 = netcdf.defVar(ncID, 'LC_klett_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_355 = netcdf.defVar(ncID, 'LC_raman_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_532 = netcdf.defVar(ncID, 'LC_raman_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_1064 = netcdf.defVar(ncID, 'LC_raman_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_387 = netcdf.defVar(ncID, 'LC_raman_387nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_607 = netcdf.defVar(ncID, 'LC_raman_607nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_355 = netcdf.defVar(ncID, 'LC_aeronet_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_532 = netcdf.defVar(ncID, 'LC_aeronet_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_1064 = netcdf.defVar(ncID, 'LC_aeronet_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_used_355 = netcdf.defVar(ncID, 'LCMean355nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_532 = netcdf.defVar(ncID, 'LCMean532nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_1064 = netcdf.defVar(ncID, 'LCMean1064nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_387 = netcdf.defVar(ncID, 'LCMean387nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_607 = netcdf.defVar(ncID, 'LCMean607nm', 'NC_DOUBLE', dimID_constant);
varID_LC_usedtag_355 = netcdf.defVar(ncID, 'LCMean355_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_532 = netcdf.defVar(ncID, 'LCMean532_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_1064 = netcdf.defVar(ncID, 'LCMean1064_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_387 = netcdf.defVar(ncID, 'LCMean387_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_607 = netcdf.defVar(ncID, 'LCMean607_flag', 'NC_SHORT', dimID_constant);
varID_LC_warning_355 = netcdf.defVar(ncID, 'LCMean355_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_532 = netcdf.defVar(ncID, 'LCMean532_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_1064 = netcdf.defVar(ncID, 'LCMean1064_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_387 = netcdf.defVar(ncID, 'LCMean387_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_607 = netcdf.defVar(ncID, 'LCMean607_warning', 'NC_SHORT', dimID_constant);

% leave define mode
netcdf.endDef(ncID);

%% write data to .nc file
netcdf.putVar(ncID, varID_datetime, datenum_2_unix_timestamp(transpose(mean(data.mTime(data.cloudFreeGroups), 2))));
netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(data.mTime(1)));
netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(data.mTime(end)));
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_altitude, data.alt0);
netcdf.putVar(ncID, varID_longitude, data.lon);
netcdf.putVar(ncID, varID_latitude, data.lat);
netcdf.putVar(ncID, varID_LC_klett_355, LC_klett_355);
netcdf.putVar(ncID, varID_LC_klett_532, LC_klett_532);
netcdf.putVar(ncID, varID_LC_klett_1064, LC_klett_1064);
netcdf.putVar(ncID, varID_LC_raman_355, LC_raman_355);
netcdf.putVar(ncID, varID_LC_raman_532, LC_raman_532);
netcdf.putVar(ncID, varID_LC_raman_1064, LC_raman_1064);
netcdf.putVar(ncID, varID_LC_raman_387, LC_raman_387);
netcdf.putVar(ncID, varID_LC_raman_607, LC_raman_607);
netcdf.putVar(ncID, varID_LC_aeronet_355, LC_aeronet_355);
netcdf.putVar(ncID, varID_LC_aeronet_532, LC_aeronet_532);
netcdf.putVar(ncID, varID_LC_aeronet_1064, LC_aeronet_1064);
netcdf.putVar(ncID, varID_LC_used_355, data.LCUsed.LCUsed355);
netcdf.putVar(ncID, varID_LC_used_532, data.LCUsed.LCUsed532);
netcdf.putVar(ncID, varID_LC_used_1064, data.LCUsed.LCUsed1064);
netcdf.putVar(ncID, varID_LC_used_387, data.LCUsed.LCUsed387);
netcdf.putVar(ncID, varID_LC_used_607, data.LCUsed.LCUsed607);
netcdf.putVar(ncID, varID_LC_usedtag_355, data.LCUsed.LCUsedTag355);
netcdf.putVar(ncID, varID_LC_usedtag_532, data.LCUsed.LCUsedTag532);
netcdf.putVar(ncID, varID_LC_usedtag_1064, data.LCUsed.LCUsedTag1064);
netcdf.putVar(ncID, varID_LC_usedtag_387, data.LCUsed.LCUsedTag387);
netcdf.putVar(ncID, varID_LC_usedtag_607, data.LCUsed.LCUsedTag607);
netcdf.putVar(ncID, varID_LC_warning_355, int32(data.LCUsed.flagLCWarning355));
netcdf.putVar(ncID, varID_LC_warning_532, int32(data.LCUsed.flagLCWarning532));
netcdf.putVar(ncID, varID_LC_warning_1064, int32(data.LCUsed.flagLCWarning1064));
netcdf.putVar(ncID, varID_LC_usedtag_387, data.LCUsed.LCUsedTag387);
netcdf.putVar(ncID, varID_LC_usedtag_607, data.LCUsed.LCUsedTag607);

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
netcdf.putAtt(ncID, varID_latitude, 'axis', 'Y');cID, varID_latitude, 'axis', 'Y');

% start_time
netcdf.putAtt(ncID, varID_startTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_startTime, 'long_name', 'Time UTC to start the current measurement');
netcdf.putAtt(ncID, varID_startTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_startTime, 'calendar', 'julian');

% end_time
netcdf.putAtt(ncID, varID_endTime, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_endTime, 'long_name', 'Time UTC to finish the current measurement');
netcdf.putAtt(ncID, varID_endTime, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_endTime, 'calendar', 'julian');

% time
netcdf.putAtt(ncID, varID_time, 'unit', 'seconds since 1970-01-01 00:00:00 UTC');
netcdf.putAtt(ncID, varID_time, 'long_name', 'Time UTC');
netcdf.putAtt(ncID, varID_time, 'standard_name', 'time');
netcdf.putAtt(ncID, varID_time, 'axis', 'T');
netcdf.putAtt(ncID, varID_time, 'calendar', 'julian');

% LC_klett_355
netcdf.putAtt(ncID, varID_LC_klett_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_355, 'long_name', 'Lidar constant at 355 nm with Klett method');
netcdf.putAtt(ncID, varID_LC_klett_355, 'standard_name', 'LC_klett_355');
netcdf.putAtt(ncID, varID_LC_klett_355, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_klett_355, 'plot_range', config.LC355Range);
netcdf.putAtt(ncID, varID_LC_klett_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_klett_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_klett_355, 'comment', 'Lidar constant at 355 nm based on klett method. The constant value is aimed at 30-s profile.');

% LC_klett_532
netcdf.putAtt(ncID, varID_LC_klett_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_532, 'long_name', 'Lidar constant at 532 nm with Klett method');
netcdf.putAtt(ncID, varID_LC_klett_532, 'standard_name', 'LC_klett_532');
netcdf.putAtt(ncID, varID_LC_klett_532, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_klett_532, 'plot_range', config.LC532Range);
netcdf.putAtt(ncID, varID_LC_klett_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_klett_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_klett_532, 'comment', 'Lidar constant at 532 nm based on klett method. The constant value is aimed at 30-s profile.');

% LC_klett_1064
netcdf.putAtt(ncID, varID_LC_klett_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_1064, 'long_name', 'Lidar constant at 1064 nm with Klett method');
netcdf.putAtt(ncID, varID_LC_klett_1064, 'standard_name', 'LC_klett_1064');
netcdf.putAtt(ncID, varID_LC_klett_1064, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_klett_1064, 'plot_range', config.LC1064Range);
netcdf.putAtt(ncID, varID_LC_klett_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_klett_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_klett_1064, 'comment', 'Lidar constant at 1064 nm based on klett method. The constant value is aimed at 30-s profile.');

% LC_raman_355
netcdf.putAtt(ncID, varID_LC_raman_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_355, 'long_name', 'Lidar constant at 355 nm with Raman method');
netcdf.putAtt(ncID, varID_LC_raman_355, 'standard_name', 'LC_raman_355');
netcdf.putAtt(ncID, varID_LC_raman_355, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_raman_355, 'plot_range', config.LC355Range);
netcdf.putAtt(ncID, varID_LC_raman_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_raman_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_raman_355, 'comment', 'Lidar constant at 355 nm based on raman method. The constant value is aimed at 30-s profile.');

% LC_raman_532
netcdf.putAtt(ncID, varID_LC_raman_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_532, 'long_name', 'Lidar constant at 532 nm with Raman method');
netcdf.putAtt(ncID, varID_LC_raman_532, 'standard_name', 'LC_raman_532');
netcdf.putAtt(ncID, varID_LC_raman_532, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_raman_532, 'plot_range', config.LC532Range);
netcdf.putAtt(ncID, varID_LC_raman_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_raman_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_raman_532, 'comment', 'Lidar constant at 532 nm based on raman method. The constant value is aimed at 30-s profile.');

% LC_raman_1064
netcdf.putAtt(ncID, varID_LC_raman_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_1064, 'long_name', 'Lidar constant at 1064 nm with Raman method');
netcdf.putAtt(ncID, varID_LC_raman_1064, 'standard_name', 'LC_raman_1064');
netcdf.putAtt(ncID, varID_LC_raman_1064, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_raman_1064, 'plot_range', config.LC1064Range);
netcdf.putAtt(ncID, varID_LC_raman_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_raman_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_raman_1064, 'comment', 'Lidar constant at 1064 nm based on raman method. The constant value is aimed at 30-s profile.');

% LC_raman_387
netcdf.putAtt(ncID, varID_LC_raman_387, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_387, 'long_name', 'Lidar constant at 387 nm with Raman method');
netcdf.putAtt(ncID, varID_LC_raman_387, 'standard_name', 'LC_raman_387');
netcdf.putAtt(ncID, varID_LC_raman_387, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_raman_387, 'plot_range', config.LC387Range);
netcdf.putAtt(ncID, varID_LC_raman_387, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_raman_387, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_raman_387, 'comment', 'Lidar constant at 387 nm based on raman method. The constant value is aimed at 30-s profile.');

% LC_raman_607
netcdf.putAtt(ncID, varID_LC_raman_607, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_607, 'long_name', 'Lidar constant at 607 nm with Raman method');
netcdf.putAtt(ncID, varID_LC_raman_607, 'standard_name', 'LC_raman_607');
netcdf.putAtt(ncID, varID_LC_raman_607, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_raman_607, 'plot_range', config.LC607Range);
netcdf.putAtt(ncID, varID_LC_raman_607, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_raman_607, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_raman_607, 'comment', 'Lidar constant at 607 nm based on raman method. The constant value is aimed at 30-s profile.');

% LC_aeronet_355
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'long_name', 'Lidar constant at 355 nm with Constrained-AOD method');
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'standard_name', 'LC_aeronet_355');
netcdf.putAtt(ncID, varID_LC_aeronet_355, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'plot_range', config.LC355Range);
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'comment', 'Lidar constant at 355 nm based on Constrained-AOD method. The constant value is aimed at 30-s profile.');

% LC_aeronet_532
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'long_name', 'Lidar constant at 532 nm with Constrained-AOD method');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'standard_name', 'LC_aeronet_532');
netcdf.putAtt(ncID, varID_LC_aeronet_532, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'plot_range', config.LC532Range);
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'comment', 'Lidar constant at 532 nm based on Constrained-AOD method. The constant value is aimed at 30-s profile.');

% LC_aeronet_1064
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'long_name', 'Lidar constant at 1064 nm with Constrained-AOD method');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'standard_name', 'LC_aeronet_1064');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'plot_range', config.LC1064Range);
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'comment', 'Lidar constant at 1064 nm based on Constrained-AOD method. The constant value is aimed at 30-s profile.');

% LC_used_355
netcdf.putAtt(ncID, varID_LC_used_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_355, 'long_name', 'Actual lidar constant at 355 nm in application.');
netcdf.putAtt(ncID, varID_LC_used_355, 'standard_name', 'LC_used_355');
netcdf.putAtt(ncID, varID_LC_used_355, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_used_355, 'plot_range', config.LC355Range);
netcdf.putAtt(ncID, varID_LC_used_355, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_used_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_used_355, 'comment', 'The constant value is aimed at 30-s profile.');

% LC_used_532
netcdf.putAtt(ncID, varID_LC_used_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_532, 'long_name', 'Actual lidar constant at 532 nm in application.');
netcdf.putAtt(ncID, varID_LC_used_532, 'standard_name', 'LC_used_532');
netcdf.putAtt(ncID, varID_LC_used_532, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_used_532, 'plot_range', config.LC532Range);
netcdf.putAtt(ncID, varID_LC_used_532, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_used_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_used_532, 'comment', 'The constant value is aimed at 30-s profile.');

% LC_used_1064
netcdf.putAtt(ncID, varID_LC_used_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_1064, 'long_name', 'Actual lidar constant at 1064 nm in application.');
netcdf.putAtt(ncID, varID_LC_used_1064, 'standard_name', 'LC_used_1064');
netcdf.putAtt(ncID, varID_LC_used_1064, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_used_1064, 'plot_range', config.LC1064Range);
netcdf.putAtt(ncID, varID_LC_used_1064, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_used_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_used_1064, 'comment', 'The constant value is aimed at 30-s profile.');

% LC_used_387
netcdf.putAtt(ncID, varID_LC_used_387, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_387, 'long_name', 'Actual lidar constant at 387 nm in application.');
netcdf.putAtt(ncID, varID_LC_used_387, 'standard_name', 'LC_used_387');
netcdf.putAtt(ncID, varID_LC_used_387, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_used_387, 'plot_range', config.LC387Range);
netcdf.putAtt(ncID, varID_LC_used_387, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_used_387, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_used_387, 'comment', 'The constant value is aimed at 30-s profile.');

% LC_used_607
netcdf.putAtt(ncID, varID_LC_used_607, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_607, 'long_name', 'Actual lidar constant at 607 nm in application.');
netcdf.putAtt(ncID, varID_LC_used_607, 'standard_name', 'LC_used_607');
netcdf.putAtt(ncID, varID_LC_used_607, '_FillValue', missingValue);
netcdf.putAtt(ncID, varID_LC_used_607, 'plot_range', config.LC607Range);
netcdf.putAtt(ncID, varID_LC_used_607, 'plot_scale', 'linear');
netcdf.putAtt(ncID, varID_LC_used_607, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_used_607, 'comment', 'The constant value is aimed at 30-s profile.');

% LC_usedtag_355
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'long_name', 'Actual lidar constant at 355 nm in application.');
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'standard_name', 'LC_usedtag_355');
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'definition', '0: no calibration; 1: klett; 2: raman; 3: defaults');

% LC_usedtag_532
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'long_name', 'Actual lidar constant at 532 nm in application.');
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'standard_name', 'LC_usedtag_532');
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'definition', '0: no calibration; 1: klett; 2: raman; 3: defaults');

% LC_usedtag_1064
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'long_name', 'Actual lidar constant at 1064 nm in application.');
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'standard_name', 'LC_usedtag_1064');
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'definition', '0: no calibration; 1: klett; 2: raman; 3: defaults');

% LC_usedtag_387
netcdf.putAtt(ncID, varID_LC_usedtag_387, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_387, 'long_name', 'Actual lidar constant at 387 nm in application.');
netcdf.putAtt(ncID, varID_LC_usedtag_387, 'standard_name', 'LC_usedtag_387');
netcdf.putAtt(ncID, varID_LC_usedtag_387, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_usedtag_387, 'definition', '0: no calibration; 1: klett; 2: raman; 3: defaults');

% LC_usedtag_607
netcdf.putAtt(ncID, varID_LC_usedtag_607, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_607, 'long_name', 'Actual lidar constant at 607 nm in application.');
netcdf.putAtt(ncID, varID_LC_usedtag_607, 'standard_name', 'LC_usedtag_607');
netcdf.putAtt(ncID, varID_LC_usedtag_607, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_usedtag_607, 'definition', '0: no calibration; 1: klett; 2: raman; 3: defaults');

% LC_warning_355
netcdf.putAtt(ncID, varID_LC_warning_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_355, 'long_name', 'flag to show whether the calibration constants is unstalbe.');
netcdf.putAtt(ncID, varID_LC_warning_355, 'standard_name', 'LC_warning_355');
netcdf.putAtt(ncID, varID_LC_warning_355, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_warning_355, 'definition', '1: yes; 0: no');

% LC_warning_532
netcdf.putAtt(ncID, varID_LC_warning_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_532, 'long_name', 'flag to show whether the calibration constants is unstalbe.');
netcdf.putAtt(ncID, varID_LC_warning_532, 'standard_name', 'LC_warning_532');
netcdf.putAtt(ncID, varID_LC_warning_532, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_warning_532, 'definition', '1: yes; 0: no');

% LC_warning_1064
netcdf.putAtt(ncID, varID_LC_warning_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_1064, 'long_name', 'flag to show whether the calibration constants is unstalbe.');
netcdf.putAtt(ncID, varID_LC_warning_1064, 'standard_name', 'LC_warning_1064');
netcdf.putAtt(ncID, varID_LC_warning_1064, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_warning_1064, 'definition', '1: yes; 0: no');

% LC_warning_387
netcdf.putAtt(ncID, varID_LC_warning_387, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_387, 'long_name', 'flag to show whether the calibration constants is unstalbe.');
netcdf.putAtt(ncID, varID_LC_warning_387, 'standard_name', 'LC_warning_387');
netcdf.putAtt(ncID, varID_LC_warning_387, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_warning_387, 'definition', '1: yes; 0: no');

% LC_warning_607
netcdf.putAtt(ncID, varID_LC_warning_607, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_607, 'long_name', 'flag to show whether the calibration constants is unstalbe.');
netcdf.putAtt(ncID, varID_LC_warning_607, 'standard_name', 'LC_warning_607');
netcdf.putAtt(ncID, varID_LC_warning_607, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_LC_warning_607, 'definition', '1: yes; 0: no');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
netcdf.putAtt(ncID, varID_global, 'source', taskInfo.pollyVersion);
netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
netcdf.putAtt(ncID, varID_global, 'reference', processInfo.homepage);
netcdf.putAtt(ncID, varID_global, 'contact', processInfo.contact);
    
% close file
netcdf.close(ncID);

end