global PicassoConfig
global CampaignConfig
global PollyConfig
global PollyDataInfo
global PollyDefaults
global LogConfig

%% Parameter initialization
PicassoDir = fileparts((fileparts(fileparts(mfilename('fullpath')))));
defaultPiassoConfig = fullfile(picassoDir, 'config', 'pollynet_processing_chain_config.json');
report = cell(0);
pollyType = 'arielle';
pollyDataFile = 'D:\';
pollyLaserlogbook = 'D:\';

%% Set PollyDataInfo
PollyDataInfo.pollyType = pollyType;
PollyDataInfo.pollyDataFile = pollyDataFile;
try
    PollyDataInfo.dataTime = pollyParseFiletime(basename(pollyDataFile), ...
        ['(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})', ...
        '_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc']);
catch ErrMsg
    if strcmp(ErrMsg.identifier, 'PICASSO:InvalidFile')
        return;
    else
        rethrow(ErrMsg);
    end
end
PollyDataInfo.pollyLaserlogbook = pollyLaserlogbook;

%% Get Picasso program version
PicassoVersion = getPicassoVersion();

% Set logger configuration
LogConfig.folder = PicassoVersion.log_folder;
LogConfig.flagEnableLogSubFolder = PicassoVersion.flagEnableLogSubFolder;
LogConfig.printLevel = PicassoVersion.printLevel;   % 0: log file & matlab command line
                            % 1: log file only
                            % 2: matlab command line only
                            % 3: simple message in log file & matlab command line
                            % 4: simple message in log file only
                            % 5: simple message in matlab command line only

%% Input check
if ~ exist('PicassoConfig', 'var')
    PicassoConfig = defaultPiassoConfig;
end

