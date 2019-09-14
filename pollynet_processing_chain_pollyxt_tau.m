function [report] = pollynet_processing_chain_pollyxt_tau(taskInfo, config)
%POLLYNET_PROCESSING_CHAIN_pollyxt_tau processing the data from arielle
%   Example:
%       [report] = pollynet_processing_chain_pollyxt_tau(taskInfo, config)
%   Inputs:
%       taskInfo, config
%   Outputs:
%       report: cell array
%           information about each figure.
%   History:
%       2018-12-17. First edition by Zhenping   
%   Contact:
%       zhenping@tropos.de

report = cell(0);
global processInfo campaignInfo defaults

%% create folder
results_folder = fullfile(processInfo.results_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'));
pic_folder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'));
if ~ exist(results_folder, 'dir')
    fprintf('Create a new folder to saving the results for %s at %s\n%s\n', campaignInfo.name, datestr(taskInfo.dataTime, 'yyyymmdd HH:MM'), results_folder);
    mkdir(results_folder);
end
if ~ exist(pic_folder, 'dir')
    fprintf('Create a new folder to saving the plots for %s\n%s\n', campaignInfo.name, datestr(taskInfo.dataTime, 'yyyymmdd HH:MM'), pic_folder);
    mkdir(pic_folder);
end

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', tNow(), campaignInfo.name, taskInfo.dataFilename);
data = polly_read_rawdata(fullfile(taskInfo.todoPath, taskInfo.dataPath, taskInfo.dataFilename), config, processInfo.flagDeleteData);
if isempty(data.rawSignal)
    warning('No measurement data in %s for %s.\n', taskInfo.dataFilename, campaignInfo.name);
    return;
end
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
laserlogbookFile = fullfile(taskInfo.todoPath, taskInfo.dataPath, sprintf('%s.laserlogbook.txt', taskInfo.dataFilename));
fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', tNow(), campaignInfo.name, laserlogbookFile);
monitorStatus = arielle_read_laserlogbook(laserlogbookFile, config, processInfo.flagDeleteData);
data.monitorStatus = monitorStatus;
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), campaignInfo.name);
data = arielle_preprocess(data, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
flagSaturation = arielle_saturationdetect(data, config);
data.flagSaturation = flagSaturation;
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), campaignInfo.name);
[data, depCaliAttri] = arielle_depolcali(data, config, taskInfo);
data.depCaliAttri = depCaliAttri;
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagChannel532NR = config.isNR & config.is532nm & config.isTot;
flagChannel532FR = config.isFR & config.is532nm & config.isTot;
PCR532FR = squeeze(data.signal(flagChannel532FR, :, :)) ./ repmat(data.mShots(flagChannel532FR, :), numel(data.height), 1) * 150 / data.hRes;
PCR532NR = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / data.hRes;
flagCloudFree2km = polly_cloudscreen(data.height, PCR532NR, config.maxSigSlope4FilterCloud/5, [config.heightFullOverlap(flagChannel532NR), 3000]);

flagCloudFree8km_FR = polly_cloudscreen(data.height, PCR532FR, config.maxSigSlope4FilterCloud, [config.heightFullOverlap(flagChannel532FR), 7000]);
flagCloudFree8km = flagCloudFree8km_FR & flagCloudFree2km;

data.flagCloudFree2km = flagCloudFree2km;
data.flagCloudFree8km = flagCloudFree8km;
fprintf('[%s] Finish cloud-screen.\n', tNow());

%% overlap estimation
fprintf('\n[%s] Start to estimate the overlap function.\n', tNow());
[data, overlapAttri] = arielle_overlap(data, config);
fprintf('[%s] Finish.\n', tNow());

%% split the cloud free profiles into continuous subgroups
fprintf('\n[%s] Start to split the cloud free profiles.\n', tNow());
cloudFreeGroups = arielle_splitcloudfree(data, config);
if isempty(cloudFreeGroups)
    fprintf('No qualified cloud-free groups were found.\n');
else
    fprintf('%d cloud-free groups were found.\n', size(cloudFreeGroups, 1));
end
data.cloudFreeGroups = cloudFreeGroups;
fprintf('[%s] Finish.\n', tNow());

%% load meteorological data
fprintf('\n[%s] Start to load meteorological data.\n', tNow());
[temperature, pressure, relh, meteorAttri] = arielle_readmeteor(data, config);
data.temperature = temperature;
data.pressure = pressure;
data.relh = relh;
data.meteorAttri = meteorAttri;
fprintf('[%s] Finish.\n', tNow());

