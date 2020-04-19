function [report] = pollynet_processing_chain_pollyxt_tjk(taskInfo, config)
%POLLYNET_PROCESSING_CHAIN_pollyxt_tjk processing the data from pollyxt
%Example:
%   [report] = pollynet_processing_chain_pollyxt_tjk(taskInfo, config)
%Inputs:
%   fileinfo_new: struct
%       todoPath: cell
%           path of the todo_filelist
%       dataPath: cell
%           directory to the respective polly lidar data
%       dataFilename: cell
%           filename of the polly data
%       zipFile: cell
%           filename of the zipped polly data
%       dataSize: array
%           file size of the zipped polly data
%       pollyVersion: cell
%           polly lidar label. e.g., 'POLLYXT_TROPOS'
%   config: struct
%       polly processing configurations.
%Outputs:
%   report: cell array
%       information about each figure.
%History:
%   2018-12-17. First edition by Zhenping   
%Contact:
%   zhenping@tropos.de

report = cell(0);
global processInfo campaignInfo defaults

%% create folder
results_folder = fullfile(processInfo.results_folder, campaignInfo.name, ...
                          datestr(taskInfo.dataTime, 'yyyy'), ...
                          datestr(taskInfo.dataTime, 'mm'), ...
                          datestr(taskInfo.dataTime, 'dd'));
pic_folder = fullfile(processInfo.pic_folder, ...
                      campaignInfo.name, ...
                      datestr(taskInfo.dataTime, 'yyyy'), ...
                      datestr(taskInfo.dataTime, 'mm'), ...
                      datestr(taskInfo.dataTime, 'dd'));
if ~ exist(results_folder, 'dir')
    fprintf('Create a new folder to saving the results for %s at %s\n%s\n', ...
            campaignInfo.name, ...
            datestr(taskInfo.dataTime, 'yyyymmdd HH:MM'), ...
            results_folder);
    mkdir(results_folder);
end
if ~ exist(pic_folder, 'dir')
    fprintf('Create a new folder to saving the plots for %s\n%s\n', ...
            campaignInfo.name, ...
            datestr(taskInfo.dataTime, 'yyyymmdd HH:MM'), ...
            pic_folder);
    mkdir(pic_folder);
end

dbFile = fullfile(processInfo.results_folder, campaignInfo.name , ...
                  sprintf('%s_calibration.db', campaignInfo.name));

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', ...
        tNow(), ...
        campaignInfo.name, ...
        taskInfo.dataFilename);
data = polly_read_rawdata(fullfile(taskInfo.todoPath, ...
                                   taskInfo.dataPath, ...
                                   taskInfo.dataFilename), ...
                'flagFilterFalseMShots', config.flagFilterFalseMShots, ...
                'flagCorrectFalseMShots', config.flagCorrectFalseMShots, ...
                'flagDeleteData', processInfo.flagDeleteData, ...
                'dataFileFormat', config.dataFileFormat);
if isempty(data.rawSignal)
    warning('No measurement data in %s for %s.\n', ...
            taskInfo.dataFilename, campaignInfo.name);
    return;
end
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
laserlogbookFile = fullfile(taskInfo.todoPath, ...
                            taskInfo.dataPath, ...
                            sprintf('%s.laserlogbook.txt', ...
                                    taskInfo.dataFilename));
fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', ...
        tNow(), campaignInfo.name, laserlogbookFile);
monitorStatus = pollyxt_read_laserlogbook(laserlogbookFile, ...
                                          processInfo.flagDeleteData);
data.monitorStatus = monitorStatus;
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), campaignInfo.name);
data = pollyxt_preprocess(data, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
flagSaturation = pollyxt_saturationdetect(data, config);
data.flagSaturation = flagSaturation;
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', ...
        tNow(), campaignInfo.name);
[data, depCaliAttri] = pollyxt_depolcali(data, config, dbFile);
data.depCaliAttri = depCaliAttri;
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagChannel532NR = config.isNR & config.is532nm & config.isTot;
flagChannel532FR = config.isFR & config.is532nm & config.isTot;
if any(flagChannel532FR)
    PCR532FR = squeeze(data.signal(flagChannel532FR, :, :)) ./ ...
               repmat(data.mShots(flagChannel532FR, :), ...
                      numel(data.height), 1) * 150 / data.hRes;
    flagCloudFree8km_FR = polly_cloudscreen(data.height, PCR532FR, ...
        config.maxSigSlope4FilterCloud, ...
        [config.heightFullOverlap(flagChannel532FR), 7000]);
