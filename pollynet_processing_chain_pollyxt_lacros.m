% function [] = pollynet_processing_chain_pollyxt_lacros(taskInfo, config)
% function [] = pollynet_processing_chain_pollyxt_lacros()

%POLLYNET_PROCESSING_CHAIN_POLLYXT_lacros processing the data from pollyxt_lacros
%	Example:
%		[] = pollynet_processing_chain_pollyxt_lacros(taskInfo, config, campaignInfo)
%	Inputs:
%		taskInfo, config, campaignInfo
%	Outputs:
%		
%	History:
%		2018-12-17. First edition by Zhenping   
%	Contact:
%		zhenping@tropos.de

load('debug.mat')

global processInfo campaignInfo defaults
% save('debug.mat', 'taskInfo', 'config', 'processInfo', 'campaignInfo', 'defaults')

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', tNow(), taskInfo.pollyVersion, taskInfo.dataFilename);
data = polly_read_rawdata(fullfile(taskInfo.todoPath, taskInfo.dataPath, taskInfo.dataFilename), config);
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
% TODO: search the unzipping laserlogbook file
% laserlogbookFile = sprintf('%s.laserlogbook.txt', taskInfo.dataFilename);
% fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', tNow(), taskInfo.pollyVersion, laserlogbookFile);
% health = pollyxt_lacros_read_laserlogbook(laserlogbookFile, config);
% fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), taskInfo.pollyVersion);
data = pollyxt_lacros_preprocess(data, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
if isfield(data, 'signal')
    flagSaturation = pollyxt_lacros_saturationdetect(data, config);
    data.flagSaturation = flagSaturation;
end
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), taskInfo.pollyVersion);
data = pollyxt_lacros_depolcali(data, config, taskInfo, defaults, fullfile(processInfo.results_folder, config.pollyVersion));
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagCloudFree2km = polly_cloudscreen(data.height, squeeze(data.signal(config.isNR & config.is532nm & config.isTot, :, :)), config.maxSigSlope4FilterCloud*5, [5, 2000]);

flagCloudFree8km_FR = polly_cloudscreen(data.height, squeeze(data.signal(config.isFR & config.is532nm & config.isTot, :, :)), config.maxSigSlope4FilterCloud*50, [1000, 7000]);
flagCloudFree8km = flagCloudFree8km_FR & flagCloudFree2km;

data.flagCloudFree2km = flagCloudFree2km;
data.flagCloudFree8km = flagCloudFree8km;
fprintf('[%s] Finish cloud-screen.\n', tNow());

%% overlap estimation
fprintf('\n[%s] Start to estimate the overlap function.\n', tNow());
data = pollyxt_lacros_overlap(data, config, taskInfo, fullfile(processInfo.results_folder, taskInfo.pollyVersion));
fprintf('[%s] Finish.\n', tNow());

%% split the cloud free profiles into continuous subgroups
fprintf('\n[%s] Start to split the cloud free profiles.\n', tNow());
cloudFreeGroups = pollyxt_lacros_splitcloudfree(data, config);
if isempty(cloudFreeGroups)
    fprintf('No qualified cloud-free groups were found.\n');
else
    fprintf('%d cloud-free groups were found.\n', size(cloudFreeGroups, 1));
end
data.cloudFreeGroups = cloudFreeGroups;
fprintf('[%s] Finish.\n', tNow());

%% load meteorological data
fprintf('\n[%s] Start to load meteorological data.\n', tNow());
[temperature, pressure, relh, meteorAttri] = pollyxt_lacros_readmeteor(data, config);
data.temperature = temperature;
data.pressure = pressure;
data.relh = relh;
fprintf('[%s] Finish.\n', tNow());

%% load AERONET data
fprintf('\n[%s] Start to load AERONET data.\n', tNow());
AERONET = struct();
[AERONET.datetime, AERONET.AOD_1640, AERONET.AOD_1020, AERONET.AOD_870, AERONET.AOD_675, AERONET.AOD_500, AERONET.AOD_440, AERONET.AOD_380, AERONET.AOD_340, AERONET.wavelength, AERONET.IWV, AERONET.angstrexp440_870, AERONET.AERONETAttri] = read_AERONET(config.AERONETSite, floor(data.mTime(1)), '15');
data.AERONET = AERONET;
fprintf('[%s] Finish.\n', tNow());

%% rayleigh fitting
fprintf('\n[%s] Start to apply rayleigh fitting.\n', tNow());
[data.refHIndx355, data.refHIndx532, data.refHIndx1064, data.dpIndx355, data.dpIndx532, data.dpIndx1064] = pollyxt_lacros_rayleighfit(data, config);
fprintf('Number of reference height for 355 nm: %d\n', sum(~ isnan(data.refHIndx355(:, 1))));
fprintf('Number of reference height for 532 nm: %d\n', sum(~ isnan(data.refHIndx532(:, 1))));
fprintf('Number of reference height for 1064 nm: %d\n', sum(~ isnan(data.refHIndx1064(:, 1))));
fprintf('[%s] Finish.\n', tNow());