%% Print headers
tStart = now();
print_msg('\n%%------------------------------------------------------%%');
print_msg(sprintf('    ____  _                               _____  ____'), 'flagSimpleMsg', true);
print_msg(sprintf('   / __ \(_)________ _______________     |__  / / __ \'), 'flagSimpleMsg', true);
print_msg(sprintf('  / /_/ / / ___/ __ `/ ___/ ___/ __ \     /_ < / / / /'), 'flagSimpleMsg', true);
print_msg(sprintf(' / ____/ / /__/ /_/ (__  |__  ) /_/ /   ___/ // /_/ /'), 'flagSimpleMsg', true);
print_msg(sprintf('/_/   /_/\___/\__,_/____/____/\____/   /____(_)____/'), 'flagSimpleMsg', true);
print_msg('\nStart pollynet processing chain\n');
print_msg(sprintf('pollynet_config_file: %s\n', PicassoConfig));
print_msg(sprintf('Polly Type: %s\n', PollyDataInfo.pollyType));
print_msg(sprintf('Polly Data: %s\n', PollyDataInfo.pollyDataFile));
print_msg('%%------------------------------------------------------%%\n');

%% Load Picasso configurations
PicassoConfig = loadConfig(PicassoConfig, defaultPiassoConfig);
PicassoConfig.PicassoVersion = PicassoVersion;

% Reduce the dependence on additionable toolboxes to get rid of license problems
% after the turndown of usage of matlab toolbox, we need to replace the applied
% function with user defined functions
if processInfo.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'disable');
    print_msg('Disable matlab statistics_toolbox\n', 'flagSimpleMsg', true);
end

%% Create log file
if ~ exist(PicassoConfig.log_folder, 'dir')
    print_msg(sprintf('Create log folder: %s.\n', PicassoConfig.log_folder), 'flagTimestamp', true);
    mkdir(PicassoConfig.log_folder);
end

if PicassoConfig.flagEnableLogSubFolder
    logPath = fullfile(PicassoConfig.log_folder, pollyType, datestr(PollyDataInfo.dataTime, 'yyyy'), datestr(PollyDataInfo.dataTime, 'mm'));
else
    logPath = PicassoConfig.log_folder;
end
mkdir(logPath);
logFile = fullfile(logPath, sprintf('%s.log', pollyDataFile));

if PicassoConfig.flagRenewLogFile
    logFid = fopen(logFile, 'w');
else
    logFid = fopen(logFid, 'a');
end
LogConfig.logFid = logFid;

%% Print PC system info for debugging
print_msg(sprintf('## PC Info\n'), 'flagSimpleMsg', true);
print_msg(sprintf('USER: %s\n', USER), 'flagSimpleMsg', true);
print_msg(sprintf('HOME: %s\n', HOME), 'flagSimpleMsg', true);
print_msg(sprintf('OS: %s\n', OS), 'flagSimpleMsg', true);
print_msg(sprintf('MATLAB: %s\n', version), 'flagSimpleMsg', true);

%% Determine data size
fileInfo = dir(pollyDataFile);
if fileInfo.bytes < PicassoConfig.minDataSize
    warning('PICASSO:InsufficientDatasize', 'Polly data file size is less than %d bytes\nStop processing.\n', PicassoConfig.minDataSize);
    fclose(LogConfig.logFid);
    return;
end

%% Search for campaign information
print_msg('Start searching polly campaign information and polly configurations.\n', 'flagTimestamp', true);
try
    [PollyConfig, CampaignConfig] = searchCampConfig(pollyDataFile, pollyType, PicassoConfig.pollynet_config_link_file);
catch ErrMsg
    if strcmp(ErrMsg.identifier, 'PICASSO:InvaliFile')
        return;
    else
        rethrow(ErrMsg);
    end
end

if isempty(CampaignConfig.location) || isempty(CampaignConfig.name)
    return;
end

if isempty(PollyConfig.startTime) || (PollyConfig.endTime)
    return;
end

print_msg(sprintf(['%s campaign info:\nlocation: %s\n', ...
                   'Lat: %f\n', ...
                   'Lon: %f\n', ...
                   'asl(m): %f\n', ...
                   'startTime: %s\n', ...
                   'caption: %s\n'], ...
                   CampaignConfig.name, ...
                   CampaignConfig.location, ...
                   CampaignConfig.lon, ...
                   CampaignConfig.lat, ...
                   CampaignConfig.asl, ...
                   datestr(CampaignConfig.startTime, 'yyyy-mm-dd HH:MM'), ...
                   CampaignConfig.caption), 'flagSimpleMsg', true);
print_msg(sprintf(['%s process info:\n', ...
                   'config file: %s\n', ...
                   'process func: %s\n', ...
                   'Instrument info: %s\n', ...
                   'polly defaults file: %s\n'], ...
                   PollyConfig.pollyVersion, ...
                   PollyConfig.pollyConfigFile, ...
                   PollyConfig.pollyProcessFunc, ...
                   PollyConfig.pollyUpdateInfo, ...
                   PollyConfig.pollyDefaultsFile), 'flagSimpleMsg', true);
print_msg('Finish.\n', 'flagTimestamp', true);

%% Create folders for saving Picasso outputs
results_folder = fullfile(PicassoConfig.results_folder, CampaignConfig.name);
pic_folder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name);

if ~ exist(results_folder, 'dir')
    print_msg(sprintf('Create a new folder for saving results for %s\n%s\n', ...
    CampaignConfig.name, results_folder), 'flagTimestamp', true);
    mkdir(results_folder);
end

if ~ exist(pic_folder, 'dir')
    print_msg(sprintf('Create a new folder for saving plots for %s\n%s\n', ...
    CampaignConfig.name, pic_folder), 'flagTimestamp', true);
    mkdir(pic_folder);
end

%% Load polly configuration
print_msg('Start loading polly config.', 'flagTimestamp', true);
PollyConfigTmp = PollyConfig;
PollyConfig = loadPollyConfig(PollyConfig.pollyConfigFile, PicassoConfig.polly_config_folder);
if ~ isstruct(PollyConfigTmp)
    % cracked polly config file
    warning('PICASSO:IOError', 'Failure in loading %s for %s\n', PollyConfig.pollyConfigFile, CampaignConfig.name);
    return;
