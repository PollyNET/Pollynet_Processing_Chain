function [] = pollynet_processing_chain_pollyxt_dwd(taskInfo, config)
%POLLYNET_PROCESSING_CHAIN_POLLYXT_DWD processing the data from pollyxt_dwd
%	Example:
%		[] = pollynet_processing_chain_pollyxt_dwd(taskInfo, config, campaignInfo)
%	Inputs:
%		taskInfo, config, campaignInfo
%	Outputs:
%		
%	History:
%		2018-12-17. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

global processInfo, campaignInfo, defaults

%% read data
fprintf('\n[%s] Start to read %s data.\n%s\n', tNow(), taskInfo.pollyVersion, taskInfo.dataFilename);
data = pollyxt_dwd_read_rawdata(fullfile(taskInfo.todoPath, taskInfo.dataPath, taskInfo.dataFilename), config);
fprintf('[%s] Finish reading data.\n', tNow());

%% read laserlogbook file
laserlogbookFile = sprintf('%s.laserlogbook.txt', taskInfo.dataFilename);
fprintf('\n[%s] Start to read %s laserlogbook data.\n%s\n', tNow(), taskInfo.pollyVersion, laserlogbookFile);
health = pollyxt_dwd_read_laserlogbook(laserlogbookFile, config);
fprintf('[%s] Finish reading laserlogbook.\n', tNow);

%% pre-processing
fprintf('\n[%s] Start to preprocess %s data.\n', tNow(), taskInfo.pollyVersion);
data = pollyxt_dwd_preprocess(data.signal, data.height, config);
fprintf('[%s] Finish signal preprocessing.\n', tNow());

%% saturation detection
fprintf('\n[%s] Start to detect signal saturation.\n', tNow());
if isfield(data, 'signal')
    flagSaturation = pollyxt_dwd_saturationdetect(data, config);
    data.flagSaturation = flagSaturation;
end
fprintf('\n[%s] Finish.\n', tNow());

%% depol calibration
fprintf('\n[%s] Start to calibrate %s depol channel.\n', tNow(), taskInfo.pollyVersion);
data = pollyxt_dwd_depolcali(data, config, taskInfo, defaults, fullfile(processConfig.results_folder, config.pollyVersion));
fprintf('[%s] Finish depol calibration.\n', tNow());

%% cloud screening
fprintf('\n[%s] Start to cloud-screen.\n', tNow());
flagCloudFree2km = polly_cloudscreen(data.height, data.signal(config.isNR & config.is532nm & config.isTot), config.maxSigSlope4FilterCloud/4, [0, 2000]);

flagCloudFree8km_FR = polly_cloudscreen(data.height, data.signal(config.isFR & config.is532nm & config.isTot), config.maxSigSlope4FilterCloud, [1000, 8000]);
flagCloudFree8km = flagCloudFree8km_FR & flagCloudFree2km;

data.flagCloudFree2km = flagCloudFree2km;
data.flagCloudFree8km = flagCloudFree8km;
fprintf('[%s] Finish cloud-screen.\n', tNow());

%% overlap estimation
fprintf('\n[%s] Start to estimate the overlap function.\n', tNow());
data = pollyxt_dwd_overlap(data, config, taskInfo, fullfile(processConfig.results_folder. config.pollyVersion));
fprintf('[%s] Finish.\n', tNow());

%% split the cloud free profiles into continuous subgroups
fprintf('\n[%s] Start to split the cloud free profiles.\n', tNow());
cloudFreeGroups = pollyxt_dwd_splitcloudfree(data, config);
if isempty(cloudFreeGroups)
    fprintf('No qualified cloud-free groups were found.\n');
else
    fprintf('%d cloud-free groups were found.\n', size(cloudFreeGroups, 1));
end
data.cloudFreeGroups = cloudFreeGroups;
fprintf('[%s] Finish.\n', tNow());

%% load meteorological data
fprintf('\n[%s] Start to load meteorological data.\n', tNow());
[temperature, pressure, relh, meteorAttri] = pollyxt_dwd_readmeteor(data, config);
data.temperature = temperature;
data.pressure = pressure;
data.relh = relh;
fprintf('[%s] Finish.\n', tNow());

%% load AERONET data
fprintf('\n[%s] Start to load AERONET data.\n', tNow());
[datetime, AOD_1640, AOD_1020, AOD_870, AOD_675, AOD_500, AOD_440, AOD_380, AOD_340, wavelength, IWV, angstrexp440_870, AERONETAttri] = read_AERONET(config.AERONETSite, floor(data.mTime(1)));
AERONET.datetime = datetime;
AERONET.AOD_1640 = AOD_1640;
AERONET.AOD_1020 = AOD_1020;
AERONET.AOD_870 = AOD_870;
AERONET.AOD_675 = AOD_675;
AERONET.AOD_500 = AOD_500;
AERONET.AOD_440 = AOD_440;
AERONET.AOD_380 = AOD_380;
AERONET.AOD_340 = AOD_340;
AERONET.wavelength = wavelength;
AERONET.IWV = IWV;
AERONET.angstrexp440_870 = angstrexp440_870;
AERONET.AERONETAttri = AERONETAttri;
fprintf('[%s] Finish.\n', tNow());

