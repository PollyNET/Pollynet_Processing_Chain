function pollySaveProfiles_QC(data)
% POLLYSAVEPROFILES save the retrieved results, including backscatter, extinction coefficients, lidar ratio, volume/particles depolarization ratio and so on.
%
% USAGE:
%    pollySaveProfiles(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-08: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

%% channel mask
flagCh355FR = PollyConfig.isFR & PollyConfig.is355nm & PollyConfig.isTot;
flagCh532FR = PollyConfig.isFR & PollyConfig.is532nm & PollyConfig.isTot;
flagCh1064FR = PollyConfig.isFR & PollyConfig.is1064nm & PollyConfig.isTot;


%%%%%%%%%%%%%%%%Works currently only for advanced systems like arielle,
%%%%%%%%%%%%%%%%lacros, cvo etc...NOT for CGE
missing_value = -999;
%%%%%%%%%%%%%%%%%%%%%here QC starts%%%%%%%%%%%%%%%%%%%%%
if size(PollyConfig.heightFullOverlap,2) >= 12 
for iGrp = 1:size(data.clFreGrps, 1)
    no_fill_low_profile =false;
    % QC flags will yet be implemetned only for standard products
    
    % cutting lower edge
    % no cutting, but filling?
    if no_fill_low_profile
        % UV FF
        data.aerBsc355_raman(iGrp,(data.height <= 300)) = missing_value;
        data.aerExt355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value; %these numbers in the array  are hardcoded and should be chnages accoridng to chanel tags
        data.LR355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.pdr355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.pdr_klett_355(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.aerBsc355_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        
        %VIS FF
        data.aerBsc532_raman(iGrp,(data.height <= 300)) = missing_value;
        data.aerExt532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.LR532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.pdr532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.pdr532_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.aerBsc532_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        %IR FF
        data.aerBsc1064_raman(iGrp,(data.height <= 300)) = missing_value;
        data.aerExt1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.LR1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.pdr1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.pdr1064_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.aerBsc1064_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        %UV NF
    else
        %UV NF
        data.aerBsc355_NR_raman(iGrp,(data.height <= 100)) = missing_value;
        data.aerExt355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(12))) = missing_value;
        data.LR355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(12))) = missing_value;
        %data.pdr355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        %data.pdr_klett_NR_355(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.aerBsc355_NR_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        
        %VIS NF
        data.aerBsc532_NR_raman(iGrp,(data.height <= 100)) = missing_value;
        data.aerExt532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(10))) = missing_value;
        data.LR532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(10))) = missing_value;
        %data.pdr532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(9))) = missing_value;
        %data.pdr532_NR_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(9))) = missing_value;
        data.aerBsc532_NR_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(9))) = missing_value;
        %%%%fill overlap region of FF with NF.
        % UV FF
        data.aerBsc355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = data.aerBsc355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3)));
        data.aerExt355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = data.aerExt355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3)));
        data.LR355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) =  data.LR355_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3)));
        data.pdr355_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.pdr_klett_355(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = missing_value;
        data.aerBsc355_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(3))) = data.aerBsc355_NR_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(3)));
        %VIS FF
        data.aerBsc532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = data.aerBsc532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6)));
        data.aerExt532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = data.aerExt532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6)));
        data.LR532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) =  data.LR532_NR_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6)));
        data.pdr532_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.pdr532_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = missing_value;
        data.aerBsc532_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(6))) = data.aerBsc532_NR_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(6)));
        %IR FF
        data.aerBsc1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.aerExt1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.LR1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.pdr1064_raman(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.pdr1064_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        data.aerBsc1064_klett(iGrp,(data.height <= PollyConfig.heightFullOverlap(8))) = missing_value;
        
    end
    
    %removing values with no aerosol
    bsc532_thres=1e-7; %--> 10 times beta ef?
    data.aerBsc355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.aerExt355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.LR355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.pdr355_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.aerBsc532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.aerExt532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.LR532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.pdr532_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.aerBsc1064_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    data.pdr1064_raman((data.aerBsc532_raman <= bsc532_thres)) = missing_value;
    
%%%%%%%%%%%%%%%%%%QC end
    
    startTime = data.mTime(data.clFreGrps(iGrp, 1));
    endTime = data.mTime(data.clFreGrps(iGrp, 2));

    ncFile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_profiles_QC.nc', rmext(PollyDataInfo.pollyDataFile), datestr(startTime, 'HHMM'), datestr(endTime, 'HHMM')));

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
    varID_shots = netcdf.defVar(ncID, 'shots', 'NC_INT', dimID_method);
    varID_zenith_angle = netcdf.defVar(ncID, 'zenith_angle', 'NC_FLOAT', dimID_method);
    varID_aerBsc_klett_355 = netcdf.defVar(ncID, 'aerBsc_klett_355', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_klett_355 = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_klett_532 = netcdf.defVar(ncID, 'aerBsc_klett_532', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_klett_532 = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_klett_1064 = netcdf.defVar(ncID, 'aerBsc_klett_1064', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_klett_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_klett_1064', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_355 = netcdf.defVar(ncID, 'aerBsc_aeronet_355', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_aeronet_355 = netcdf.defVar(ncID, 'uncertainty_aerBsc_aeronet_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_532 = netcdf.defVar(ncID, 'aerBsc_aeronet_532', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_aeronet_532 = netcdf.defVar(ncID, 'uncertainty_aerBsc_aeronet_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_aeronet_1064 = netcdf.defVar(ncID, 'aerBsc_aeronet_1064', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_aeronet_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_aeronet_1064', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_355 = netcdf.defVar(ncID, 'aerBsc_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_raman_355 = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_532 = netcdf.defVar(ncID, 'aerBsc_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_raman_532 = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_raman_1064 = netcdf.defVar(ncID, 'aerBsc_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_355 = netcdf.defVar(ncID, 'aerExt_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_raman_355 = netcdf.defVar(ncID, 'uncertainty_aerExt_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_532 = netcdf.defVar(ncID, 'aerExt_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_raman_532 = netcdf.defVar(ncID, 'uncertainty_aerExt_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerExt_raman_1064 = netcdf.defVar(ncID, 'aerExt_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_aerExt_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_355 = netcdf.defVar(ncID, 'aerLR_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_raman_355 = netcdf.defVar(ncID, 'uncertainty_aerLR_raman_355', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_532 = netcdf.defVar(ncID, 'aerLR_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_raman_532 = netcdf.defVar(ncID, 'uncertainty_aerLR_raman_532', 'NC_FLOAT', dimID_height);
    varID_aerLR_raman_1064 = netcdf.defVar(ncID, 'aerLR_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_aerLR_raman_1064', 'NC_FLOAT', dimID_height);
    varID_aerBsc_RR_355 = netcdf.defVar(ncID, 'aerBsc_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_RR_355 = netcdf.defVar(ncID, 'uncertainty_aerBsc_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerBsc_RR_532 = netcdf.defVar(ncID, 'aerBsc_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_RR_532 = netcdf.defVar(ncID, 'uncertainty_aerBsc_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerBsc_RR_1064 = netcdf.defVar(ncID, 'aerBsc_RR_1064', 'NC_FLOAT', dimID_height);
    varID_aerBscStd_RR_1064 = netcdf.defVar(ncID, 'uncertainty_aerBsc_RR_1064', 'NC_FLOAT', dimID_height);
    varID_aerExt_RR_355 = netcdf.defVar(ncID, 'aerExt_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_RR_355 = netcdf.defVar(ncID, 'uncertainty_aerExt_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerExt_RR_532 = netcdf.defVar(ncID, 'aerExt_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_RR_532 = netcdf.defVar(ncID, 'uncertainty_aerExt_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerExt_RR_1064 = netcdf.defVar(ncID, 'aerExt_RR_1064', 'NC_FLOAT', dimID_height);
    varID_aerExtStd_RR_1064 = netcdf.defVar(ncID, 'uncertainty_aerExt_RR_1064', 'NC_FLOAT', dimID_height);
    varID_aerLR_RR_355 = netcdf.defVar(ncID, 'aerLR_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_RR_355 = netcdf.defVar(ncID, 'uncertainty_aerLR_RR_355', 'NC_FLOAT', dimID_height);
    varID_aerLR_RR_532 = netcdf.defVar(ncID, 'aerLR_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_RR_532 = netcdf.defVar(ncID, 'uncertainty_aerLR_RR_532', 'NC_FLOAT', dimID_height);
    varID_aerLR_RR_1064 = netcdf.defVar(ncID, 'aerLR_RR_1064', 'NC_FLOAT', dimID_height);
    varID_aerLRStd_RR_1064 = netcdf.defVar(ncID, 'uncertainty_aerLR_RR_1064', 'NC_FLOAT', dimID_height);
    varID_vdr_klett_532 = netcdf.defVar(ncID, 'volDepol_klett_532', 'NC_FLOAT', dimID_height);
    varID_vdrStd_klett_532 = netcdf.defVar(ncID, 'uncertainty_volDepol_klett_532', 'NC_FLOAT', dimID_height);
    varID_vdr_klett_355 = netcdf.defVar(ncID, 'volDepol_klett_355', 'NC_FLOAT', dimID_height);
    varID_vdrStd_klett_355 = netcdf.defVar(ncID, 'uncertainty_volDepol_klett_355', 'NC_FLOAT', dimID_height);
    varID_vdr_raman_532 = netcdf.defVar(ncID, 'volDepol_raman_532', 'NC_FLOAT', dimID_height);
    varID_vdrStd_raman_532 = netcdf.defVar(ncID, 'uncertainty_volDepol_raman_532', 'NC_FLOAT', dimID_height);
    varID_vdr_raman_355 = netcdf.defVar(ncID, 'volDepol_raman_355', 'NC_FLOAT', dimID_height);
    varID_vdrStd_raman_355 = netcdf.defVar(ncID, 'uncertainty_volDepol_raman_355', 'NC_FLOAT', dimID_height);
    varID_pdr_klett_532 = netcdf.defVar(ncID, 'parDepol_klett_532', 'NC_FLOAT', dimID_height);
    varID_pdr_klett_355 = netcdf.defVar(ncID, 'parDepol_klett_355', 'NC_FLOAT', dimID_height);
    varID_pdr_raman_532 = netcdf.defVar(ncID, 'parDepol_raman_532', 'NC_FLOAT', dimID_height);
    varID_pdr_raman_355 = netcdf.defVar(ncID, 'parDepol_raman_355', 'NC_FLOAT', dimID_height);
    varID_pdrStd_klett_532 = netcdf.defVar(ncID, 'uncertainty_parDepol_klett_532', 'NC_FLOAT', dimID_height);
    varID_pdrStd_klett_355 = netcdf.defVar(ncID, 'uncertainty_parDepol_klett_355', 'NC_FLOAT', dimID_height);
    varID_pdrStd_raman_532 = netcdf.defVar(ncID, 'uncertainty_parDepol_raman_532', 'NC_FLOAT', dimID_height);
    varID_pdrStd_raman_355 = netcdf.defVar(ncID, 'uncertainty_parDepol_raman_355', 'NC_FLOAT', dimID_height);
    varID_vdr_klett_1064 = netcdf.defVar(ncID, 'volDepol_klett_1064', 'NC_FLOAT', dimID_height);
    varID_vdrStd_klett_1064 = netcdf.defVar(ncID, 'uncertainty_volDepol_klett_1064', 'NC_FLOAT', dimID_height);
    varID_vdr_raman_1064 = netcdf.defVar(ncID, 'volDepol_raman_1064', 'NC_FLOAT', dimID_height);
    varID_vdrStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_volDepol_raman_1064', 'NC_FLOAT', dimID_height);
    varID_pdr_klett_1064 = netcdf.defVar(ncID, 'parDepol_klett_1064', 'NC_FLOAT', dimID_height);
    varID_pdr_raman_1064 = netcdf.defVar(ncID, 'parDepol_raman_1064', 'NC_FLOAT', dimID_height);
    varID_pdrStd_klett_1064 = netcdf.defVar(ncID, 'uncertainty_parDepol_klett_1064', 'NC_FLOAT', dimID_height);
    varID_pdrStd_raman_1064 = netcdf.defVar(ncID, 'uncertainty_parDepol_raman_1064', 'NC_FLOAT', dimID_height);
    varID_molBsc_355 = netcdf.defVar(ncID, 'molBsc_355', 'NC_FLOAT', dimID_height);
    varID_molBsc_532 = netcdf.defVar(ncID, 'molBsc_532', 'NC_FLOAT', dimID_height);
    varID_molBsc_1064 = netcdf.defVar(ncID, 'molBsc_1064', 'NC_FLOAT', dimID_height);
   
    
    varID_WVMR = netcdf.defVar(ncID, 'WVMR', 'NC_FLOAT', dimID_height);
    varID_WVMR_no_QC = netcdf.defVar(ncID, 'WVMR_no_QC', 'NC_FLOAT', dimID_height);
    varID_WVMR_error = netcdf.defVar(ncID, 'uncertainty_WVMR', 'NC_FLOAT', dimID_height);
    varID_WVMR_rel_error = netcdf.defVar(ncID, 'WVMR_rel_error', 'NC_FLOAT', dimID_height);
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
    netcdf.defVarFill(ncID, varID_aerBscStd_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_aeronet_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_aeronet_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_aeronet_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_aeronet_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBsc_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerBscStd_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExt_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerExtStd_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_RR_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_RR_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLR_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_aerLRStd_RR_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_klett_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_klett_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_raman_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_raman_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdr_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_vdrStd_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_klett_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdr_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_pdrStd_raman_1064, false, missing_value);
    netcdf.defVarFill(ncID, varID_molBsc_355, false, missing_value);
    netcdf.defVarFill(ncID, varID_molBsc_532, false, missing_value);
    netcdf.defVarFill(ncID, varID_molBsc_1064, false, missing_value);
    
    
    netcdf.defVarFill(ncID, varID_WVMR, false, missing_value);
    netcdf.defVarFill(ncID, varID_WVMR_no_QC, false, missing_value);
    netcdf.defVarFill(ncID, varID_WVMR_error, false, missing_value);
    netcdf.defVarFill(ncID, varID_WVMR_rel_error, false, missing_value);
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
    netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_aeronet_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_aeronet_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_aeronet_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_aeronet_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBsc_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerBscStd_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExt_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerExtStd_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_RR_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_RR_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLR_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_aerLRStd_RR_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_klett_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_klett_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_raman_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_raman_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdr_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_vdrStd_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_klett_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdr_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_pdrStd_raman_1064, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_molBsc_355, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_molBsc_532, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_molBsc_1064, true, true, 5);
    
    netcdf.defVarDeflate(ncID, varID_WVMR, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_WVMR_error, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_WVMR_no_QC, true, true, 5);
    netcdf.defVarDeflate(ncID, varID_WVMR_rel_error, true, true, 5);
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
    netcdf.putVar(ncID, varID_aerBscStd_klett_355, single(fillmissing(data.aerBscStd355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_klett_532, single(fillmissing(data.aerBsc532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_klett_532, single(fillmissing(data.aerBscStd532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_klett_1064, single(fillmissing(data.aerBsc1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_klett_1064, single(fillmissing(data.aerBscStd1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_355, single(fillmissing(data.aerBsc355_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_aeronet_355, single(fillmissing(data.aerBscStd355_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_532, single(fillmissing(data.aerBsc532_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_aeronet_532, single(fillmissing(data.aerBscStd532_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_aeronet_1064, single(fillmissing(data.aerBsc1064_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_aeronet_1064, single(fillmissing(data.aerBscStd1064_aeronet(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_355, single(fillmissing(data.aerBsc355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_raman_355, single(fillmissing(data.aerBscStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_532, single(fillmissing(data.aerBsc532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_raman_532, single(fillmissing(data.aerBscStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_raman_1064, single(fillmissing(data.aerBsc1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_raman_1064, single(fillmissing(data.aerBscStd1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_355, single(fillmissing(data.aerExt355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_raman_355, single(fillmissing(data.aerExtStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_532, single(fillmissing(data.aerExt532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_raman_532, single(fillmissing(data.aerExtStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_raman_1064, single(fillmissing(data.aerExt1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_raman_1064, single(fillmissing(data.aerExtStd1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_355, single(fillmissing(data.LR355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_raman_355, single(fillmissing(data.LRStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_532, single(fillmissing(data.LR532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_raman_532, single(fillmissing(data.LRStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_raman_1064, single(fillmissing(data.LR1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_raman_1064, single(fillmissing(data.LRStd1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_RR_355, single(fillmissing(data.aerBsc355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_RR_355, single(fillmissing(data.aerBscStd355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_RR_532, single(fillmissing(data.aerBsc532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_RR_532, single(fillmissing(data.aerBscStd532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBsc_RR_1064, single(fillmissing(data.aerBsc1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerBscStd_RR_1064, single(fillmissing(data.aerBscStd1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_RR_355, single(fillmissing(data.aerExt355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_RR_355, single(fillmissing(data.aerExtStd355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_RR_532, single(fillmissing(data.aerExt532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_RR_532, single(fillmissing(data.aerExtStd532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExt_RR_1064, single(fillmissing(data.aerExt1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerExtStd_RR_1064, single(fillmissing(data.aerExtStd1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_RR_355, single(fillmissing(data.LR355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_RR_355, single(fillmissing(data.LRStd355_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_RR_532, single(fillmissing(data.LR532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_RR_532, single(fillmissing(data.LRStd532_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLR_RR_1064, single(fillmissing(data.LR1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_aerLRStd_RR_1064, single(fillmissing(data.LRStd1064_RR(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_klett_532, single(fillmissing(data.vdr532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_klett_532, single(fillmissing(data.vdrStd532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_klett_355, single(fillmissing(data.vdr355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_klett_355, single(fillmissing(data.vdrStd355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_raman_532, single(fillmissing(data.vdr532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_raman_532, single(fillmissing(data.vdrStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_raman_355, single(fillmissing(data.vdr355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_raman_355, single(fillmissing(data.vdrStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_klett_532, single(fillmissing(data.pdr532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_klett_532, single(fillmissing(data.pdrStd532_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_klett_355, single(fillmissing(data.pdr355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_klett_355, single(fillmissing(data.pdrStd355_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_raman_532, single(fillmissing(data.pdr532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_raman_532, single(fillmissing(data.pdrStd532_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_raman_355, single(fillmissing(data.pdr355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_raman_355, single(fillmissing(data.pdrStd355_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_klett_1064, single(fillmissing(data.vdr1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_klett_1064, single(fillmissing(data.vdrStd1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdr_raman_1064, single(fillmissing(data.vdr1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_vdrStd_raman_1064, single(fillmissing(data.vdrStd1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_klett_1064, single(fillmissing(data.pdr1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_klett_1064, single(fillmissing(data.pdrStd1064_klett(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdr_raman_1064, single(fillmissing(data.pdr1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_pdrStd_raman_1064, single(fillmissing(data.pdrStd1064_raman(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_molBsc_355, single(fillmissing(data.molBsc355(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_molBsc_532, single(fillmissing(data.molBsc532(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_molBsc_1064, single(fillmissing(data.molBsc1064(iGrp, :), missing_value)));
    
    netcdf.putVar(ncID, varID_WVMR, single(fillmissing(data.wvmr(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_WVMR_no_QC, single(fillmissing(data.wvmr_no_QC(iGrp, :), missing_value)));
    netcdf.putVar(ncID, varID_WVMR_error, single(fillmissing(data.wvmr_error(iGrp, :), missing_value)));%temporarily stored relative error for validation
    netcdf.putVar(ncID, varID_WVMR_rel_error, single(fillmissing(data.wvmr_rel_error(iGrp, :), missing_value)));%temporarily stored relative error for validation
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

    % aerBscStd_klett_355
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR355, PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_klett_355, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

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

    % aerBscStd_klett_532
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR532, PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_klett_532, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

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

    % aerBscStd_klett_1064
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'retrieving_info', sprintf('Fixed lidar ratio: %5.1f [Sr]; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', PollyConfig.LR1064, PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_klett_1064, 'comment', sprintf('The result is retrieved with Klett method. If you want to know more about the algorithm, please go to Klett, J. D. (1985). \"Lidar inversion with variable backscatter/extinction ratios.\" Applied optics 24(11): 1638-1643.'));

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

    % aerBscStd_aeronet_355
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD355(iGrp), PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_klett_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_355, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

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

    % aerBscStd_aeronet_532
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD532(iGrp), PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_klett_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_532, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

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

    % aerBscStd_aeronet_1064
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'retrieving_info', sprintf('Delta AOD: %7.5f; Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]', data.deltaAOD1064(iGrp), PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_klett_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerBscStd_aeronet_1064, 'comment', sprintf('The result is retrieved with constrained-AOD method. In order to reach a good agreement between the AOD from lidar and collocated sunphotometer, the lidar ratio was tuned till the deviation converged.'));

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

    % aerBscStd_raman_355
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

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

    % aerBscStd_raman_532
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

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

    % aerBscStd_raman_1064
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

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

    % aerExtStd_raman_355
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'long_name', 'uncertainty of aerosol extinction coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

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

    % aerExtStd_raman_532
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'long_name', 'uncertainty of aerosol extinction coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

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

    % aerExtStd_raman_1064
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'long_name', 'uncertainty of aerosol extinction coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_355
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLRStd_raman_355
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'long_name', 'uncertainty of aerosol lidar ratio at 355 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_raman_355, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_532
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLRStd_raman_532
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'long_name', 'uncertainty of aerosol lidar ratio at 532 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_raman_532, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_raman_1064
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with Raman method');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %5.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerLR_raman_1064, 'comment', sprintf('This result is based on extrapolated extinction. Not by real Raman method. Be careful!'));

    % aerLRStd_raman_1064
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'long_name', 'uncertainty of aerosol lidar ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_raman_1064, 'comment', sprintf('The result is retrieved with Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_RR_355
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'long_name', 'aerosol backscatter coefficient at 355 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'standard_name', 'beta (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBscStd_RR_355
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'long_name', 'uncertainty of aerosol backscatter coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta355 * 1e6, PollyConfig.heightFullOverlap(flagCh355FR), PollyConfig.maxDecomHeight355, PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_RR_532
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'long_name', 'aerosol backscatter coefficient at 532 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'standard_name', 'beta (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBscStd_RR_532
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'long_name', 'uncertainty of aerosol backscatter coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta532 * 1e6, PollyConfig.heightFullOverlap(flagCh532FR), PollyConfig.maxDecomHeight532, PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBsc_RR_1064
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'long_name', 'aerosol backscatter coefficient at 1064 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'standard_name', 'beta (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBsc_RR_1064, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerBscStd_RR_1064
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'long_name', 'uncertainty of aerosol backscatter coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'standard_name', 'sigma (beta)');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'retrieving_info', sprintf('Reference value: %2e [Mm^{-1}*Sr^{-1}]; Reference search range: %8.2f - %8.2f [m]; Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.refBeta1064 * 1e6, PollyConfig.heightFullOverlap(flagCh1064FR), PollyConfig.maxDecomHeight1064, PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerBscStd_RR_1064, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_RR_355
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'long_name', 'aerosol extinction coefficient at 355 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'standard_name', 'alpha (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExtStd_RR_355
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'long_name', 'uncertainty of aerosol extinction coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_355 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_RR_532
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'long_name', 'aerosol extinction coefficient at 532 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'standard_name', 'alpha (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExtStd_RR_532
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'long_name', 'uncertainty of aerosol extinction coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_532 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerExt_RR_1064
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'unit_html', 'm<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'long_name', 'aerosol extinction coefficient at 1064 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'standard_name', 'alpha (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'plot_range', PollyConfig.xLim_Profi_Ext/1e6);
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExt_RR_1064, 'comment', sprintf('This result is extrapolated by Raman extinction at 532 nm. Not real Raman extinction. Be careful!!!'));

    % aerExtStd_RR_1064
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'unit', 'm^-1');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'long_name', 'uncertainty of aerosol extinction coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'standard_name', 'sigma (alpha)');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %4.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerExtStd_RR_1064, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_RR_355
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'long_name', 'aerosol lidar ratio at 355 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'standard_name', 'S (aer, 355 nm)');
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLRStd_RR_355
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'long_name', 'uncertainty of aerosol lidar ratio at 355 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_355 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_RR_355, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_RR_532
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'long_name', 'aerosol lidar ratio at 532 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'standard_name', 'S (aer, 532 nm)');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLR_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLRStd_RR_532
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'long_name', 'uncertainty of aerosol lidar ratio at 532 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_532 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_RR_532, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % aerLR_RR_1064
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'long_name', 'aerosol lidar ratio at 1064 nm retrieved with rotation Raman method');
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'standard_name', 'S (aer, 1064 nm)');
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'plot_range', PollyConfig.xLim_Profi_LR);
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; Angstroem exponent: %5.2f', PollyConfig.smoothWin_raman_1064 * data.hRes, PollyConfig.angstrexp));
    netcdf.putAtt(ncID, varID_aerLR_RR_1064, 'comment', sprintf('This result is based on extrapolated extinction. Not by real Raman method. Be careful!'));

    % aerLRStd_RR_1064
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'unit', 'sr');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'long_name', 'uncertainty of aerosol lidar ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'standard_name', 'sigma (S)');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]', PollyConfig.smoothWin_raman_1064 * data.hRes));
    netcdf.putAtt(ncID, varID_aerLRStd_RR_1064, 'comment', sprintf('The result is retrieved with rotation Raman method. For information, please go to Ansmann, A., et al. (1992). \"Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar.\" Applied optics 31(33): 7113-7131.'));

    % vdr_klett_532
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'long_name', 'volume linear depolarization ratio at 532 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_vdr_klett_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd532_klett
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'long_name', 'uncertainty of volume depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'standard_name', 'sigma (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_vdrStd_klett_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdr_klett_355
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'long_name', 'volume linear depolarization ratio at 355 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'standard_name', 'delta (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_vdr_klett_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd355_klett
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'long_name', 'uncertainty of volume depolarization ratio at 355 nm');
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'standard_name', 'sigma (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_vdrStd_klett_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdr_klett_1064
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'long_name', 'volume linear depolarization ratio at 1064 nm with the same smoothing as Klett method');
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'standard_name', 'delta (vol, 1064 nm)');
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_vdr_klett_1064, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd1064_klett
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'long_name', 'uncertainty of volume depolarization ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'standard_name', 'sigma (vol, 1064 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_vdrStd_klett_1064, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdr_raman_532
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'long_name', 'volume linear depolarization ratio at 532 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'standard_name', 'delta (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_vdr_raman_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd532_raman
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'long_name', 'uncertainty of volume depolarization ratio at 532 nm');
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'standard_name', 'sigma (vol, 532 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_vdrStd_raman_532, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdr_raman_355
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'long_name', 'volume linear depolarization ratio at 355 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'standard_name', 'delta (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_vdr_raman_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd355_raman
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'long_name', 'uncertainty of volume depolarization ratio at 355 nm');
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'standard_name', 'sigma (vol, 355 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_vdrStd_raman_355, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdr_raman_1064
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'long_name', 'volume linear depolarization ratio at 1064 nm with the same smoothing as Raman method');
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'standard_name', 'delta (vol, 1064 nm)');
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_vdr_raman_1064, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    % vdrStd1064_raman
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'long_name', 'uncertainty of volume depolarization ratio at 1064 nm');
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'standard_name', 'sigma (vol, 1064 nm)');
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_vdrStd_raman_1064, 'comment', sprintf('Depolarization channel was calibrated with +- 45 \\degree method. You can find more information in Freudenthaler, V., et al. (2009). \"Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006.\" Tellus B 61(1): 165-179.'));

    
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

    % pdrStd_klett_532
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'long_name', 'uncertainty of particle linear depolarization ratio at 532 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'standard_name', 'sigma (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdrStd_klett_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

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

    % pdrStd_klett_355
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'long_name', 'uncertainty of particle linear depolarization ratio at 355 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'standard_name', 'sigma (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdrStd_klett_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_klett_1064
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'long_name', 'particle linear depolarization ratio at 1064 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'standard_name', 'delta (par, 1064 nm)');
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'molecular_depolarization_ratio', data.mdr1064(iGrp));
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_pdr_klett_1064, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdrStd_klett_1064
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'long_name', 'uncertainty of particle linear depolarization ratio at 1064 nm with Klett backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'standard_name', 'sigma (par, 1064 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'molecular_depolarization_ratio', data.mdr1064(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_klett_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_pdrStd_klett_1064, 'comment', sprintf('The aerosol backscatter profile was retrieved by Klett method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

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

    % pdrStd_raman_532
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'long_name', 'uncertainty of particle linear depolarization ratio at 532 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'standard_name', 'sigma (par, 532 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'molecular_depolarization_ratio', data.mdr532(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_532 * data.hRes, data.polCaliEta532));
    netcdf.putAtt(ncID, varID_pdrStd_raman_532, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

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

    % pdrStd_raman_355
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'long_name', 'uncertainty of particle linear depolarization ratio at 355 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'standard_name', 'sigma (par, 355 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'molecular_depolarization_ratio', data.mdr355(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_355 * data.hRes, data.polCaliEta355));
    netcdf.putAtt(ncID, varID_pdrStd_raman_355, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdr_raman_1064
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'long_name', 'particle linear depolarization ratio at 1064 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'standard_name', 'delta (par, 1064 nm)');
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'molecular_depolarization_ratio', data.mdr1064(iGrp));
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_pdr_raman_1064, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % pdrStd_raman_1064
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'unit', '');
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'long_name', 'uncertainty of particle linear depolarization ratio at 1064 nm with Raman backscatter');
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'standard_name', 'sigma (par, 1064 nm)');
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'plot_range', [0, 0.4]);
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'molecular_depolarization_ratio', data.mdr1064(iGrp));
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'retrieving_info', sprintf('Smoothing window: %d [m]; eta: %f', PollyConfig.smoothWin_raman_1064 * data.hRes, data.polCaliEta1064));
    netcdf.putAtt(ncID, varID_pdrStd_raman_1064, 'comment', sprintf('The aerosol backscatter profile was retrieved by Raman method. The uncertainty of particle depolarization ratio will be very large at aerosol-free altitude. Please take care!'));

    % molBsc_355
    netcdf.putAtt(ncID, varID_molBsc_355, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_molBsc_355, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_molBsc_355, 'long_name', 'molecular backscatter coefficient at 355 nm');
    netcdf.putAtt(ncID, varID_molBsc_355, 'standard_name', 'beta (mol, 355 nm)');
    netcdf.putAtt(ncID, varID_molBsc_355, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_molBsc_355, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_molBsc_355, 'source', CampaignConfig.name);
        
    % molBsc_532
    netcdf.putAtt(ncID, varID_molBsc_532, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_molBsc_532, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_molBsc_532, 'long_name', 'molecular backscatter coefficient at 532 nm');
    netcdf.putAtt(ncID, varID_molBsc_532, 'standard_name', 'beta (mol, 532 nm)');
    netcdf.putAtt(ncID, varID_molBsc_532, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_molBsc_532, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_molBsc_532, 'source', CampaignConfig.name);
    
    % molBsc_1064
    netcdf.putAtt(ncID, varID_molBsc_1064, 'unit', 'sr^-1 m^-1');
    netcdf.putAtt(ncID, varID_molBsc_1064, 'unit_html', 'sr<sup>-1</sup> m<sup>-1</sup>')
    netcdf.putAtt(ncID, varID_molBsc_1064, 'long_name', 'molecular backscatter coefficient at 1064 nm');
    netcdf.putAtt(ncID, varID_molBsc_1064, 'standard_name', 'beta (mol, 1064 nm)');
    netcdf.putAtt(ncID, varID_molBsc_1064, 'plot_range', PollyConfig.xLim_Profi_Bsc/1e6);
    netcdf.putAtt(ncID, varID_molBsc_1064, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_molBsc_1064, 'source', CampaignConfig.name);
    
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

     % WVMR_no_QC
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'unit', 'g kg^-1');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'unit_html', 'g kg<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'long_name', 'water vapor mixing ratio without Quality control');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'standard_name', 'WVMR_no_QC');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'plot_range', PollyConfig.xLim_Profi_WVMR);
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'wv_calibration_constant_used', data.wvconstUsed);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'retrieving_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', data.hRes, thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));
    netcdf.putAtt(ncID, varID_WVMR_no_QC, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));

    
    % WVMR_error
    netcdf.putAtt(ncID, varID_WVMR_error, 'unit', 'g kg^-1');
    netcdf.putAtt(ncID, varID_WVMR_error, 'unit_html', 'g kg<sup>-1</sup>');
    netcdf.putAtt(ncID, varID_WVMR_error, 'long_name', 'absolute water vapor mixing ratio uncertainty');
    netcdf.putAtt(ncID, varID_WVMR_error, 'standard_name', 'uncertainty_WVMR');
    netcdf.putAtt(ncID, varID_WVMR_error, 'plot_range', PollyConfig.xLim_Profi_WV_RH);
    netcdf.putAtt(ncID, varID_WVMR_error, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_WVMR_error, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_WVMR_error, 'wv_calibration_constant_used', data.wvconstUsed);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR_error, 'retrieving_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', data.hRes, thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));
    netcdf.putAtt(ncID, varID_WVMR_error, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));

    % WVMR_rel_error
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'unit', '1');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'unit_html', '1');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'long_name', 'relative error of the water vapor mixing ratio');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'standard_name', 'WVMR_rel_error');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'plot_range', [0, 1]);
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'plot_scale', 'linear');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'wv_calibration_constant_used', data.wvconstUsed);
    thisStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'retrieving_info', sprintf('Smoothing window: %d [m]; flagCalibrated: %s; Calibration instrument: %s; Number of successful calibration: %d;', data.hRes, thisStr{1}, data.IWVAttri.source, data.wvconstUsedInfo.nIWVCali));
    netcdf.putAtt(ncID, varID_WVMR_rel_error, 'comment', sprintf('The difference of AOD between 387 and 407 nm is not taken into account. More information about the water vapor calibration, please go to Dai, G., et al. (2018). \"Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data.\" Atmospheric Measurement Techniques 11(5): 2735-2748.'));

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
    netcdf.putAtt(ncID, varID_global, 'Licence', 'Creative Commons Attribution Share Alike 4.0 International (CC BY-SA 4.0)');
    netcdf.putAtt(ncID, varID_global, 'Data Policy', 'Each PollyNET site has Principal Investigator(s) (PI), responsible for deployment, maintenance and data collection. Information on which PI is responsible can be gathered via polly@tropos.de. The PI has priority use of the data collected at the site. The PI is entitled to be informed of any use of that data. Mandatory guidelines for data use and publication: Using PollyNET data or plots (also for presentations/workshops): Please consult with the PI or the PollyNET team (see contact_mail contact) before using data or plots! This will help to avoid misinterpretations of the lidar data and avoid the use of data from periods of malfunction of the instrument. Using PollyNET images/data on external websites: PIs and PollyNET must be asked for agreement and a link directed to polly.tropos.de must be included. Publishing PollyNET data and/or plots data: Offer authorship for the PI(s)! Acknowledge projects which have made the measurements possible according to PI(s) recommendation. PollyNET requests a notification of any published papers or reports or a brief description of other uses (e.g., posters, oral presentations, etc.) of data/plots used from PollyNET. This will help us determine the use of PollyNET data, which is helpful in optimizing product development and acquire new funding for future measurements. It also helps us to keep our product-related references up-to-date.');
    netcdf.putAtt(ncID, varID_global, 'location', CampaignConfig.location);
    netcdf.putAtt(ncID, varID_global, 'institute', PicassoConfig.institute);
    netcdf.putAtt(ncID, varID_global, 'source', CampaignConfig.name);
    netcdf.putAtt(ncID, varID_global, 'version', PicassoConfig.PicassoVersion);
    netcdf.putAtt(ncID, varID_global, 'reference', PicassoConfig.homepage);
    netcdf.putAtt(ncID, varID_global, 'contact', PicassoConfig.contact);
    netcdf.putAtt(ncID, varID_global, 'PicassoConfig_Info', data.PicassoConfig_saving_info);
    netcdf.putAtt(ncID, varID_global, 'PollyConfig_Info', data.PollyConfig_saving_info);
    netcdf.putAtt(ncID, varID_global, 'CampaignConfig_Info', data.CampaignConfig_saving_info);
    netcdf.putAtt(ncID, varID_global, 'PollyData_Info', data.PollyDataInfo_saving_info);
    cwd = pwd;
    cd(PicassoConfig.PicassoRootDir);
    gitInfo = getGitInfo();
    cd(cwd);
    netcdf.putAtt(ncID, varID_global, 'history', sprintf('Last processing time at %s by %s, git branch: %s, git commit: %s', tNow, mfilename, gitInfo.branch, gitInfo.hash));

    % close file
    netcdf.close(ncID);
end
end