end
PollyConfig.startTime = PollyConfigTmp.startTime;
PollyConfig.endTime = PollyConfigTmp.endTime;
PollyConfig.pollyConfigFile = PollyConfigTmp.pollyConfigFile;
PollyConfig.pollyPeox = PollyConfigTmp.pollyProcessFunc;
PollyConfig.startTime = PollyConfigTmp.pollyUpdateInfo;
PollyConfig.startTime = PollyConfigTmp.pollyDefaultsFile;
print_msg('Finish.\n', 'flagTimestamp', true);

% Keep the same naming of polly
PollyConfig.pollyVersion = CampaignConfig.name;
PollyDataInfo.pollyType  = CampaignConfig.name;

%% Load polly defaults
print_msg('Start loading polly defaults.\n', 'flagTimestamp', true);
defaultsFilepath = fullfile(PicassoDir, PollyConfig.pollyDefaultsFile);
PollyDefaults = readPollyDefaults(defaultsFilepath);
if ~ isstruct(PollyDefaults)
    warning('PICASSO:IOError', 'Failure in loading %s for %s.', ...
            PollyConfig.pollyDefaultsFile, CampaignConfig.name);
    return;
end
print_msg('Finish.\n', 'flagTimestamp', true);

% %% Start polly data processing
% print_msg(sprintf('Start processing %s data.\ndata source: %s\n', ...
%                   CampaignConfig.name, basedir(PollyDataInfo.pollyDataFile)), ...
%           'flagTimestamp', true);
% report = eval(sprintf('%s;', PollyConfig.pollyProcessFunc));
% print_msg('Finish.\n', 'flagTimestamp', true);

%% Create sub-folders for polly results
resSubFolder = fullfile(PicassoConfig.results_folder, CampaignConfig.name, ...
                        datestr(PollyDataInfo.dataTime, 'yyyy'), ...
                        datestr(PollyDataInfo.dataTime, 'mm'), ...
                        datestr(PollyDataInfo.dataTime, 'dd'));
picSubFolder = fullfile(PicassoConfig.results_folder, CampaignConfig.name, ...
                        datestr(PollyDataInfo.dataTime, 'yyyy'), ...
                        datestr(PollyDataInfo.dataTime, 'mm'), ...
                        datestr(PollyDataInfo.dataTime, 'dd'));

% Create sub-folders if not exist
if ~ exist(resSubFolder, 'dir')
    print_msg(sprintf('Create a new folder for saving outputs of %s at %s\n%s\n', ...
        CampaignConfig.name, CampaignConfig.location, resSubFolder), 'flagSimpleMsg', true);
    mkdir(resSubFolder);
end
if ~ exist(picSubFolder, 'dir')
    print_msg(sprintf('Create a new folder for saving figures of %s at %s\n%s\n', ...
        CampaignConfig.name, CampaignConfig.location, picSubFolder), 'flagSimpleMsg', true);
    mkdir(picSubFolder);
end

% Path of calibration database
dbFile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, PollyConfig.calibrationDB);

%% Specify channel tags
[channelTags, channelLabels, flagFarRangeChannel, flagNearRangeChannel, flagRotRamanChannel, flagTotalChannel, flagCrossChannel, flagParallelChannel, flag355nmChannel, flag387nmChannel, flag407nmChannel, flag532nmChannel, flag607nmChannel, flag1064nmChannel] = pollyChannelTags(PollyConfig.isFR, PollyConfig.isNR, ...
                               PollyConfig.isRR, PollyConfig.isTot, ...
                               PollyConfig.isCross, PollyConfig.isParallel, ...
                               PollyConfig.is355nm, PollyConfig.is387nm, ...
                               PollyConfig.is407nm, PollyConfig.is532nm, ...
                               PollyConfig.is607nm, PollyConfig.is1064nm, ...
                               'chTags', PollyConfig.channelTags);