else
    flagCloudFree8km_FR = true(size(data.mTime));
end

if any(flagChannel532NR)
    PCR532NR = squeeze(data.signal(flagChannel532NR, :, :)) ./ ...
               repmat(data.mShots(flagChannel532NR, :), ...
               numel(data.height), 1) * 150 / data.hRes;
    flagCloudFree2km = polly_cloudscreen(data.height, PCR532NR, ...
        config.maxSigSlope4FilterCloud_NR, ...
        [config.heightFullOverlap(flagChannel532NR), 3000]);
else
    flagCloudFree2km = true(size(data.mTime));
end
flagCloudFree8km = flagCloudFree8km_FR & flagCloudFree2km;

data.flagCloudFree2km = flagCloudFree2km & (~ data.shutterOnMask);
data.flagCloudFree8km = flagCloudFree8km & (~ data.shutterOnMask);
fprintf('[%s] Finish cloud-screen.\n', tNow());

%% overlap estimation
fprintf('\n[%s] Start to estimate the overlap function.\n', tNow());
[data, overlapAttri] = pollyxt_overlap(data, config);
fprintf('[%s] Finish.\n', tNow());

%% split the cloud free profiles into contiguous subgroups
fprintf('\n[%s] Start to split the cloud free profiles.\n', tNow());
cloudFreeGroups = pollyxt_splitcloudfree(data, config);
if isempty(cloudFreeGroups)
    fprintf('No qualified cloud-free groups were found.\n');
else
    fprintf('%d cloud-free groups were found.\n', size(cloudFreeGroups, 1));
end
data.cloudFreeGroups = cloudFreeGroups;
fprintf('[%s] Finish.\n', tNow());

%% load meteorological data
fprintf('\n[%s] Start to load meteorological data.\n', tNow());
[temperature, pressure, relh, meteorAttri] = pollyxt_readmeteor(data, config);
data.temperature = temperature;
data.pressure = pressure;
data.relh = relh;
data.meteorAttri = meteorAttri;
fprintf('[%s] Finish.\n', tNow());

%% load AERONET data
fprintf('\n[%s] Start to load AERONET data.\n', tNow());
AERONET = struct();
[AERONET.datetime, AERONET.AOD_1640, AERONET.AOD_1020, AERONET.AOD_870, ...
 AERONET.AOD_675, AERONET.AOD_500, AERONET.AOD_440, AERONET.AOD_380, ...
 AERONET.AOD_340, AERONET.wavelength, AERONET.IWV, ...
 AERONET.angstrexp440_870, AERONET.AERONETAttri] = read_AERONET(...
    config.AERONETSite, ...
    [floor(data.mTime(1)) - 1, floor(data.mTime(1)) + 1], '15');
data.AERONET = AERONET;
fprintf('[%s] Finish.\n', tNow());

%% rayleigh fitting
fprintf('\n[%s] Start to apply rayleigh fitting.\n', tNow());
[data.refHIndx355, data.refHIndx532, data.refHIndx1064, ...
 data.dpIndx355, data.dpIndx532, data.dpIndx1064] = pollyxt_rayleighfit(data, config);
fprintf('Number of reference height found for 355 nm: %2d\n', ...
        sum(~ isnan(data.refHIndx355(:)))/2);
fprintf('Number of reference height found for 532 nm: %2d\n', ...
        sum(~ isnan(data.refHIndx532(:)))/2);
fprintf('Number of reference height found for 1064 nm: %2d\n', ...
        sum(~ isnan(data.refHIndx1064(:)))/2);
fprintf('[%s] Finish.\n', tNow());

%% optical properties retrieving
fprintf('\n[%s] Start to retrieve aerosol optical properties.\n', tNow());
meteorStr = '';
for iMeteor = 1:length(meteorAttri.dataSource)
    meteorStr = cat(2, meteorStr, ' ', meteorAttri.dataSource{iMeteor});
end
fprintf('Meteorological file : %s.\n', meteorStr);

