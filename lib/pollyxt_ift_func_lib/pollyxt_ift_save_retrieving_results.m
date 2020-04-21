function pollyxt_ift_save_retrieving_results(data, taskInfo, config)
%POLLYXT_IFT_SAVE_RETRIEVING_RESULTS saving the retrieved results, including backscatter, extinction coefficients, lidar ratio, volume/particles depolarization ratio and so on.
%Example:
%   pollyxt_ift_save_retrieving_results(data, taskInfo, config)
%Inputs:
%   data.struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   taskInfo: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%History:
%   2018-12-31. First Edition by Zhenping
%   2019-05-10. Add one field of start&end time to be compatible with larda ncReader.
%   2019-05-16. Extended the attributes for all the variables and comply with the ACTRIS
%   2019-05-24. Add voldepol with different smoothing window  convention.
%   2019-09-27. Turn on the netCDF4 compression.
%Contact:
%   zhenping@tropos.de

global processInfo defaults campaignInfo

missing_value = -999;

for iGroup = 1:size(data.cloudFreeGroups, 1)
    ncFile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_profiles.nc', rmext(taskInfo.dataFilename), datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HHMM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HHMM')));
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
    mode = netcdf.getConstant('NETCDF4');
    mode = bitor(mode, netcdf.getConstant('CLASSIC_MODEL'));
    mode = bitor(mode, netcdf.getConstant('CLOBBER'));
    ncID = netcdf.create(ncFile, mode);

    %% define dimensions
    dimID_height = netcdf.defDim(ncID, 'height', length(data.height));
    dimID_method = netcdf.defDim(ncID, 'method', 1);
    dimID_refHeight = netcdf.defDim(ncID, 'reference_height', 2);

    %% define variables
    varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_DOUBLE', dimID_method);
    varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_DOUBLE', dimID_method);
    varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_DOUBLE', dimID_method);
    varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_method);
    varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_method);
    varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_klett_355 = netcdf.defVar(ncID, 'aerBsc_klett_355', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_klett_1064 = netcdf.defVar(ncID, 'aerBsc_klett_1064', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_aeronet_355 = netcdf.defVar(ncID, 'aerBsc_aeronet_355', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_aeronet_532 = netcdf.defVar(ncID, 'aerBsc_aeronet_532', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_aeronet_1064 = netcdf.defVar(ncID, 'aerBsc_aeronet_1064', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_raman_355 = netcdf.defVar(ncID, 'aerBsc_raman_355', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerBsc_raman_1064 = netcdf.defVar(ncID, 'aerBsc_raman_1064', 'NC_DOUBLE', dimID_height);
    varID_aerExt_raman_355 = netcdf.defVar(ncID, 'aerExt_raman_355', 'NC_DOUBLE', dimID_height);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerExt_raman_1064 = netcdf.defVar(ncID, 'aerExt_raman_1064', 'NC_DOUBLE', dimID_height);
    varID_aerLR_raman_355 = netcdf.defVar(ncID, 'aerLR_raman_355', 'NC_DOUBLE', dimID_height);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_DOUBLE', dimID_height);
    varID_aerLR_raman_1064 = netcdf.defVar(ncID, 'aerLR_raman_1064', 'NC_DOUBLE', dimID_height);
    varID_volDepol_klett_532 = netcdf.defVar(ncID, 'volDepol_klett_532', 'NC_DOUBLE', dimID_height);
    varID_volDepol_raman_532 = netcdf.defVar(ncID, 'volDepol_raman_532', 'NC_DOUBLE', dimID_height);
    varID_parDepol_klett_532 = netcdf.defVar(ncID, 'parDepol_klett_532', 'NC_DOUBLE', dimID_height);
    varID_parDepol_raman_532 = netcdf.defVar(ncID, 'parDepol_raman_532', 'NC_DOUBLE', dimID_height);
    varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_DOUBLE', dimID_height);
    varID_RH = netcdf.defVar(ncID, 'RH', 'NC_DOUBLE', dimID_height);
    varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_DOUBLE', dimID_height);
    varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_DOUBLE', dimID_height);
    varID_LR_aeronet_355 = netcdf.defVar(ncID, 'LR_aeronet_355', 'NC_DOUBLE', dimID_method);
    varID_LR_aeronet_532 = netcdf.defVar(ncID, 'LR_aeronet_532', 'NC_DOUBLE', dimID_method);
    varID_LR_aeronet_1064 = netcdf.defVar(ncID, 'LR_aeronet_1064', 'NC_DOUBLE', dimID_method);
    varID_reference_height_355 = netcdf.defVar(ncID, 'reference_height_355', 'NC_DOUBLE', dimID_refHeight);
    varID_reference_height_532 = netcdf.defVar(ncID, 'reference_height_532', 'NC_DOUBLE', dimID_refHeight);
    varID_reference_height_1064 = netcdf.defVar(ncID, 'reference_height_1064', 'NC_DOUBLE', dimID_refHeight);

    % define the filling value
    netcdf.defVarFill(ncID, varID_aerBsc_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_parDepol_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_parDepol_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_WVMR, false, missing_value);
    netcdf.defVarFill(ncID, varID_RH, false, missing_value);
    netcdf.defVarFill(ncID, varID_temperature, false, missing_value);
    netcdf.defVarFill(ncID, varID_pressure, false, missing_value);
    netcdf.defVarFill(ncID, varID_LR_aeronet_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_LR_aeronet_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_LR_aeronet_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_reference_height_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_reference_height_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_reference_height_1064, false, missing_value);

    % define the data compression
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_parDepol_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_parDepol_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_WVMR, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_RH, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_temperature, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pressure, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_LR_aeronet_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_LR_aeronet_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_LR_aeronet_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_reference_height_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_reference_height_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_reference_height_1064, true, true, 5);

    % leve define mode
    netcdf.endDef(ncID);

    %% write data to .nc file
    netcdf.putVar(ncID, varID_altitude, data.alt0);
    netcdf.putVar(ncID, varID_longitude, data.lon);
    netcdf.putVar(ncID, varID_latitude, data.lat);
    netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(startTime));
    netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(endTime));
    netcdf.putVar(ncID, varID_height, data.height);
    netcdf.putVar(ncID, varID_aerBsc_klett_355, fillmissing(data.aerBsc355_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_klett_532, fillmissing(data.aerBsc532_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_klett_1064, fillmissing(data.aerBsc1064_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_355, fillmissing(data.aerBsc355_aeronet(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_532, fillmissing(data.aerBsc532_aeronet(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_1064, fillmissing(data.aerBsc1064_aeronet(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_raman_355, fillmissing(data.aerBsc355_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_raman_532, fillmissing(data.aerBsc532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerBsc_raman_1064, fillmissing(data.aerBsc1064_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerExt_raman_355, fillmissing(data.aerExt355_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerExt_raman_532, fillmissing(data.aerExt532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerExt_raman_1064, fillmissing(data.aerExt1064_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerLR_raman_355, fillmissing(data.LR355_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerLR_raman_532, fillmissing(data.LR532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_aerLR_raman_1064, fillmissing(data.LR1064_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_volDepol_klett_532, fillmissing(data.voldepol532_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_volDepol_raman_532, fillmissing(data.voldepol532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_parDepol_klett_532, fillmissing(data.pardepol532_klett(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_parDepol_raman_532, fillmissing(data.pardepol532_raman(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_WVMR, fillmissing(data.wvmr(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_RH, fillmissing(data.rh(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_temperature, fillmissing(data.temperature(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_pressure, fillmissing(data.pressure(iGroup, :), missing_value));
    netcdf.putVar(ncID, varID_LR_aeronet_355, fillmissing(data.LR355_aeronet(iGroup), missing_value));
    netcdf.putVar(ncID, varID_LR_aeronet_532, fillmissing(data.LR532_aeronet(iGroup), missing_value));
    netcdf.putVar(ncID, varID_LR_aeronet_1064, fillmissing(data.LR1064_aeronet(iGroup), missing_value));
    netcdf.putVar(ncID, varID_reference_height_355, refH355);
    netcdf.putVar(ncID, varID_reference_height_532, refH532);
    netcdf.putVar(ncID, varID_reference_height_1064, refH1064);

    % reenter define mode
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

    % height
    netcdf.putAtt(ncID, varID_height, 'unit', 'm');
    netcdf.putAtt(ncID, varID_height, 'long_name', 'Height above the ground');
    netcdf.putAtt(ncID, varID_height, 'standard_name', 'height');
    netcdf.putAtt(ncID, varID_height, 'axis', 'Z');

    % aerBsc_klett_355
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR355, config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_klett_532
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR532, config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_klett_1064
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'retrieved_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', config.LR1064, config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'comment', sprintf('The result is retrieved with klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_aeronet_355
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD355(iGroup), config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % aerBsc_aeronet_532
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD532(iGroup), config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % aerBsc_aeronet_1064
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with constained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD1064(iGroup), config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % aerBsc_raman_355
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta355 * 1e6, config.smoothWin_raman_355 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_raman_532
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta532 * 1e6, config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_raman_1064
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_range', config.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'retrieved_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.refBeta1064 * 1e6, config.smoothWin_raman_1064 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_355
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'long_name', 'aerosol extinction coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'standard_name', 'alpha (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'plot_range', config.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_355 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_532
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'standard_name', 'alpha (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_range', config.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_532 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_1064
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'long_name', 'aerosol extinction coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'standard_name', 'alpha (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'plot_range', config.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', config.smoothWin_raman_1064 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'comment', sprintf('This results is extrapolated by Raman extinction at 532 nm. Not real Raman extinction. Be careful!!!'));

    % aerLR_raman_355
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_532
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The results is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_1064
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'retrieved_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %5.2f', config.smoothWin_raman_1064 * data.hRes, config.angstrexp));
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'comment', sprintf('This result is based on interpolated extinction. Not by real Raman method. Be careful!'));

    % volDepol_klett_532
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'long_name', 'volume depolarization ratio at 532 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'retrieved_info', sprintf('Smoothing window: %d [m];', config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'comment', sprintf('depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % volDepol_raman_532
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'long_name', 'volume depolarization ratio at 532 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m];', config.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'comment', sprintf('depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % parDepol_klett_532
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'standard_name', 'delta (par, 532 nm)');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_klett_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % parDepol_raman_532
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'long_name', 'particle depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'standard_name', 'delta (par, 532 nm)');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'retrieved_info', sprintf('Smoothing window: %d [m]; molecule depolarization ratio: %7.5f', config.smoothWin_raman_532 * data.hRes, data.moldepol532(iGroup)));
    netcdf.putAtt(ncID, varID_parDepol_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % WVMR
    netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g kg^-1');
    netcdf.putAtt(ncID, varID_WVMR, 'unit_html', 'g kg<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'Water vapor mixing ratio');
    netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
    netcdf.putAtt(ncID, varID_WVMR, 'plot_range', config.xLim_Profi_WV_RH);
    netcdf.putAtt(ncID, varID_WVMR, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_WVMR, 'source', campaignInfo.name);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR, 'retrieved_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s', data.hRes, thisStr{1}, data.IWVAttri.source));
    netcdf.putAtt(ncID, varID_WVMR, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));

    % RH
    netcdf.putAtt(ncID, varID_RH, 'unit', '%');
    netcdf.putAtt(ncID, varID_RH, 'long_name', 'Relative humidity');
    netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
    netcdf.putAtt(ncID, varID_RH, 'plot_range', [0, 100]);
    netcdf.putAtt(ncID, varID_RH, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_RH, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_RH, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));
    netcdf.putAtt(ncID, varID_RH, 'comment', sprintf('The RH is sensitive to temperature and water vapor calibration constants. Please take care!'));

    % temperature
    netcdf.putAtt(ncID, varID_temperature, 'unit', 'degree_Celsius');
    netcdf.putAtt(ncID, varID_temperature, 'unit_html', '&#176C');
    netcdf.putAtt(ncID, varID_temperature, 'long_name', 'Temperature');
    netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'air_temperature');
    netcdf.putAtt(ncID, varID_temperature, 'plot_range', [-60, 40]);
    netcdf.putAtt(ncID, varID_temperature, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_temperature, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));

    % pressure
    netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
    netcdf.putAtt(ncID, varID_pressure, 'long_name', 'Pressure');
    netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'air_pressure');
    netcdf.putAtt(ncID, varID_pressure, 'plot_range', [0, 1000]);
    netcdf.putAtt(ncID, varID_pressure, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pressure, 'retrieved_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGroup}));

    % LR_aeronet_355
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'long_name', 'Aerosol lidar ratio at 355 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD355(iGroup), config.refBeta355 * 1e6, config.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % LR_aeronet_532
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'long_name', 'Aerosol lidar ratio at 532 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD532(iGroup), config.refBeta532 * 1e6, config.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % LR_aeronet_1064
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'long_name', 'Aerosol lidar ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'plot_range', config.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'retrieved_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD1064(iGroup), config.refBeta1064 * 1e6, config.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'comment', sprintf('The results is retrieved with constrined-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned. And choose lidar ratio as the deviation is converged.'));

    % reference_height_355
    netcdf.putAtt(ncID, varID_reference_height_355, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'long_name', 'Reference height for 355 nm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'standard_name', 'ref_h_355');
    netcdf.putAtt(ncID, varID_reference_height_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_355, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_reference_height_355, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    % reference_height_532
    netcdf.putAtt(ncID, varID_reference_height_532, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'long_name', 'Reference height for 532 nm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'standard_name', 'ref_h_532');
    netcdf.putAtt(ncID, varID_reference_height_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_532, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_reference_height_532, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    % reference_height_1064
    netcdf.putAtt(ncID, varID_reference_height_1064, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'long_name', 'Reference height for 1064 nm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'standard_name', 'ref_h_1064');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'source', campaignInfo.name);
    netcdf.putAtt(ncID, varID_reference_height_1064, 'comment', sprintf('The reference height is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

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