data.channelTags = channelTags;
data.channelLabels = channelLabels;
data.flagFarRangeChannel = flagFarRangeChannel;
data.flagNearRangeChannel = flagNearRangeChannel;
data.flagRotRamanChannel = flagRotRamanChannel;
data.flagTotalChannel = flagTotalChannel;
data.flagCrossChannel = flagCrossChannel;
data.flagParallelChannel = flagParallelChannel;
data.flag355nmChannel = flag355nmChannel;
data.flag387nmChannel = flag387nmChannel;
data.flag407nmChannel = flag407nmChannel;
data.flag532nmChannel = flag532nmChannel;
data.flag607nmChannel = flag607nmChannel;
data.flag1064nmChannel = flag1064nmChannel;

%% Read data
print_msg(sprintf('Start reading %s data.\n', CampaignConfig.name), 'flagTimestamp', true);
data = readPollyRawData(PollyDataInfo.pollyDataFile, ...
            'flagFilterFalseMShots', PollyConfig.flagFilterFalseMShots, ...
            'flagCorrectFalseMShots', PollyConfig.flagCorrectFalseMShots, ...
            'flagDeleteData', PicassoConfig.flagDeleteData, ...
            'dataFileFormat', PollyConfig.dataFileFormat);
if isempty(data.rawSignal)
    warning('PICASSO:NoData', 'No measurement data in %s for %s.\n', ...
            PollyDataInfo.pollyDataFile, CampaignConfig.name);
    return;
end
print_msg('Finish.\n', 'flagTimestamp', true);

%% Read laserlogbook file
print_msg(sprintf('Start reading laserlogbook file.\n%s\n', PollyDataInfo.pollyLaserlogbook), 'flagTimestamp', true);
monitorStatus = readPollyLaserlogbook(PollyDataInfo.pollyLaserlogbook, ...
                        'flagDeleteData', PicassoConfig.flagDeleteData, ...
                        'pollyType', CampaignConfig.name);
data.monitorStatus = monitorStatus;
print_msg('Finish.\n', 'flagTimestamp', true);

%% Pre-processing
print_msg('Start lidar data pre-processing.\n', 'flagTimestamp', true); 
data = pollyPreprocess(data, 'flagForceMeasTime', PollyConfig.flagForceMeasTime, ...
                    'maxHeightBin', PollyConfig.max_height_bin, ...
                    'firstBinIndex', PollyConfig.first_range_gate_indx, ...
                    'firstBinHeight', PollyConfig.first_range_gate_height, ...
                    'pollyVersion', CampaignConfig.name, ...
                    'flagDeadTimeCorrection', PollyConfig.flagDTCor, ...
                    'deadtimeCorrectionMode', PollyConfig.dtCorMode, ...
                    'deadtimeParams', PollyConfig.dt, ...
                    'bgCorrectionIndex', PollyConfig.bgCorRangeIndx, ...
                    'asl', CampaignConfig.asl, ...
                    'initialPolAngle', PollyConfig.init_depAng, ...
                    'maskPolCalAngle', PollyConfig.maskDepCalAng, ...
                    'minSNRThresh', PollyConfig.mask_SNRmin, ...
                    'flagFarRangeChannel', data.flagFarRangeChannel, ...
                    'flag532nmChannel', data.flag532nmChannel, ...
                    'flagTotalChannel', data.flagTotalChannel, ...
                    'flag355nmChannel', data.flag355nmChannel, ...
                    'flag607nmChannel', data.flag607nmChannel, ...
                    'flag387nmChannel', data.flag387nmChannel, ...
                    'flag407nmChannel', data.flag407nmChannel, ...
                    'flag532nmRotRaman', data.flag532nmChannel & data.flagRotRamanChannel);
print_msg('Finish.\n', 'flagTimestamp', true);

%% Saturation detection
print_msg('Start detecting signal saturation.\n', 'flagTimestamp', true);
flagSaturation = pollySaturationDetect(data, ...
    'hFullOverlap', PollyConfig.heightFullOverlap, ...
    'sigSaturateThresh', PollyConfig.saturate_thresh);