%% load AERONET data
fprintf('\n[%s] Start to load AERONET data.\n', tNow());
AERONET = struct();
[AERONET.datetime, AERONET.AOD_1640, AERONET.AOD_1020, AERONET.AOD_870, AERONET.AOD_675, AERONET.AOD_500, AERONET.AOD_440, AERONET.AOD_380, AERONET.AOD_340, AERONET.wavelength, AERONET.IWV, AERONET.angstrexp440_870, AERONET.AERONETAttri] = read_AERONET(config.AERONETSite, [floor(data.mTime(1)) - 1, floor(data.mTime(1)) + 1], '15');
data.AERONET = AERONET;
fprintf('[%s] Finish.\n', tNow());

%% rayleigh fitting
fprintf('\n[%s] Start to apply rayleigh fitting.\n', tNow());
[data.refHIndx355, data.refHIndx532, data.refHIndx1064, data.dpIndx355, data.dpIndx532, data.dpIndx1064] = arielle_rayleighfit(data, config);
fprintf('Number of reference height for 355 nm: %2d\n', sum(~ isnan(data.refHIndx355(:)))/2);
fprintf('Number of reference height for 532 nm: %2d\n', sum(~ isnan(data.refHIndx532(:)))/2);
fprintf('Number of reference height for 1064 nm: %2d\n', sum(~ isnan(data.refHIndx1064(:)))/2);
fprintf('[%s] Finish.\n', tNow());

%% optical properties retrieving
fprintf('\n[%s] Start to retrieve aerosol optical properties.\n', tNow());
meteorStr = '';
for iMeteor = 1:length(meteorAttri.dataSource)
    meteorStr = [meteorStr, ' ', meteorAttri.dataSource{iMeteor}];
end
fprintf('Meteorological file : %s.\n', meteorStr);

% Klett method 
[data.el355, data.bgEl355, data.el532, data.bgEl532] = arielle_transratioCor(data, config);
[data.aerBsc355_klett, data.aerBsc532_klett, data.aerBsc1064_klett, data.aerExt355_klett, data.aerExt532_klett, data.aerExt1064_klett] = arielle_klett(data, config);
[data.aerBsc355_NR_klett, data.aerBsc532_NR_klett, data.aerExt355_NR_klett, data.aerExt532_NR_klett, data.refBeta_NR_355_klett, data.refBeta_NR_532_klett] = arielle_NR_klett(data, config);

% Constrained-AOD Klett method
[data.aerBsc355_aeronet, data.aerBsc532_aeronet, data.aerBsc1064_aeronet, data.aerExt355_aeronet, data.aerExt532_aeronet, data.aerExt1064_aeronet, data.LR355_aeronet, data.LR532_aeronet, data.LR1064_aeronet, data.deltaAOD355, data.deltaAOD532, data.deltaAOD1064] = arielle_constrainedklett(data, AERONET, config);   % constrain Lidar Ratio

% Raman method
[data.aerBsc355_raman, data.aerBsc532_raman, data.aerBsc1064_raman, data.aerExt355_raman, data.aerExt532_raman, data.aerExt1064_raman, data.LR355_raman, data.LR532_raman, data.LR1064_raman] = arielle_raman(data, config);
[data.aerBsc355_NR_raman, data.aerBsc532_NR_raman, data.aerExt355_NR_raman, data.aerExt532_NR_raman, data.LR355_NR_raman, data.LR532_NR_raman, data.refBeta_NR_355_raman, data.refBeta_NR_532_raman] = arielle_NR_raman(data,config);

