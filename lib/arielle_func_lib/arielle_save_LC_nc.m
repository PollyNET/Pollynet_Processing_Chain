function [] = arielle_save_LC_nc(data, taskInfo, config)
%arielle_save_LC_nc save the lidar constants.
%   Example:
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

LC_klett_532 = data.LC.LC_klett_532;
LC_klett_532(isnan(LC_klett_532)) = missingValue;
LC_raman_532 = data.LC.LC_raman_532;
LC_raman_532(isnan(LC_raman_532)) = missingValue;
LC_aeronet_532 = data.LC.LC_aeronet_532;
LC_aeronet_532(isnan(LC_aeronet_532)) = missingValue;

if isempty(data.cloudFreeGroups)
    return;
end

% Create .nc file by overwriting any existing file with the name filename
ncID = netcdf.create(saveFile, 'CLOBBER');

% define dimensions
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_datetime = netcdf.defVar(ncID, 'datetime', 'NC_DOUBLE', dimID_time);
varID_LC_klett_532 = netcdf.defVar(ncID, 'LC_klett_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_532 = netcdf.defVar(ncID, 'LC_raman_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_532 = netcdf.defVar(ncID, 'LC_aeronet_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_used_532 = netcdf.defVar(ncID, 'LCMean532nm', 'NC_DOUBLE', dimID_constant);
varID_LC_usedtag_532 = netcdf.defVar(ncID, 'LCMean532_flag', 'NC_SHORT', dimID_constant);
varID_LC_warning_532 = netcdf.defVar(ncID, 'LCMean532_warning', 'NC_SHORT', dimID_constant);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_datetime, transpose(mean(data.mTime(data.cloudFreeGroups), 2)));
netcdf.putVar(ncID, varID_LC_klett_532, LC_klett_532);
netcdf.putVar(ncID, varID_LC_raman_532, LC_raman_532);
netcdf.putVar(ncID, varID_LC_aeronet_532, LC_aeronet_532);
netcdf.putVar(ncID, varID_LC_used_532, data.LCUsed.LCUsed532);
netcdf.putVar(ncID, varID_LC_usedtag_532, data.LCUsed.LCUsedTag532);
netcdf.putVar(ncID, varID_LC_warning_532, int32(data.LCUsed.flagLCWarning532));

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_datetime, 'unit', 'datenum');
netcdf.putAtt(ncID, varID_datetime, 'long_name', 'medium datetime for each calibration period.');


netcdf.putAtt(ncID, varID_LC_klett_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_532, 'long_name', 'Lidar constant at 532 nm based on klett method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_klett_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_raman_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_532, 'long_name', 'Lidar constant at 532 nm based on raman method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_raman_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_aeronet_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'long_name', 'Lidar constant at 532 nm based on constrained-aod method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_used_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_532, 'long_name', 'Actual lidar constant at 532 nm in application. The constant value is aimed at 30-s profile.');

netcdf.putAtt(ncID, varID_LC_usedtag_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'long_name', 'The source of applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)');

netcdf.putAtt(ncID, varID_LC_warning_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_532, 'long_name', 'flag to show whether it is unstalbe for the calibration constants. (1: yes; 0: no)');

% global attributes
varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'location', globalAttri.location);
netcdf.putAtt(ncID, varID_global, 'institute', globalAttri.institute);
netcdf.putAtt(ncID, varID_global, 'version', globalAttri.version);
netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', globalAttri.contact));
 
% close file
netcdf.close(ncID);

end