data.flagSaturation = flagSaturation;
print_msg('Finish.\n', 'flagTimestamp', true);

%% Polarization calibration
print_msg('Start polarization calibration.\n', 'flagTimestamp', true);
[polCaliFac355, polCaliFacStd355, polCaliTime355, polCali355Attri] = pollyPolCali(data, PollyConfig.TR, ...
    'wavelength', '355nm', ...
    'depolCaliMinBin', PollyConfig.depol_cal_minbin_355, ...
    'depolCaliMaxBin', PollyConfig.depol_cal_maxbin_355, ...
    'depolCaliMinSNR', PollyConfig.depol_cal_SNRmin_355, ...
    'depolCaliMaxSig', PollyConfig.depol_cal_sigMax_355, ...
    'relStdDPlus', PollyConfig.rel_std_dplus_355, ...
    'relStdDMinus', PollyConfig.rel_std_dminus_355, ...
    'depolCaliSegLen', PollyConfig.depol_cal_segmentLen_355, ...
    'depolCaliSmWin', PollyConfig.depol_cal_smoothWin_355, ...
    'dbFile', dbFile, ...
    'pollyVersion', CampaignConfig.name, ...
    'flagUsePrevDepolConst', PollyConfig.flagUsePrevDepolConst, ...
    'flagDepolCali', PollyConfig.flagDepolCali, ...
    'default_depolconst', PollyDefaults.depolCaliConst355, ...
    'default_depolconstStd', PollyDefaults.depolCaliConstStd355);
[polCaliFac532, polCaliFacStd532, polCaliTime532, polCali532Attri] = pollyPolCali(data, PollyConfig.TR, ...
    'wavelength', '532nm', ...
    'depolCaliMinBin', PollyConfig.depol_cal_minbin_532, ...
    'depolCaliMaxBin', PollyConfig.depol_cal_maxbin_532, ...
    'depolCaliMinSNR', PollyConfig.depol_cal_SNRmin_532, ...
    'depolCaliMaxSig', PollyConfig.depol_cal_sigMax_532, ...
    'relStdDPlus', PollyConfig.rel_std_dplus_532, ...
    'relStdDMinus', PollyConfig.rel_std_dminus_532, ...
    'depolCaliSegLen', PollyConfig.depol_cal_segmentLen_532, ...
    'depolCaliSmWin', PollyConfig.depol_cal_smoothWin_532, ...
    'dbFile', dbFile, ...
    'pollyVersion', CampaignConfig.name, ...
    'flagUsePrevDepolConst', PollyConfig.flagUsePrevDepolConst, ...
    'flagDepolCali', PollyConfig.flagDepolCali, ...
    'default_depolconst', PollyDefaults.depolCaliConst532, ...
    'default_depolconstStd', PollyDefaults.depolCaliConstStd532);
print_msg('Finish.\n', 'flagTimestamp', true);

%% Cloud screen
print_msg('Start cloud screening.\n', 'flagTimestamp', true);
flagChannel532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flagChannel532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
PCRate = data.signal ./ repmat(reshape(data.mShots, size(data.mShots, 1), 1, []), ...
        1, size(data.signal, 2), 1) * 150 / data.hRes;
flagCloudFree = true(size(data.mTime));

if sum(flagChannel532FR) == 1
    % with only one far-range total channel at 532 nm
    [flagCloudFree_FR, layers] = cloudScreen(data.mTime, data.height, ...
        squeeze(PCRate(flagChannel532FR, :, :)), ...
        'mode', PollyConfig.cloudScreenMode, ...
        'detectRange', [PollyConfig.heightFullOverlap(flagChannel532FR), 7000], ...
        'slope_thres', PollyConfig.maxSigSlope4FilterCloud, ...
        'background', squeeze(data.bg(flag532nmChannel, 1, :)), ...
        'heightFullOverlap', PollyConfig.heightFullOverlap(flagChannel532FR), ...
        'minSNR', 2);
end