% Klett method 
[data.el355, data.bgEl355, data.el532, data.bgEl532] = ...
    pollyxt_transratioCor(data, config);
[data.aerBsc355_klett, data.aerBsc532_klett, data.aerBsc1064_klett, ...
 data.aerExt355_klett, data.aerExt532_klett, data.aerExt1064_klett] = ...
    pollyxt_klett(data, config);
[data.aerBsc355_NR_klett, data.aerBsc532_NR_klett, data.aerExt355_NR_klett, ...
 data.aerExt532_NR_klett, data.refBeta_NR_355_klett, ...
 data.refBeta_NR_532_klett] = pollyxt_NR_klett(data, config);
 [data.aerBsc355_OC_klett, data.aerBsc532_OC_klett, data.aerBsc1064_OC_klett, data.aerExt355_OC_klett, data.aerExt532_OC_klett, data.aerExt1064_OC_klett] = pollyxt_OC_klett(data, config);

% Constrained-AOD Klett method
[data.aerBsc355_aeronet, data.aerBsc532_aeronet, data.aerBsc1064_aeronet, ...
 data.aerExt355_aeronet, data.aerExt532_aeronet, data.aerExt1064_aeronet, ...
 data.LR355_aeronet, data.LR532_aeronet, data.LR1064_aeronet, ...
 data.deltaAOD355, data.deltaAOD532, ...
 data.deltaAOD1064] = pollyxt_constrainedklett(data, AERONET, config);

% Raman method
[data.aerBsc355_raman, data.aerBsc532_raman, data.aerBsc1064_raman, ...
 data.aerExt355_raman, data.aerExt532_raman, data.aerExt1064_raman, ...
 data.LR355_raman, data.LR532_raman, ...
 data.LR1064_raman] = pollyxt_raman(data, config);
[data.aerBsc355_NR_raman, data.aerBsc532_NR_raman, data.aerExt355_NR_raman, ...
 data.aerExt532_NR_raman, data.LR355_NR_raman, data.LR532_NR_raman, ...
 data.refBeta_NR_355_raman, ...
 data.refBeta_NR_532_raman] = pollyxt_NR_raman(data, config);
[data.aerBsc355_OC_raman, data.aerBsc532_OC_raman, data.aerBsc1064_OC_raman, data.aerExt355_OC_raman, data.aerExt532_OC_raman, data.aerExt1064_OC_raman, data.LR355_OC_raman, data.LR532_OC_raman, data.LR1064_OC_raman] = pollyxt_OC_raman(data, config);