% Vol- and Par-depol
[data.voldepol355_klett, data.pardepol355_klett, data.pardepolStd355_klett, data.voldepol355_raman, data.pardepol355_raman, data.pardepolStd355_raman, data.moldepol355, data.moldepolStd355, data.flagDefaultMoldepol355, data.voldepol532_klett, data.pardepol532_klett, data.pardepolStd532_klett, data.voldepol532_raman, data.pardepol532_raman, data.pardepolStd532_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = arielle_depolratio(data, config);

% Angstroem exponent
[data.ang_ext_355_532_raman, data.ang_bsc_355_532_raman, data.ang_bsc_532_1064_raman, data.ang_bsc_355_532_klett, data.ang_bsc_532_1064_klett] = arielle_angstrexp(data, config);
[data.ang_ext_355_532_raman_NR, data.ang_bsc_355_532_raman_NR, data.ang_bsc_355_532_klett_NR] = arielle_NR_angstrexp(data, config);
fprintf('[%s] Finish.\n', tNow());

%% water vapor calibration
% get IWV from other instruments
fprintf('\n[%s] Start to water vapor calibration.\n', tNow());
[data.IWV, IWVAttri] = arielle_read_IWV(data, config);
data.IWVAttri = IWVAttri;
[wvconst, wvconstStd, wvCaliInfo] = arielle_wv_calibration(data, config);
% if not successful wv calibration, choose the default values
[data.wvconstUsed, data.wvconstUsedStd, data.wvconstUsedInfo] = arielle_select_wvconst(wvconst, wvconstStd, data.IWVAttri, polly_parsetime(taskInfo.dataFilename, config.dataFileFormat), fullfile(processInfo.results_folder, campaignInfo.name, config.wvCaliFile), config.flagUsePreviousLC);
[data.wvmr, data.rh, ~, data.WVMR, data.RH] = arielle_wv_retrieve(data, config, wvCaliInfo.IntRange);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = arielle_lidar_calibration(data, config);
data.LC = LC;
LCUsed = struct();
[LCUsed.LCUsed355, LCUsed.LCUsedTag355, LCUsed.flagLCWarning355, LCUsed.LCUsed532, LCUsed.LCUsedTag532, LCUsed.flagLCWarning532, LCUsed.LCUsed1064, LCUsed.LCUsedTag1064, LCUsed.flagLCWarning1064, LCUsed.LCUsed387, LCUsed.LCUsedTag387, LCUsed.flagLCWarning387, LCUsed.LCUsed607, LCUsed.LCUsedTag607, LCUsed.flagLCWarning607] = arielle_mean_LC(data, config, taskInfo, fullfile(processInfo.results_folder, config.pollyVersion));
data.LCUsed = LCUsed;
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
[att_beta_355, att_beta_532, att_beta_1064, att_beta_387, att_beta_607] = arielle_att_beta(data, config);
data.att_beta_355 = att_beta_355;
data.att_beta_532 = att_beta_532;
data.att_beta_1064 = att_beta_1064;
data.att_beta_387 = att_beta_387;
data.att_beta_607 = att_beta_607;
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method.\n', tNow());
[data.quasi_par_beta_355, data.quasi_par_beta_532, data.quasi_par_beta_1064, data.quasi_parDepol_532, data.volDepol_355, data.volDepol_532, data.quasi_ang_532_1064, data.quality_mask_355, data.quality_mask_532, data.quality_mask_1064, data.quality_mask_volDepol_355, data.quality_mask_volDepol_532, quasiAttri] = arielle_quasiretrieve(data, config);
data.quasiAttri = quasiAttri;
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving V2 (with using Raman signal)
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method (Version 2).\n', tNow());
[data.quasi_par_beta_355_V2, data.quasi_par_beta_532_V2, data.quasi_par_beta_1064_V2, data.quasi_parDepol_532_V2, ~, ~, data.quasi_ang_532_1064_V2, data.quality_mask_355_V2, data.quality_mask_532_V2, data.quality_mask_1064_V2, data.quality_mask_volDepol_355_V2, data.quality_mask_volDepol_532_V2, quasiAttri_V2] = arielle_quasiretrieve_V2(data, config);
data.quasiAttri_V2 = quasiAttri_V2;
fprintf('[%s] Finish.\n', tNow());

%% target classification
fprintf('\n[%s] Start to aerosol target classification with quasi results.\n', tNow());
tc_mask = arielle_targetclassi(data, config);
data.tc_mask = tc_mask;
fprintf('[%s] Finish.\n', tNow());

%% target classification with quasi-retrieving V2
fprintf('\n[%s] Start to aerosol target classification with quasi results (V2).\n', tNow());
tc_mask_V2 = arielle_targetclassi_V2(data, config);
data.tc_mask_V2 = tc_mask_V2;
fprintf('[%s] Finish.\n', tNow());

%% saving calibration results
if processInfo.flagEnableCaliResultsOutput

    fprintf('\n[%s] Start to save calibration results.\n', tNow());

    %% save depol cali results
    arielle_save_depolcaliconst(depCaliAttri.depol_cal_fac_532, depCaliAttri.depol_cal_fac_std_532, depCaliAttri.depol_cal_time_532, taskInfo.dataFilename, data.depol_cal_fac_532, data.depol_cal_fac_std_532, fullfile(processInfo.results_folder, campaignInfo.name, config.depolCaliFile532));
    arielle_save_depolcaliconst(depCaliAttri.depol_cal_fac_355, depCaliAttri.depol_cal_fac_std_355, depCaliAttri.depol_cal_time_355, taskInfo.dataFilename, data.depol_cal_fac_355, data.depol_cal_fac_std_355, fullfile(processInfo.results_folder, campaignInfo.name, config.depolCaliFile355));

    %% save water vapor calibration results
    arielle_save_wvconst(wvconst, wvconstStd, wvCaliInfo, data.IWVAttri, taskInfo.dataFilename, data.wvconstUsed, data.wvconstUsedStd, fullfile(processInfo.results_folder, campaignInfo.name, config.wvCaliFile));

    %% save lidar calibration results
    arielle_save_LC_nc(data, taskInfo, config);
    arielle_save_LC_txt(data, taskInfo, config);
    
    fprintf('[%s] Finish.\n', tNow());

end

%% saving retrieving results
if processInfo.flagEnableResultsOutput

    if processInfo.flagDeletePreOutputs
        % delete the previous outputs
        % This is only necessary when you run the code on the live server, 
        % where the polly data keep being updated every now and then. If the 
        % previous outputs were not cleared, it will piled up to a huge amount.
        fprintf('\n[%s] Start tp delete previous nc files.\n', tNow());

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
    saveFile = fullfile(processInfo.results_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_overlap.nc', rmext(taskInfo.dataFilename)));
    arielle_save_overlap(data, taskInfo, config, overlapAttri, saveFile);

    %% save aerosol optical results
    arielle_save_retrieving_results(data, taskInfo, config);
    arielle_save_NR_retrieving_results(data, taskInfo, config);

    %% save attenuated backscatter
    arielle_save_att_bsc(data, taskInfo, config);

    %% save water vapor mixing ratio and relative humidity
    arielle_save_WVMR_RH(data, taskInfo, config);
    
    %% save volume depolarization ratio
    arielle_save_voldepol(data, taskInfo, config);

    %% save quasi results
    arielle_save_quasi_results(data, taskInfo, config);

    %% save quasi results V2
    arielle_save_quasi_results_V2(data, taskInfo, config);

    %% save target classification results
    arielle_save_tc(data, taskInfo, config);

    %% save target classification results V2
    arielle_save_tc_V2(data, taskInfo, config);

    fprintf('[%s] Finish.\n', tNow());
end

%% visualization
if processInfo.flagEnableDataVisualization
        
    if processInfo.flagDeletePreOutputs
        % delete the previous outputs
        % This is only necessary when you run the code on the live server, 
        % where the polly data keep being updated every now and then. If the 
        % previous outputs were not cleared, it will piled up to a huge amount.
        fprintf('\n[%s] Start tp delete previous figures.\n', tNow());

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
    arielle_display_monitor(data, taskInfo, config);

    %% display signal
    disp('Display RCS and volume depolarization ratio')
    arielle_display_rcs(data, taskInfo, config);

    %% display depol calibration results
    disp('Display depolarization calibration results')
    arielle_display_depolcali(data, taskInfo, depCaliAttri);

    %% display saturation and cloud free tags
    disp('Display signal flags')
    arielle_display_saturation(data, taskInfo, config);

    %% display overlap
    disp('Display overlap')
    arielle_display_overlap(data, taskInfo, overlapAttri, config);

    %% display optical profiles
    disp('Display profiles')
    arielle_display_retrieving(data, taskInfo, config);

    %% display attenuated backscatter
    disp('Display attnuated backscatter')
    arielle_display_att_beta(data, taskInfo, config);

    %% display WVMR and RH
    disp('Display WVMR and RH')
    arielle_display_WV(data, taskInfo, config);

    %% display quasi backscatter, particle depol and angstroem exponent 
    disp('Display quasi parameters')
    arielle_display_quasiretrieving(data, taskInfo, config);
    
    %% display quasi backscatter, particle depol and angstroem exponent V2 
    disp('Display quasi parameters V2')
    arielle_display_quasiretrieving_V2(data, taskInfo, config);

    %% target classification
    disp('Display target classifications')
    arielle_display_targetclassi(data, taskInfo, config);

    %% target classification V2
    disp('Display target classifications V2')
    arielle_display_targetclassi_V2(data, taskInfo, config);

    %% display lidar calibration constants
    disp('Display Lidar constants.')
    arielle_display_lidarconst(data, taskInfo, config);
    
    %% display Long-term lidar constant with logbook
    disp('Display Long-Term lidar cosntants.')
    arielle_display_longterm_cali(taskInfo, config);

    fprintf('[%s] Finish.\n', tNow());
end

%% get report
report = arielle_results_report(data, taskInfo, config);

%% debug output
if isfield(processInfo, 'flagDebugOutput')
    if processInfo.flagDebugOutput
        save(fullfile(processInfo.results_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'), [rmext(taskInfo.dataFilename), '.mat']));
    end
end

end