if sum(flagChannel532NR) == 1
    % with only one near-range total channel at 532 nm
    [flagCloudFree_NR, layers] = cloudScreen(data.mTime, data.height, ...
        squeeze(PCRate(flagChannel532NR, :, :)), ...
        'mode', PollyConfig.cloudScreenMode, ...
        'detectRange', [PollyConfig.heightFullOverlap(flagChannel532NR), 2000], ...
        'slope_thres', PollyConfig.maxSigSlope4FilterCloud, ...
        'background', squeeze(data.bg(flag532nmChannel, 1, :)), ...
        'heightFullOverlap', PollyConfig.heightFullOverlap(flagChannel532NR), ...
        'minSNR', 2);
end

if (sum(flagChannel532FR) == 1) && (sum(flagChannel532NR) == 1)
    % combined cloud mask from near-range and far-range channels
    flagCloudFree = flagCloudFree_FR & flagCloudFree_NR & (~ data.shutterOnMask);
elseif (sum(flagChannel532FR) == 1)
    % cloud-mask from far-range channel
    flagCloudFree = flagCloudFree_FR & (~ data.shutterOnMask);
else
    print_msg('No cloud mask available\n', 'flagSimpleMsg', false);
end
print_msg('Finish.\n', 'flagTimestamp', true);

%% Overlap estimation
print_msg('Start overlap estimation.\n', 'flagTimestamp', true);

% 355 nm
flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
olAttri355 = struct();
if (sum(flag355FR) == 1) && (sum(flag355NR) == 1)
    sig355NR = squeeze(sum(data.signal(flag355NR, :, data.flagCloudFree_NR), 3));
    bg355NR = squeeze(sum(data.bg(flag355NR, :, data.flagCloudFree_NR), 3));
    sig355FR = squeeze(sum(data.signal(flag355FR, :, data.flagCloudFree_NR), 3));
    bg355FR = squeeze(sum(data.bg(flag355FR, :, data.flagCloudFree_NR), 3));
    [olFunc355, olStd355, olAttri355] = pollyOVLCalc(data.height, ...
        sig355FR, sig355NR, bg355FR, bg355NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag355FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode);
end
data.olFunc355 = olFunc355;
data.olStd355 = olStd355;
data.olAttri355 = olAttri355;

% 387 nm
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
olAttri387 = struct();
if (sum(flag387FR) == 1) && (sum(flag387NR) == 1)
    sig387NR = squeeze(sum(data.signal(flag387NR, :, data.flagCloudFree_NR), 3));
    bg387NR = squeeze(sum(data.bg(flag387NR, :, data.flagCloudFree_NR), 3));
    sig387FR = squeeze(sum(data.signal(flag387FR, :, data.flagCloudFree_NR), 3));
    bg387FR = squeeze(sum(data.bg(flag387FR, :, data.flagCloudFree_NR), 3));
    [olFunc387, olStd387, olAttri387] = pollyOVLCalc(data.height, ...
        sig387FR, sig387NR, bg387FR, bg387NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag387FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode);
end
data.olFunc387 = olFunc387;
data.olStd387 = olStd387;
data.olAttri387 = olAttri387;

% 532 nm
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
olAttri532 = struct();
if (sum(flag532FR) == 1) && (sum(flag532NR) == 1)
    sig532NR = squeeze(sum(data.signal(flag532NR, :, data.flagCloudFree_NR), 3));
    bg532NR = squeeze(sum(data.bg(flag532NR, :, data.flagCloudFree_NR), 3));
    sig532FR = squeeze(sum(data.signal(flag532FR, :, data.flagCloudFree_NR), 3));
    bg532FR = squeeze(sum(data.bg(flag532FR, :, data.flagCloudFree_NR), 3));
    [olFunc532, olStd532, olAttri532] = pollyOVLCalc(data.height, ...
        sig532FR, sig532NR, bg532FR, bg532NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag532FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode);
end
data.olFunc532 = olFunc532;
data.olStd532 = olStd532;
data.olAttri532 = olAttri532;

