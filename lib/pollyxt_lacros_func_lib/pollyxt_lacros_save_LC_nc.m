function [] = pollyxt_lacros_save_LC_nc(data, LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064, file, globalAttri)
%pollyxt_lacros_save_LC_nc save the lidar constants.
%   Example:
%       pollyxt_lacros_save_LC_nc(data, LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064, file, globalAttri)
%   Inputs:
%       data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       LCUsed355: float
%           applied lidar constant at 355 nm for target classification.
%       LCUsedTag355: integer
%           source of the applied lidar constant at 355 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)
%       flagLCWarning355: integer
%           flag to show whether the lidar constants is very unstable.
%       LCUsed532: float
%           applied lidar constant at 532 nm for target classification.
%       LCUsedTag532: integer
%           source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)
%       flagLCWarning532: integer
%           flag to show whether the lidar constants is very unstable.
%       LCUsed1064: float
%           applied lidar constant at 1064 nm for target classification.
%       LCUsedTag1064: integer
%           source of the applied lidar constant at 1064 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)
%       flagLCWarning1064: integer
%           flag to show whether the lidar constants is very unstable.
%       file: char
%           netcdf file to save the results.
%       globalAttri: struct          
%           location: char
%               location of the current polly system.
%           institute: char
%           contact: char
%           version: char
%   Outputs:
%       
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

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

% Create .nc file by overwriting any existing file with the name filename
ncID = netcdf.create(file, 'CLOBBER');

% define dimensions
dimID_time = netcdf.defDim(ncID, 'time', numel(LC_klett_355));
dimID_constant = netcdf.defDim(ncID, 'constant', 1);