% Vol- and Par-depol
[data.voldepol355_klett, data.pardepol355_klett, data.pardepolStd355_klett, ...
 data.voldepol355_raman, data.pardepol355_raman, data.pardepolStd355_raman, ...
 data.moldepol355, data.moldepolStd355, data.flagDefaultMoldepol355, ...
 data.voldepol532_klett, data.pardepol532_klett, data.pardepolStd532_klett, ...
 data.voldepol532_raman, data.pardepol532_raman, data.pardepolStd532_raman, ...
 data.moldepol532, data.moldepolStd532, ...
 data.flagDefaultMoldepol532] = pollyxt_depolratio(data, config);
 [data.voldepol355_OC_klett, data.pardepol355_OC_klett, data.pardepolStd355_OC_klett, data.voldepol355_OC_raman, data.pardepol355_OC_raman, data.pardepolStd355_OC_raman, data.moldepol355, data.moldepolStd355, data.flagDefaultMoldepol355, data.voldepol532_OC_klett, data.pardepol532_OC_klett, data.pardepolStd532_OC_klett, data.voldepol532_OC_raman, data.pardepol532_OC_raman, data.pardepolStd532_OC_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = pollyxt_OC_depolratio(data, config);

% Angstroem exponent
[data.ang_ext_355_532_raman, data.ang_bsc_355_532_raman, ...
 data.ang_bsc_532_1064_raman, data.ang_bsc_355_532_klett, ...
 data.ang_bsc_532_1064_klett] = pollyxt_angstrexp(data, config);
[data.ang_ext_355_532_raman_NR, data.ang_bsc_355_532_raman_NR, ...
 data.ang_bsc_355_532_klett_NR] = pollyxt_NR_angstrexp(data, config);
[data.ang_ext_355_532_raman_OC, data.ang_bsc_355_532_raman_OC, data.ang_bsc_532_1064_raman_OC, data.ang_bsc_355_532_klett_OC, data.ang_bsc_532_1064_klett_OC] = pollyxt_OC_angstrexp(data, config);
fprintf('[%s] Finish.\n', tNow());

%% water vapor calibration
% get IWV from other instruments
fprintf('\n[%s] Start to water vapor calibration.\n', tNow());
[data.IWV, IWVAttri] = pollyxt_read_IWV(data, config);
data.IWVAttri = IWVAttri;
[wvconst, wvconstStd, wvCaliInfo] = pollyxt_wv_calibration(data, config);
[data.wvconstUsed, data.wvconstUsedStd, data.wvconstUsedInfo] = ...
    select_wvconst(wvconst, wvconstStd, data.IWVAttri, ...
        polly_parsetime(taskInfo.dataFilename, config.dataFileFormat), ...
        dbFile, campaignInfo.name, ...
        'flagUsePrevWVConst', config.flagUsePreviousLC, ...
        'flagWVCalibration', config.flagWVCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_wvconst', defaults.wvconst, ...
        'default_wvconstStd', defaults.wvconstStd);
[data.wvmr, data.rh, ~, data.WVMR, data.RH] = pollyxt_wv_retrieve(data, ...
    config, wvCaliInfo.IntRange);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = pollyxt_lidar_calibration(data, config);
data.LC = LC;

% select lidar calibration constant
data.LCUsed = pollyxt_select_liconst(data, config, dbFile);
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
[data.att_beta_355, data.att_beta_532, data.att_beta_1064, ...
 data.att_beta_387, data.att_beta_607] = pollyxt_att_beta(data, config);
[data.att_beta_OC_355, data.att_beta_OC_532, data.att_beta_OC_1064, ~, ~] = pollyxt_OC_att_beta(data, config);
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf(['\n[%s] Start to retrieve high spatial-temporal resolved ', ...
         'backscatter coeff. and vol.Depol with quasi-retrieving method.\n'], tNow());
[data.quasi_par_beta_355, data.quasi_par_beta_532, data.quasi_par_beta_1064, ...
 data.quasi_parDepol_532, data.volDepol_355, data.volDepol_532, ...
 data.quasi_ang_532_1064, data.quality_mask_355, data.quality_mask_532, ...
 data.quality_mask_1064, data.quality_mask_volDepol_355, ...
 data.quality_mask_volDepol_532, data.quasiAttri] = pollyxt_quasiretrieve(data, config);
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving V2 (with using Raman signal)
fprintf(['\n[%s] Start to retrieve high spatial-temporal resolved ', ...
         'backscatter coeff. and vol.Depol with quasi-retrieving method (Version 2).\n'], tNow());
[data.quasi_par_beta_355_V2, data.quasi_par_beta_532_V2, ...
 data.quasi_par_beta_1064_V2, data.quasi_parDepol_532_V2, ~, ~, ...
 data.quasi_ang_532_1064_V2, data.quality_mask_355_V2, ...
 data.quality_mask_532_V2, data.quality_mask_1064_V2, ...
 data.quality_mask_volDepol_355_V2, ...
 data.quality_mask_volDepol_532_V2, ...
 data.quasiAttri_V2] = pollyxt_quasiretrieve_V2(data, config);
fprintf('[%s] Finish.\n', tNow());

%% target classification
fprintf('\n[%s] Start to aerosol target classification with quasi results.\n', tNow());
tc_mask = pollyxt_targetclassi(data, config);
data.tc_mask = tc_mask;
fprintf('[%s] Finish.\n', tNow());

%% target classification with quasi-retrieving V2
fprintf('\n[%s] Start to aerosol target classification with quasi results (V2).\n', tNow());
tc_mask_V2 = pollyxt_targetclassi_V2(data, config);
data.tc_mask_V2 = tc_mask_V2;
fprintf('[%s] Finish.\n', tNow());

%% saving calibration results
if processInfo.flagEnableCaliResultsOutput

    fprintf('\n[%s] Start to save calibration results.\n', tNow());

    %% save depol cali results
    save_depolconst(dbFile, ...
                    depCaliAttri.depol_cal_fac_355, ...
                    depCaliAttri.depol_cal_fac_std_355, ...
                    depCaliAttri.depol_cal_start_time_355, ...
                    depCaliAttri.depol_cal_stop_time_355, ...
                    taskInfo.dataFilename, ...
                    campaignInfo.name, ...
                    '355');
    save_depolconst(dbFile, ...
                    depCaliAttri.depol_cal_fac_532, ...
                    depCaliAttri.depol_cal_fac_std_532, ...
                    depCaliAttri.depol_cal_start_time_532, ...
                    depCaliAttri.depol_cal_stop_time_532, ...
                    taskInfo.dataFilename, ...
                    campaignInfo.name, ...
                    '532');

    %% save water vapor calibration results
    save_wvconst(dbFile, wvconst, wvconstStd, wvCaliInfo, data.IWVAttri, ...
                 taskInfo.dataFilename, campaignInfo.name);

    %% save lidar calibration results
    save_liconst(dbFile, LC.LC_klett_355, LC.LCStd_klett_355, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '355', 'Klett_Method');
    save_liconst(dbFile, LC.LC_klett_532, LC.LCStd_klett_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'Klett_Method');
    save_liconst(dbFile, LC.LC_klett_1064, LC.LCStd_klett_1064, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '1064', 'Klett_Method');
    save_liconst(dbFile, LC.LC_raman_355, LC.LCStd_raman_355, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '355', 'Raman_Method');
    save_liconst(dbFile, LC.LC_raman_532, LC.LCStd_raman_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'Raman_Method');
    save_liconst(dbFile, LC.LC_raman_1064, LC.LCStd_raman_1064, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '1064', 'Raman_Method');
    save_liconst(dbFile, LC.LC_raman_387, LC.LCStd_raman_387, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '387', 'Raman_Method');
    save_liconst(dbFile, LC.LC_raman_607, LC.LCStd_raman_607, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '607', 'Raman_Method');
    save_liconst(dbFile, LC.LC_aeronet_355, LC.LCStd_aeronet_355, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '355', 'AOD_Constrained_Method');
    save_liconst(dbFile, LC.LC_aeronet_532, LC.LCStd_aeronet_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'AOD_Constrained_Method');
    save_liconst(dbFile, LC.LC_aeronet_1064, LC.LCStd_aeronet_1064, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '1064', 'AOD_Constrained_Method');

    fprintf('[%s] Finish.\n', tNow());

end

%% saving retrieving results
if processInfo.flagEnableResultsOutput

    if processInfo.flagDeletePreOutputs
        % delete the previous outputs
        % This is only necessary when you run the code on the server, 
        % where the polly data was updated in time. If the 
        % previous outputs were not cleared, it will piled up to a huge amount.
        fprintf('\n[%s] Start to delete previous nc files.\n', tNow());

        % search files associated with the same start time
        fileList = listfile(fullfile(processInfo.results_folder, ...
                                     campaignInfo.name, ...
                                     datestr(data.mTime(1), 'yyyy'), ...
                                     datestr(data.mTime(1), 'mm'), ...
                                     datestr(data.mTime(1), 'dd')), ...
                            sprintf('%s.*.nc', rmext(taskInfo.dataFilename)));

        % delete the files
        for iFile = 1:length(fileList)
            delete(fileList{iFile});
        end
    end

    fprintf('\n[%s] Start to save retrieving results.\n', tNow());

     %% save overlap results
    saveFile = fullfile(processInfo.results_folder, ...
                        campaignInfo.name, datestr(data.mTime(1), 'yyyy'), ...
                        datestr(data.mTime(1), 'mm'), ...
                        datestr(data.mTime(1), 'dd'), ...
                        sprintf('%s_overlap.nc', rmext(taskInfo.dataFilename)));
    pollyxt_save_overlap(data, taskInfo, config, overlapAttri, saveFile);

    %% save aerosol optical results
    pollyxt_save_retrieving_results(data, taskInfo, config);
    pollyxt_save_NR_retrieving_results(data, taskInfo, config);
    pollyxt_save_OC_retrieving_results(data, taskInfo, config);

    %% save attenuated backscatter
    pollyxt_save_att_bsc(data, taskInfo, config);
    pollyxt_save_OC_att_bsc(data, taskInfo, config);

    %% save water vapor mixing ratio and relative humidity
    pollyxt_save_WVMR_RH(data, taskInfo, config);

    %% save volume depolarization ratio
    pollyxt_save_voldepol(data, taskInfo, config);

    %% save quasi results
    pollyxt_save_quasi_results(data, taskInfo, config);

    %% save quasi results V2
    pollyxt_save_quasi_results_V2(data, taskInfo, config);

    %% save target classification results
    pollyxt_save_tc(data, taskInfo, config);

    %% save target classification results V2
    pollyxt_save_tc_V2(data, taskInfo, config);

    fprintf('[%s] Finish.\n', tNow());
end

%% visualization
if processInfo.flagEnableDataVisualization
        
    if processInfo.flagDeletePreOutputs
        % delete the previous outputs
        % This is only necessary when you run the code on the server, 
        % where the polly data was updated in time. If the 
        % previous outputs were not cleared, it will piled up to a huge amount.
        fprintf('\n[%s] Start to delete previous figures.\n', tNow());

        % search files associated with the same start time
        fileList = listfile(fullfile(processInfo.pic_folder, ...
                                     campaignInfo.name, ...
                                     datestr(data.mTime(1), 'yyyy'), ...
                                     datestr(data.mTime(1), 'mm'), ...
                                     datestr(data.mTime(1), 'dd')), ...
                            sprintf('%s.*.png', rmext(taskInfo.dataFilename)));
        
        % delete the files
        for iFile = 1:length(fileList)
            delete(fileList{iFile});
        end
    end

    fprintf('\n[%s] Start to visualize results.\n', tNow());

    %% display monitor status
    disp('Display housekeeping')
    pollyxt_display_monitor(data, taskInfo, config);

    %% display signal
    disp('Display RCS and volume depolarization ratio')
    pollyxt_display_rcs(data, taskInfo, config);

    %% display depol calibration results
    disp('Display depolarization calibration results')
    pollyxt_display_depolcali(data, taskInfo, depCaliAttri);

    %% display saturation and cloud free tags
    disp('Display signal flags')
    pollyxt_display_saturation(data, taskInfo, config);

    %% display overlap
    disp('Display overlap')
    pollyxt_display_overlap(data, taskInfo, overlapAttri, config);

    %% display optical profiles
    disp('Display profiles')
    pollyxt_display_retrieving(data, taskInfo, config);
    pollyxt_display_OC_retrieving(data, taskInfo, config);

    %% display attenuated backscatter
    disp('Display attnuated backscatter')
    pollyxt_display_att_beta(data, taskInfo, config);
    pollyxt_display_OC_att_beta(data, taskInfo, config);

    %% display WVMR and RH
    disp('Display WVMR and RH')
    pollyxt_display_WV(data, taskInfo, config);

    %% display quasi backscatter, particle depol and angstroem exponent 
    disp('Display quasi parameters')
    pollyxt_display_quasiretrieving(data, taskInfo, config);

    %% display quasi backscatter, particle depol and angstroem exponent V2 
    disp('Display quasi parameters V2')
    pollyxt_display_quasiretrieving_V2(data, taskInfo, config);

    %% target classification
    disp('Display target classifications')
    pollyxt_display_targetclassi(data, taskInfo, config);

    %% target classification V2
    disp('Display target classifications V2')
    pollyxt_display_targetclassi_V2(data, taskInfo, config);

    %% display lidar calibration constants
    disp('Display Lidar constants.')
    pollyxt_display_lidarconst(data, taskInfo, config);

    %% display Long-term lidar constant with logbook
    disp('Display Long-Term lidar cosntants.')
    pollyxt_display_longterm_cali(dbFile, taskInfo, config);

    fprintf('[%s] Finish.\n', tNow());
end

%% get report
report = pollyxt_results_report(data, taskInfo, config);

%% debug output
if isfield(processInfo, 'flagDebugOutput')
    if processInfo.flagDebugOutput
        save(fullfile(processInfo.results_folder, campaignInfo.name, ...
                      datestr(taskInfo.dataTime, 'yyyy'), ...
                      datestr(taskInfo.dataTime, 'mm'), ...
                      datestr(taskInfo.dataTime, 'dd'), ...
                      [rmext(taskInfo.dataFilename), '.mat']));
    end
end

end