% 607 nm
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
olAttri607 = struct();
if (sum(flag607FR) == 1) && (sum(flag607NR) == 1)
    sig607NR = squeeze(sum(data.signal(flag607NR, :, data.flagCloudFree_NR), 3));
    bg607NR = squeeze(sum(data.bg(flag607NR, :, data.flagCloudFree_NR), 3));
    sig607FR = squeeze(sum(data.signal(flag607FR, :, data.flagCloudFree_NR), 3));
    bg607FR = squeeze(sum(data.bg(flag607FR, :, data.flagCloudFree_NR), 3));
    [olFunc607, olStd607, olAttri607] = pollyOVLCalc(data.height, ...
        sig607FR, sig607NR, bg607FR, bg607NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag607FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode);
end
data.olFunc607 = olFunc607;
data.olStd607 = olStd607;
data.olAttri607 = olAttri607;

print_msg('Finish.\n', 'flagTimestamp', true);

%% Overlap correction
print_msg('Start overlap correction.\n', 'flagTimestamp', true);

% 355 nm
sig355FR = squeeze(data.signal(flag355FR, :, :));
bg355FR = squeeze(data.bg(flag355FR, :, :));
sig355NR = squeeze(data.signal(flag355NR, :, :));
bg355NR = squeeze(data.bg(flag355NR, :, :));
[sigOLCor355, bgOLCor355, olFuncDeft355, flagOLDeft355] = pollyOLCor(data.height, sig355FR, bg355FR, ...
    'signalNR', sig355NR, 'bgNR', bg355NR, ...
    'signalRatio', data.olAttri355.sigRatio, 'normRange', data.olAttri355.normRange, ...
    'overlap', data.olFunc355, ...
    'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
    'overlapCorMode', PollyConfig.overlapCorMode, ...
    'overlapSmWin', PollyConfig.overlapSmoothBins);

% 387 nm
sig387FR = squeeze(data.signal(flag387FR, :, :));
bg387FR = squeeze(data.bg(flag387FR, :, :));
sig387NR = squeeze(data.signal(flag387NR, :, :));
bg387NR = squeeze(data.bg(flag387NR, :, :));
[sigOLCor387, bgOLCor387, olFuncDeft387, flagOLDeft387] = pollyOLCor(data.height, sig387FR, bg387FR, ...
    'signalNR', sig387NR, 'bgNR', bg387NR, ...
    'signalRatio', data.olAttri387.sigRatio, 'normRange', data.olAttri387.normRange, ...
    'overlap', data.olFunc387, ...
    'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
    'overlapCorMode', PollyConfig.overlapCorMode, ...
    'overlapSmWin', PollyConfig.overlapSmoothBins);

% 532 nm
sig532FR = squeeze(data.signal(flag532FR, :, :));
bg532FR = squeeze(data.bg(flag532FR, :, :));
sig532NR = squeeze(data.signal(flag532NR, :, :));
bg532NR = squeeze(data.bg(flag532NR, :, :));
[sigOLCor532, bgOLCor532, olFuncDeft532, flagOLDeft532] = pollyOLCor(data.height, sig532FR, bg532FR, ...
    'signalNR', sig532NR, 'bgNR', bg532NR, ...
    'signalRatio', data.olAttri532.sigRatio, 'normRange', data.olAttri532.normRange, ...
    'overlap', data.olFunc532, ...
    'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
    'overlapCorMode', PollyConfig.overlapCorMode, ...
    'overlapSmWin', PollyConfig.overlapSmoothBins);

% 607 nm
sig607FR = squeeze(data.signal(flag607FR, :, :));
bg607FR = squeeze(data.bg(flag607FR, :, :));
sig607NR = squeeze(data.signal(flag607NR, :, :));
bg607NR = squeeze(data.bg(flag607NR, :, :));
[sigOLCor607, bgOLCor607, olFuncDeft607, flagOLDeft607] = pollyOLCor(data.height, sig607FR, bg607FR, ...
    'signalNR', sig607NR, 'bgNR', bg607NR, ...
    'signalRatio', data.olAttri607.sigRatio, 'normRange', data.olAttri607.normRange, ...
    'overlap', data.olFunc355, ...
    'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
    'overlapCorMode', PollyConfig.overlapCorMode, ...
    'overlapSmWin', PollyConfig.overlapSmoothBins);