% define variables
varID_datetime = netcdf.defVar(ncID, 'datetime', 'NC_DOUBLE', dimID_time);
varID_LC_klett_355 = netcdf.defVar(ncID, 'LC_klett_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_klett_532 = netcdf.defVar(ncID, 'LC_klett_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_klett_1064 = netcdf.defVar(ncID, 'LC_klett_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_355 = netcdf.defVar(ncID, 'LC_raman_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_532 = netcdf.defVar(ncID, 'LC_raman_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_raman_1064 = netcdf.defVar(ncID, 'LC_raman_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_355 = netcdf.defVar(ncID, 'LC_aeronet_355nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_532 = netcdf.defVar(ncID, 'LC_aeronet_532nm', 'NC_DOUBLE', dimID_time);
varID_LC_aeronet_1064 = netcdf.defVar(ncID, 'LC_aeronet_1064nm', 'NC_DOUBLE', dimID_time);
varID_LC_used_355 = netcdf.defVar(ncID, 'LCMean355nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_532 = netcdf.defVar(ncID, 'LCMean532nm', 'NC_DOUBLE', dimID_constant);
varID_LC_used_1064 = netcdf.defVar(ncID, 'LCMean1064nm', 'NC_DOUBLE', dimID_constant);
varID_LC_usedtag_355 = netcdf.defVar(ncID, 'LCMean355_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_532 = netcdf.defVar(ncID, 'LCMean532_flag', 'NC_SHORT', dimID_constant);
varID_LC_usedtag_1064 = netcdf.defVar(ncID, 'LCMean1064_flag', 'NC_SHORT', dimID_constant);
varID_LC_warning_355 = netcdf.defVar(ncID, 'LCMean355_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_532 = netcdf.defVar(ncID, 'LCMean532_warning', 'NC_SHORT', dimID_constant);
varID_LC_warning_1064 = netcdf.defVar(ncID, 'LCMean1064_warning', 'NC_SHORT', dimID_constant);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_datetime, transpose(mean(data.mTime(data.cloudFreeGroups), 2)));
netcdf.putVar(ncID, varID_LC_klett_355, LC_klett_355);
netcdf.putVar(ncID, varID_LC_klett_532, LC_klett_532);
netcdf.putVar(ncID, varID_LC_klett_1064, LC_klett_1064);
netcdf.putVar(ncID, varID_LC_raman_355, LC_raman_355);
netcdf.putVar(ncID, varID_LC_raman_532, LC_raman_532);
netcdf.putVar(ncID, varID_LC_raman_1064, LC_raman_1064);
netcdf.putVar(ncID, varID_LC_aeronet_355, LC_aeronet_355);
netcdf.putVar(ncID, varID_LC_aeronet_532, LC_aeronet_532);
netcdf.putVar(ncID, varID_LC_aeronet_1064, LC_aeronet_1064);
netcdf.putVar(ncID, varID_LC_used_355, LCUsed355);
netcdf.putVar(ncID, varID_LC_used_532, LCUsed532);
netcdf.putVar(ncID, varID_LC_used_1064, LCUsed1064);
netcdf.putVar(ncID, varID_LC_usedtag_355, LCUsedTag355);
netcdf.putVar(ncID, varID_LC_usedtag_532, LCUsedTag532);
netcdf.putVar(ncID, varID_LC_usedtag_1064, LCUsedTag1064);
netcdf.putVar(ncID, varID_LC_warning_355, int32(flagLCWarning355));
netcdf.putVar(ncID, varID_LC_warning_532, int32(flagLCWarning532));
netcdf.putVar(ncID, varID_LC_warning_1064, int32(flagLCWarning1064));

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_datetime, 'unit', 'datenum');
netcdf.putAtt(ncID, varID_datetime, 'long_name', 'medium datetime for each calibration period.');

netcdf.putAtt(ncID, varID_LC_klett_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_355, 'long_name', 'Lidar constant at 355 nm based on klett method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_klett_355, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_klett_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_532, 'long_name', 'Lidar constant at 532 nm based on klett method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_klett_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_klett_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_klett_1064, 'long_name', 'Lidar constant at 1064 nm based on klett method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_klett_1064, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_raman_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_355, 'long_name', 'Lidar constant at 355 nm based on raman method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_raman_355, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_raman_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_532, 'long_name', 'Lidar constant at 532 nm based on raman method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_raman_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_raman_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_raman_1064, 'long_name', 'Lidar constant at 1064 nm based on raman method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_raman_1064, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_aeronet_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'long_name', 'Lidar constant at 355 nm based on constrained-aod method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_aeronet_355, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_aeronet_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'long_name', 'Lidar constant at 532 nm based on constrained-aod method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_aeronet_532, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'long_name', 'Lidar constant at 1064 nm based on constrained-aod method. The constant value is aimed at 30-s profile.');
netcdf.putAtt(ncID, varID_LC_aeronet_1064, 'missing_value', missingValue);

netcdf.putAtt(ncID, varID_LC_used_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_355, 'long_name', 'Actual lidar constant at 355 nm in application. The constant value is aimed at 30-s profile.');

netcdf.putAtt(ncID, varID_LC_used_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_532, 'long_name', 'Actual lidar constant at 532 nm in application. The constant value is aimed at 30-s profile.');

netcdf.putAtt(ncID, varID_LC_used_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_used_1064, 'long_name', 'Actual lidar constant at 1064 nm in application. The constant value is aimed at 30-s profile.');

netcdf.putAtt(ncID, varID_LC_usedtag_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_355, 'long_name', 'The source of applied lidar constant at 355 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)');

netcdf.putAtt(ncID, varID_LC_usedtag_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_532, 'long_name', 'The source of applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)');

netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_usedtag_1064, 'long_name', 'The source of applied lidar constant at 1064 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults)');

netcdf.putAtt(ncID, varID_LC_warning_355, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_355, 'long_name', 'flag to show whether it is unstalbe for the calibration constants. (1: yes; 0: no)');

netcdf.putAtt(ncID, varID_LC_warning_532, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_532, 'long_name', 'flag to show whether it is unstalbe for the calibration constants. (1: yes; 0: no)');

netcdf.putAtt(ncID, varID_LC_warning_1064, 'unit', '');
netcdf.putAtt(ncID, varID_LC_warning_1064, 'long_name', 'flag to show whether it is unstalbe for the calibration constants. (1: yes; 0: no)');

% global attributes
varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'location', globalAttri.location);
netcdf.putAtt(ncID, varID_global, 'institute', globalAttri.institute);
netcdf.putAtt(ncID, varID_global, 'version', globalAttri.version);
netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', globalAttri.contact));
 
% close file
netcdf.close(ncID);

end