%% rayleigh fitting
fprintf('\n[%s] Start to apply rayleigh fitting.\n', tNow());
% data.refheight355, refheight532, refheight1064
[refHIndx355, refHIndx532, refHIndx1064, dpIndx355, dpIndx532, dpIndx1064] = pollyxt_dwd_rayleighfit(data, config);
data.refHIndx355 = refHIndx355;
data.refHIndx532 = refHIndx532;
data.refHIndx1064 = refHIndx1064;
data.dpIndx355 = dpIndx355;
data.dpIndx532 = dpIndx532;
data.dpIndx1064 = dpIndx1064;
fprintf('[%s] Finish.\n', tNow());

%% optical properties retrieving
fprintf('\n[%s] Start to retrieve aerosol optical properties.\n', tNow());
fprintf('Meteorological file from: %s.\n', meteorAttri.dataSource);

[el532, bgEl532] = pollyxt_dwd_transratioCor(data, config);
data.el532 = el532;
data.bgEl532 = bgEl532;

% TODO: replace the total 532nm signal with elastic 532 nm signal
[data.aerBsc355_klett, data.aerBsc532_klett, data.aerBsc1064_klett, data.aerExt355_klett, data.aerExt532_klett, data.aerExt1064_klett] = pollyxt_dwd_klett(data, config);
[data.aerBsc355_aeronet, data.aerBsc532_aeronet, data.aerBsc1064_aeronet, data.aerExt355_aeronet, data.aerExt532_aeronet, data.aerExt1064_aeronet, data.LR355_aeronet, data.LR532_aeronet, data.LR1064_aeronet, data.deltaAOD355, data.deltaAOD532, data.deltaAOD1064] = pollyxt_dwd_constrainedklett(data, AERONET, config);   % constrain Lidar Ratio
[data.aerBsc355_raman, data.aerBsc532_raman, data.aerBsc1064_raman, data.aerExt355_raman, data.aerExt532_raman, data.aerExt1064_raman, data.LR355_raman, data.LR532_raman, data.LR1064_raman] = pollyxt_dwd_raman(data, config);
[data.voldepol532, data.pardepol532_klett, data.pardepol532_raman, data.moldepol532, data.moldepolStd532, data.flagDefaultMoldepol532] = pollyxt_dwd_depolratio(data, config);
[data.ang_ext_355_532_raman, data.ang_bsc_355_532_raman, data.ang_bsc_532_1064_raman, data.ang_bsc_355_532_klett, data.ang_bsc_532_1064_klett] = pollyxt_dwd_angstrexp(data, config);
fprintf('[%s] Finish.\n', tNow());

%% water vapor calibration
% get IWV from other instruments
fprintf('\n[%s] Start to water vapor calibration.\n', tNow());
IWV = NaN(1, size(data.cloudFreeGroups, 1));
for iGroup = 1:size(data.cloudFreeGroups, 1)
    % aeronet and MWR
    thisIWV = get_IWV(mean(data.mTime(data.cloudFreeGroups(iGroup, :)), 2), config.instrument_4_IWV);
end

[wvconst, wvconstTime, meteorSouce, IWVInstrument, wvCaliInfo] = pollyxt_dwd_wv_calibration(data, IWV, config, campaignInfo);
% if not successful wv calibration, choose the default values
wvconst = pollyxt_dwd_save_wvconst(wvconst, wvconstTime, meteorSouce, IWVInstrument, wvCaliInfo, config, defaults);
fprintf('[%s] Finish.\n', tNow());

%% lidar calibration
fprintf('\n[%s] Start to lidar calibration.\n', tNow());
LC = pollyxt_dwd_lidar_calibration(data, config);
data.LC = LC;
LCUsed = pollyxt_dwd_save_LC(data, config, taskInfo, fullfile(processConfig.results_folder, config.pollyVersion));
data.LCUsed = LCUsed;
fprintf('[%s] Finish.\n', tNow());

%% attenuated backscatter
fprintf('\n[%s] Start to calculate attenuated backscatter.\n', tNow());
att_beta = pollyxt_dwd_att_beta(data, config);
fprintf('[%s] Finish.\n', tNow());

%% quasi-retrieving
fprintf('\n[%s] Start to retrieve high spatial-temporal resolved backscatter coeff. and vol.Depol with quasi-retrieving method.\n', tNow());
[quasi_bsc_532, quasi_bsc_1064, quasi_parDepol_532, volDepol_532, quasi_angstrexp_532_1064] = pollyxt_dwd_quasiretrive(data, config);
fprintf('[%s] Finish.\n');

%% target classification
fprintf('\n[%s] Start to aerosol target classification.\n', tNow());
tc_mask = pollyxt_dwd_targetclassi(data, config);
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
end