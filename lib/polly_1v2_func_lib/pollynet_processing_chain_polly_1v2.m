function [report] = pollynet_processing_chain_polly_1v2(taskInfo, config)
%POLLYNET_PROCESSING_CHAIN_POLLY_1V2 processing the data from polly_1v2
%Example:
%    [report] = pollynet_processing_chain_polly_1v2(taskInfo, config)
%Inputs:
%   taskInfo: struct
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
%    report: cell array
%        information about each figure.
%History:
%    2018-12-17. First edition by Zhenping   
%Contact:
%    zhenping@tropos.de

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

dbFile = fullfile(processInfo.results_folder, campaignInfo.name , ...
                  config.calibrationDB);

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', tNow(), campaignInfo.name, taskInfo.dataFilename);
data = polly_read_rawdata(fullfile(taskInfo.todoPath, ...
                                   taskInfo.dataPath, ...
                                   taskInfo.dataFilename), ...
                'flagFilterFalseMShots', config.flagFilterFalseMShots, ...
                'flagCorrectFalseMShots', config.flagCorrectFalseMShots, ...
                'flagDeleteData', processInfo.flagDeleteData, ...
                'dataFileFormat', config.dataFileFormat);
if isempty(data.rawSignal)
    warning('No measurement data in %s for %s.\n', taskInfo.dataFilename, campaignInfo.name);
    return;
end
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
laserlogbookFile = fullfile(taskInfo.todoPath, taskInfo.dataPath, sprintf('%s.laserlogbook.txt', taskInfo.dataFilename));
fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', tNow(), campaignInfo.name, laserlogbookFile);
monitorStatus = polly_1v2_read_laserlogbook(laserlogbookFile, config, processInfo.flagDeleteData);
data.monitorStatus = monitorStatus;
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), campaignInfo.name);
data = polly_1v2_preprocess(data, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

if size(data.signal, 3) < 2
    warning('Only single signal profile is available!');
    return;
end

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
flagSaturation = polly_1v2_saturationdetect(data, config);
data.flagSaturation = flagSaturation;
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), campaignInfo.name);
[data, depCaliAttri] = polly_1v2_depolcali(data, config, dbFile);
data.depCaliAttri = depCaliAttri;
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagChannel532FR = config.isFR & config.is532nm & config.isTot;

PCR = data.signal ./ ...
repmat(reshape(data.mShots, size(data.mShots, 1), 1, []), ...
    1, size(data.signal, 2), 1) * 150 / data.hRes;

% far-field
if config.cloudScreenMode == 1

    % based on signal gradient
    flagCloudFree_FR = polly_cloudScreen(data.mTime, data.height, ...
        squeeze(PCR(flagChannel532FR, :, :)), ...
        'mode', 1, ...
        'detectRange', [config.heightFullOverlap(flagChannel532FR), 7000], ...
        'slope_thres', config.maxSigSlope4FilterCloud);

elseif config.cloudScreenMode == 2

    % based on Zhao's algorithm
    [flagCloudFree_FR, layer_status] = polly_cloudScreen(data.mTime, data.height, ...
        squeeze(data.signal(flagChannel532FR, :, :)), ...
        'mode', 2, ...
        'background', squeeze(data.bg(flagChannel532FR, 1, :)), ...
        'detectRange', [0, config.maxDecomHeight532], ...
        'heightFullOverlap', config.heightFullOverlap(flagChannel532FR), ...
        'minSNR', 2);

else
    warning('Unknown cloudscreen mode.');
end

data.flagCloudFree_FR = flagCloudFree_FR & (~ data.shutterOnMask);
fprintf('[%s] Finish cloud-screen.\n', tNow());

%% overlap estimation
fprintf('\n[%s] Start to estimate the overlap function.\n', tNow());
[data, overlapAttri] = polly_1v2_overlap(data, config);
fprintf('[%s] Finish.\n', tNow());

