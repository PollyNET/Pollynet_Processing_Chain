function [] = pollyxt_tropos_save_retrieving_results(data, taskInfo, config)
%pollyxt_tropos_save_retrieving_results saving the retrieved results, including backscatter, extinction coefficients, lidar ratio, volume/particles depolarization ratio and so on.
%   Example:
%       [] = pollyxt_tropos_save_retrieving_results(data, taskInfo, config)
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
%       2018-12-31. First Edition by Zhenping
%       2019-05-10. Add one field of start&end time to be compatible with larda ncReader.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

missing_value = -999;

for iGroup = 1:size(data.cloudFreeGroups, 1)
    ncFile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_profiles.nc', rmext(taskInfo.dataFilename), datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HHMM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HHMM')));
    startTime = data.mTime(data.cloudFreeGroups(iGroup, 1));
    endTime = data.mTime(data.cloudFreeGroups(iGroup, 2));

    % filling missing values for reference height
    if isnan(data.refHIndx355(iGroup, 1))
        refH355 = [missing_value, missing_value];
    else
        refH355 = data.height(data.refHIndx355(iGroup, :));
    end
    if isnan(data.refHIndx532(iGroup, 1))
        refH532 = [missing_value, missing_value];
    else
        refH532 = data.height(data.refHIndx532(iGroup, :));
    end
    if isnan(data.refHIndx1064(iGroup, 1))
        refH1064 = [missing_value, missing_value];
    else
        refH1064 = data.height(data.refHIndx1064(iGroup, :));
    end

    % create .nc file by overwriting any existing file with the name filename
    ncID = netcdf.create(ncFile, 'clobber');

    % define dimensions
    dimID_altitude = netcdf.defDim(ncID, 'altitude', length(data.alt));
    dimID_method = netcdf.defDim(ncID, 'method', 1);
    dimID_refHeight = netcdf.defDim(ncID, 'reference_height', 2);

    % define variables
    varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_method);
    varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_method);
    varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_altitude);
    varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_klett_355 = netcdf.defVar(ncID, 'aerBsc_klett_355', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_klett_1064 = netcdf.defVar(ncID, 'aerBsc_klett_1064', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_aeronet_355 = netcdf.defVar(ncID, 'aerBsc_aeronet_355', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_aeronet_532 = netcdf.defVar(ncID, 'aerBsc_aeronet_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_aeronet_1064 = netcdf.defVar(ncID, 'aerBsc_aeronet_1064', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_raman_355 = netcdf.defVar(ncID, 'aerBsc_raman_355', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerBsc_raman_1064 = netcdf.defVar(ncID, 'aerBsc_raman_1064', 'NC_DOUBLE', dimID_altitude);
    varID_aerExt_raman_355 = netcdf.defVar(ncID, 'aerExt_raman_355', 'NC_DOUBLE', dimID_altitude);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerExt_raman_1064 = netcdf.defVar(ncID, 'aerExt_raman_1064', 'NC_DOUBLE', dimID_altitude);
    varID_aerLR_raman_355 = netcdf.defVar(ncID, 'aerLR_raman_355', 'NC_DOUBLE', dimID_altitude);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_aerLR_raman_1064 = netcdf.defVar(ncID, 'aerLR_raman_1064', 'NC_DOUBLE', dimID_altitude);
    varID_volDepol_532 = netcdf.defVar(ncID, 'volDepol_532', 'NC_DOUBLE', dimID_altitude);
    varID_volDepol_355 = netcdf.defVar(ncID, 'volDepol_355', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_klett_532 = netcdf.defVar(ncID, 'parDepol_klett_532', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_klett_355 = netcdf.defVar(ncID, 'parDepol_klett_355', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_raman_532 = netcdf.defVar(ncID, 'parDepol_raman_532', 'NC_DOUBLE', dimID_altitude);
    varID_parDepol_raman_355 = netcdf.defVar(ncID, 'parDepol_raman_355', 'NC_DOUBLE', dimID_altitude);
    varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_DOUBLE', dimID_altitude);
    varID_RH = netcdf.defVar(ncID, 'RH', 'NC_DOUBLE', dimID_altitude);
    varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_DOUBLE', dimID_altitude);
    varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_DOUBLE', dimID_altitude);
    varID_LR_aeronet_355 = netcdf.defVar(ncID, 'LR_aeronet_355', 'NC_DOUBLE', dimID_method);
    varID_LR_aeronet_532 = netcdf.defVar(ncID, 'LR_aeronet_532', 'NC_DOUBLE', dimID_method);
    varID_LR_aeronet_1064 = netcdf.defVar(ncID, 'LR_aeronet_1064', 'NC_DOUBLE', dimID_method);
    varID_reference_height_355 = netcdf.defVar(ncID, 'reference_height_355', 'NC_DOUBLE', dimID_refHeight);
    varID_reference_height_532 = netcdf.defVar(ncID, 'reference_height_532', 'NC_DOUBLE', dimID_refHeight);
    varID_reference_height_1064 = netcdf.defVar(ncID, 'reference_height_1064', 'NC_DOUBLE', dimID_refHeight);

    % leve define mode
    netcdf.endDef(ncID);

    % write data to .nc file
    netcdf.putVar(ncID, varID_startTime, startTime);
    netcdf.putVar(ncID, varID_endTime, endTime);
    netcdf.putVar(ncID, varID_height, data.height);
    netcdf.putVar(ncID, varID_altitude, data.alt);
    netcdf.putVar(ncID, varID_aerBsc_klett_355, fillmissing(data.aerBsc355_klett(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_klett_532, fillmissing(data.aerBsc532_klett(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_klett_1064, fillmissing(data.aerBsc1064_klett(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_aeronet_355, fillmissing(data.aerBsc355_aeronet(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_aeronet_532, fillmissing(data.aerBsc532_aeronet(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_aeronet_1064, fillmissing(data.aerBsc1064_aeronet(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_raman_355, fillmissing(data.aerBsc355_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_raman_532, fillmissing(data.aerBsc532_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerBsc_raman_1064, fillmissing(data.aerBsc1064_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerExt_raman_355, fillmissing(data.aerExt355_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerExt_raman_532, fillmissing(data.aerExt532_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerExt_raman_1064, fillmissing(data.aerExt1064_raman(iGroup, :)) * 1e6);
    netcdf.putVar(ncID, varID_aerLR_raman_355, fillmissing(data.LR355_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_aerLR_raman_532, fillmissing(data.LR532_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_aerLR_raman_1064, fillmissing(data.LR1064_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_volDepol_532, fillmissing(data.voldepol532(iGroup, :)));
    netcdf.putVar(ncID, varID_volDepol_355, fillmissing(data.voldepol355(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_klett_532, fillmissing(data.pardepol532_klett(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_klett_355, fillmissing(data.pardepol355_klett(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_raman_532, fillmissing(data.pardepol532_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_parDepol_raman_355, fillmissing(data.pardepol355_raman(iGroup, :)));
    netcdf.putVar(ncID, varID_WVMR, fillmissing(data.wvmr(iGroup, :)));
    netcdf.putVar(ncID, varID_RH, fillmissing(data.rh(iGroup, :)));
    netcdf.putVar(ncID, varID_temperature, fillmissing(data.temperature(iGroup, :)));
    netcdf.putVar(ncID, varID_pressure, fillmissing(data.pressure(iGroup, :)));
    netcdf.putVar(ncID, varID_LR_aeronet_355, fillmissing(data.LR355_aeronet(iGroup)));
    netcdf.putVar(ncID, varID_LR_aeronet_532, fillmissing(data.LR532_aeronet(iGroup)));
    netcdf.putVar(ncID, varID_LR_aeronet_1064, fillmissing(data.LR1064_aeronet(iGroup)));
    netcdf.putVar(ncID, varID_reference_height_355, refH355);
    netcdf.putVar(ncID, varID_reference_height_532, refH532);
    netcdf.putVar(ncID, varID_reference_height_1064, refH1064);

    % reenter define mode
    netcdf.reDef(ncID);

    % write attributes to the variables
    varID_global = netcdf.getConstant('GLOBAL');
    netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
    netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
    netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
    netcdf.putAtt(ncID, varID_global, 'location', campaignInfo.location);
    netcdf.putAtt(ncID, varID_global, 'institute', processInfo.institute);
    netcdf.putAtt(ncID, varID_global, 'version', processInfo.programVersion);
    netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', processInfo.contact));

    netcdf.putAtt(ncID, varID_startTime, 'unit', '');
    netcdf.putAtt(ncID, varID_startTime, 'long_name', 'start time for the profile (matlab datenum)');
    netcdf.putAtt(ncID, varID_startTime, 'standard_name', 'startTime');

    netcdf.putAtt(ncID, varID_endTime, 'unit', '');
    netcdf.putAtt(ncID, varID_endTime, 'long_name', 'end time for the profile (matlab datenum)');
    netcdf.putAtt(ncID, varID_endTime, 'standard_name', 'endTime');

    netcdf.putAtt(ncID, varID_height, 'unit', 'm');
    netcdf.putAtt(ncID, varID_height, 'long_name', 'height (above surface)');
    netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');

    netcdf.putAtt(ncID, varID_altitude, 'unit', 'm');
    netcdf.putAtt(ncID, varID_altitude, 'long_name', 'height above mean sea level');
    netcdf.putAtt(ncID, varID_altitude, 'standard_name', 'altitude');

    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'standard_name', '\\beta_{aer, 355}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR355, config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR532, config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'standard_name', '\\beta_{aer, 1064}');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR1064, config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'standard_name', '\\beta_{aer, 355}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD355(iGroup), config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD532(iGroup), config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'standard_name', '\\beta_{aer, 1064}');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD1064(iGroup), config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'standard_name', '\\beta_{aer, 355}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta355 * 1e6, config.smoothWin_raman_355 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', '\\beta_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta532 * 1e6, config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit', 'Mm^{-1}*Sr^{-1}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'standard_name', '\\beta_{aer, 1064}');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta1064 * 1e6, config.smoothWin_raman_1064 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'unit', 'Mm^{-1}');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'long_name', 'aerosol extinction coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'standard_name', '\\alpha_{aer, 355}');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_355 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit', 'Mm^{-1}');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'standard_name', '\\alpha_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'unit', 'Mm^{-1}');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'long_name', 'aerosol extinction coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'standard_name', '\\alpha_{aer, 1064}');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_1064 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'standard_name', 'S_{aer, 355}');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S_{aer, 532}');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'standard_name', 'S_{aer, 1064}');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));
    
    netcdf.putAtt(ncID, varID_volDepol_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_532, 'long_name', 'volume depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_volDepol_532, 'standard_name', '\\delta_{vol, 532}');
    netcdf.putAtt(ncID, varID_volDepol_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_volDepol_532, 'comment', sprintf('depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));
    
    netcdf.putAtt(ncID, varID_volDepol_355, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_355, 'long_name', 'volume depolarization ratio at 355 nm');
    netcdf.putAtt(ncID, varID_volDepol_355, 'standard_name', '\\delta_{vol, 355}');
    netcdf.putAtt(ncID, varID_volDepol_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_volDepol_355, 'comment', sprintf('depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));
    
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'standard_name', '\\delta_{par, 532}');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_klett_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'long_name', 'particle depolarization ratio at 355 nm');
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'standard_name', '\\delta_{par, 355}');
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_klett_355 * data.hRes, data.moldepol355(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_klett_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'standard_name', '\\delta_{par, 532}');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_raman_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'long_name', 'particle depolarization ratio at 355 nm');
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'standard_name', '\\delta_{par, 355}');
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_raman_355 * data.hRes, data.moldepol355(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_raman_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));
    
    netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g*kg^{-1}');
    netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'Water vapor mixing ratio');
    netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
    netcdf.putAtt(ncID, varID_WVMR, 'missing_value', -999);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR, 'retrieved_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s', data.hRes, thisStr{1}, data.IWVAttri.source));
    netcdf.putAtt(ncID, varID_WVMR, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));
    
    netcdf.putAtt(ncID, varID_RH, 'unit', '%');
    netcdf.putAtt(ncID, varID_RH, 'long_name', 'Relative humidity');
    netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
    netcdf.putAtt(ncID, varID_RH, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_RH, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    netcdf.putAtt(ncID, varID_RH, 'comment', sprintf('The RH is sensitive to temperature and water vapor calibration constants. Please take care!'));
    
    netcdf.putAtt(ncID, varID_temperature, 'unit', '\\circC');
    netcdf.putAtt(ncID, varID_temperature, 'long_name', 'Temperature');
    netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'T');
    netcdf.putAtt(ncID, varID_temperature, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_temperature, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
    netcdf.putAtt(ncID, varID_pressure, 'long_name', 'Pressure');
    netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'P');
    netcdf.putAtt(ncID, varID_pressure, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_pressure, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'long_name', 'Aerosol lidar ratio at 355 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'standard_name', 'S_{355}');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD355(iGroup), config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'long_name', 'Aerosol lidar ratio at 532 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'standard_name', 'S_{532}');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD532(iGroup), config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'unit', 'Sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'long_name', 'Aerosol lidar ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'standard_name', 'S_{1064}');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD1064(iGroup), config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));
    
    netcdf.putAtt(ncID, varID_reference_height_355, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'long_name', 'Reference height for 355 nm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'standard_name', '');
    netcdf.putAtt(ncID, varID_reference_height_355, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_reference_height_355, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));
    
    netcdf.putAtt(ncID, varID_reference_height_532, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'long_name', 'Reference height for 532 nm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'standard_name', '');
    netcdf.putAtt(ncID, varID_reference_height_532, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_reference_height_532, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));
    
    netcdf.putAtt(ncID, varID_reference_height_1064, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'long_name', 'Reference height for 1064 nm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'standard_name', '');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'missing_value', -999);
    netcdf.putAtt(ncID, varID_reference_height_1064, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    % close file
    netcdf.close(ncID);
    
end