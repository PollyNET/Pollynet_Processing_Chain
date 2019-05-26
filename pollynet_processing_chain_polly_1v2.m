function [report] = pollynet_processing_chain_polly_1v2(taskInfo, config)
%POLLYNET_PROCESSING_CHAIN_polly_1v2 processing the data from polly_1v2
%	Example:
%		[report] = pollynet_processing_chain_polly_1v2(taskInfo, config)
%	Inputs:
%		taskInfo, config
%	Outputs:
%		report: cell array
%           information about each figure.
%	History:
%		2018-12-17. First edition by Zhenping   
%	Contact:
%		zhenping@tropos.de

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
monitorStatus = polly_1v2_read_laserlogbook(laserlogbookFile, config, processInfo.flagDeleteData);
data.monitorStatus = monitorStatus;
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), campaignInfo.name);
data = polly_1v2_preprocess(data, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
flagSaturation = polly_1v2_saturationdetect(data, config);
data.flagSaturation = flagSaturation;
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), campaignInfo.name);
[data, depCaliAttri] = polly_1v2_depolcali(data, config, taskInfo, defaults);
data.depCaliAttri = depCaliAttri;
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagChannel532FR = config.isFR & config.is532nm & config.isTot;
PCR532FR = squeeze(data.signal(flagChannel532FR, :, :)) ./ repmat(data.mShots(flagChannel532FR, :), numel(data.height), 1) * 150 / data.hRes;

flagCloudFree8km_FR = polly_cloudscreen(data.height, PCR532FR, config.maxSigSlope4FilterCloud, [config.heightFullOverlap(flagChannel532FR), 7000]);

data.flagCloudFree8km = flagCloudFree8km_FR;
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
[AERONET.datetime, AERONET.AOD_1640, AERONET.AOD_1020, AERONET.AOD_870, AERONET.AOD_675, AERONET.AOD_500, AERONET.AOD_440, AERONET.AOD_380, AERONET.AOD_340, AERONET.wavelength, AERONET.IWV, AERONET.angstrexp440_870, AERONET.AERONETAttri] = read_AERONET(config.AERONETSite, floor(data.mTime(1)), '15');
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

% TODO: replace the total 532nm signal with elastic 532 nm signal
[data.aerBsc532_klett, data.aerExt532_klett] = polly_1v2_klett(data, config);
[data.aerBsc532_aeronet, data.aerExt532_aeronet, data.LR532_aeronet, data.deltaAOD532] = polly_1v2_constrainedklett(data, AERONET, config);   % constrain Lidar Ratio
[data.aerBsc532_raman, data.aerBsc532_RR, data.aerExt532_raman, data.aerExt532_RR, data.LR532_raman, data.LR532_RR] = polly_1v2_raman(data, config);
[data.voldepol532_klett, data.pardepol532_klett, data.pardepolStd532_klett, data.voldepol532_raman, data.pardepol532_raman, data.pardepolStd532_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = polly_1v2_depolratio(data, config);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = polly_1v2_lidar_calibration(data, config);
data.LC = LC;
LCUsed = struct();
[LCUsed.LCUsed532, LCUsed.LCUsedTag532, LCUsed.flagLCWarning532] = polly_1v2_mean_LC(data, config, taskInfo, fullfile(processInfo.results_folder, config.pollyVersion));
data.LCUsed = LCUsed;
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
[att_beta_532] = polly_1v2_att_beta(data, config);
data.att_beta_532 = att_beta_532;
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method.\n', tNow());
[data.quasi_par_beta_532, data.quasi_parDepol_532, data.volDepol_532, data.quality_mask_532, data.quality_mask_volDepol_532, quasiAttri] = polly_1v2_quasiretrieve(data, config);
data.quasiAttri = quasiAttri;
fprintf('[%s] Finish.\n', tNow());

% saving results

if processInfo.flagEnableResultsOutput

    %% save aerosol optical results
    polly_1v2_save_retrieving_results(data, taskInfo, config);

    %% save lidar calibration results
    polly_1v2_save_LC_nc(data, taskInfo, config);
    polly_1v2_save_LC_txt(data, taskInfo, config);

    %% save attenuated backscatter
    polly_1v2_save_att_bsc(data, taskInfo, config);
    
    %% save volume depolarization ratio
    polly_1v2_save_voldepol(data, taskInfo, config);

    %% save quasi results
    polly_1v2_save_quasi_results(data, taskInfo, config);
 
    fprintf('[%s] Finish.\n', tNow());
end   

%% visualization
if processInfo.flagEnableDataVisualization
        
    fprintf('\n[%s] Start to visualize results.\n', tNow());

    %% display monitor status
    polly_1v2_display_monitor(data, taskInfo, config);

    % display signal
    polly_1v2_display_rcs(data, taskInfo, config);

    %% display saturation and cloud free tags
    polly_1v2_display_saturation(data, taskInfo, config);

    % %% optical profiles
    polly_1v2_display_retrieving(data, taskInfo, config);

    %% display attenuated backscatter
    polly_1v2_display_att_beta(data, taskInfo, config);

    % %% display quasi backscatter, particle depol and angstroem exponent 
    polly_1v2_display_quasiretrieving(data, taskInfo, config);

    % %% display lidar calibration constants
    polly_1v2_display_lidarconst(data, taskInfo, config);

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