print_msg('Finish.\n', 'flagTimestamp', true);

%% Cloud-free profiles segmentation
print_msg('Start cloud-free profiles segmentation.\n', 'flagTimestamp', true);

flagValPrf = data.flagCloudFree & (~ data.fogMask) & (~ data.depCalMask) & (~ data.shutterOnMask);
clFreGrps = clFreeSeg(flagValPrf, PollyConfig.intNProfiles, PollyConfig.minIntNProfiles);
data.clFreGrps = clFreGrps;

if isempty(clFreGrps)
    print_msg('No cloud-free groups were found.\n', 'flagSimpleMsg', true);
else
    print_msg('%d cloud-free groups were found.\n', 'flagSimpleMsg', true);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Meteorological data loading
print_msg('Start loading meteorological data.\n', 'flagTimestamp', true);

clFreGrpTimes = nanmean(data.mTime(clFreGrps), 2);
[temp, pres, relh, ~, ~, meteorAttri] = loadMeteor(clFreGrpTimes, data.alt, ...
    'meteorDataSource', PollyConfig.meteorDataSource, ...
    'gdas1Site', PollyConfig.gdas1Site, ...
    'gdas1_folder', PicassoConfig.gdas1_folder, ...
    'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
    'radiosondeFolder', PollyConfig.radiosondeFolder, ...
    'radiosondeType', PollyConfig.radiosondeType, ...
    'method', 'linear');
data.temperature = temp;
data.pressure = pres;
data.relh = relh;
data.meteorAttri = meteorAttri;

print_msg('Finish.\n', 'flagTimestamp', true);

%% AERONET data loading
print_msg('Start loading AERONET data.\n', 'flagTimestamp', true);

AERONET = struct();
[AERONET.datetime, AERONET.AOD_1640, AERONET.AOD_1020, AERONET.AOD_870, ...
 AERONET.AOD_675, AERONET.AOD_500, AERONET.AOD_440, AERONET.AOD_380, ...
 AERONET.AOD_340, AERONET.wavelength, AERONET.IWV, ...
 AERONET.angstrexp440_870, AERONET.AERONETAttri] = read_AERONET(...
    config.AERONETSite, ...
    [floor(data.mTime(1)) - 1, floor(data.mTime(1)) + 1], '15');
data.AERONET = AERONET;

print_msg('Finish\n', 'flagTimestamp', true);

%% Rayleigh fitting
print_msg('Start Rayleigh fitting.\n', 'flagTimestamp', true);
print_msg('Finish.\n', 'flagTimestamp', true);

%% Clean
fclose(LogConfig.logFid);

tEnd = now();
tUsage = (tEnd - tStart) * 24 * 3600;
report{end + 1} = tStart;
report{end + 1} = tUsage;
print_msg('\n%%------------------------------------------------------%%');
print_msg('Finish pollynet processing chain\n', 'flagTimestamp', true);
print_msg('%%------------------------------------------------------%%\n');

%% Enable the usage of matlab toolbox
if PicassoConfig.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'enable');
    print_msg('Enable the usage of matlab statistics_toolbox\n', ...
              'flagSimpleMsg', true);
end

% %% publish the report
% if PicassoConfig.flagSendNotificationEmail
%     system(sprintf('%s %s %s %s "%s" "%s" "%s"', ...
%            fullfile(PicassoConfig.pyBinDir, 'python'), ...
%            fullfile(PicassoDir, 'lib', 'sendmail_msg.py'), ...
%            'sender@email.com', 'recipient@email.com', ...
%            sprintf('[%s] PollyNET Processing Report', tNow()), ...
%            'Have an overview', PicassoConfig.fileinfo_new));
% end