%% optical properties retrieving
fprintf('\n[%s] Start to retrieve aerosol optical properties.\n', tNow());
meteorStr = '';
for iMeteor = 1:length(meteorAttri.dataSource)
    meteorStr = [meteorStr, ' ', meteorAttri.dataSource{iMeteor}];
end
fprintf('Meteorological file : %s.\n', meteorStr);

[data.el355, data.bgEl355, data.el532, data.bgEl532] = pollyxt_lacros_transratioCor(data, config);

% TODO: replace the total 532nm signal with elastic 532 nm signal
[data.aerBsc355_klett, data.aerBsc532_klett, data.aerBsc1064_klett, data.aerExt355_klett, data.aerExt532_klett, data.aerExt1064_klett] = pollyxt_lacros_klett(data, config);
[data.aerBsc355_aeronet, data.aerBsc532_aeronet, data.aerBsc1064_aeronet, data.aerExt355_aeronet, data.aerExt532_aeronet, data.aerExt1064_aeronet, data.LR355_aeronet, data.LR532_aeronet, data.LR1064_aeronet, data.deltaAOD355, data.deltaAOD532, data.deltaAOD1064] = pollyxt_lacros_constrainedklett(data, AERONET, config);   % constrain Lidar Ratio
[data.aerBsc355_raman, data.aerBsc532_raman, data.aerBsc1064_raman, data.aerExt355_raman, data.aerExt532_raman, data.aerExt1064_raman, data.LR355_raman, data.LR532_raman, data.LR1064_raman] = pollyxt_lacros_raman(data, config);
[data.voldepol355, data.pardepol355_klett, data.pardepol355_raman, data.moldepol355, data.moldepolStd355, data.flagDefaultMoldepol355, data.voldepol532, data.pardepol532_klett, data.pardepol532_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = pollyxt_lacros_depolratio(data, config);
[data.ang_ext_355_532_raman, data.ang_bsc_355_532_raman, data.ang_bsc_532_1064_raman, data.ang_bsc_355_532_klett, data.ang_bsc_532_1064_klett] = pollyxt_lacros_angstrexp(data, config);
fprintf('[%s] Finish.\n', tNow());

%% water vapor calibration
% get IWV from other instruments
fprintf('\n[%s] Start to water vapor calibration.\n', tNow());
[data.IWV, data.IWVAttri] = pollyxt_lacros_read_IWV(data, config);
[wvconst, wvconstStd, wvCaliInfo] = pollyxt_lacros_wv_calibration(data, config);
% if not successful wv calibration, choose the default values
[data.wvconstUsed, data.wvconstUsedStd, data.wvconstUsedInfo] = pollyxt_lacros_save_wvconst(wvconst, wvconstStd, wvCaliInfo, data.IWVAttri, taskInfo.dataFilename, defaults, fullfile(processInfo.results_folder, taskInfo.pollyVersion, config.wvCaliFile));
[data.wvmr, data.rh, data.MVWR, data.RH] = pollyxt_lacros_wv_retrieve(data, config, wvCaliInfo.IntRange);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = pollyxt_lacros_lidar_calibration(data, config);
data.LC = LC;
LCUsed = struct();
[LCUsed.LCUsed355, LCUsed.LCUsedTag355, LCUsed.flagLCWarning355, LCUsed.LCUsed532, LCUsed.LCUsedTag532, LCUsed.flagLCWarning532, LCUsed.LCUsed1064, LCUsed.LCUsedTag1064, LCUsed.flagLCWarning1064] = pollyxt_lacros_save_LC(data, config, taskInfo, fullfile(processConfig.results_folder, config.pollyVersion));
data.LCUsed = LCUsed;
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
[att_beta_355, att_beta_532, att_beta_1064] = pollyxt_lacros_att_beta(data, config);
data.att_beta_355 = att_beta_355;
data.att_beta_532 = att_beta_532;
data.att_beta_1064 = att_beta_1064;
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method.\n', tNow());
[data.quasi_bsc_532, data.quasi_bsc_1064, data.quasi_parDepol_532, data.volDepol_532, data.quasi_angstrexp_532_1064] = pollyxt_lacros_quasiretrive(data, config);
fprintf('[%s] Finish.\n', tNow());

%% target classification
fprintf('\n[%s] Start to aerosol target classification.\n', tNow());
tc_mask = pollyxt_lacros_targetclassi(data, config);
data.tc_mask = tc_mask;
fprintf('[%s] Finish.\n', tNow());

%% visualization
% display signal, volDepol and water vapor (add the cloud free flag), display low SNR and signal saturation
% display overlap
% display wv calibration profiles and wv calibration constants
% display rayleigh fit, raman and klett profiles, volDepol532 and parDepol532, lidar ratio, angstroem exponent and meteorological profiles
% display attenuated backscatter
% display quasi backscatter, particle depol and angstroem exponent and target classification
% display lidar calibration constants

%% saving results
% end