%% split the cloud free profiles into continuous subgroups
fprintf('\n[%s] Start to split the cloud free profiles.\n', tNow());
cloudFreeGroups = polly_1v2_splitcloudfree(data, config);
if isempty(cloudFreeGroups)
    fprintf('No qualified cloud-free groups were found.\n');
else
    fprintf('%d cloud-free groups were found.\n', size(cloudFreeGroups, 1));
end
data.cloudFreeGroups = cloudFreeGroups;
fprintf('[%s] Finish.\n', tNow());

%% load meteorological data
fprintf('\n[%s] Start to load meteorological data.\n', tNow());
[temperature, pressure, relh, meteorAttri] = polly_1v2_readmeteor(data, config);
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
[data.refHIndx532, data.dpIndx532] = polly_1v2_rayleighfit(data, config);
fprintf('Number of reference height for 532 nm: %2d\n', sum(~ isnan(data.refHIndx532(:)))/2);
fprintf('[%s] Finish.\n', tNow());

%% optical properties retrieving
fprintf('\n[%s] Start to retrieve aerosol optical properties.\n', tNow());
meteorStr = '';
for iMeteor = 1:length(meteorAttri.dataSource)
    meteorStr = [meteorStr, ' ', meteorAttri.dataSource{iMeteor}];
end
fprintf('Meteorological file : %s.\n', meteorStr);

