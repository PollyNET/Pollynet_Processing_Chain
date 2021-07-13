function pollySaveProfiles(data)
% POLLYSAVEPROFILES save the retrieved results, including backscatter,
% extinction coefficients, lidar ratio, volume/particles depolarization ratio
% and so on.
% USAGE:
%    pollySaveProfiles(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-08: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

%% channel mask
flagCh355FR = PollyConfig.isFR & PollyConfig.is355nm & PollyConfig.isTot;
flagCh532FR = PollyConfig.isFR & PollyConfig.is532nm & PollyConfig.isTot;
flagCh1064FR = PollyConfig.isFR & PollyConfig.is1064nm & PollyConfig.isTot;

missing_value = -999;

for iGrp = 1:size(data.clFreGrps, 1)
    save_for_detlef = false;
    if save_for_detlef
        %cutting lower edge
        data.aerBsc355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.aerExt355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.LR355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.pdr355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.aerBsc532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.aerExt532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.LR532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.pdr532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.aerBsc1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.aerExt1064_raman(iGrp,:) = missing_value;
        data.LR1064_raman(iGrp,:) = missing_value;

        %removing values with no aerosol
        bsc532_thres=1e-6;
        data.aerBsc355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.aerExt355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.LR355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.pdr355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.aerBsc532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.aerExt532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.LR532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.pdr532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
        data.aerBsc1064_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    end

    startTime = data.mTime(data.clFreGrps(iGrp, 1));
    endTime = data.mTime(data.clFreGrps(iGrp, 2));

    ncFile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_profiles.nc', rmext(PollyDataInfo.pollyDataFile), datestr(startTime, 'HHMM'), datestr(endTime, 'HHMM')));

    prfInd = data.clFreGrps(iGrp, 1):data.clFreGrps(iGrp, 2);
    shots = nansum(data.mShots(flagCh532FR, prfInd), 2);

    % filling missing values for reference height
    if isnan(data.refHInd355(iGrp, 1))
        refH355 = [missing_value, missing_value];
    else
        refH355 = data.height(data.refHInd355(iGrp, :));
    end
    if isnan(data.refHInd532(iGrp, 1))
        refH532 = [missing_value, missing_value];
    else
        refH532 = data.height(data.refHInd532(iGrp, :));
    end
    if isnan(data.refHInd1064(iGrp, 1))
        refH1064 = [missing_value, missing_value];
    else
        refH1064 = data.height(data.refHInd1064(iGrp, :));
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
    varID_altitude = netcdf.defVar(ncID, 'altitude', 'NC_FLOAT', dimID_method);
    varID_longitude = netcdf.defVar(ncID, 'longitude', 'NC_FLOAT', dimID_method);
    varID_latitude = netcdf.defVar(ncID, 'latitude', 'NC_FLOAT', dimID_method);
    varID_startTime = netcdf.defVar(ncID, 'start_time', 'NC_DOUBLE', dimID_method);
    varID_endTime = netcdf.defVar(ncID, 'end_time', 'NC_DOUBLE', dimID_method);
    varID_height = netcdf.defVar(ncID, 'height', 'NC_FLOAT', dimID_height);
    varID_shots = netcdf.defVar(ncID, 'shots', 'NC_SHORT', dimID_method);
    varID_zenith_angle = netcdf.defVar(ncID, 'zenith_angle', 'NC_FLOAT', dimID_method);
    varID_aerBsc_klett_355 = netcdf.defVar(ncID, 'aerBsc_klett_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_klett_1064 = netcdf.defVar(ncID, 'aerBsc_klett_1064', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_355 = netcdf.defVar(ncID, 'aerBsc_aeronet_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_532 = netcdf.defVar(ncID, 'aerBsc_aeronet_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_1064 = netcdf.defVar(ncID, 'aerBsc_aeronet_1064', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_355 = netcdf.defVar(ncID, 'aerBsc_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_1064 = netcdf.defVar(ncID, 'aerBsc_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_355 = netcdf.defVar(ncID, 'aerExt_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_1064 = netcdf.defVar(ncID, 'aerExt_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_355 = netcdf.defVar(ncID, 'aerLR_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_1064 = netcdf.defVar(ncID, 'aerLR_raman_1064', 'NC_FLOAT', dimID_height);
    varID_volDepol_klett_532 = netcdf.defVar(ncID, 'volDepol_klett_532', 'NC_FLOAT', dimID_height);
    varID_volDepol_klett_355 = netcdf.defVar(ncID, 'volDepol_klett_355', 'NC_FLOAT', dimID_height);
    varID_volDepol_raman_532 = netcdf.defVar(ncID, 'volDepol_raman_532', 'NC_FLOAT', dimID_height);
    varID_volDepol_raman_355 = netcdf.defVar(ncID, 'volDepol_raman_355', 'NC_FLOAT', dimID_height);
    varID_pdr_klett_532 = netcdf.defVar(ncID, 'pdr_klett_532', 'NC_FLOAT', dimID_height);
    varID_pdr_klett_355 = netcdf.defVar(ncID, 'pdr_klett_355', 'NC_FLOAT', dimID_height);
    varID_pdr_raman_532 = netcdf.defVar(ncID, 'pdr_raman_532', 'NC_FLOAT', dimID_height);
    varID_pdr_raman_355 = netcdf.defVar(ncID, 'pdr_raman_355', 'NC_FLOAT', dimID_height);
    varID_pdr_std_klett_532 = netcdf.defVar(ncID, 'uncertainty_pdr_klett_532', 'NC_FLOAT', dimID_height);
    varID_pdr_std_klett_355 = netcdf.defVar(ncID, 'uncertainty_pdr_klett_355', 'NC_FLOAT', dimID_height);
    varID_pdr_std_raman_532 = netcdf.defVar(ncID, 'uncertainty_pdr_raman_532', 'NC_FLOAT', dimID_height);
    varID_pdr_std_raman_355 = netcdf.defVar(ncID, 'uncertainty_pdr_raman_355', 'NC_FLOAT', dimID_height);
    varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_FLOAT', dimID_height);
    varID_RH = netcdf.defVar(ncID, 'RH', 'NC_FLOAT', dimID_height);
    varID_temperature = netcdf.defVar(ncID, 'temperature', 'NC_FLOAT', dimID_height);
    varID_pressure = netcdf.defVar(ncID, 'pressure', 'NC_FLOAT', dimID_height);
    varID_LR_aeronet_355 = netcdf.defVar(ncID, 'LR_aeronet_355', 'NC_FLOAT', dimID_method);
    varID_LR_aeronet_532 = netcdf.defVar(ncID, 'LR_aeronet_532', 'NC_FLOAT', dimID_method);
    varID_LR_aeronet_1064 = netcdf.defVar(ncID, 'LR_aeronet_1064', 'NC_FLOAT', dimID_method);
    varID_reference_height_355 = netcdf.defVar(ncID, 'reference_height_355', 'NC_FLOAT', dimID_refHeight);
    varID_reference_height_532 = netcdf.defVar(ncID, 'reference_height_532', 'NC_FLOAT', dimID_refHeight);
    varID_reference_height_1064 = netcdf.defVar(ncID, 'reference_height_1064', 'NC_FLOAT', dimID_refHeight);

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
    netcdf.defVarFill(ncID, varID_volDepol_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_volDepol_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_std_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_std_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_std_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_std_raman_355, false, missing_value);
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
    netcdf.defVarDeflate(ncID, varID_volDepol_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_volDepol_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_std_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_std_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_std_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_std_raman_355, true, true, 5);
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
    netcdf.defVarDeflate(ncID, varID_shots, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_zenith_angle, true, true, 5);

    % leave define mode
    netcdf.endDef(ncID);

    %% write data to .nc file
    netcdf.putVar(ncID, varID_altitude, single(data.alt0));
    netcdf.putVar(ncID, varID_longitude, single(data.lon));
    netcdf.putVar(ncID, varID_latitude, single(data.lat));
    netcdf.putVar(ncID, varID_shots, int16(shots));
    netcdf.putVar(ncID, varID_zenith_angle, single(data.zenithAng));
    netcdf.putVar(ncID, varID_startTime, datenum_2_unix_timestamp(startTime));
    netcdf.putVar(ncID, varID_endTime, datenum_2_unix_timestamp(endTime));
    netcdf.putVar(ncID, varID_height, single(data.height));
    netcdf.putVar(ncID, varID_aerBsc_klett_355, single(fillmissing(data.aerBsc355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_klett_532, single(fillmissing(data.aerBsc532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_klett_1064, single(fillmissing(data.aerBsc1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_355, single(fillmissing(data.aerBsc355_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_532, single(fillmissing(data.aerBsc532_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_1064, single(fillmissing(data.aerBsc1064_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_355, single(fillmissing(data.aerBsc355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_532, single(fillmissing(data.aerBsc532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_1064, single(fillmissing(data.aerBsc1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_355, single(fillmissing(data.aerExt355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_532, single(fillmissing(data.aerExt532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_1064, single(fillmissing(data.aerExt1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_355, single(fillmissing(data.LR355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_532, single(fillmissing(data.LR532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_1064, single(fillmissing(data.LR1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_volDepol_klett_532, single(fillmissing(data.vdr532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_volDepol_klett_355, single(fillmissing(data.vdr355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_volDepol_raman_532, single(fillmissing(data.vdr532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_volDepol_raman_355, single(fillmissing(data.vdr355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_klett_532, single(fillmissing(data.pdr532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_std_klett_532, single(fillmissing(data.pdrStd532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_klett_355, single(fillmissing(data.pdr355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_std_klett_355, single(fillmissing(data.pdrStd355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_raman_532, single(fillmissing(data.pdr532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_std_raman_532, single(fillmissing(data.pdrStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_raman_355, single(fillmissing(data.pdr355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_std_raman_355, single(fillmissing(data.pdrStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_WVMR, single(fillmissing(data.wvmr(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_RH, single(fillmissing(data.rh(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_temperature, single(fillmissing(data.temperature(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pressure, single(fillmissing(data.pressure(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_LR_aeronet_355, single(fillmissing(data.LR355_aeronet(iGrp), missing_value)));
    netcdf.putVar(ncID, varID_LR_aeronet_532, single(fillmissing(data.LR532_aeronet(iGrp), missing_value)));
    netcdf.putVar(ncID, varID_LR_aeronet_1064, single(fillmissing(data.LR1064_aeronet(iGrp), missing_value)));
    netcdf.putVar(ncID, varID_reference_height_355, single(refH355));
    netcdf.putVar(ncID, varID_reference_height_532, single(refH532));
    netcdf.putVar(ncID, varID_reference_height_1064, single(refH1064));

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

    % accumulated shots
    netcdf.putAtt(ncID, varID_shots, 'unit', '')
    netcdf.putAtt(ncID, varID_shots, 'long_name', 'accumulated laser shots');
    netcdf.putAtt(ncID, varID_shots, 'standard_name', 'shots');

    % zenith angle
    netcdf.putAtt(ncID, varID_zenith_angle, 'unit', 'degree');
    netcdf.putAtt(ncID, varID_zenith_angle, 'long_name', 'laser pointing angle with respect to the zenith');
    netcdf.putAtt(ncID, varID_zenith_angle, 'standard_name', 'zenith_angle');

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
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR355, PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_355, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_klett_532
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR532, PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_532, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_klett_1064
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Klett method');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR1064, PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_klett_1064, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

    % aerBsc_aeronet_355
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD355(iGrp), PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_355, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % aerBsc_aeronet_532
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD532(iGrp), PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_532, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % aerBsc_aeronet_1064
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD1064(iGrp), PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBsc_aeronet_1064, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % aerBsc_raman_355
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_raman_532
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_raman_1064
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_355
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'long_name', 'aerosol extinction coefficient at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'standard_name', 'alpha (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_532
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'standard_name', 'alpha (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_raman_1064
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'long_name', 'aerosol extinction coefficient at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'standard_name', 'alpha (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_raman_1064, 'comment', sprintf('This result is extrapolated by Raman extinction at 532 nm. Not real Raman extinction. Be careful!!!'));

    % aerLR_raman_355
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_532
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_1064
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %5.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'comment', sprintf('This result is based on extrapolated extinction. Not by real Raman method. Be careful!'));

    % volDepol_klett_532
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'long_name', 'volume linear depolarization ratio at 532 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_volDepol_klett_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % volDepol_klett_355
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'long_name', 'volume linear depolarization ratio at 355 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'standard_name', 'delta (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_volDepol_klett_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % volDepol_raman_532
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'long_name', 'volume linear depolarization ratio at 532 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_volDepol_raman_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % volDepol_raman_355
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'long_name', 'volume linear depolarization ratio at 355 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'standard_name', 'delta (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_volDepol_raman_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % pdr_klett_532
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'long_name', 'particle linear depolarization ratio at 532 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'standard_name', 'delta (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdr_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_std_klett_532
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'long_name', 'uncertainty of particle linear depolarization ratio at 532 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'standard_name', 'sigma (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdr_std_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_klett_355
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'long_name', 'particle linear depolarization ratio at 355 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'standard_name', 'delta (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdr_klett_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_std_klett_355
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'long_name', 'uncertainty of particle linear depolarization ratio at 355 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'standard_name', 'sigma (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdr_std_klett_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_raman_532
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'long_name', 'particle linear depolarization ratio at 532 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'standard_name', 'delta (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdr_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_std_raman_532
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'long_name', 'uncertainty of particle linear depolarization ratio at 532 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'standard_name', 'sigma (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdr_std_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_raman_355
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'long_name', 'particle linear depolarization ratio at 355 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'standard_name', 'delta (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdr_raman_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_std_raman_355
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'long_name', 'uncertainty of particle linear depolarization ratio at 355 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'standard_name', 'sigma (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdr_std_raman_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % WVMR
    netcdf.putAtt(ncID, varID_WVMR, 'unit', 'g kg^-1');
    netcdf.putAtt(ncID, varID_WVMR, 'unit_html', 'g kg<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_WVMR, 'long_name', 'water vapor mixing ratio');
    netcdf.putAtt(ncID, varID_WVMR, 'standard_name', 'WVMR');
    netcdf.putAtt(ncID, varID_WVMR, 'plot_range', PollyConfig.xLim_Profi_WV_RH);
    netcdf.putAtt(ncID, varID_WVMR, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_WVMR, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_WVMR, 'wv_calibration_constant_used', data.wvconstUsed);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR, 'retrieving_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', data.hRes, thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));
    netcdf.putAtt(ncID, varID_WVMR, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));

    % RH
    netcdf.putAtt(ncID, varID_RH, 'unit', '%');
    netcdf.putAtt(ncID, varID_RH, 'long_name', 'relative humidity');
    netcdf.putAtt(ncID, varID_RH, 'standard_name', 'RH');
    netcdf.putAtt(ncID, varID_RH, 'plot_range', [0, 100]);
    netcdf.putAtt(ncID, varID_RH, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_RH, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_RH, 'wv_calibration_constant_used', data.wvconstUsed);
    netcdf.putAtt(ncID, varID_RH, 'retrieving_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGrp}));
    netcdf.putAtt(ncID, varID_RH, 'comment', sprintf('RH is sensitive to temperature and water vapor calibration constants. Please take care!'));

    % temperature
    netcdf.putAtt(ncID, varID_temperature, 'unit', 'degree_Celsius');
    netcdf.putAtt(ncID, varID_temperature, 'unit_html', '&#176C');
    netcdf.putAtt(ncID, varID_temperature, 'long_name', 'temperature');
    netcdf.putAtt(ncID, varID_temperature, 'standard_name', 'air_temperature');
    netcdf.putAtt(ncID, varID_temperature, 'plot_range', [-60, 40]);
    netcdf.putAtt(ncID, varID_temperature, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_temperature, 'retrieving_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGrp}));

    % pressure
    netcdf.putAtt(ncID, varID_pressure, 'unit', 'hPa');
    netcdf.putAtt(ncID, varID_pressure, 'long_name', 'pressure');
    netcdf.putAtt(ncID, varID_pressure, 'standard_name', 'air_pressure');
    netcdf.putAtt(ncID, varID_pressure, 'plot_range', [0, 1000]);
    netcdf.putAtt(ncID, varID_pressure, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pressure, 'retrieving_info', sprintf('Meteorological Source: %s', data.meteorAttri.dataSource{iGrp}));

    % LR_aeronet_355
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD355(iGrp), PollyConfig.refBeta355 * 1e6, PollyConfig.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_355, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % LR_aeronet_532
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD532(iGrp), PollyConfig.refBeta532 * 1e6, PollyConfig.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_532, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % LR_aeronet_1064
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with constrained-AOD method');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Smoothing window: %d [m]', data.deltaAOD1064(iGrp), PollyConfig.refBeta1064 * 1e6, PollyConfig.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_LR_aeronet_1064, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

    % reference_height_355
    netcdf.putAtt(ncID, varID_reference_height_355, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'long_name', 'reference height for 355 nm');
    netcdf.putAtt(ncID, varID_reference_height_355, 'standard_name', 'ref_h_355');
    netcdf.putAtt(ncID, varID_reference_height_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_reference_height_355, 'comment', sprintf('The reference height interval is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    % reference_height_532
    netcdf.putAtt(ncID, varID_reference_height_532, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'long_name', 'reference height for 532 nm');
    netcdf.putAtt(ncID, varID_reference_height_532, 'standard_name', 'ref_h_532');
    netcdf.putAtt(ncID, varID_reference_height_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_reference_height_532, 'comment', sprintf('The reference height interval is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    % reference_height_1064
    netcdf.putAtt(ncID, varID_reference_height_1064, 'unit', 'm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'long_name', 'reference height for 1064 nm');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'standard_name', 'ref_h_1064');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_reference_height_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_reference_height_1064, 'comment', sprintf('The reference height interval is searched by Rayleigh Fitting algorithm. It is through comparing the correlation of the slope between molecule backscatter and range-corrected signal and find the segement with best agreement.'));

    varID_global = netcdf.getConstant('GLOBAL');
    netcdf.putAtt(ncID, varID_global, 'Conventions', 'CF-1.0');
    netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
    netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
    netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
    netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
    netcdf.putAtt(ncID, varID_global, 'PI', PollyConfig.PI);
    netcdf.putAtt(ncID, varID_global, 'PI_affiliation', PollyConfig.PI_affiliation);
    netcdf.putAtt(ncID, varID_global, 'PI_affiliation_acronym', PollyConfig.PI_affiliation_acronym);
    netcdf.putAtt(ncID, varID_global, 'PI_address', PollyConfig.PI_address);
    netcdf.putAtt(ncID, varID_global, 'PI_phone', PollyConfig.PI_phone);
    netcdf.putAtt(ncID, varID_global, 'PI_email', PollyConfig.PI_email);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator', PollyConfig.Data_Originator);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation', PollyConfig.Data_Originator_affiliation);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator_affiliation_acronym', PollyConfig.Data_Originator_affiliation_acronym);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator_address', PollyConfig.Data_Originator_address);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator_phone', PollyConfig.Data_Originator_phone);
    netcdf.putAtt(ncID, varID_global, 'Data_Originator_email', PollyConfig.Data_Originator_email);
    netcdf.putAtt(ncID, varID_global, 'title', 'profiles of aerosol properties and water vapor content');
    netcdf.putAtt(ncID, varID_global, 'comment', PollyConfig.comment);
    cwd = pwd;
    cd(PicassoConfig.PicassoRootDir);
    gitInfo = getGitInfo();
    cd(cwd);
    netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

    % close file
    netcdf.close(ncID);

end