[data.el532, data.bgEl532] = polly_1v2_transratioCor(data, config);
[data.aerBsc532_klett, data.aerExt532_klett] = polly_1v2_klett(data, config);
[data.aerBsc532_aeronet, data.aerExt532_aeronet, data.LR532_aeronet, data.deltaAOD532] = polly_1v2_constrainedklett(data, AERONET, config);   % constrain Lidar Ratio
[data.aerBsc532_raman, data.aerBsc532_RR, data.aerExt532_raman, data.aerExt532_RR, data.LR532_raman, data.LR532_RR] = polly_1v2_raman(data, config);
[data.voldepol532_klett, data.pardepol532_klett, data.pardepolStd532_klett, data.voldepol532_raman, data.pardepol532_raman, data.pardepolStd532_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = polly_1v2_depolratio(data, config);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = polly_1v2_lidar_calibration(data, config);
data.LC = LC;

% select lidar calibration constant
data.LCUsed = polly_1v2_select_liconst(data, config, dbFile);
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
[data.att_beta_532, data.att_beta_607] = polly_1v2_att_beta(data, config);
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method.\n', tNow());
[data.quasi_par_beta_532, data.quasi_parDepol_532, data.volDepol_532, data.quality_mask_532, data.quality_mask_volDepol_532, quasiAttri] = polly_1v2_quasiretrieve(data, config);
data.quasiAttri = quasiAttri;
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving V2 (with using Raman signal)
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method (Version 2).\n', tNow());
[data.quasi_par_beta_532_V2, data.quasi_parDepol_532_V2, ~, data.quality_mask_532_V2, data.quality_mask_volDepol_532_V2, quasiAttri_V2] = polly_1v2_quasiretrieve_V2(data, config);
data.quasiAttri_V2 = quasiAttri_V2;
fprintf('[%s] Finish.\n', tNow());

%% cloud layering
fprintf('\n[%s] Start to extract cloud information.\n', tNow());
if config.cloudScreenMode == 2
    [data.clBaseH, data.clTopH, ~, ~] = ...
            cloud_layering(data.mTime, data.height, layer_status, ...
                            'minCloudDepth', 100, ...
                            'liquidCloudBit', 1, ...
                            'iceCloudBit', 1, ...
                            'cloudBits', 1);
    data.clPh = zeros(size(data.clBaseH));
    data.clPhProb = zeros(size(data.clBaseH));
end
fprintf('[%s] Finish.\n', tNow());

%% saving calibration results
if processInfo.flagEnableCaliResultsOutput

    fprintf('\n[%s] Start to save calibration results.\n', tNow());

    %% save depol cali results
    save_depolconst(dbFile, ...
                    depCaliAttri.depol_cal_fac_532, ...
                    depCaliAttri.depol_cal_fac_std_532, ...
                    depCaliAttri.depol_cal_start_time_532, ...
                    depCaliAttri.depol_cal_stop_time_532, ...
                    taskInfo.dataFilename, ...
                    campaignInfo.name, ...
                    '532');

    %% save lidar calibration results
    save_liconst(dbFile, LC.LC_klett_532, LC.LCStd_klett_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'Klett_Method', 'far_range');
    save_liconst(dbFile, LC.LC_raman_532, LC.LCStd_raman_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'Raman_Method', 'far_range');
    save_liconst(dbFile, LC.LC_raman_607, LC.LCStd_raman_607, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '607', 'Raman_Method', 'far_range');
    save_liconst(dbFile, LC.LC_aeronet_532, LC.LCStd_aeronet_532, ...
                 LC.LC_start_time, LC.LC_stop_time, taskInfo.dataFilename, ...
                 campaignInfo.name, '532', 'AOD_Constrained_Method', 'far_range');

    fprintf('[%s] Finish.\n', tNow());

end

% saving retrieving results
if processInfo.flagEnableResultsOutput

    fprintf('\n[%s] Start to save retrieving results.\n', tNow());

    for iProd = 1:length(config.prodSaveList)
        switch lower(config.prodSaveList{iProd})

        case 'aerproffr'
            %% save aerosol optical results
            polly_1v2_save_retrieving_results(data, taskInfo, config);

        case 'aerattbetafr'
            %% save attenuated backscatter
            polly_1v2_save_att_bsc(data, taskInfo, config);

        case 'voldepol'
            %% save volume depolarization ratio
            polly_1v2_save_voldepol(data, taskInfo, config);

        case 'quasiv1'
            %% save quasi results
            polly_1v2_save_quasi_results(data, taskInfo, config);

        case 'quasiv2'
            %% save quasi results (V2)
            polly_1v2_save_quasi_results_V2(data, taskInfo, config);

        case 'cloudinfo'
            pollyxt_save_cloudinfo(data, taskInfo, config);

        otherwise
            warning('Unknow product %s', config.prodSaveList{iProd});
        end
    end
 
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
    polly_1v2_display_monitor(data, taskInfo, config);

    %% display signal
    disp('Display RCS and volume depolarization ratio')
    polly_1v2_display_rcs(data, taskInfo, config);

    %% display depol calibration results
    disp('Display depolarization calibration results')
    polly_1v2_display_depolcali(data, config, taskInfo, depCaliAttri);

    %% display saturation and cloud free tags
    disp('Display signal flags')
    polly_1v2_display_saturation(data, taskInfo, config);

    % %% display optical profiles
    disp('Display profiles')
    polly_1v2_display_retrieving(data, taskInfo, config);

    %% display attenuated backscatter
    disp('Display attnuated backscatter')
    polly_1v2_display_att_beta(data, taskInfo, config);

    %% display quasi backscatter, particle depol and angstroem exponent 
    disp('Display quasi parameters')
    polly_1v2_display_quasiretrieving(data, taskInfo, config);

    %% display quasi backscatter, particle depol and angstroem exponent 
    disp('Display quasi parameters V2')
    polly_1v2_display_quasiretrieving_V2(data, taskInfo, config);

    %% display lidar calibration constants
    disp('Display Lidar constants.')
    polly_1v2_display_lidarconst(data, taskInfo, config);

    %% display Long-term lidar constant with logbook
    disp('Display Long-Term lidar cosntants.')
    polly_1v2_display_longterm_cali(dbFile, taskInfo, config);

    fprintf('[%s] Finish.\n', tNow());
end

%% get report
report = polly_1v2_results_report(data, taskInfo, config);

%% debug output
if isfield(processInfo, 'flagDebugOutput')
    if processInfo.flagDebugOutput
        save(fullfile(processInfo.results_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'), [rmext(taskInfo.dataFilename), '.mat']));
    end
end

end
