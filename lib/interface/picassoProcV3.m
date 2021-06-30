function [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile, varargin)
% PICASSOPROCV3 Picasso processing main program (Version 3.0).
% USAGE:
%    % Usecase 1: process polly data
%    [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile)
%    % Usecase 2: process polly data and laserlogbook
%    [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile, 'pollyLaserlogbook', pollyLaserlogbook)
% INPUTS:
%    pollyDataFile: char
%        absolute path of polly data.
%    pollyType: char
%        polly type.
%    PicassoConfigFile: char
%        absolute path of Picasso configuration file.
% KEYWORDS:
%    defaultPiassoConfigFile: char
%        absolute path of default Picasso configuration file.
%    pollyGlobalConfigFile:
%        polly global configuration file.
%    pollyZipFile: char
%        path of the compressed file of polly data.
%    pollyZipFileSize: numeric
%        compressed polly data file size in bytes.
%    pollyLaserlogbook: char
%        absolut path of polly laserlogbook file.
%    flagDonefileList: logical
%        flag for writing done_filelist.
% OUTPUTS:
%    report: cell
%        processing report.
% EXAMPLE:
% HISTORY:
%    2021-06-25: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig
global CampaignConfig
global PollyConfig
global PollyDataInfo
global PollyDefaults
global LogConfig

PicassoDir = fileparts((fileparts(fileparts(mfilename('fullpath')))));

%% Input parser
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'pollyDataFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addRequired(p, 'PicassoConfigFile', @ischar);
addParameter(p, 'defaultPiassoConfigFile', fullfile(PicassoDir, 'lib', 'config', 'pollynet_processing_chain_config.json'), @ischar);
addParameter(p, 'pollyGlobalConfigFile', fullfile(PicassoDir, 'lib', 'config', 'polly_global_config.json'), @ischar);
addParameter(p, 'pollyZipFile', '', @ischar);
addParameter(p, 'pollyZipFileSize', 0, @isnumeric);
addParameter(p, 'pollyLaserlogbook', '', @ischar);
addParameter(p, 'flagDonefileList', false, @islogical);

parse(p, pollyDataFile, pollyType, PicassoConfigFile, varargin{:});

%% Parameter initialization
defaultPiassoConfigFile = p.Results.defaultPiassoConfigFile;
pollyGlobalConfigFile = p.Results.pollyGlobalConfigFile;
report = cell(0);

%% Input check
if ~ exist('PicassoConfigFile', 'var')
    PicassoConfigFile = defaultPiassoConfigFile;
end

%% Set PollyDataInfo
PollyDataInfo.pollyType = pollyType;
PollyDataInfo.pollyDataFile = pollyDataFile;
PollyDataInfo.zipFile = p.Results.pollyZipFile;
PollyDataInfo.dataSize = p.Results.pollyZipFileSize;
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
PollyDataInfo.pollyLaserlogbook = p.Results.pollyLaserlogbook;

%% Get Picasso program version
PicassoVersion = getPicassoVersion();

%% Load Picasso configurations
PicassoConfig = loadConfig(PicassoConfigFile, defaultPiassoConfigFile);
PicassoConfig.PicassoVersion = PicassoVersion;
PicassoConfig.PicassoRootDir = PicassoDir;

%% Create log file
if ~ exist(PicassoConfig.log_folder, 'dir')
    fprintf('Create log folder: %s.\n', PicassoConfig.log_folder);
    mkdir(PicassoConfig.log_folder);
end

if PicassoConfig.flagEnableLogSubFolder
    logPath = fullfile(PicassoConfig.log_folder, pollyType, datestr(PollyDataInfo.dataTime, 'yyyy'), datestr(PollyDataInfo.dataTime, 'mm'));
else
    logPath = PicassoConfig.log_folder;
end
mkdir(logPath);
logFile = fullfile(logPath, sprintf('%s.log', basename(pollyDataFile)));

if PicassoConfig.flagRenewLogFile
    logFid = fopen(logFile, 'w');
else
    logFid = fopen(logFile, 'a');
end

% Set logger configuration
LogConfig.logFid = logFid;
LogConfig.logFile = logFile;
LogConfig.folder = PicassoConfig.log_folder;
LogConfig.flagEnableLogSubFolder = PicassoConfig.flagEnableLogSubFolder;
LogConfig.printLevel = PicassoConfig.printLevel;   % 0: log file & matlab command line
                            % 1: log file only
                            % 2: matlab command line only
                            % 3: simple message in log file & matlab command line
                            % 4: simple message in log file only
                            % 5: simple message in matlab command line only

%% Print headers
tStart = now();
print_msg('\n%%------------------------------------------------------%%\n');
print_msg('    ____  _                               _____  ____\n', 'flagSimpleMsg', true);
print_msg('   / __ \\(_)________ _______________     |__  / / __ \\\n', 'flagSimpleMsg', true);
print_msg('  / /_/ / / ___/ __ `/ ___/ ___/ __ \\     /_ < / / / /\n', 'flagSimpleMsg', true);
print_msg(' / ____/ / /__/ /_/ (__  |__  ) /_/ /   ___/ // /_/ /\n', 'flagSimpleMsg', true);
print_msg('/_/   /_/\\___/\\__,_/____/____/\\____/   /____(_)____/\n', 'flagSimpleMsg', true);
print_msg('\nStart pollynet processing chain\n');
print_msg(sprintf('Picasso config file: %s\n', strrep(PicassoConfigFile, '\', '\\')));
print_msg(sprintf('Polly Type: %s\n', PollyDataInfo.pollyType));
print_msg(sprintf('Polly Data: %s\n', strrep(PollyDataInfo.pollyDataFile, '\', '\\')));
print_msg('%%------------------------------------------------------%%\n');

% Reduce the dependence on additionable toolboxes to get rid of license problems
% after the turndown of usage of matlab toolbox, we need to replace the applied
% function with user defined functions
if PicassoConfig.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'disable');
    print_msg('Disable matlab statistics_toolbox\n', 'flagSimpleMsg', true);
end

%% Print PC system info for debugging
[USER, HOME, OS] = getsysinfo();
print_msg(sprintf('## PC Info\n'), 'flagSimpleMsg', true);
print_msg(sprintf('USER: %s\n', USER), 'flagSimpleMsg', true);
print_msg(sprintf('HOME: %s\n', strrep(HOME, '\', '\\')), 'flagSimpleMsg', true);
print_msg(sprintf('OS: %s\n', OS), 'flagSimpleMsg', true);
print_msg(sprintf('MATLAB: %s\n', version), 'flagSimpleMsg', true);

%% Determine data size
fileInfo = dir(pollyDataFile);
if isempty(fileInfo)
    warning('PICASSO:EmptyData', 'No polly data was found.\n');
    fclose(LogConfig.logFid);
    return;
elseif fileInfo.bytes < PicassoConfig.minDataSize
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

if isempty(PollyConfig.startTime) || isempty(PollyConfig.endTime)
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
                   PollyConfig.pollyType, ...
                   PollyConfig.pollyConfigFile, ...
                   PollyConfig.pollyProcessFunc, ...
                   PollyConfig.pollyUpdateInfo, ...
                   PollyConfig.pollyDefaultsFile), 'flagSimpleMsg', true);
print_msg('Finish.\n', 'flagTimestamp', true);

%% Create folders for saving Picasso outputs
results_folder = fullfile(PicassoConfig.results_folder, CampaignConfig.name, ...
                          datestr(PollyDataInfo.dataTime, 'yyyy'), ...
                          datestr(PollyDataInfo.dataTime, 'mm'), ...
                          datestr(PollyDataInfo.dataTime, 'dd'));
pic_folder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, ...
                          datestr(PollyDataInfo.dataTime, 'yyyy'), ...
                          datestr(PollyDataInfo.dataTime, 'mm'), ...
                          datestr(PollyDataInfo.dataTime, 'dd'));

if ~ exist(results_folder, 'dir')
    print_msg(sprintf('Create a new folder for saving results for %s\n%s\n', ...
    CampaignConfig.name, strrep(results_folder, '\', '\\')), 'flagTimestamp', true);
    mkdir(results_folder);
end

if ~ exist(pic_folder, 'dir')
    print_msg(sprintf('Create a new folder for saving plots for %s\n%s\n', ...
    CampaignConfig.name, strrep(pic_folder, '\', '\\')), 'flagTimestamp', true);
    mkdir(pic_folder);
end

%% Load polly configuration
print_msg('Start loading polly config.\n', 'flagTimestamp', true);
PollyConfigTmp = PollyConfig;
PollyConfig = loadPollyConfig(fullfile(PicassoConfig.polly_config_folder, PollyConfig.pollyConfigFile), pollyGlobalConfigFile);
if ~ isstruct(PollyConfigTmp)
    % cracked polly config file
    warning('PICASSO:IOError', 'Failure in loading %s for %s\n', PollyConfig.pollyConfigFile, CampaignConfig.name);
    return;
end
PollyConfig.startTime = PollyConfigTmp.startTime;
PollyConfig.endTime = PollyConfigTmp.endTime;
PollyConfig.pollyConfigFile = PollyConfigTmp.pollyConfigFile;
PollyConfig.pollyProcessFunc = PollyConfigTmp.pollyProcessFunc;
PollyConfig.pollyUpdateInfo = PollyConfigTmp.pollyUpdateInfo;
PollyConfig.pollyDefaultsFile = PollyConfigTmp.pollyDefaultsFile;
print_msg('Finish.\n', 'flagTimestamp', true);

% Keep the same naming of polly
PollyConfig.pollyType = CampaignConfig.name;
PollyDataInfo.pollyType  = CampaignConfig.name;

%% Load polly defaults
print_msg('Start loading polly defaults.\n', 'flagTimestamp', true);
defaultsFilepath = fullfile(PicassoConfig.defaultFile_folder, PollyConfig.pollyDefaultsFile);
globalDefaultFile = fullfile(PicassoConfig.PicassoRootDir, 'lib', 'config', 'polly_global_defaults.json');
PollyDefaults = readPollyDefaults(defaultsFilepath, globalDefaultFile);
if ~ isstruct(PollyDefaults)
    warning('PICASSO:IOError', 'Failure in loading %s for %s.', ...
            PollyConfig.pollyDefaultsFile, CampaignConfig.name);
    return;
end
print_msg('Finish.\n', 'flagTimestamp', true);

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
        CampaignConfig.name, CampaignConfig.location, strrep(resSubFolder, '\', '\\')), 'flagSimpleMsg', true);
    mkdir(resSubFolder);
end
if ~ exist(picSubFolder, 'dir')
    print_msg(sprintf('Create a new folder for saving figures of %s at %s\n%s\n', ...
        CampaignConfig.name, CampaignConfig.location, strrep(picSubFolder, '\', '\\')), 'flagSimpleMsg', true);
    mkdir(picSubFolder);
end

% Path of calibration database
dbFile = fullfile(PicassoConfig.results_folder, CampaignConfig.name, PollyConfig.calibrationDB);

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

%% Specify channel tags
[channelTags, channelLabels, flagFarRangeChannel, flagNearRangeChannel, flagRotRamanChannel, flagTotalChannel, flagCrossChannel, flagParallelChannel, flag355nmChannel, flag387nmChannel, flag407nmChannel, flag532nmChannel, flag607nmChannel, flag1064nmChannel] = pollyChannelTags(PollyConfig.channelTags, ...
    'flagFarRangeChannel', PollyConfig.isFR, ...
    'flagNearRangeChannel', PollyConfig.isNR, ...
    'flagRotRamanChannel', PollyConfig.isRR, ...
    'flagTotalChannel', PollyConfig.isTot, ...
    'flagCrossChannel', PollyConfig.isCross, ...
    'flagParallelChannel', PollyConfig.isParallel, ...
    'flag355nmChannel', PollyConfig.is355nm, ...
    'flag387nmChannel', PollyConfig.is387nm, ...
    'flag407nmChannel', PollyConfig.is407nm, ...
    'flag532nmChannel', PollyConfig.is532nm, ...
    'flag607nmChannel', PollyConfig.is607nm, ...
    'flag1064nmChannel', PollyConfig.is1064nm);
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

%% Read laserlogbook file
print_msg(sprintf('Start reading laserlogbook file.\n%s\n', strrep(PollyDataInfo.pollyLaserlogbook, '\', '\\')), 'flagTimestamp', true);
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
                    'pollyType', CampaignConfig.name, ...
                    'flagDeadTimeCorrection', PollyConfig.flagDTCor, ...
                    'deadtimeCorrectionMode', PollyConfig.dtCorMode, ...
                    'deadtimeParams', PollyConfig.dt, ...
                    'bgCorrectionIndex', PollyConfig.bgCorRangeIndx, ...
                    'asl', CampaignConfig.asl, ...
                    'initialPolAngle', PollyConfig.init_depAng, ...
                    'maskPolCalAngle', PollyConfig.maskDepCalAng, ...
                    'minSNRThresh', PollyConfig.mask_SNRmin, ...
                    'minPC_fog', PollyConfig.minPC_fog, ...
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
    'pollyType', CampaignConfig.name, ...
    'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
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
    'pollyType', CampaignConfig.name, ...
    'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
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
    [flagCloudFree_FR, cloudMask] = cloudScreen(data.mTime, data.height, ...
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
    [flagCloudFree_NR, cloudMask] = cloudScreen(data.mTime, data.height, ...
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
olAttri355.sigFR = [];
olAttri355.sigNR = [];
olAttri355.sigRatio = [];
olAttri355.normRange = [];
olFunc355 = NaN(length(data.height), 1);
olStd355 = NaN(length(data.height), 1);
if (sum(flag355FR) == 1) && (sum(flag355NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flagCloudFree_NR)) / 150;

    sig355NR = squeeze(sum(data.signal(flag355NR, :, flagCloudFree_NR), 3));
    bg355NR = squeeze(sum(data.bg(flag355NR, :, flagCloudFree_NR), 3));
    sig355FR = squeeze(sum(data.signal(flag355FR, :, flagCloudFree_NR), 3));
    bg355FR = squeeze(sum(data.bg(flag355FR, :, flagCloudFree_NR), 3));
    [olFunc355, olStd355, olAttri355] = pollyOVLCalc(data.height, ...
        sig355FR, sig355NR, bg355FR, bg355NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag355FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode, ...
        'PC2PCR', PC2PCR);
end

% 387 nm
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
olAttri387 = struct();
olAttri387.sigFR = [];
olAttri387.sigNR = [];
olAttri387.sigRatio = [];
olAttri387.normRange = [];
olFunc387 = NaN(length(data.height), 1);
olStd387 = NaN(length(data.height), 1);
if (sum(flag387FR) == 1) && (sum(flag387NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flagCloudFree_NR)) / 150;

    sig387NR = squeeze(sum(data.signal(flag387NR, :, flagCloudFree_NR), 3));
    bg387NR = squeeze(sum(data.bg(flag387NR, :, flagCloudFree_NR), 3));
    sig387FR = squeeze(sum(data.signal(flag387FR, :, flagCloudFree_NR), 3));
    bg387FR = squeeze(sum(data.bg(flag387FR, :, flagCloudFree_NR), 3));
    [olFunc387, olStd387, olAttri387] = pollyOVLCalc(data.height, ...
        sig387FR, sig387NR, bg387FR, bg387NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag387FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode, ...
        'PC2PCR', PC2PCR);
end

% 532 nm
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
olAttri532 = struct();
olAttri532.sigFR = [];
olAttri532.sigNR = [];
olAttri532.sigRatio = [];
olAttri532.normRange = [];
olFunc532 = NaN(length(data.height), 1);
olStd532 = NaN(length(data.height), 1);
if (sum(flag532FR) == 1) && (sum(flag532NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flagCloudFree_NR)) / 150;

    sig532NR = squeeze(sum(data.signal(flag532NR, :, flagCloudFree_NR), 3));
    bg532NR = squeeze(sum(data.bg(flag532NR, :, flagCloudFree_NR), 3));
    sig532FR = squeeze(sum(data.signal(flag532FR, :, flagCloudFree_NR), 3));
    bg532FR = squeeze(sum(data.bg(flag532FR, :, flagCloudFree_NR), 3));
    [olFunc532, olStd532, olAttri532] = pollyOVLCalc(data.height, ...
        sig532FR, sig532NR, bg532FR, bg532NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag532FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode, ...
        'PC2PCR', PC2PCR);
end

% 607 nm
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
olAttri607 = struct();
olAttri607.sigFR = [];
olAttri607.sigNR = [];
olAttri607.sigRatio = [];
olAttri607.normRange = [];
olFunc607 = NaN(length(data.height), 1);
olStd607 = NaN(length(data.height), 1);
if (sum(flag607FR) == 1) && (sum(flag607NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flagCloudFree_NR)) / 150;

    sig607NR = squeeze(sum(data.signal(flag607NR, :, flagCloudFree_NR), 3));
    bg607NR = squeeze(sum(data.bg(flag607NR, :, flagCloudFree_NR), 3));
    sig607FR = squeeze(sum(data.signal(flag607FR, :, flagCloudFree_NR), 3));
    bg607FR = squeeze(sum(data.bg(flag607FR, :, flagCloudFree_NR), 3));
    [olFunc607, olStd607, olAttri607] = pollyOVLCalc(data.height, ...
        sig607FR, sig607NR, bg607FR, bg607NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag607FR), ...
        'overlapCalMode', PollyConfig.overlapCalMode, ...
        'PC2PCR', PC2PCR);
end

% 1064 nm
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
olAttri1064 = struct();
olAttri1064.sigFR = [];
olAttri1064.sigNR = [];
olAttri1064.sigRatio = [];
olAttri1064.normRange = [];
olFunc1064 = NaN(length(data.height), 1);
olStd1064 = NaN(length(data.height), 1);
if (sum(flag1064FR) == 1) && (sum(flag532FR) == 1) && (sum(flag532NR) == 1)
    olFunc1064 = olFunc532;
    olStd1064 = olStd532;
    olAttri1064 = olAttri532;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Overlap correction
print_msg('Start overlap correction.\n', 'flagTimestamp', true);

% 355 nm
sigOLCor355 = [];
bgOLCor355 = [];
olFuncDeft355 = NaN(length(data.height), 1);
flagOLDeft355 = false;
if (sum(flag355FR) == 1) 
    sig355FR = squeeze(data.signal(flag355FR, :, :));
    bg355FR = squeeze(data.bg(flag355FR, :, :));
    sig355NR = squeeze(data.signal(flag355NR, :, :));
    bg355NR = squeeze(data.bg(flag355NR, :, :));
    [sigOLCor355, bgOLCor355, olFuncDeft355, flagOLDeft355] = pollyOLCor(data.height, sig355FR, bg355FR, ...
        'signalNR', sig355NR, 'bgNR', bg355NR, ...
        'signalRatio', olAttri355.sigRatio, 'normRange', olAttri355.normRange, ...
        'overlap', olFunc355, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
        'overlapCorMode', PollyConfig.overlapCorMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end

% 387 nm
sigOLCor387 = [];
bgOLCor387 = [];
olFuncDeft387 = NaN(length(data.height), 1);
flagOLDeft387 = false;
if (sum(flag387FR) == 1)
    sig387FR = squeeze(data.signal(flag387FR, :, :));
    bg387FR = squeeze(data.bg(flag387FR, :, :));
    sig387NR = squeeze(data.signal(flag387NR, :, :));
    bg387NR = squeeze(data.bg(flag387NR, :, :));
    [sigOLCor387, bgOLCor387, olFuncDeft387, flagOLDeft387] = pollyOLCor(data.height, sig387FR, bg387FR, ...
        'signalNR', sig387NR, 'bgNR', bg387NR, ...
        'signalRatio', olAttri387.sigRatio, 'normRange', olAttri387.normRange, ...
        'overlap', olFunc387, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
        'overlapCorMode', PollyConfig.overlapCorMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end

% 532 nm
sigOLCor532 = [];
bgOLCor532 = [];
olFuncDeft532 = NaN(length(data.height), 1);
flagOLDeft532 = false;
if (sum(flag532FR) == 1)
    sig532FR = squeeze(data.signal(flag532FR, :, :));
    bg532FR = squeeze(data.bg(flag532FR, :, :));
    sig532NR = squeeze(data.signal(flag532NR, :, :));
    bg532NR = squeeze(data.bg(flag532NR, :, :));
    [sigOLCor532, bgOLCor532, olFuncDeft532, flagOLDeft532] = pollyOLCor(data.height, sig532FR, bg532FR, ...
        'signalNR', sig532NR, 'bgNR', bg532NR, ...
        'signalRatio', olAttri532.sigRatio, 'normRange', olAttri532.normRange, ...
        'overlap', olFunc532, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end

% 607 nm
sigOLCor607 = [];
bgOLCor607 = [];
olFuncDeft607 = NaN(length(data.height), 1);
flagOLDeft607 = false;
if (sum(flag607FR) == 1)
    sig607FR = squeeze(data.signal(flag607FR, :, :));
    bg607FR = squeeze(data.bg(flag607FR, :, :));
    sig607NR = squeeze(data.signal(flag607NR, :, :));
    bg607NR = squeeze(data.bg(flag607NR, :, :));
    [sigOLCor607, bgOLCor607, olFuncDeft607, flagOLDeft607] = pollyOLCor(data.height, sig607FR, bg607FR, ...
        'signalNR', sig607NR, 'bgNR', bg607NR, ...
        'signalRatio', olAttri607.sigRatio, 'normRange', olAttri607.normRange, ...
        'overlap', olFunc607, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end

% 1064 nm
sigOLCor1064 = [];
bgOLCor1064 = [];
olFuncDeft1064 = NaN(length(data.height), 1);
flagOLDeft1064 = false;
if (sum(flag1064FR) == 1) && (sum(flag532FR) == 1)
    sig1064FR = squeeze(data.signal(flag1064FR, :, :));
    bg1064FR = squeeze(data.bg(flag1064FR, :, :));
    sig1064NR = [];
    bg1064NR = [];
    [sigOLCor1064, bgOLCor1064, olFuncDeft1064, flagOLDeft1064] = pollyOLCor(data.height, sig1064FR, bg1064FR, ...
        'signalNR', sig1064NR, 'bgNR', bg1064NR, ...
        'signalRatio', olAttri1064.sigRatio, 'normRange', olAttri1064.normRange, ...
        'overlap', olFunc1064, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Cloud-free profiles segmentation
print_msg('Start cloud-free profiles segmentation.\n', 'flagTimestamp', true);

flagValPrf = flagCloudFree & (~ data.fogMask) & (~ data.depCalMask) & (~ data.shutterOnMask);
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
 AERONET.angstrexp440_870, AERONET.AERONETAttri] = readAERONET(...
    PollyConfig.AERONETSite, ...
    [floor(data.mTime(1)) - 1, floor(data.mTime(1)) + 1], '15');
data.AERONET = AERONET;

print_msg('Finish\n', 'flagTimestamp', true);

%% Rayleigh fitting
print_msg('Start Rayleigh fitting.\n', 'flagTimestamp', true);

flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
refHInd355 = [];   % reference height range at 355 nm
refHInd532 = [];   % reference height range at 532 nm
refHInd1064 = [];   % reference height range at 1064 nm
DPInd355 = {};   % points decomposed by Douglas-Peucker method at 355 nm
DPInd532 = {};   % points decomposed by Douglas-Peucker method at 532 nm
DPInd1064 = {};   % points decomposed by Douglas-Peucker method at 1064 nm

for iGrp = 1:size(clFreGrps, 1)

    tInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
    temperature = data.temperature(iGrp, :);
    pressure = data.pressure(iGrp, :);

    % 532 nm
    if sum(flag532FR) == 1
        sig532 = squeeze(sum(data.signal(flag532FR, :, tInd), 3));   % photon count
        bg532 = squeeze(sum(data.bg(flag532FR, :, tInd), 3));
        nShots532 = nansum(data.mShots(flag532FR, tInd), 2);
        pcr532 = sig532 / nShots532 * (150 / data.hRes);

        % Rayleigh scattering
        [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
        mSig532 = mBsc532 .* exp(-2 * cumsum(mExt532 .* [data.distance0(1), diff(data.distance0)]));

        print_msg(sprintf('\nStart searching reference height for signal at 532 nm, period from %s to %s.\n', ...
            datestr(data.mTime(tInd(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(tInd(end)), 'HH:MM')), 'flagSimpleMsg', true);
        [thisRefH532, thisDPInd532] = pollyRayleighFit(data.distance0, sig532, pcr532, bg532, mSig532, ...
            'minDecomLogDist', PollyConfig.minDecomLogDist532, ...
            'maxDecomHeight', PollyConfig.maxDecomHeight532, ...
            'maxDecomThickness', PollyConfig.maxDecomThickness532, ...
            'decomSmWin', PollyConfig.decomSmoothWin532, ...
            'minRefThickness', PollyConfig.minRefThickness532, ...
            'minRefDeltaExt', PollyConfig.minRefDeltaExt532, ...
            'minRefSNR', PollyConfig.minRefSNR532, ...
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag532FR), ...
            'flagSameRef', false, ...
            'defaultRefH', [NaN, NaN], 'defaultDPInd', []);
    else
        thisRefH532 = [NaN, NaN];
        thisDPInd532 = [];
    end

    % 355 nm
    if sum(flag355FR) == 1
        sig355 = squeeze(sum(data.signal(flag355FR, :, tInd), 3));   % photon count
        bg355 = squeeze(sum(data.bg(flag355FR, :, tInd), 3));
        nShots355 = nansum(data.mShots(flag355FR, tInd), 2);
        pcr355 = sig355 / nShots355 * (150 / data.hRes);

        % Rayleigh scattering
        [mBsc355, mExt355] = rayleigh_scattering(355, pressure, temperature + 273.17, 380, 70);
        mSig355 = mBsc355 .* exp(-2 * cumsum(mExt355 .* [data.distance0(1), diff(data.distance0)]));

        print_msg(sprintf('\nStart searching reference height for 355 nm, period from %s to %s.\n', ...
            datestr(data.mTime(tInd(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(tInd(end)), 'HH:MM')), 'flagSimpleMsg', true);
        [thisRefH355, thisDPInd355] = pollyRayleighFit(data.distance0, sig355, pcr355, bg355, mSig355, ...
            'minDecomLogDist', PollyConfig.minDecomLogDist355, ...
            'maxDecomHeight', PollyConfig.maxDecomHeight355, ...
            'maxDecomThickness', PollyConfig.maxDecomThickness355, ...
            'decomSmWin', PollyConfig.decomSmoothWin355, ...
            'minRefThickness', PollyConfig.minRefThickness355, ...
            'minRefDeltaExt', PollyConfig.minRefDeltaExt355, ...
            'minRefSNR', PollyConfig.minRefSNR355, ...
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag355FR), ...
            'flagSameRef', PollyConfig.flagUseSameRefH, ...
            'defaultRefH', thisRefH532, 'defaultDPInd', thisDPInd532);
    else
        thisRefH355 = [NaN, NaN];
        thisDPInd355 = [];
    end

    % 1064 nm
    if sum(flag1064FR) == 1
        sig1064 = squeeze(sum(data.signal(flag1064FR, :, tInd), 3));   % photon count
        bg1064 = squeeze(sum(data.bg(flag1064FR, :, tInd), 3));
        nShots1064 = nansum(data.mShots(flag1064FR, tInd), 2);
        pcr1064 = sig1064 / nShots1064 * (150 / data.hRes);

        % Rayleigh scattering
        [mBsc1064, mExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.17, 380, 70);
        mSig1064 = mBsc1064 .* exp(-2 * cumsum(mExt1064 .* [data.distance0(1), diff(data.distance0)]));

        print_msg(sprintf('\nStart searching reference height for 1064 nm, period from %s to %s.\n', ...
            datestr(data.mTime(tInd(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(tInd(end)), 'HH:MM')), 'flagSimpleMsg', true);
        [thisRefH1064, thisDPInd1064] = pollyRayleighFit(data.distance0, sig1064, pcr1064, bg1064, mSig1064, ...
            'minDecomLogDist', PollyConfig.minDecomLogDist1064, ...
            'maxDecomHeight', PollyConfig.maxDecomHeight1064, ...
            'maxDecomThickness', PollyConfig.maxDecomThickness1064, ...
            'decomSmWin', PollyConfig.decomSmoothWin1064, ...
            'minRefThickness', PollyConfig.minRefThickness1064, ...
            'minRefDeltaExt', PollyConfig.minRefDeltaExt1064, ...
            'minRefSNR', PollyConfig.minRefSNR1064, ...
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag1064FR), ...
            'flagSameRef', PollyConfig.flagUseSameRefH, ...
            'defaultRefH', thisRefH532, 'defaultDPInd', thisDPInd532);
    else
        thisRefH1064 = [NaN, NaN];
        thisDPInd1064 = [];
    end

    refHInd355 = cat(1, refHInd355, thisRefH355);
    refHInd532 = cat(1, refHInd532, thisRefH532);
    refHInd1064 = cat(1, refHInd1064, thisRefH1064);
    DPInd355 = cat(2, DPInd355, thisDPInd355);
    DPInd532 = cat(2, DPInd532, thisDPInd532);
    DPInd1064 = cat(2, DPInd1064, thisDPInd1064);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Lidar retrievals for aerosol optical properties
print_msg('Start to retrieve aerosol optical properties.\n', 'flagTimestamp', true);

meteorStr = '';
for iMeteor = 1:length(meteorAttri.dataSource)
    meteorStr = cat(2, meteorStr, ' ', meteorAttri.dataSource{iMeteor});
end

print_msg(sprintf('Meteorological file : %s.\n', meteorStr), 'flagSimpleMsg', true);

% Transmission correction at 355 nm
flag355 = data.flag355nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
flag355X = data.flag355nmChannel & data.flagCrossChannel & data.flagFarRangeChannel;

if (sum(flag355) == 1) && (sum(flag355X) == 1) && PollyConfig.flagTransCor
    % transmission correction
    [el355, bgEl355] = transCor(squeeze(data.signal(flag355, :, :)), ...
        squeeze(data.bg(flag355, :, :)), ...
        squeeze(data.signal(flag355X, :, :)), ...
        squeeze(data.bg(flag355X, :, :)), ...
        'transRatioTotal', PollyConfig.TR(flag355), ...
        'transRatioTotalStd', 0, ...
        'transRatioCross', PollyConfig.TR(flag355X), ...
        'transRatioCrossStd', 0, ...
        'polCaliFactor', polCaliFac355, ...
        'polCaliFacStd', polCaliFacStd355);
elseif (sum(flag355) == 1) && (sum(flag355X ~= 1))
    % disable transmission correction
    el355 = squeeze(data.signal(flag355, :, :));
    bgEl355 = squeeze(data.bg(flag355, :, :));
else
    el355 = [];
    bgEl355 = [];
end

% Transmission correction at 532 nm
flag532 = data.flag532nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
flag532X = data.flag532nmChannel & data.flagCrossChannel & data.flagFarRangeChannel;

if (sum(flag532) == 1) && (sum(flag532X) == 1) && PollyConfig.flagTransCor
    % transmission correction
    [el532, bgEl532] = transCor(squeeze(data.signal(flag532, :, :)), ...
        squeeze(data.bg(flag532, :, :)), ...
        squeeze(data.signal(flag532X, :, :)), ...
        squeeze(data.bg(flag532X, :, :)), ...
        'transRatioTotal', PollyConfig.TR(flag532), ...
        'transRatioTotalStd', 0, ...
        'transRatioCross', PollyConfig.TR(flag532X), ...
        'transRatioCrossStd', 0, ...
        'polCaliFactor', polCaliFac532, ...
        'polCaliFacStd', polCaliFacStd532);
elseif (sum(flag532) == 1) && (sum(flag532X ~= 1))
    % disable transmission correction
    el532 = squeeze(data.signal(flag532, :, :));
    bgEl532 = squeeze(data.bg(flag532, :, :));
else
    el532 = [];
    bgEl532 = [];
end

% Klett method at 355 nm
flag355 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag355nmChannel;

aerBsc355_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc355_klett = NaN(length(data.height));
    thisAerExt355_klett = NaN(length(data.height));

    if isnan(refHInd355(iGrp, 1)) || (sum(flag355) ~= 1)
        continue;
    end

    sig355 = transpose(squeeze(sum(el355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg355 = transpose(squeeze(sum(bgEl355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH355 = [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))];
    [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig355 = sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2)));
    refBg355 = sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2)));

    SNRRef355 = pollySNR(refSig355, refBg355);

    [thisAerBsc355_klett, ~] = pollyFernald(data.distance0, sig355, PollyConfig.LR355, refH355, PollyConfig.refBeta355, mBsc355, PollyConfig.smoothWin_klett_355);
    thisAerExt355_klett = PollyConfig.LR355 * thisAerBsc355_klett;

    aerBsc355_klett(iGrp, :) = thisAerBsc355_klett;
    aerExt355_klett(iGrp, :) = thisAerExt355_klett;
end

% Klett method at 532 nm
flag532 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag532nmChannel;

aerBsc532_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc532_klett = NaN(length(data.height));
    thisAerExt532_klett = NaN(length(data.height));

    if isnan(refHInd532(iGrp, 1)) || (sum(flag532) ~= 1)
        continue;
    end

    sig532 = transpose(squeeze(sum(el532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg532 = transpose(squeeze(sum(bgEl532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH532 = [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))];
    [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig532 = sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2)));
    refBg532 = sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2)));

    SNRRef532 = pollySNR(refSig532, refBg532);

    [thisAerBsc532_klett, ~] = pollyFernald(data.distance0, sig532, PollyConfig.LR532, refH532, PollyConfig.refBeta532, mBsc532, PollyConfig.smoothWin_klett_532);
    thisAerExt532_klett = PollyConfig.LR532 * thisAerBsc532_klett;

    aerBsc532_klett(iGrp, :) = thisAerBsc532_klett;
    aerExt532_klett(iGrp, :) = thisAerExt532_klett;
end

% Klett method at 1064 nm
flag1064 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag1064nmChannel;

aerBsc1064_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt1064_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc1064_klett = NaN(length(data.height));
    thisAerExt1064_klett = NaN(length(data.height));

    if isnan(refHInd1064(iGrp, 1)) || (sum(flag1064) ~= 1)
        continue;
    end

    sig1064 = squeeze(sum(data.signal(flag1064, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg1064 = squeeze(sum(data.bg(flag1064, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    refH1064 = [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))];
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig1064 = sum(sig1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2)));
    refBg1064 = sum(bg1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2)));

    SNRRef1064 = pollySNR(refSig1064, refBg1064);

    [thisAerBsc1064_klett, ~] = pollyFernald(data.distance0, sig1064, PollyConfig.LR1064, refH1064, PollyConfig.refBeta1064, mBsc1064, PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_klett = PollyConfig.LR1064 * thisAerBsc1064_klett;

    aerBsc1064_klett(iGrp, :) = thisAerBsc1064_klett;
    aerExt1064_klett(iGrp, :) = thisAerExt1064_klett;
end

% Klett method at 355 nm (near-field)
flag355NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag355nmChannel;

aerBsc355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
refBeta_NR_355_klett = NaN(1, size(clFreGrps, 1));
refH355 = PollyConfig.refH_NR_355;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc355_NR_klett = NaN(length(data.height));
    thisAerExt355_NR_klett = NaN(length(data.height));
    flagRefSNRLow355 = false;
    refBeta355 = NaN;

    % determine the existence of near-field data
    if isnan(refHInd355(iGrp, 1)) || (sum(flag355NR) ~= 1)
        continue;
    end

    % search index for reference height
    if (refH355(1) < data.height(1)) || (refH355(1) > data.height(end)) || ...
       (refH355(2) < data.height(1)) || (refH355(2) > data.height(end))
        print_msg(sprintf('refH_NR_355 (%f - %f m) in the polly config file is out of range.\n', ...
            refH355(1), refH355(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_355 to [2500 - 3000 m]\n');
        refH355 = [2500, 3000];
    end
    refHTopInd355 = find(data.height <= refH355(2), 1, 'last');
    refHBaseInd355 = find(data.height >= refH355(1), 1, 'first');

    sig355 = squeeze(sum(data.signal(flag355NR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg355 = squeeze(sum(data.bg(flag355NR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    % criteria on SNR at reference height
    SNRRef355 = pollySNR(sum(sig355(refHBaseInd355:refHTopInd355)), sum(bg355(refHBaseInd355:refHTopInd355)));
    if SNRRef355 < PollyConfig.minRefSNR_NR_355
        print_msg(sprintf('Signal for 355 nm near-field channel is too noisy at the reference height [%f - %f] m.\n', refH355(1), refH355(2)), 'flagSimpleMsg', true);
        flagRefSNRLow355 = true;
    else
        [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        refBeta355 = mean(aerBsc355_klett(iGrp, refHBaseInd355:refHTopInd355), 2); 

        [thisAerBsc355_NR_klett, ~] = pollyFernald(data.distance0, sig355, PollyConfig.LR_NR_355, refH355, refBeta355, mBsc355, PollyConfig.smoothWin_klett_NR_355);
        thisAerExt355_NR_klett = PollyConfig.LR_NR_355 * thisAerBsc355_NR_klett;
    
        aerBsc355_klett(iGrp, :) = thisAerBsc355_NR_klett;
        aerExt355_klett(iGrp, :) = thisAerExt355_NR_klett;
        refBeta_NR_355_klett(iGrp) = refBeta355;
    end
end

% Klett method at 532 nm (near-field)
flag532NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag532nmChannel;

aerBsc532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
refBeta_NR_532_klett = NaN(1, size(clFreGrps, 1));
refH532 = PollyConfig.refH_NR_532;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc532_NR_klett = NaN(length(data.height));
    thisAerExt532_NR_klett = NaN(length(data.height));
    flagRefSNRLow532 = false;
    refBeta532 = NaN;

    % determine the existence of near-field data
    if isnan(refHInd532(iGrp, 1)) || (sum(flag532NR) ~= 1)
        continue;
    end

    % search index for reference height
    if (refH532(1) < data.height(1)) || (refH532(1) > data.height(end)) || ...
       (refH532(2) < data.height(1)) || (refH532(2) > data.height(end))
        print_msg(sprintf('refH_NR_532 (%f - %f m) in the polly config file is out of range.\n', ...
            refH532(1), refH532(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_532 to [2500 - 3000 m]\n');
        refH532 = [2500, 3000];
    end
    refHTopInd532 = find(data.height <= refH532(2), 1, 'last');
    refHBaseInd532 = find(data.height >= refH532(1), 1, 'first');

    sig532 = squeeze(sum(data.signal(flag532NR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg532 = squeeze(sum(data.bg(flag532NR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    % criteria on SNR at reference height
    SNRRef532 = pollySNR(sum(sig532(refHBaseInd532:refHTopInd532)), sum(bg532(refHBaseInd532:refHTopInd532)));
    if SNRRef532 < PollyConfig.minRefSNR_NR_532
        print_msg(sprintf('Signal for 532 nm near-field channel is too noisy at the reference height [%f - %f] m.\n', refH532(1), refH532(2)), 'flagSimpleMsg', true);
        flagRefSNRLow532 = true;
    else
        [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        refBeta532 = mean(aerBsc532_klett(iGrp, refHBaseInd532:refHTopInd532), 2); 

        [thisAerBsc532_NR_klett, ~] = pollyFernald(data.distance0, sig532, PollyConfig.LR_NR_532, refH532, refBeta532, mBsc532, PollyConfig.smoothWin_klett_NR_532);
        thisAerExt532_NR_klett = PollyConfig.LR_NR_532 * thisAerBsc532_NR_klett;
    
        aerBsc532_klett(iGrp, :) = thisAerBsc532_NR_klett;
        aerExt532_klett(iGrp, :) = thisAerExt532_NR_klett;
        refBeta_NR_532_klett(iGrp) = refBeta532;
    end
end

% Klett method at 355 nm (overlap corrected)
flag355FR = data.flagFarRangeChannel & data.flagTotalChannel & data.flag355nmChannel;

aerBsc355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc355_OC_klett = NaN(length(data.height));
    thisAerExt355_OC_klett = NaN(length(data.height));

    if isnan(refHInd355(iGrp, 1)) || (sum(flag355FR) ~= 1)
        continue;
    end

    sig355 = transpose(squeeze(sum(sigOLCor355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg355 = transpose(squeeze(sum(bgOLCor355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH355 = [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))];
    [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig355 = sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2)));
    refBg355 = sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2)));

    SNRRef355 = pollySNR(refSig355, refBg355);

    [thisAerBsc355_OC_klett, ~] = pollyFernald(data.distance0, sig355, PollyConfig.LR355, refH355, PollyConfig.refBeta355, mBsc355, PollyConfig.smoothWin_klett_355);
    thisAerExt355_OC_klett = PollyConfig.LR355 * thisAerBsc355_OC_klett;

    aerBsc355_OC_klett(iGrp, :) = thisAerBsc355_OC_klett;
    aerExt355_OC_klett(iGrp, :) = thisAerExt355_OC_klett;
end

% Klett method at 532 nm (overlap corrected)
flag532FR = data.flagFarRangeChannel & data.flagTotalChannel & data.flag532nmChannel;

aerBsc532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc532_OC_klett = NaN(length(data.height));
    thisAerExt532_OC_klett = NaN(length(data.height));

    if isnan(refHInd532(iGrp, 1)) || (sum(flag532FR) ~= 1)
        continue;
    end

    sig532 = transpose(squeeze(sum(sigOLCor532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg532 = transpose(squeeze(sum(bgOLCor532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH532 = [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))];
    [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig532 = sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2)));
    refBg532 = sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2)));

    SNRRef532 = pollySNR(refSig532, refBg532);

    [thisAerBsc532_OC_klett, ~] = pollyFernald(data.distance0, sig532, PollyConfig.LR532, refH532, PollyConfig.refBeta532, mBsc532, PollyConfig.smoothWin_klett_532);
    thisAerExt532_OC_klett = PollyConfig.LR532 * thisAerBsc532_OC_klett;

    aerBsc532_OC_klett(iGrp, :) = thisAerBsc532_OC_klett;
    aerExt532_OC_klett(iGrp, :) = thisAerExt532_OC_klett;
end

% Klett method at 1064 nm (overlap corrected)
flag1064FR = data.flagFarRangeChannel & data.flagTotalChannel & data.flag1064nmChannel;

aerBsc1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
aerExt1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc1064_OC_klett = NaN(length(data.height));
    thisAerExt1064_OC_klett = NaN(length(data.height));

    if isnan(refHInd1064(iGrp, 1)) || (sum(flag1064FR) ~= 1)
        continue;
    end

    sig1064 = transpose(squeeze(sum(sigOLCor1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg1064 = transpose(squeeze(sum(bgOLCor1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH1064 = [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))];
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refSig1064 = sum(sig1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2)));
    refBg1064 = sum(bg1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2)));

    SNRRef1064 = pollySNR(refSig1064, refBg1064);

    [thisAerBsc1064_OC_klett, ~] = pollyFernald(data.distance0, sig1064, PollyConfig.LR1064, refH1064, PollyConfig.refBeta1064, mBsc1064, PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_OC_klett = PollyConfig.LR1064 * thisAerBsc1064_OC_klett;

    aerBsc1064_OC_klett(iGrp, :) = thisAerBsc1064_OC_klett;
    aerExt1064_OC_klett(iGrp, :) = thisAerExt1064_OC_klett;
end

% Constrained-AOD Klett method at 355 nm (far-field)
flag355FR = data.flag355nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
aerBsc355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
LR355_aeronet = NaN(size(clFreGrps, 1), 1);
deltaAOD355 = NaN(size(clFreGrps, 1), 1);
for iGrp = size(clFreGrps, 1)
    thisAerBsc355_aeronet = NaN(size(data.height));
    thisAerExt355_aeronet = NaN(size(data.height));
    thisLR_355 = NaN;
    thisDeltaAOD355 = NaN;

    if isnan(refHInd355(iGrp, 1)) || (sum(flag355FR) ~= 1)
        continue;
    end

    sig355 = squeeze(sum(el355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg355 = squeeze(sum(bgEl355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR355 = pollySNR(sig355, bg355);
    refH355 = [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))];
    [mBsc355, ~] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    % SNR at reference height
    SNRRef355 = pollySNR(sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));

    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_355_aeronet = interp_AERONET_AOD(340, AERONET.AOD_340(AERONETInd), 380, AERONET.AOD_380(AERONETInd), 355);

    % constrained Klett method
    [thisAerBsc355_aeronet, thisLR_355, thisDeltaAOD355, ~] = pollyConstrainedKlett(data.distance0, sig355, SNR355, refH355, PollyConfig.refBeta355, mBsc355, PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_355_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag355FR), PollyConfig.mask_SNRmin(flag355FR), PollyConfig.smoothWin_klett_355);
    thisAerExt355_aeronet = thisAerBsc355_aeronet * thisLR_355;

    aerBsc355_aeronet(iGrp, :) = thisAerBsc355_aeronet;
    aerExt355_aeronet(iGrp, :) = thisAerExt355_aeronet;
    LR355_aeronet(iGrp) = thisLR_355;
    deltaAOD355(iGrp) = thisDeltaAOD355;
end

% Constrained-AOD Klett method at 532 nm (far-field)
flag532FR = data.flag532nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
aerBsc532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
LR532_aeronet = NaN(size(clFreGrps, 1), 1);
deltaAOD532 = NaN(size(clFreGrps, 1), 1);
for iGrp = size(clFreGrps, 1)
    thisAerBsc532_aeronet = NaN(size(data.height));
    thisAerExt532_aeronet = NaN(size(data.height));
    thisLR_532 = NaN;
    thisDeltaAOD532 = NaN;

    if isnan(refHInd532(iGrp, 1)) || (sum(flag532FR) ~= 1)
        continue;
    end

    sig532 = squeeze(sum(el532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg532 = squeeze(sum(bgEl532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR532 = pollySNR(sig532, bg532);
    refH532 = [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))];
    [mBsc532, ~] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    % SNR at reference height
    SNRRef532 = pollySNR(sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));

    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_532_aeronet = interp_AERONET_AOD(500, AERONET.AOD_500(AERONETInd), 675, AERONET.AOD_675(AERONETInd), 532);

    % constrained Klett method
    [thisAerBsc532_aeronet, thisLR_532, thisDeltaAOD532, ~] = pollyConstrainedKlett(data.distance0, sig532, SNR532, refH532, PollyConfig.refBeta532, mBsc532, PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_532_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag532FR), PollyConfig.mask_SNRmin(flag532FR), PollyConfig.smoothWin_klett_532);
    thisAerExt532_aeronet = thisAerBsc532_aeronet * thisLR_532;

    aerBsc532_aeronet(iGrp, :) = thisAerBsc532_aeronet;
    aerExt532_aeronet(iGrp, :) = thisAerExt532_aeronet;
    LR532_aeronet(iGrp) = thisLR_532;
    deltaAOD532(iGrp) = thisDeltaAOD532;
end

% Constrained-AOD Klett method at 1064 nm
flag1064FR = data.flag1064nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
aerBsc1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
aerExt1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
LR1064_aeronet = NaN(size(clFreGrps, 1), 1);
deltaAOD1064 = NaN(size(clFreGrps, 1), 1);
for iGrp = size(clFreGrps, 1)
    thisAerBsc1064_aeronet = NaN(size(data.height));
    thisAerExt1064_aeronet = NaN(size(data.height));
    thisLR_1064 = NaN;
    thisDeltaAOD1064 = NaN;

    if isnan(refHInd1064(iGrp, 1)) || (sum(flag1064FR) ~= 1)
        continue;
    end

    sig1064 = squeeze(sum(data.signal(flag1064FR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg1064 = squeeze(sum(data.bg(flag1064FR, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    SNR1064 = pollySNR(sig1064, bg1064);
    refH1064 = [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))];
    [mBsc1064, ~] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    % SNR at reference height
    SNRRef1064 = pollySNR(sum(sig1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))), sum(bg1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))));

    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_1064_aeronet = interp_AERONET_AOD(1020, AERONET.AOD_1020(AERONETInd), 1640, AERONET.AOD_1640(AERONETInd), 1064);

    % constrained Klett method
    [thisAerBsc1064_aeronet, thisLR_1064, thisDeltaAOD1064, ~] = pollyConstrainedKlett(data.distance0, sig1064, SNR1064, refH1064, PollyConfig.refBeta1064, mBsc1064, PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_1064_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag1064FR), PollyConfig.mask_SNRmin(flag1064FR), PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_aeronet = thisAerBsc1064_aeronet * thisLR_1064;

    aerBsc1064_aeronet(iGrp, :) = thisAerBsc1064_aeronet;
    aerExt1064_aeronet(iGrp, :) = thisAerExt1064_aeronet;
    LR1064_aeronet(iGrp) = thisLR_1064;
    deltaAOD1064(iGrp) = thisDeltaAOD1064;
end

% Raman method (355 nm)
aerBsc355_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_raman = NaN(size(clFreGrps, 1), length(data.height));
LR355_raman = NaN(size(clFreGrps, 1), length(data.height));

flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc355_raman = NaN(size(data.height));
    thisAerExt355_raman = NaN(size(data.height));
    thisLR355_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask387Off);
    if (sum(flag355FR) ~= 1) || (sum(flag387FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig355 = transpose(squeeze(sum(el355(:, flagClFre), 2)));
    bg355 = transpose(squeeze(sum(bgEl355(:, flagClFre), 2)));
    sig387 = squeeze(sum(data.signal(flag387FR, :, flagClFre), 3));
    bg387 = squeeze(sum(data.bg(flag387FR, :, flagClFre), 3));

    thisAerExt355_raman = pollyRamanExt(data.distance0, sig387, 355, 387, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_355, 380, 70, 'moving');
    aerExt355_raman(iGrp, :) = thisAerExt355_raman;

    if isnan(refHInd355(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH355 = [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))];
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355FR) + PollyConfig.smoothWin_raman_355/2 * data.hRes, 1);

    if isempty(hBaseInd355)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd355 = 100;
    end

    SNRRef355 = pollySNR(sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));

    if (SNRRef355 < PollyConfig.minRamanRefSNR355) || (SNRRef387 < PollyConfig.minRamanRefSNR387)
        continue;
    end

    thisAerExt355_raman_tmp = thisAerExt355_raman;
    thisAerExt355_raman(1:hBaseInd355) = thisAerExt355_raman(hBaseInd355);
    [thisAerBsc355_raman, ~] = pollyRamanBsc(data.distance0, sig355, sig387, thisAerExt355_raman, PollyConfig.angstrexp, mExt355, mBsc355, refH355, 355, PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355, true);
    thisLR355_raman = thisAerExt355_raman_tmp ./ thisAerBsc355_raman;

    aerBsc355_raman(iGrp, :) = thisAerBsc355_raman;
    LR355_raman(iGrp, :) = thisLR355_raman;

end

% Raman method (532 nm)
aerBsc532_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_raman = NaN(size(clFreGrps, 1), length(data.height));
LR532_raman = NaN(size(clFreGrps, 1), length(data.height));

flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc532_raman = NaN(size(data.height));
    thisAerExt532_raman = NaN(size(data.height));
    thisLR532_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag532FR) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig532 = transpose(squeeze(sum(el532(:, flagClFre), 2)));
    bg532 = transpose(squeeze(sum(bgEl532(:, flagClFre), 2)));
    sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607FR, :, flagClFre), 3));

    thisAerExt532_raman = pollyRamanExt(data.distance0, sig607, 532, 607, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_532, 380, 70, 'moving');
    aerExt532_raman(iGrp, :) = thisAerExt532_raman;

    if isnan(refHInd532(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH532 = [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))];
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532FR) + PollyConfig.smoothWin_raman_532/2 * data.hRes, 1);

    if isempty(hBaseInd532)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd532 = 100;
    end

    SNRRef532 = pollySNR(sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));

    if (SNRRef532 < PollyConfig.minRamanRefSNR532) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt532_raman_tmp = thisAerExt532_raman;
    thisAerExt532_raman(1:hBaseInd532) = thisAerExt532_raman(hBaseInd532);
    [thisAerBsc532_raman, ~] = pollyRamanBsc(data.distance0, sig532, sig607, thisAerExt532_raman, PollyConfig.angstrexp, mExt532, mBsc532, refH532, 532, PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532, true);
    thisLR532_raman = thisAerExt532_raman_tmp ./ thisAerBsc532_raman;

    aerBsc532_raman(iGrp, :) = thisAerBsc532_raman;
    LR532_raman(iGrp, :) = thisLR532_raman;

end

% Raman method (1064 nm)
aerBsc1064_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt1064_raman = NaN(size(clFreGrps, 1), length(data.height));
LR1064_raman = NaN(size(clFreGrps, 1), length(data.height));

flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc1064_raman = NaN(size(data.height));
    thisAerExt1064_raman = NaN(size(data.height));
    thisLR1064_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag1064FR) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig1064 = squeeze(sum(data.signal(flag1064FR, :, flagClFre), 3));
    bg1064 = squeeze(sum(data.bg(flag1064FR, :, flagClFre), 3));
    sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607FR, :, flagClFre), 3));

    thisAerExt532_raman = pollyRamanExt(data.distance0, sig607, 532, 607, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_1064, 380, 70, 'moving');
    thisAerExt1064_raman = thisAerExt532_raman / (1064/532).^PollyConfig.angstrexp;
    aerExt1064_raman(iGrp, :) = thisAerExt1064_raman;

    if isnan(refHInd1064(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH1064 = [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))];
    hBaseInd1064 = find(data.height >= PollyConfig.heightFullOverlap(flag1064FR) + PollyConfig.smoothWin_raman_1064/2 * data.hRes, 1);

    if isempty(hBaseInd1064)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd1064 = 100;
    end

    SNRRef1064 = pollySNR(sum(sig1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))), sum(bg1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))), sum(bg607(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))));

    if (SNRRef1064 < PollyConfig.minRamanRefSNR1064) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt1064_raman_tmp = thisAerExt1064_raman;
    thisAerExt1064_raman(1:hBaseInd1064) = thisAerExt1064_raman(hBaseInd1064);
    [thisAerBsc1064_raman, ~] = pollyRamanBsc(data.distance0, sig1064, sig607, thisAerExt1064_raman, PollyConfig.angstrexp, mExt1064, mBsc1064, [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))], 1064, PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064, true);
    thisLR1064_raman = thisAerExt1064_raman_tmp ./ thisAerBsc1064_raman;

    aerBsc1064_raman(iGrp, :) = thisAerBsc1064_raman;
    LR1064_raman(iGrp, :) = thisLR1064_raman;

end

% Raman method (near-field 355 nm)
aerBsc355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
LR355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
refBeta_NR_355_raman = NaN(1, size(clFreGrps, 1));
refH355 = PollyConfig.refH_NR_355;

flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag355NR) ~= 1) || (sum(flag387NR) ~= 1)
        continue;
    end

    % search index for reference height
    if (refH355(1) < data.height(1)) || (refH355(1) > data.height(end)) || ...
       (refH355(2) < data.height(1)) || (refH355(2) > data.height(end))
        print_msg(sprintf('refH_NR_355 (%f - %f m) in the polly config file is out of range.\n', ...
            refH355(1), refH355(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_355 to [2500 - 3000 m]\n');
        refH355 = [2500, 3000];
    end

    thisAerBsc355_NR_raman = NaN(size(data.height));
    thisAerExt355_NR_raman = NaN(size(data.height));
    thisLR355_NR_raman = NaN(size(data.height));
    refBeta355 = NaN;
    flagRefSNRLow355 = false;

    mask387Off = pollyIs387Off(squeeze(data.signal(flag387NR, :, :)));
    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ mask387Off);
    if sum(flagClFre) == 0
        continue;
    end

    sig355 = squeeze(sum(data.signal(flag355NR, :, flagClFre), 3));
    bg355 = squeeze(sum(data.bg(flag355NR, :, flagClFre), 3));
    sig387 = squeeze(sum(data.signal(flag387FR, :, flagClFre), 3));
    bg387 = squeeze(sum(data.bg(flag387FR, :, flagClFre), 3));

    thisAerExt355_NR_raman = pollyRamanExt(data.distance0, sig387, 355, 387, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_NR_355, 380, 70, 'moving');
    aerExt355_NR_raman(iGrp, :) = thisAerExt355_NR_raman;
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355NR) + PollyConfig.smoothWin_raman_NR_355/2 * data.hRes, 1);
    if isempty(hBaseInd355)
        print_msg('Failure in searching the index of minimum height for near-field channel. Set the index of the minimum integral range to be 40\n', 'flagSimpleMsg', true);
        hBaseInd355 =40;
    end

    if (refH355(1) < data.height(1)) || (refH355(1) > data.height(end)) || ...
       (refH355(2) < data.height(1)) || (refH355(2) > data.height(end))
       print_msg(sprintf('refH_NR_355 (%f - %f) m in the polly config file is out of range.\n', refH355(1), refH355(2)), 'flagSimpleMsg', true);
       print_msg('Set refH_NR_355 to [2500 - 3000] m', 'flagSimpleMsg', true);
       refH355 = [2500, 3000];
    end
    refHTopInd355 = find(data.height <= refH355(2), 1, 'last');
    refHBaseInd355 = find(data.height >= refH355(1), 1, 'first');

    % molecular scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    SNRRef355 = pollySNR(sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));
    refBeta355 = mean(aerBsc355_raman(iGrp, refHBaseInd355:refHTopInd355), 2);

    if (SNRRef355 < PollyConfig.minRefSNR_NR_355) || (SNRRef387 < PollyConfig.minRamanRefSNR387) || isnan(refBeta355)
        continue;
    end

    thisAerExt355_NR_raman_tmp = thisAerExt355_NR_raman;
    thisAerExt355_NR_raman(1:hBaseInd355) = thisAerExt355_NR_raman(hBaseInd355);
    [thisAerBsc355_NR_raman, ~] = pollyRamanBsc(data.distance0, sig355, sig387, thisAerExt355_NR_raman, PollyConfig.angstrexp, mExt355, mBsc355, refH355, 355, refBeta355, PollyConfig.smoothWin_raman_NR_355, true);
    thisLR355_NR_raman = thisAerExt355_NR_raman_tmp ./ thisAerBsc355_NR_raman;

    aerBsc355_NR_raman(iGrp, :) = thisAerBsc355_NR_raman;
    LR355_NR_raman(iGrp, :) = thisLR355_NR_raman;
    refBeta_NR_355_raman(iGrp) = refBeta355;

end

% Raman method (near-field 532 nm)
aerBsc532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
LR532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
refBeta_NR_532_raman = NaN(1, size(clFreGrps, 1));
refH532 = PollyConfig.refH_NR_532;

flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag532NR) ~= 1) || (sum(flag607NR) ~= 1)
        continue;
    end

    % search index for reference height
    if (refH532(1) < data.height(1)) || (refH532(1) > data.height(end)) || ...
       (refH532(2) < data.height(1)) || (refH532(2) > data.height(end))
        print_msg(sprintf('refH_NR_532 (%f - %f m) in the polly config file is out of range.\n', ...
            refH532(1), refH532(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_532 to [2500 - 3000 m]\n');
        refH532 = [2500, 3000];
    end

    thisAerBsc532_NR_raman = NaN(size(data.height));
    thisAerExt532_NR_raman = NaN(size(data.height));
    thisLR532_NR_raman = NaN(size(data.height));
    refBeta532 = NaN;
    flagRefSNRLow532 = false;

    mask607Off = pollyIs607Off(squeeze(data.signal(flag607NR, :, :)));
    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ mask607Off);
    if sum(flagClFre) == 0
        continue;
    end

    sig532 = squeeze(sum(data.signal(flag532NR, :, flagClFre), 3));
    bg532 = squeeze(sum(data.bg(flag532NR, :, flagClFre), 3));
    sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607FR, :, flagClFre), 3));

    thisAerExt532_NR_raman = pollyRamanExt(data.distance0, sig607, 532, 607, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_NR_532, 380, 70, 'moving');
    aerExt532_NR_raman(iGrp, :) = thisAerExt532_NR_raman;

    refH532 = PollyConfig.refH_NR_532;
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532NR) + PollyConfig.smoothWin_raman_NR_532/2 * data.hRes, 1);
    if isempty(hBaseInd532)
        print_msg('Failure in searching the index of minimum height for near-field channel. Set the index of the minimum integral range to be 40\n', 'flagSimpleMsg', true);
        hBaseInd532 =40;
    end

    if (refH532(1) < data.height(1)) || (refH532(1) > data.height(end)) || ...
       (refH532(2) < data.height(1)) || (refH532(2) > data.height(end))
       print_msg(sprintf('refH_NR_532 (%f - %f) m in the polly config file is out of range.\n', refH532(1), refH532(2)), 'flagSimpleMsg', true);
       print_msg('Set refH_NR_532 to [2500 - 3000] m', 'flagSimpleMsg', true);
       refH532 = [2500, 3000];
    end
    refHTopInd532 = find(data.height <= refH532(2), 1, 'last');
    refHBaseInd532 = find(data.height >= refH532(1), 1, 'first');

    % molecular scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    SNRRef532 = pollySNR(sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));
    refBeta532 = mean(aerBsc532_raman(iGrp, refHBaseInd532:refHTopInd532), 2);

    if (SNRRef532 < PollyConfig.minRefSNR_NR_532) || (SNRRef607 < PollyConfig.minRamanRefSNR607) || isnan(refBeta532)
        continue;
    end

    thisAerExt532_NR_raman_tmp = thisAerExt532_NR_raman;
    thisAerExt532_NR_raman(1:hBaseInd532) = thisAerExt532_NR_raman(hBaseInd532);
    [thisAerBsc532_NR_raman, ~] = pollyRamanBsc(data.distance0, sig532, sig607, thisAerExt532_NR_raman, PollyConfig.angstrexp, mExt532, mBsc532, refH532, 532, refBeta532, PollyConfig.smoothWin_raman_NR_532, true);
    thisLR532_NR_raman = thisAerExt532_NR_raman_tmp ./ thisAerBsc532_NR_raman;

    aerBsc532_NR_raman(iGrp, :) = thisAerBsc532_NR_raman;
    LR532_NR_raman(iGrp, :) = thisLR532_NR_raman;
    refBeta_NR_532_raman(iGrp) = refBeta532;

end

% Raman method (overlap corrected at 355 nm)
aerBsc355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
LR355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc355_OC_raman = NaN(size(data.height));
    thisAerExt355_OC_raman = NaN(size(data.height));
    thisLR355_OC_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask387Off);
    if (sum(flag355FR) ~= 1) || (sum(flag387FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig355 = transpose(squeeze(sum(sigOLCor355(:, flagClFre), 2)));
    bg355 = transpose(squeeze(sum(bgOLCor355(:, flagClFre), 2)));
    sig387 = transpose(squeeze(sum(sigOLCor387(:, flagClFre), 2)));
    bg387 = transpose(squeeze(sum(bgOLCor387(:, flagClFre), 2)));

    thisAerExt355_OC_raman = pollyRamanExt(data.distance0, sig387, 355, 387, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_355, 380, 70, 'moving');
    aerExt355_OC_raman(iGrp, :) = thisAerExt355_OC_raman;

    if isnan(refHInd355(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH355 = [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))];
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355FR) + PollyConfig.smoothWin_raman_355/2 * data.hRes, 1);

    if isempty(hBaseInd355)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd355 = 100;
    end

    SNRRef355 = pollySNR(sum(sig355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg355(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))), sum(bg387(refHInd355(iGrp, 1):refHInd355(iGrp, 2))));

    if (SNRRef355 < PollyConfig.minRamanRefSNR355) || (SNRRef387 < PollyConfig.minRamanRefSNR387)
        continue;
    end

    thisAerExt355_raman_tmp = thisAerExt355_OC_raman;
    thisAerExt355_OC_raman(1:hBaseInd355) = thisAerExt355_OC_raman(hBaseInd355);
    [thisAerBsc355_OC_raman, ~] = pollyRamanBsc(data.distance0, sig355, sig387, thisAerExt355_OC_raman, PollyConfig.angstrexp, mExt355, mBsc355, [data.distance0(refHInd355(iGrp, 1)), data.distance0(refHInd355(iGrp, 2))], 355, PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355, true);
    thisLR355_OC_raman = thisAerExt355_raman_tmp ./ thisAerBsc355_OC_raman;

    aerBsc355_OC_raman(iGrp, :) = thisAerBsc355_OC_raman;
    LR355_OC_raman(iGrp, :) = thisLR355_OC_raman;

end

% Raman method (overlap corrected 532 nm)
aerBsc532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
LR532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc532_OC_raman = NaN(size(data.height));
    thisAerExt532_OC_raman = NaN(size(data.height));
    thisLR532_OC_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag532FR) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig532 = transpose(squeeze(sum(sigOLCor532(:, flagClFre), 2)));
    bg532 = transpose(squeeze(sum(bgOLCor532(:, flagClFre), 2)));
    sig607 = transpose(squeeze(sum(sigOLCor607(:, flagClFre), 2)));
    bg607 = transpose(squeeze(sum(bgOLCor607(:, flagClFre), 2)));

    thisAerExt532_OC_raman = pollyRamanExt(data.distance0, sig607, 532, 607, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_532, 380, 70, 'moving');
    aerExt532_OC_raman(iGrp, :) = thisAerExt532_OC_raman;

    if isnan(refHInd532(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH532 = [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))];
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532FR) + PollyConfig.smoothWin_raman_532/2 * data.hRes, 1);

    if isempty(hBaseInd532)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd532 = 100;
    end

    SNRRef532 = pollySNR(sum(sig532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg532(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))), sum(bg607(refHInd532(iGrp, 1):refHInd532(iGrp, 2))));

    if (SNRRef532 < PollyConfig.minRamanRefSNR532) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt532_raman_tmp = thisAerExt532_OC_raman;
    thisAerExt532_OC_raman(1:hBaseInd532) = thisAerExt532_OC_raman(hBaseInd532);
    [thisAerBsc532_OC_raman, ~] = pollyRamanBsc(data.distance0, sig532, sig607, thisAerExt532_OC_raman, PollyConfig.angstrexp, mExt532, mBsc532, [data.distance0(refHInd532(iGrp, 1)), data.distance0(refHInd532(iGrp, 2))], 532, PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532, true);
    thisLR532_OC_raman = thisAerExt532_raman_tmp ./ thisAerBsc532_OC_raman;

    aerBsc532_OC_raman(iGrp, :) = thisAerBsc532_OC_raman;
    LR532_OC_raman(iGrp, :) = thisLR532_OC_raman;

end

% Raman method (overlap corrected 1064 nm)
aerBsc1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
aerExt1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
LR1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    thisAerBsc1064_OC_raman = NaN(size(data.height));
    thisAerExt1064_OC_raman = NaN(size(data.height));
    thisLR1064_OC_raman = NaN(size(data.height));

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag1064FR) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig1064 = transpose(squeeze(sum(sigOLCor1064(:, flagClFre), 2)));
    bg1064 = transpose(squeeze(sum(bgOLCor1064(:, flagClFre), 2)));
    sig607 = transpose(squeeze(sum(sigOLCor607(:, flagClFre), 2)));
    bg607 = transpose(squeeze(sum(bgOLCor607(:, flagClFre), 2)));

    thisAerExt1064_OC_raman = pollyRamanExt(data.distance0, sig607, 1064, 607, PollyConfig.angstrexp, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, PollyConfig.smoothWin_raman_1064, 380, 70, 'moving');
    aerExt1064_OC_raman(iGrp, :) = thisAerExt1064_OC_raman;

    if isnan(refHInd1064(iGrp, 1))
        continue;
    end

    % molecular scattering
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

    refH1064 = [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))];
    hBaseInd1064 = find(data.height >= PollyConfig.heightFullOverlap(flag1064FR) + PollyConfig.smoothWin_raman_1064/2 * data.hRes, 1);

    if isempty(hBaseInd1064)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd1064 = 100;
    end

    SNRRef1064 = pollySNR(sum(sig1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))), sum(bg1064(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))), sum(bg607(refHInd1064(iGrp, 1):refHInd1064(iGrp, 2))));

    if (SNRRef1064 < PollyConfig.minRamanRefSNR1064) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt1064_raman_tmp = thisAerExt1064_OC_raman;
    thisAerExt1064_OC_raman(1:hBaseInd1064) = thisAerExt1064_OC_raman(hBaseInd1064);
    [thisAerBsc1064_OC_raman, ~] = pollyRamanBsc(data.distance0, sig1064, sig607, thisAerExt1064_OC_raman, PollyConfig.angstrexp, mExt1064, mBsc1064, [data.distance0(refHInd1064(iGrp, 1)), data.distance0(refHInd1064(iGrp, 2))], 1064, PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064, true);
    thisLR1064_OC_raman = thisAerExt1064_raman_tmp ./ thisAerBsc1064_OC_raman;

    aerBsc1064_OC_raman(iGrp, :) = thisAerBsc1064_OC_raman;
    LR1064_OC_raman(iGrp, :) = thisLR1064_OC_raman;

end

% Volume depolarization ratio at 355 nm
vdr355_klett = NaN(size(clFreGrps, 1), length(data.height));
vdrStd355_klett = NaN(size(clFreGrps, 1), length(data.height));
vdr355_raman = NaN(size(clFreGrps, 1), length(data.height));
vdrStd355_raman = NaN(size(clFreGrps, 1), length(data.height));

flag355T = data.flag355nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
flag355C = data.flag355nmChannel & data.flagCrossChannel & data.flagFarRangeChannel;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag355T) ~= 1) || (sum(flag355C) ~= 1)
        continue;
    end

    sig355T = squeeze(sum(data.signal(flag355T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg355T = squeeze(sum(data.bg(flag355T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sig355C = squeeze(sum(data.signal(flag355C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg355C = squeeze(sum(data.bg(flag355C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [thisVdr355_klett, thisVdrStd355_klett] = pollyVDR(sig355T, bg355T, sig355C, bg355C, ...
        PollyConfig.TR(flag355T), 0, ...
        PollyConfig.TR(flag355C), 0, ...
        polCaliFac355, polCaliFacStd355, PollyConfig.smoothWin_klett_355);
    [thisVdr355_raman, thisVdrStd355_raman] = pollyVDR(sig355T, bg355T, sig355C, bg355C, ...
        PollyConfig.TR(flag355T), 0, ...
        PollyConfig.TR(flag355C), 0, ...
        polCaliFac355, polCaliFacStd355, PollyConfig.smoothWin_raman_355);

    vdr355_klett(iGrp, :) = thisVdr355_klett;
    vdrStd355_klett(iGrp, :) = thisVdrStd355_klett;
    vdr355_raman(iGrp, :) = thisVdr355_raman;
    vdrStd355_raman(iGrp, :) = thisVdrStd355_raman;
end

% Volume depolarization ratio at 532 nm
vdr532_klett = NaN(size(clFreGrps, 1), length(data.height));
vdrStd532_klett = NaN(size(clFreGrps, 1), length(data.height));
vdr532_raman = NaN(size(clFreGrps, 1), length(data.height));
vdrStd532_raman = NaN(size(clFreGrps, 1), length(data.height));

flag532T = data.flag532nmChannel & data.flagTotalChannel & data.flagFarRangeChannel;
flag532C = data.flag532nmChannel & data.flagCrossChannel & data.flagFarRangeChannel;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag532T) ~= 1) || (sum(flag532C) ~= 1)
        continue;
    end

    sig532T = squeeze(sum(data.signal(flag532T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg532T = squeeze(sum(data.bg(flag532T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sig532C = squeeze(sum(data.signal(flag532C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg532C = squeeze(sum(data.bg(flag532C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [thisVdr532_klett, thisVdrStd532_klett] = pollyVDR(sig532T, bg532T, sig532C, bg532C, ...
        PollyConfig.TR(flag532T), 0, ...
        PollyConfig.TR(flag532C), 0, ...
        polCaliFac532, polCaliFacStd532, PollyConfig.smoothWin_klett_532);
    [thisVdr532_raman, thisVdrStd532_raman] = pollyVDR(sig532T, bg532T, sig532C, bg532C, ...
        PollyConfig.TR(flag532T), 0, ...
        PollyConfig.TR(flag532C), 0, ...
        polCaliFac532, polCaliFacStd532, PollyConfig.smoothWin_raman_532);

    vdr532_klett(iGrp, :) = thisVdr532_klett;
    vdrStd532_klett(iGrp, :) = thisVdrStd532_klett;
    vdr532_raman(iGrp, :) = thisVdr532_raman;
    vdrStd532_raman(iGrp, :) = thisVdrStd532_raman;
end

% Particle depolarization ratio at 355 nm
pdr355_klett = NaN(size(clFreGrps, 1), length(data.height));
pdrStd355_klett = NaN(size(clFreGrps, 1), length(data.height));
pdr355_raman = NaN(size(clFreGrps, 1), length(data.height));
pdrStd355_raman = NaN(size(clFreGrps, 1), length(data.height));
pdr355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
pdr355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
pdrStd355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
pdrStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
mdr355 = NaN(size(clFreGrps, 1), 1);
mdrStd355 = NaN(size(clFreGrps, 1), 1);
flagDeftMdr355 = true(size(clFreGrps, 1), 1);

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag355T) ~= 1) || (sum(flag355C) ~= 1) || isnan(refHInd355(iGrp, 1))
        continue;
    end

    sig355T = squeeze(sum(data.signal(flag355T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg355T = squeeze(sum(data.bg(flag355T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sig355C = squeeze(sum(data.signal(flag355C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg355C = squeeze(sum(data.bg(flag355C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [mBsc355, ~] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [thisMdr355, thisMdrStd355, thisFlagDeftMdr355] = pollyMDR(...
        sig355T(refHInd355(iGrp, 1):refHInd355(iGrp, 2)), ...
        bg355T(refHInd355(iGrp, 1):refHInd355(iGrp, 2)), ...
        sig355C(refHInd355(iGrp, 1):refHInd355(iGrp, 2)), ...
        bg355C(refHInd355(iGrp, 1):refHInd355(iGrp, 2)), ...
        PollyConfig.TR(flag355T), 0, ...
        PollyConfig.TR(flag355C), 0, ...
        polCaliFac355, polCaliFacStd355, 10, ...
        PollyDefaults.molDepol355, PollyDefaults.molDepolStd355);
    mdr355(iGrp) = thisMdr355;
    mdrStd355(iGrp) = thisMdrStd355;
    flagDeftMdr355(iGrp) = thisFlagDeftMdr355;

    if ~ isnan(aerBsc355_klett(iGrp, 80))
        [thisPdr355_klett, thisPdrStd355_klett] = pollyPDR(vdr355_klett(iGrp, :), vdrStd355_klett(iGrp, :), aerBsc355_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355, thisMdr355, thisMdrStd355);
        pdr355_klett(iGrp, :) = thisPdr355_klett;
        pdrStd355_klett(iGrp, :) = thisPdrStd355_klett;
    end

    if ~ isnan(aerBsc355_raman(iGrp, 80))
        [thisPdr355_raman, thisPdrStd355_raman] = pollyPDR(vdr355_raman(iGrp, :), vdrStd355_raman(iGrp, :), aerBsc355_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355, thisMdr355, thisMdrStd355);
        pdr355_raman(iGrp, :) = thisPdr355_raman;
        pdrStd355_raman(iGrp, :) = thisPdrStd355_raman;
    end

    if ~ isnan(aerBsc355_OC_klett(iGrp, 80))
        [thisPdr355_OC_klett, thisPdrStd355_OC_klett] = pollyPDR(vdr355_klett(iGrp, :), vdrStd355_klett(iGrp, :), aerBsc355_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355, thisMdr355, thisMdrStd355);
        pdr355_OC_klett(iGrp, :) = thisPdr355_OC_klett;
        pdrStd355_OC_klett(iGrp, :) = thisPdrStd355_OC_klett;
    end

    if ~ isnan(aerBsc355_OC_raman(iGrp, 80))
        [thisPdr355_OC_raman, thisPdrStd355_OC_raman] = pollyPDR(vdr355_raman(iGrp, :), vdrStd355_raman(iGrp, :), aerBsc355_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355, thisMdr355, thisMdrStd355);
        pdr355_OC_raman(iGrp, :) = thisPdr355_OC_raman;
        pdrStd355_OC_raman(iGrp, :) = thisPdrStd355_OC_raman;
    end
end

% Particle depolarization ratio at 532 nm
pdr532_klett = NaN(size(clFreGrps, 1), length(data.height));
pdrStd532_klett = NaN(size(clFreGrps, 1), length(data.height));
pdr532_raman = NaN(size(clFreGrps, 1), length(data.height));
pdrStd532_raman = NaN(size(clFreGrps, 1), length(data.height));
pdr532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
pdr532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
pdrStd532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
pdrStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
mdr532 = NaN(size(clFreGrps, 1), 1);
mdrStd532 = NaN(size(clFreGrps, 1), 1);
flagDeftMdr532 = true(size(clFreGrps, 1), 1);

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag532T) ~= 1) || (sum(flag532C) ~= 1) || isnan(refHInd532(iGrp, 1))
        continue;
    end

    sig532T = squeeze(sum(data.signal(flag532T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg532T = squeeze(sum(data.bg(flag532T, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sig532C = squeeze(sum(data.signal(flag532C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bg532C = squeeze(sum(data.bg(flag532C, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [mBsc532, ~] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [thisMdr532, thisMdrStd532, thisFlagDeftMdr532] = pollyMDR(...
        sig532T(refHInd532(iGrp, 1):refHInd532(iGrp, 2)), ...
        bg532T(refHInd532(iGrp, 1):refHInd532(iGrp, 2)), ...
        sig532C(refHInd532(iGrp, 1):refHInd532(iGrp, 2)), ...
        bg532C(refHInd532(iGrp, 1):refHInd532(iGrp, 2)), ...
        PollyConfig.TR(flag532T), 0, ...
        PollyConfig.TR(flag532C), 0, ...
        polCaliFac532, polCaliFacStd532, 10, ...
        PollyDefaults.molDepol532, PollyDefaults.molDepolStd532);
    mdr532(iGrp) = thisMdr532;
    mdrStd532(iGrp) = thisMdrStd532;
    flagDeftMdr532(iGrp) = thisFlagDeftMdr532;

    if ~ isnan(aerBsc532_klett(iGrp, 80))
        [thisPdr532_klett, thisPdrStd532_klett] = pollyPDR(vdr532_klett(iGrp, :), vdrStd532_klett(iGrp, :), aerBsc532_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532, thisMdr532, thisMdrStd532);
        pdr532_klett(iGrp, :) = thisPdr532_klett;
        pdrStd532_klett(iGrp, :) = thisPdrStd532_klett;
    end

    if ~ isnan(aerBsc532_raman(iGrp, 80))
        [thisPdr532_raman, thisPdrStd532_raman] = pollyPDR(vdr532_raman(iGrp, :), vdrStd532_raman(iGrp, :), aerBsc532_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532, thisMdr532, thisMdrStd532);
        pdr532_raman(iGrp, :) = thisPdr532_raman;
        pdrStd532_raman(iGrp, :) = thisPdrStd532_raman;
    end

    if ~ isnan(aerBsc532_OC_klett(iGrp, 80))
        [thisPdr532_OC_klett, thisPdrStd532_OC_klett] = pollyPDR(vdr532_klett(iGrp, :), vdrStd532_klett(iGrp, :), aerBsc532_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532, thisMdr532, thisMdrStd532);
        pdr532_OC_klett(iGrp, :) = thisPdr532_OC_klett;
        pdrStd532_OC_klett(iGrp, :) = thisPdrStd532_OC_klett;
    end

    if ~ isnan(aerBsc532_OC_raman(iGrp, 80))
        [thisPdr532_OC_raman, thisPdrStd532_OC_raman] = pollyPDR(vdr532_raman(iGrp, :), vdrStd532_raman(iGrp, :), aerBsc532_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532, thisMdr532, thisMdrStd532);
        pdr532_OC_raman(iGrp, :) = thisPdr532_OC_raman;
        pdrStd532_OC_raman(iGrp, :) = thisPdrStd532_OC_raman;
    end
end

% (Near-field) Ångström exponent (Klett/Fernald/Raman method retrieved parameters)
AE_Bsc_355_532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
AE_Ext_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Ångström exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(aerExt355_NR_klett(iGrp, 60))) && (~ isnan(aerExt355_NR_klett(iGrp, 60)))
        thisAE_Bsc_355_532_NR_klett = pollyAE(aerBsc355_NR_klett(iGrp, :), zeros(size(data.height)), aerBsc532_NR_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_NR_532);
        AE_Bsc_355_532_NR_klett(iGrp, :) = thisAE_Bsc_355_532_NR_klett;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerExt355_NR_raman(iGrp, 80))) && (~ isnan(aerExt532_NR_raman(iGrp, 80)))
        thisAE_Ext_355_532_NR_raman = pollyAE(aerExt355_NR_raman(iGrp, :), zeros(size(data.height)), aerExt532_NR_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_NR_532);
        AE_Ext_355_532_NR_raman(iGrp, :) = thisAE_Ext_355_532_NR_raman;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerBsc355_NR_raman(iGrp, 80))) && (~ isnan(aerBsc532_NR_raman(iGrp, 80)))
        thisAE_Bsc_355_532_NR_raman = pollyAE(aerBsc355_NR_raman(iGrp, :), zeros(size(data.height)), aerBsc532_NR_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_NR_raman_532);
        AE_Bsc_355_532_NR_raman(iGrp, :) = thisAE_Bsc_355_532_NR_raman;
    end
end

% (Overlap corrected) Ångström exponent (Klett/Fernald/Raman method retrieved parameters)
AE_Bsc_355_532_klett = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_532_1064_klett = NaN(size(clFreGrps, 1), length(data.height));
AE_Ext_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_532_1064_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Ångström exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(refHInd355(iGrp, 1))) && (~ isnan(refHInd532(iGrp, 1)))
        thisAE_Bsc_355_532_klett = pollyAE(aerBsc355_klett(iGrp, :), zeros(size(data.height)), aerBsc532_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_532);
        AE_Bsc_355_532_klett(iGrp, :) = thisAE_Bsc_355_532_klett;
    end

    % Ångström exponent 532-1064 (based on parameters by Klett method)
    if (~ isnan(refHInd532(iGrp, 1))) && (~ isnan(refHInd1064(iGrp, 1)))
        thisAE_Bsc_532_1064_klett = pollyAE(aerBsc532_klett(iGrp, :), zeros(size(data.height)), aerBsc1064_klett(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_klett_1064);
        AE_Bsc_532_1064_klett(iGrp, :) = thisAE_Bsc_532_1064_klett;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerExt355_raman(iGrp, 80))) && (~ isnan(aerExt532_raman(iGrp, 80)))
        thisAE_Ext_355_532_raman = pollyAE(aerExt355_raman(iGrp, :), zeros(size(data.height)), aerExt532_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        AE_Ext_355_532_raman(iGrp, :) = thisAE_Ext_355_532_raman;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerBsc355_raman(iGrp, 80))) && (~ isnan(aerBsc532_raman(iGrp, 80)))
        thisAE_Bsc_355_532_raman = pollyAE(aerBsc355_raman(iGrp, :), zeros(size(data.height)), aerBsc532_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        AE_Bsc_355_532_raman(iGrp, :) = thisAE_Bsc_355_532_raman;
    end

    % Ångström exponent 532-1064 (based on parameters by Raman method)
    if (~ isnan(aerBsc532_raman(iGrp, 80))) && (~ isnan(aerBsc1064_raman(iGrp, 80)))
        thisAE_Bsc_532_1064_raman = pollyAE(aerBsc532_raman(iGrp, :), zeros(size(data.height)), aerBsc1064_raman(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_raman_1064);
        AE_Bsc_532_1064_raman(iGrp, :) = thisAE_Bsc_532_1064_raman;
    end
end

% Ångström exponent (Klett/Fernald/Raman method retrieved parameters)
AE_Bsc_355_532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_532_1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
AE_Ext_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
AE_Bsc_532_1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Ångström exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(refHInd355(iGrp, 1))) && (~ isnan(refHInd532(iGrp, 1)))
        thisAE_Bsc_355_532_OC_klett = pollyAE(aerBsc355_OC_klett(iGrp, :), zeros(size(data.height)), aerBsc532_OC_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_532);
        AE_Bsc_355_532_OC_klett(iGrp, :) = thisAE_Bsc_355_532_OC_klett;
    end

    % Ångström exponent 532-1064 (based on parameters by Klett method)
    if (~ isnan(refHInd532(iGrp, 1))) && (~ isnan(refHInd1064(iGrp, 1)))
        thisAE_Bsc_532_1064_OC_klett = pollyAE(aerBsc532_OC_klett(iGrp, :), zeros(size(data.height)), aerBsc1064_OC_klett(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_klett_1064);
        AE_Bsc_532_1064_OC_klett(iGrp, :) = thisAE_Bsc_532_1064_OC_klett;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerExt355_OC_raman(iGrp, 80))) && (~ isnan(aerExt532_OC_raman(iGrp, 80)))
        thisAE_Ext_355_532_OC_raman = pollyAE(aerExt355_OC_raman(iGrp, :), zeros(size(data.height)), aerExt532_OC_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        AE_Ext_355_532_OC_raman(iGrp, :) = thisAE_Ext_355_532_OC_raman;
    end

    % Ångström exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(aerBsc355_OC_raman(iGrp, 80))) && (~ isnan(aerBsc532_OC_raman(iGrp, 80)))
        thisAE_Bsc_355_532_OC_raman = pollyAE(aerBsc355_OC_raman(iGrp, :), zeros(size(data.height)), aerBsc532_OC_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        AE_Bsc_355_532_OC_raman(iGrp, :) = thisAE_Bsc_355_532_OC_raman;
    end

    % Ångström exponent 532-1064 (based on parameters by Raman method)
    if (~ isnan(aerBsc532_OC_raman(iGrp, 80))) && (~ isnan(aerBsc1064_OC_raman(iGrp, 80)))
        thisAE_Bsc_532_1064_OC_raman = pollyAE(aerBsc532_OC_raman(iGrp, :), zeros(size(data.height)), aerBsc1064_OC_raman(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_raman_1064);
        AE_Bsc_532_1064_OC_raman(iGrp, :) = thisAE_Bsc_532_1064_OC_raman;
    end
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Signal status
SNR = NaN(size(data.signal));
for iCh = 1:size(data.signal, 1)
    signal_sm = smooth2(squeeze(data.signal(iCh, :, :)), PollyConfig.quasi_smooth_h(iCh), PollyConfig.quasi_smooth_t(iCh));
    signal_int = signal_sm * (PollyConfig.quasi_smooth_h(iCh) * PollyConfig.quasi_smooth_t(iCh));
    bg_sm = smooth2(squeeze(data.bg(iCh, :, :)), PollyConfig.quasi_smooth_h(iCh), PollyConfig.quasi_smooth_t(iCh));
    bg_int = bg_sm * (PollyConfig.quasi_smooth_h(iCh) * PollyConfig.quasi_smooth_t(iCh));
    SNR(iCh, :, :) = pollySNR(signal_int, bg_int);
end

flag532T = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag355T = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355C = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
quality_mask_355 = zeros(length(data.height), length(data.mTime));
quality_mask_532 = zeros(length(data.height), length(data.mTime));
quality_mask_1064 = zeros(length(data.height), length(data.mTime));
quality_mask_vdr_532 = zeros(length(data.height), length(data.mTime));
quality_mask_vdr_355 = zeros(length(data.height), length(data.mTime));
quality_mask_387 = zeros(length(data.height), length(data.mTime));
quality_mask_607 = zeros(length(data.height), length(data.mTime));
% 0 in quality_mask means good data
% 1 in quality_mask means low-SNR data
% 2 in quality_mask means depolarization calibration periods
% 3 in quality_mask means shutter on
% 4 in quality_mask means fog
if (sum(flag355T) == 1)
    quality_mask_355(squeeze(SNR(flag355T, :, :)) < PollyConfig.mask_SNRmin(flag355T)) = 1;
    quality_mask_355(:, data.depCalMask) = 2;
    quality_mask_355(:, data.shutterOnMask) = 3;
    quality_mask_355(:, data.fogMask) = 4;
end
if (sum(flag532T) == 1)
    quality_mask_532(squeeze(SNR(flag532T, :, :)) < PollyConfig.mask_SNRmin(flag532T)) = 1;
    quality_mask_532(:, data.depCalMask) = 2;
    quality_mask_532(:, data.shutterOnMask) = 3;
    quality_mask_532(:, data.fogMask) = 4;
end
if (sum(flag1064) == 1)
    quality_mask_1064(squeeze(SNR(flag1064, :, :)) < PollyConfig.mask_SNRmin(flag1064)) = 1;
    quality_mask_1064(:, data.depCalMask) = 2;
    quality_mask_1064(:, data.shutterOnMask) = 3;
    quality_mask_1064(:, data.fogMask) = 4;
end
if (sum(flag387) == 1)
    quality_mask_387(squeeze(SNR(flag387, :, :)) < PollyConfig.mask_SNRmin(flag387)) = 1;
    quality_mask_387(:, data.depCalMask) = 2;
    quality_mask_387(:, data.shutterOnMask) = 3;
    quality_mask_387(:, data.fogMask) = 4;
end
if (sum(flag607) == 1)
    quality_mask_607(squeeze(SNR(flag607, :, :)) < PollyConfig.mask_SNRmin(flag607)) = 1;
    quality_mask_607(:, data.depCalMask) = 2;
    quality_mask_607(:, data.shutterOnMask) = 3;
    quality_mask_607(:, data.fogMask) = 4;
end
if (sum(flag355T) == 1) && (sum(flag355C) == 1)
    quality_mask_vdr_355((squeeze(SNR(flag355C, :, :)) < PollyConfig.mask_SNRmin(flag355C)) | (squeeze(SNR(flag355T, :, :)) < PollyConfig.mask_SNRmin(flag355T))) = 1;
    quality_mask_vdr_355(:, data.depCalMask) = 2;
    quality_mask_vdr_355(:, data.shutterOnMask) = 3;
    quality_mask_vdr_355(:, data.fogMask) = 4;
end
if (sum(flag532T) == 1) && (sum(flag532C) == 1)
    quality_mask_vdr_532((squeeze(SNR(flag532C, :, :)) < PollyConfig.mask_SNRmin(flag532C)) | (squeeze(SNR(flag532T, :, :)) < PollyConfig.mask_SNRmin(flag532T))) = 1;
    quality_mask_vdr_532(:, data.depCalMask) = 2;
    quality_mask_vdr_532(:, data.shutterOnMask) = 3;
    quality_mask_vdr_532(:, data.fogMask) = 4;
end

%% Water vapor calibration
print_msg('Start water vapor calibration\n', 'flagTimestamp', true);

% external IWV
[IWV, IWVAttri] = readIWV(PollyConfig.IWV_instrument, data.mTime(clFreGrps), ...
    'AERONETSite', PollyConfig.AERONETSite, ...
    'AERONETIWV', AERONET.IWV, ...
    'AERONETTime', AERONET.datetime, ...
    'MWRFolder', PollyConfig.MWRFolder, ...
    'MWRSite', CampaignConfig.location, ...
    'maxIWVTLag', PollyConfig.maxIWVTLag, ...
    'PI', AERONET.AERONETAttri.PI, ...
    'contact', AERONET.AERONETAttri.contact);

% sunrise/sunset
sun_rise_set = suncycle(CampaignConfig.lat, CampaignConfig.lon, floor(data.mTime(1)), 2880);
sunriseTime = sun_rise_set(1)/24 + floor(data.mTime(1));
sunsetTime = rem(sun_rise_set(2)/24, 1) + floor(data.mTime(1));

% water vapor calibration
wvconst = NaN(size(clFreGrps, 1), 1);
wvconstStd = NaN(size(clFreGrps, 1), 1);
wvCaliInfo = struct();
wvCaliInfo.cali_start_time = NaN(size(clFreGrps, 1), 1);
wvCaliInfo.cali_stop_time = NaN(size(clFreGrps, 1), 1);
wvCaliInfo.WVCaliInfo = cell(1, size(clFreGrps, 1));
wvCaliInfo.IntRange = NaN(size(clFreGrps, 1), 2);

flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag407 = data.flagFarRangeChannel & data.flag407nmChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel;

for iGrp = 1:size(clFreGrps, 1)

    thisWVconst = NaN;
    thisWVconstStd = NaN;
    thisCaliStartTime = data.mTime(clFreGrps(iGrp, 1));
    thisCaliStopTime = data.mTime(clFreGrps(iGrp, 2));
    thisWVCaliInfo = '407 off';
    thisIntRange = [NaN, NaN];

    if (sum(flag387) ~= 1) || (sum(flag407) ~= 1) || (sum(flag1064) ~= 1) || isnan(IWV(iGrp))
        wvCaliInfo.cali_start_time(iGrp) = thisCaliStartTime;
        wvCaliInfo.cali_stop_time(iGrp) = thisCaliStopTime;
        wvCaliInfo.WVCaliInfo{iGrp} = thisWVCaliInfo;
        continue;
    end

    flag407On = (~ pollyIs407Off(squeeze(data.signal(flag407, :, :))));
    flagWVCali = false(size(flag407On));
    wvCaliInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
    flagWVCali(wvCaliInd) = true;
    flagLowSolarBG = (data.mTime <= (sunriseTime - PollyConfig.tTwilight)) | (data.mTime >= (sunsetTime + PollyConfig.tTwilight));

    sig387 = squeeze(sum(data.signal(flag387, :, flag407On & flagWVCali & flagLowSolarBG), 3));
    bg387 = squeeze(sum(data.bg(flag387, :, flag407On & flagWVCali & flagLowSolarBG), 3));
    sig407 = squeeze(sum(data.signal(flag407, :, flag407On & flagWVCali & flagLowSolarBG), 3));
    [~, closestIndx] = min(abs(data.mTime - IWVAttri.datetime(iGrp)));
    print_msg(sprintf('IWV measurement time: %s\nClosest lidar measurement time: %s\n', ...
        datestr(IWVAttri.datetime(iGrp), 'HH:MM'), ...
        datestr(data.mTime(closestIndx), 'HH:MM')), 'flagSimpleMsg', true);
    E_tot_1064_IWV = sum(squeeze(data.signal(flag1064, :, closestIndx)));
    E_tot_1064_cali = sum(squeeze(mean(data.signal(flag1064, :, flag407On & flagWVCali), 3)));
    E_tot_1064_cali_std = std(squeeze(sum(data.signal(flag1064, :, flag407On & flagWVCali), 2)));

    [~, mExt387] = rayleigh_scattering(387, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [~, mExt407] = rayleigh_scattering(407, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    trans387 = exp(-cumsum(mExt387 .* [data.distance0(1), diff(data.distance0)]));
    trans407 = exp(-cumsum(mExt407 .* [data.distance0(1), diff(data.distance0)]));
    rhoAir = rho_air(data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17);

    [thisWVconst, thisWVconstStd, thisWVAttri] = pollyWVCali(data.height, ...
        sig387, bg387, sig407, E_tot_1064_IWV, E_tot_1064_cali, E_tot_1064_cali_std, ...
        thisCaliStartTime, thisCaliStopTime, IWV(iGrp), flagWVCali, flag407On, ...
        trans387, trans407, rhoAir, sunriseTime, sunsetTime, ...
        'hWVCaliBase', PollyConfig.hWVCaliBase, ...
        'hWVCaliTop', PollyConfig.hWVCaliTop, ...
        'hFullOL387', PollyConfig.heightFullOverlap(flag387), ...
        'minSNRWVCali', PollyConfig.minSNRWVCali);

    wvconst(iGrp) = thisWVconst;
    wvconstStd(iGrp) = thisWVconstStd;
    wvCaliInfo.WVCaliInfo{iGrp} = thisWVAttri.WVCaliInfo;
    wvCaliInfo.IntRange(iGrp, :) = thisWVAttri.IntRange;
    wvCaliInfo.cali_start_time(iGrp) = thisWVAttri.cali_start_time;
    wvCaliInfo.cali_stop_time(iGrp) = thisWVAttri.cali_stop_time;
end

% select water vapor calibration constant
[wvconstUsed, wvconstUsedStd, data.wvconstUsedInfo] = selectWVConst(...
    wvconst, wvconstStd, IWVAttri, ...
    pollyParseFiletime(basename(PollyDataInfo.pollyDataFile), PollyConfig.dataFileFormat), ...
    dbFile, CampaignConfig.name, ...
    'flagUsePrevWVConst', PollyConfig.flagUsePreviousWVconst, ...
    'flagWVCalibration', PollyConfig.flagWVCalibration, ...
    'deltaTime', datenum(0, 1, 7), ...
    'default_wvconst', PollyDefaults.wvconst, ...
    'default_wvconstStd', PollyDefaults.wvconstStd);

% obtain averaged water vapor profiles
wvmr = NaN(size(clFreGrps, 1), length(data.height));
rh = NaN(size(clFreGrps, 1), length(data.height));
wvPrfInfo = struct();
wvPrfInfo.n407Prfs = NaN(size(clFreGrps, 1), 1);
wvPrfInfo.IWV = NaN(size(clFreGrps, 1), 1);
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag407 = data.flagFarRangeChannel & data.flag407nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    flagClFre = false(size(data.mTime));
    clFreInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
    flagClFre(clFreInd) = true;
    flag407On = flagClFre & (~ data.mask407Off);
    n407OnPrf = sum(flag407On);

    if (n407OnPrf <= 10) || (sum(flag387) ~= 1) || (sum(flag407) ~= 1)
        continue;
    end

    sig387 = sum(data.signal(flag387, :, flag407On), 3);
    bg387 = sum(data.bg(flag387, :, flag407On), 3);
    snr387 = pollySNR(sig387, bg387);

    sig407 = sum(data.signal(flag407, :, flag407On), 3);
    bg407 = sum(data.bg(flag407, :, flag407On), 3);
    snr407 = pollySNR(sig407, bg407);
        
    % calculate molecule optical properties
    [~, mExt387] = rayleigh_scattering(387, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [~, mExt407] = rayleigh_scattering(407, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    trans387 = exp(- cumsum(mExt387 .* [data.distance0(1), diff(data.distance0)]));
    trans407 = exp(- cumsum(mExt407 .* [data.distance0(1), diff(data.distance0)]));

    % calculate saturated water vapor pressure
    es = saturated_vapor_pres(data.temperature(iGrp, :));
    rhoAir = rho_air(data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17);

    % calculate wvmr and rh
    wvmr(iGrp, :) = sig407 ./ sig387 .* trans387 ./ trans407 .* wvconstUsed;
    rh(iGrp, :) = wvmr_2_rh(wvmr(iGrp, :), es, data.pressure(iGrp, :));

    % integral water vapor
    if isnan(wvCaliInfo.IntRange(iGrp, 1))
        continue;
    end

    IWVIntRange= wvCaliInfo.IntRange(iGrp, 1):wvCaliInfo.IntRange(iGrp, 2);
    wvPrfInfo.n407Prfs(iGrp) = n407OnPrf;
    wvPrfInfo.IWV(iGrp) = sum(wvmr(iGrp, IWVIntRange) .* rhoAir(IWVIntRange) ./ 1e6 .* [data.height(IWVIntRange(1)), diff(data.height(IWVIntRange))]);

end

%% retrieve high resolution WVMR and RH
WVMR = NaN(size(data.signal, 2), size(data.signal, 3));
RH = NaN(size(data.signal, 2), size(data.signal, 3));
quality_mask_WVMR = 3 * ones(size(data.signal, 2), size(data.signal, 3));
quality_mask_RH = 3 * ones(size(data.signal, 2), size(data.signal, 3));

flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag407 = data.flagFarRangeChannel & data.flag407nmChannel;

if (sum(flag387) == 1) && (sum(flag407 == 1))

    sig387 = squeeze(data.signal(flag387, :, :));
    sig387(:, data.depCalMask) = NaN;
    sig407 = squeeze(data.signal(flag407, :, :));
    sig407(:, data.depCalMask) = NaN;

    % quality mask to filter low SNR bits
    quality_mask_WVMR = zeros(size(data.signal, 2), size(data.signal, 3));
    quality_mask_WVMR((squeeze(SNR(flag387, :, :)) < PollyConfig.mask_SNRmin(flag387)) | (squeeze(SNR(flag407, :, :)) < PollyConfig.mask_SNRmin(flag407))) = 1;
    quality_mask_WVMR(:, data.depCalMask) = 2;
    quality_mask_RH = quality_mask_WVMR;

    % mask the signal
    quality_mask_WVMR(:, data.mask407Off) = 3;
    sig407_QC = sig407;
    sig407_QC(:, data.depCalMask) = NaN;
    sig407_QC(:, data.mask407Off) = NaN;
    sig387_QC = sig387;
    sig387_QC(:, data.depCalMask) = NaN;
    sig387_QC(:, data.mask407Off) = NaN;

    % smooth the signal
    sig387_QC = smooth2(sig387_QC, PollyConfig.quasi_smooth_h(flag387), PollyConfig.quasi_smooth_t(flag387));
    sig407_QC = smooth2(sig407_QC, PollyConfig.quasi_smooth_h(flag407), PollyConfig.quasi_smooth_t(flag407));

    % read the meteorological data
    [temp, pres, relh, ~] = loadMeteor(...
                            mean(data.mTime), data.alt, ...
                            'meteorDataSource', PollyConfig.meteorDataSource, ...
                            'gdas1Site', PollyConfig.gdas1Site, ...
                            'gdas1_folder', PicassoConfig.gdas1_folder, ...
                            'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
                            'radiosondeFolder', PollyConfig.radiosondeFolder, ...
                            'radiosondeType', PollyConfig.radiosondeType);

    % repmat the array to matrix as the size of data.signal
    temperature = repmat(transpose(temp), 1, length(data.mTime));
    pressure = repmat(transpose(pres), 1, length(data.mTime));

    % calculate the molecule optical properties
    [~, mExt387] = rayleigh_scattering(387, transpose(pressure(:, 1)), transpose(temperature(:, 1)) + 273.17, 380, 70);
    [~, mExt407] = rayleigh_scattering(407, transpose(pressure(:, 1)), transpose(temperature(:, 1)) + 273.17, 380, 70);
    trans387 = exp(- cumsum(mExt387 .* [data.distance0(1), diff(data.distance0)]));
    trans407 = exp(- cumsum(mExt407 .* [data.distance0(1), diff(data.distance0)]));
    TRANS387 = repmat(transpose(trans387), 1, length(data.mTime));
    TRANS407 = repmat(transpose(trans407), 1, length(data.mTime));

    % calculate the saturation water vapor pressure
    es = saturated_vapor_pres(temperature(:, 1));
    ES = repmat(es, 1, length(data.mTime));

    rhoAir = rho_air(pressure(:, 1), temperature(:, 1) + 273.17);
    RHOAIR = repmat(rhoAir, 1, length(data.mTime));
    DIFFHeight = repmat(transpose([data.height(1), diff(data.height)]), 1, length(data.mTime));

    % calculate wvmr and rh
    WVMR = sig407_QC ./ sig387_QC .* TRANS387 ./ TRANS407 .* wvconstUsed;
    RH = wvmr_2_rh(WVMR, ES, pressure);
    IWV = sum(WVMR .* RHOAIR .* DIFFHeight .* (quality_mask_WVMR == 0), 1) ./ 1e6;   % kg*m^{-2}
end

print_msg('Start\n', 'flagTimestamp', true);

%% Lidar calibration
print_msg('Start lidar calibration\n', 'flagTimestamp', true);

LC = struct();
LC.LC_klett_355 = NaN(size(clFreGrps, 1), 1);
LC.LC_klett_355 = NaN(size(clFreGrps, 1), 1);
LC.LC_klett_532 = NaN(size(clFreGrps, 1), 1);
LC.LC_klett_1064 = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_355 = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_532 = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_1064 = NaN(size(clFreGrps, 1), 1);
LC.LC_aeronet_355 = NaN(size(clFreGrps, 1), 1);
LC.LC_aeronet_532 = NaN(size(clFreGrps, 1), 1);
LC.LC_aeronet_1064 = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_607 = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_387 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_klett_355 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_klett_532 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_klett_1064 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_355 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_532 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_1064 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_aeronet_355 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_aeronet_532 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_aeronet_1064 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_607 = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_387 = NaN(size(clFreGrps, 1), 1);
LC.LC_start_time = NaN(size(clFreGrps, 1), 1);
LC.LC_stop_time = NaN(size(clFreGrps, 1), 1);

flag355 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag355nmChannel;
flag532 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag532nmChannel;
flag1064 = data.flagFarRangeChannel & data.flagTotalChannel & data.flag1064nmChannel;
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;

for iGrp = 1:size(clFreGrps, 1)
    LC.LC_start_time(iGrp) = data.mTime(clFreGrps(iGrp, 1));
    LC.LC_stop_time(iGrp) = data.mTime(clFreGrps(iGrp, 2));

    % 355 nm
    if sum(flag355) == 1

        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_355/2);

        if isnan(aerBsc355_klett(iGrp, 80))
            continue;
        end

        [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig355 = squeeze(sum(data.signal(flag355, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt355 = aerExt355_klett(iGrp, :);
        aExt355(1:hIndBase) = aerExt355_klett(hIndBase);
        aBsc355 = aerBsc355_klett(iGrp, :);
        aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
        mOT355 = nancumsum(mExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aOT355 + mOT355));
        bsc355 = mBsc355 + aBsc355;

        % lidar calibration
        LC_klett_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
        [LC_klett_355, ~, lcStd] = mean_stable(LC_klett_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_klett_355 = LC_klett_355 * lcStd;

        LC.LC_klett_355(iGrp) = LC_klett_355;
        LC.LCStd_klett_355(iGrp) = LCStd_klett_355;
    end

    % 532 nm
    if sum(flag532) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_532/2);

        if isnan(aerBsc532_klett(iGrp, 80))
            continue;
        end

        [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig532 = squeeze(sum(data.signal(flag532, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt532 = aerExt532_klett(iGrp, :);
        aExt532(1:hIndBase) = aerExt532_klett(hIndBase);
        aBsc532 = aerBsc532_klett(iGrp, :);
        aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
        mOT532 = nancumsum(mExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aOT532 + mOT532));
        bsc532 = mBsc532 + aBsc532;

        % lidar calibration
        LC_klett_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
        [LC_klett_532, ~, lcStd] = mean_stable(LC_klett_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_klett_532 = LC_klett_532 * lcStd;

        LC.LC_klett_532(iGrp) = LC_klett_532;
        LC.LCStd_klett_532(iGrp) = LCStd_klett_532;
    end

    % 1064 nm
    if sum(flag1064) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_1064/2);

        if isnan(aerBsc1064_klett(iGrp, 80))
            continue;
        end

        [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig1064 = squeeze(sum(data.signal(flag1064, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt1064 = aerExt1064_klett(iGrp, :);
        aExt1064(1:hIndBase) = aerExt1064_klett(hIndBase);
        aBsc1064 = aerBsc1064_klett(iGrp, :);
        aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
        mOT1064 = nancumsum(mExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aOT1064 + mOT1064));
        bsc1064 = mBsc1064 + aBsc1064;

        % lidar calibration
        LC_klett_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
        [LC_klett_1064, ~, lcStd] = mean_stable(LC_klett_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_klett_1064 = LC_klett_1064 * lcStd;

        LC.LC_klett_1064(iGrp) = LC_klett_1064;
        LC.LCStd_klett_1064(iGrp) = LCStd_klett_1064;
    end

    % 355 nm (Raman)
    if sum(flag355) == 1

        if isnan(aerBsc355_raman(iGrp, 80))
            continue;
        end

        [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        flagClFre = false(size(data.mTime));
        flagClFre(prfInd) = true;
        flagClFre = flagClFre & (~ data.mask387Off);
        nPrf = sum(flagClFre);
        sig355 = squeeze(sum(data.signal(flag355, :, flagClFre), 3)) / nPrf;

        % optical thickness (OT)
        aBsc355 = aerBsc355_raman(iGrp, :);
        aBsc355(aBsc355 <= 0) = NaN;
        aExt355 = aBsc355 * PollyConfig.LR355;
        aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
        mOT355 = nancumsum(mExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aOT355 + mOT355));
        bsc355 = mBsc355 + aBsc355;

        % lidar calibration
        LC_raman_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
        LC_raman_355(LC_raman_355 <= 0) = NaN;
        [LC_raman_355, ~, lcStd] = mean_stable(LC_raman_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_raman_355 = LC_raman_355 * lcStd;

        LC.LC_raman_355(iGrp) = LC_raman_355;
        LC.LCStd_raman_355(iGrp) = LCStd_raman_355;
    end

    % 532 nm (Raman)
    if sum(flag532) == 1

        if isnan(aerBsc532_raman(iGrp, 80))
            continue;
        end

        [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        flagClFre = false(size(data.mTime));
        flagClFre(prfInd) = true;
        flagClFre = flagClFre & (~ data.mask607Off);
        nPrf = sum(flagClFre);
        sig532 = squeeze(sum(data.signal(flag532, :, flagClFre), 3)) / nPrf;

        % optical thickness (OT)
        aBsc532 = aerBsc532_raman(iGrp, :);
        aBsc532(aBsc532 <= 0) = NaN;
        aExt532 = aBsc532 * PollyConfig.LR532;
        aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
        mOT532 = nancumsum(mExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aOT532 + mOT532));
        bsc532 = mBsc532 + aBsc532;

        % lidar calibration
        LC_raman_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
        LC_raman_532(LC_raman_532 <= 0) = NaN;
        [LC_raman_532, ~, lcStd] = mean_stable(LC_raman_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_raman_532 = LC_raman_532 * lcStd;

        LC.LC_raman_532(iGrp) = LC_raman_532;
        LC.LCStd_raman_532(iGrp) = LCStd_raman_532;
    end

    % 1064 nm (Raman)
    if sum(flag1064) == 1

        if isnan(aerBsc1064_raman(iGrp, 80))
            continue;
        end

        [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        flagClFre = false(size(data.mTime));
        flagClFre(prfInd) = true;
        flagClFre = flagClFre & (~ data.mask607Off);
        nPrf = sum(flagClFre);
        sig1064 = squeeze(sum(data.signal(flag1064, :, flagClFre), 3)) / nPrf;

        % optical thickness (OT)
        aBsc1064 = aerBsc1064_raman(iGrp, :);
        aBsc1064(aBsc1064 <= 0) = NaN;
        aExt1064 = aBsc1064 * PollyConfig.LR1064;
        aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
        mOT1064 = nancumsum(mExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aOT1064 + mOT1064));
        bsc1064 = mBsc1064 + aBsc1064;

        % lidar calibration
        LC_raman_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
        LC_raman_1064(LC_raman_1064 <= 0) = NaN;
        [LC_raman_1064, ~, lcStd] = mean_stable(LC_raman_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_raman_1064 = LC_raman_1064 * lcStd;

        LC.LC_raman_1064(iGrp) = LC_raman_1064;
        LC.LCStd_raman_1064(iGrp) = LCStd_raman_1064;
    end

    % 387 nm (Raman)
    if sum(flag355) == 1

        if isnan(aerBsc355_raman(iGrp, 80))
            continue;
        end

        [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
        [~, mExt387] = rayleigh_scattering(387, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        flagClFre = false(size(data.mTime));
        flagClFre(prfInd) = true;
        flagClFre = flagClFre & (~ data.mask387Off);
        nPrf = sum(flagClFre);
        sig387 = squeeze(sum(data.signal(flag387, :, flagClFre), 3)) / nPrf;

        % optical thickness (OT)
        aBsc355 = aerBsc355_raman(iGrp, :);
        aBsc355(aBsc355 <= 0) = NaN;
        aExt355 = aBsc355 * PollyConfig.LR355;
        aExt387 = aExt355 * (355/387).^PollyConfig.angstrexp;
        aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
        aOT387 = nancumsum(aExt387 .* [data.distance0(1), diff(data.distance0)]);
        mOT355 = nancumsum(mExt355 .* [data.distance0(1), diff(data.distance0)]);
        mOT387 = nancumsum(mExt387 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans_355_387 = exp(- (aOT355 + mOT355 + aOT387 + mOT387));
        bsc355 = mBsc355;

        % lidar calibration
        LC_raman_387 = transpose(smooth(sig387 .* data.distance0.^2, PollyConfig.smoothWin_raman_355)) ./ bsc355 ./ trans_355_387;
        LC_raman_387(LC_raman_387 <= 0) = NaN;
        [LC_raman_387, ~, lcStd] = mean_stable(LC_raman_387, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_raman_387 = LC_raman_387 * lcStd;

        LC.LC_raman_387(iGrp) = LC_raman_387;
        LC.LCStd_raman_387(iGrp) = LCStd_raman_387;
    end

    % 607 nm (Raman)
    if sum(flag532) == 1

        if isnan(aerBsc532_raman(iGrp, 80))
            continue;
        end

        [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
        [~, mExt607] = rayleigh_scattering(607, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        flagClFre = false(size(data.mTime));
        flagClFre(prfInd) = true;
        flagClFre = flagClFre & (~ data.mask607Off);
        nPrf = sum(flagClFre);
        sig607 = squeeze(sum(data.signal(flag607, :, flagClFre), 3)) / nPrf;

        % optical thickness (OT)
        aBsc532 = aerBsc532_raman(iGrp, :);
        aBsc532(aBsc532 <= 0) = NaN;
        aExt532 = aBsc532 * PollyConfig.LR532;
        aExt607 = aExt532 * (532/607).^PollyConfig.angstrexp;
        aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
        aOT607 = nancumsum(aExt607 .* [data.distance0(1), diff(data.distance0)]);
        mOT532 = nancumsum(mExt532 .* [data.distance0(1), diff(data.distance0)]);
        mOT607 = nancumsum(mExt607 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans_532_607 = exp(- (aOT532 + mOT532 + aOT607 + mOT607));
        bsc532 = mBsc532;

        % lidar calibration
        LC_raman_607 = transpose(smooth(sig607 .* data.distance0.^2, PollyConfig.smoothWin_raman_532)) ./ bsc532 ./ trans_532_607;
        LC_raman_607(LC_raman_607 <= 0) = NaN;
        [LC_raman_607, ~, lcStd] = mean_stable(LC_raman_607, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_raman_607 = LC_raman_607 * lcStd;

        LC.LC_raman_607(iGrp) = LC_raman_607;
        LC.LCStd_raman_607(iGrp) = LCStd_raman_607;
    end

    % 355 nm (AOD-constrained Klett)
    if sum(flag355) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_355/2);

        if isnan(aerBsc355_aeronet(iGrp, 80))
            continue;
        end

        [mBsc355, mExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig355 = squeeze(sum(data.signal(flag355, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt355 = aerExt355_aeronet(iGrp, :);
        aExt355(1:hIndBase) = aerExt355_aeronet(hIndBase);
        aBsc355 = aerBsc355_aeronet(iGrp, :);
        aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
        mOT355 = nancumsum(mExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aOT355 + mOT355));
        bsc355 = mBsc355 + aBsc355;

        % lidar calibration
        LC_aeronet_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
        [LC_aeronet_355, ~, lcStd] = mean_stable(LC_aeronet_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_aeronet_355 = LC_aeronet_355 * lcStd;

        LC.LC_aeronet_355(iGrp) = LC_aeronet_355;
        LC.LCStd_aeronet_355(iGrp) = LCStd_aeronet_355;
    end

    % 532 nm (AOD-constrained Klett)
    if sum(flag532) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_532/2);

        if isnan(aerBsc532_aeronet(iGrp, 80))
            continue;
        end

        [mBsc532, mExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig532 = squeeze(sum(data.signal(flag532, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt532 = aerExt532_aeronet(iGrp, :);
        aExt532(1:hIndBase) = aerExt532_aeronet(hIndBase);
        aBsc532 = aerBsc532_aeronet(iGrp, :);
        aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
        mOT532 = nancumsum(mExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aOT532 + mOT532));
        bsc532 = mBsc532 + aBsc532;

        % lidar calibration
        LC_aeronet_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
        [LC_aeronet_532, ~, lcStd] = mean_stable(LC_aeronet_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_aeronet_532 = LC_aeronet_532 * lcStd;

        LC.LC_aeronet_532(iGrp) = LC_aeronet_532;
        LC.LCStd_aeronet_532(iGrp) = LCStd_aeronet_532;
    end

    % 1064 nm (AOD-constrained Klett)
    if sum(flag1064) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_1064/2);

        if isnan(aerBsc1064_aeronet(iGrp, 80))
            continue;
        end

        [mBsc1064, mExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);

        prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
        nPrf = numel(prfInd);
        sig1064 = squeeze(sum(data.signal(flag1064, :, prfInd), 3)) / nPrf;

        % optical thickness (OT)
        aExt1064 = aerExt1064_aeronet(iGrp, :);
        aExt1064(1:hIndBase) = aerExt1064_aeronet(hIndBase);
        aBsc1064 = aerBsc1064_aeronet(iGrp, :);
        aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
        mOT1064 = nancumsum(mExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aOT1064 + mOT1064));
        bsc1064 = mBsc1064 + aBsc1064;

        % lidar calibration
        LC_aeronet_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
        [LC_aeronet_1064, ~, lcStd] = mean_stable(LC_aeronet_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
        LCStd_aeronet_1064 = LC_aeronet_1064 * lcStd;

        LC.LC_aeronet_1064(iGrp) = LC_aeronet_1064;
        LC.LCStd_aeronet_1064(iGrp) = LCStd_aeronet_1064;
    end
end

% lidar constants for near-range channels
LC.LC_raman_355_NR = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_355_NR = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_387_NR = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_387_NR = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_532_NR = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_532_NR = NaN(size(clFreGrps, 1), 1);
LC.LC_raman_607_NR = NaN(size(clFreGrps, 1), 1);
LC.LCStd_raman_607_NR = NaN(size(clFreGrps, 1), 1);
flag355NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag355nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
flag532NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag532nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
if (~ isempty(olAttri355.sigRatio)) && (sum(flag355NR) == 1)
    LC.LC_raman_355_NR = LC.LC_raman_355 .* olAttri355.sigRatio;
    LC.LCStd_raman_355_NR = LC.LCStd_raman_355 .* olAttri355.sigRatio;
end
if (~ isempty(olAttri387.sigRatio)) && (sum(flag387NR) == 1)
    LC.LC_raman_387_NR = LC.LC_raman_387 .* olAttri387.sigRatio;
    LC.LCStd_raman_387_NR = LC.LCStd_raman_387 .* olAttri387.sigRatio;
end
if (~ isempty(olAttri532.sigRatio)) && (sum(flag532NR) == 1)
    LC.LC_raman_532_NR = LC.LC_raman_532 .* olAttri532.sigRatio;
    LC.LCStd_raman_532_NR = LC.LCStd_raman_532 .* olAttri532.sigRatio;
end
if (~ isempty(olAttri607.sigRatio)) && (sum(flag607NR) == 1)
    LC.LC_raman_607_NR = LC.LC_raman_607 .* olAttri607.sigRatio;
    LC.LCStd_raman_607_NR = LC.LCStd_raman_607 .* olAttri607.sigRatio;
end

% select lidar calibration constant
LCUsed = struct();
flag355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;

%% far-range calibration constants
[LCUsed.LCUsed355, ~, LCUsed.LCUsedTag355, LCUsed.flagLCWarning355] = ...
    selectLiConst(LC.LC_raman_355, zeros(size(LC.LC_raman_355)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '355', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag355), ...
        'default_liconstStd', PollyDefaults.LCStd(flag355));
[LCUsed.LCUsed532, ~, LCUsed.LCUsedTag532, LCUsed.flagLCWarning532] = ...
    selectLiConst(LC.LC_raman_532, zeros(size(LC.LC_raman_532)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '532', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag532), ...
        'default_liconstStd', PollyDefaults.LCStd(flag532));
[LCUsed.LCUsed1064, ~, LCUsed.LCUsedTag1064, LCUsed.flagLCWarning1064] = ...
    selectLiConst(LC.LC_raman_1064, zeros(size(LC.LC_raman_1064)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '1064', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag1064), ...
        'default_liconstStd', PollyDefaults.LCStd(flag1064));
[LCUsed.LCUsed387, ~, LCUsed.LCUsedTag387, LCUsed.flagLCWarning387] = ...
    selectLiConst(LC.LC_raman_387, zeros(size(LC.LC_raman_387)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '387', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag387), ...
        'default_liconstStd', PollyDefaults.LCStd(flag387));
[LCUsed.LCUsed607, ~, LCUsed.LCUsedTag607, LCUsed.flagLCWarning607] = ...
    selectLiConst(LC.LC_raman_607, zeros(size(LC.LC_raman_607)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '607', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag607), ...
        'default_liconstStd', PollyDefaults.LCStd(flag607));

%% near-range lidar calibration constants
[LCUsed.LCUsed532NR, ~, LCUsed.LCUsedTag532NR, LCUsed.flagLCWarning532NR] = ...
    selectLiConst(LC.LC_raman_532_NR, zeros(size(LC.LC_raman_532_NR)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '532', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag532NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag532NR));
[LCUsed.LCUsed607NR, ~, LCUsed.LCUsedTag607NR, LCUsed.flagLCWarning607NR] = ...
    selectLiConst(LC.LC_raman_607_NR, zeros(size(LC.LC_raman_607_NR)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '607', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag607NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag607NR));
[LCUsed.LCUsed355NR, ~, LCUsed.LCUsedTag355NR, LCUsed.flagLCWarning355NR] = ...
    selectLiConst(LC.LC_raman_355_NR, zeros(size(LC.LC_raman_355_NR)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '355', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag355NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag355NR));
[LCUsed.LCUsed387NR, ~, LCUsed.LCUsedTag387NR, LCUsed.flagLCWarning387NR] = ...
    selectLiConst(LC.LC_raman_387_NR, zeros(size(LC.LC_raman_387_NR)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '387', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag387NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag387NR));

print_msg('Finish\n', 'flagTimestamp', true);

%% Attnuated backscatter
print_msg('Start calculating attnuated backscatter.\n', 'flagTimestamp', true);

flag355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
att_beta_355 = NaN(length(data.height), length(data.mTime));
if (sum(flag355) == 1)
    att_beta_355 = squeeze(data.signal(flag355, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed355;
    att_beta_355(:, data.depCalMask) = NaN;
end

flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
att_beta_532 = NaN(length(data.height), length(data.mTime));
if (sum(flag532) == 1)
    att_beta_532 = squeeze(data.signal(flag532, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed532;
    att_beta_532(:, data.depCalMask) = NaN;
end

flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
att_beta_1064 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064) == 1)
    att_beta_1064 = squeeze(data.signal(flag1064, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed1064;
    att_beta_1064(:, data.depCalMask) = NaN;
end

flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
att_beta_387 = NaN(length(data.height), length(data.mTime));
if (sum(flag387) == 1)
    att_beta_387 = squeeze(data.signal(flag387, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed387;
    att_beta_387(:, data.depCalMask) = NaN;
end

flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
att_beta_607 = NaN(length(data.height), length(data.mTime));
if (sum(flag607) == 1)
    att_beta_607 = squeeze(data.signal(flag607, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed607;
    att_beta_607(:, data.depCalMask) = NaN;
end

flag355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
att_beta_OC_355 = NaN(length(data.height), length(data.mTime));
if (sum(flag355) == 1)
    att_beta_OC_355 = sigOLCor355 .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed355;
    att_beta_OC_355(:, data.depCalMask) = NaN;
end

flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
att_beta_OC_532 = NaN(length(data.height), length(data.mTime));
if (sum(flag532) == 1)
    att_beta_OC_532 = sigOLCor532 .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed532;
    att_beta_OC_532(:, data.depCalMask) = NaN;
end

flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & flagTotalChannel;
att_beta_OC_1064 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064) == 1)
    att_beta_OC_1064 = sigOLCor1064 .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed1064;
    att_beta_OC_1064(:, data.depCalMask) = NaN;
end

flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
att_beta_OC_387 = NaN(length(data.height), length(data.mTime));
if (sum(flag387) == 1)
    att_beta_OC_387 = sigOLCor387 .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed387;
    att_beta_OC_387(:, data.depCalMask) = NaN;
end

flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
att_beta_OC_607 = NaN(length(data.height), length(data.mTime));
if (sum(flag607) == 1)
    att_beta_OC_607 = sigOLCor607 .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed607;
    att_beta_OC_607(:, data.depCalMask) = NaN;
end

flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
att_beta_NR_355 = NaN(length(data.height), length(data.mTime));
if (sum(flag355NR) == 1)
    att_beta_NR_355 = squeeze(data.signal(flag355NR, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed355NR;
    att_beta_NR_355(:, data.depCalMask) = NaN;
end

flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
att_beta_NR_532 = NaN(length(data.height), length(data.mTime));
if (sum(flag532NR) == 1)
    att_beta_NR_532 = squeeze(data.signal(flag532NR, :, :)) .* repmat(transpose(data.height), 1, length(data.mTime)).^2 / LCUsed.LCUsed532NR;
    att_beta_NR_532(:, data.depCalMask) = NaN;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Volume linear depolarization ratio with high temporal resolution
print_msg('Start calculating volume linear depolarization ratio.\n', 'flagTimestamp', true);

% 355 nm
flag355T = data.flagFarRangeChannel & data.flagTotalChannel & data.flag355nmChannel;
flag355C = data.flagFarRangeChannel & data.flagCrossChannel & data.flag355nmChannel;
vdr355 = NaN(length(data.height), length(data.mTime));
if (sum(flag355T) == 1) && (sum(flag355C) == 1)
    vdr355 = pollyVDR2(squeeze(data.signal(flag355T, :, :)), ...
                       squeeze(data.signal(flag355C, :, :)), ...
                       PollyConfig.TR(flag355T), ...
                       PollyConfig.TR(flag355C), polCaliFac355);
    vdr355(:, data.depCalMask) = NaN;
end

% 532 nm
flag532T = data.flagFarRangeChannel & data.flagTotalChannel & data.flag532nmChannel;
flag532C = data.flagFarRangeChannel & data.flagCrossChannel & data.flag532nmChannel;
vdr532 = NaN(length(data.height), length(data.mTime));
if (sum(flag532T) == 1) && (sum(flag532C) == 1)
    vdr532 = pollyVDR2(squeeze(data.signal(flag532T, :, :)), ...
                       squeeze(data.signal(flag532C, :, :)), ...
                       PollyConfig.TR(flag532T), ...
                       PollyConfig.TR(flag532C), polCaliFac532);
    vdr532(:, data.depCalMask) = NaN;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Quasi-retrieval (V1)
print_msg('Start quasi-retrieval (V1).\n', 'flagTimestamp', true);

% load meteorological data
[temperature, pressure, ~, ~, ~, thisMeteorAttri] = loadMeteor(mean(data.mTime), data.alt, ...
    'meteorDataSource', PollyConfig.meteorDataSource, ...
    'gdas1Site', PollyConfig.gdas1Site, ...
    'gdas1_folder', PicassoConfig.gdas1_folder, ...
    'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
    'radiosondeFolder', PollyConfig.radiosondeFolder, ...
    'radiosondeType', PollyConfig.radiosondeType, ...
    'method', 'linear');

quasiAttri = struct();
quasiAttri.flagGDAS1 = false;
quasiAttri.timestamp = [];

% quasi-retrieved backscatter at 355 nm
flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
qsiBsc355V1 = NaN(length(data.height), length(data.mTime));
att_beta_355_qsi = att_beta_355;
if (sum(flag355) == 1)
    att_beta_355_qsi(quality_mask_355 ~= 0) = NaN;
    att_beta_355_qsi = smooth2(att_beta_355_qsi, PollyConfig.quasi_smooth_h(flag355), PollyConfig.quasi_smooth_t(flag355));

    % Rayleigh scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, pressure, temperature + 273.17, 380, 70);
    mBsc355 = repmat(transpose(mBsc355), 1, length(data.mTime));
    mExt355 = repmat(transpose(mExt355), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355), 1);
    if ~ isempty(hIndOL)
        att_beta_355_qsi(1:hIndOL, :) = repmat(att_beta_355_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [qsiBsc355V1, ~] = quasiRetrieval(data.height, att_beta_355_qsi, mExt355, mBsc355, PollyConfig.LR355, 'nIters', 6);
end

% quasi-retrieved backscatter at 532 nm
flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
qsiBsc532V1 = NaN(length(data.height), length(data.mTime));
att_beta_532_qsi = att_beta_532;
if (sum(flag532) == 1)
    att_beta_532_qsi(quality_mask_532 ~= 0) = NaN;
    att_beta_532_qsi = smooth2(att_beta_532_qsi, PollyConfig.quasi_smooth_h(flag532), PollyConfig.quasi_smooth_t(flag532));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    mBsc532 = repmat(transpose(mBsc532), 1, length(data.mTime));
    mExt532 = repmat(transpose(mExt532), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532), 1);
    if ~ isempty(hIndOL)
        att_beta_532_qsi(1:hIndOL, :) = repmat(att_beta_532_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [qsiBsc532V1, ~] = quasiRetrieval(data.height, att_beta_532_qsi, mExt532, mBsc532, PollyConfig.LR532, 'nIters', 6);
end

% quasi-retrieved backscatter at 1064 nm
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
qsiBsc1064V1 = NaN(length(data.height), length(data.mTime));
att_beta_1064_qsi = att_beta_1064;
if (sum(flag1064) == 1)
    att_beta_1064_qsi(quality_mask_1064 ~= 0) = NaN;
    att_beta_1064_qsi = smooth2(att_beta_1064_qsi, PollyConfig.quasi_smooth_h(flag1064), PollyConfig.quasi_smooth_t(flag1064));

    % Rayleigh scattering
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.17, 380, 70);
    mBsc1064 = repmat(transpose(mBsc1064), 1, length(data.mTime));
    mExt1064 = repmat(transpose(mExt1064), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064), 1);
    if ~ isempty(hIndOL)
        att_beta_1064_qsi(1:hIndOL, :) = repmat(att_beta_1064_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [qsiBsc1064V1, ~] = quasiRetrieval(data.height, att_beta_1064_qsi, mExt1064, mBsc1064, PollyConfig.LR1064, 'nIters', 6);
end

% quasi-retrieved particle depolarization ratio at 532 nm
flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;
qsiPDR532V1 = NaN(length(data.height), length(data.mTime));
if (sum(flag532T) == 1) && (sum(flag532C) == 1)
    sig532T = squeeze(data.signal(flag532T, :, :));
    sig532C = squeeze(data.signal(flag532C, :, :));
    sig532T(:, data.depCalMask) = NaN;
    sig532C(:, data.depCalMask) = NaN;
    sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532T), PollyConfig.quasi_smooth_t(flag532T));
    sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532C), PollyConfig.quasi_smooth_t(flag532C));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    mBsc532 = repmat(transpose(mBsc532), 1, length(data.mTime));
    mExt532 = repmat(transpose(mExt532), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    vdr532Sm = pollyVDR2(sig532TSm, sig532CSm, PollyConfig.TR(flag532T), PollyConfig.TR(flag532C), polCaliFac532);
    qsiPDR532V1 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (qsiBsc532V1 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
    qsiPDR532V1((quality_mask_vdr_532 ~= 0) | (quality_mask_532 ~= 0)) = NaN;
end

% % quasi-retrieved Ångström exponents 355-532
% flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
% flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
% qsiAE_355_532 = NaN(length(data.height), length(data.mTime));
% if (sum(flag532) == 1) && (sum(flag355) == 1)
%     ratio_par_bsc_355_532 = qsiBsc532V1 ./ qsiBsc355V1;
%     ratio_par_bsc_355_532(ratio_par_bsc_355_532 <= 0) = NaN;
%     qsiAE_355_532 = log(ratio_par_bsc_355_532) ./ log(355/532);
% end

% % quasi-retrieved Ångström exponents 355-1064
% flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
% flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
% qsiAE_355_1064 = NaN(length(data.height), length(data.mTime));
% if (sum(flag1064) == 1) && (sum(flag355) == 1)
%     ratio_par_bsc_355_1064 = qsiBsc1064V1 ./ qsiBsc355V1;
%     ratio_par_bsc_355_1064(ratio_par_bsc_355_1064 <= 0) = NaN;
%     qsiAE_355_1064 = log(ratio_par_bsc_355_1064) ./ log(355/1064);
% end

% quasi-retrieved Ångström exponents 532-1064
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
qsiAE_532_1064_V1 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064) == 1) && (sum(flag532) == 1)
    ratio_par_bsc_532_1064 = qsiBsc1064V1 ./ qsiBsc532V1;
    ratio_par_bsc_532_1064(ratio_par_bsc_532_1064 <= 0) = NaN;
    qsiAE_532_1064_V1 = log(ratio_par_bsc_532_1064) ./ log(532/1064);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Target classification (V1)
print_msg('Start aerosol/cloud target classification (v1).\n', 'flagTimestamp', true);

tcMaskV1 = zeros(length(data.height), length(data.mTime));
flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;
if (sum(flag532T) == 1) && (sum(flag532C) == 1) && (sum(flag1064) == 1)
    tcMaskV1 = targetClassify(data.height, att_beta_532, qsiBsc1064V1, qsiBsc532V1, qsiPDR532V1, vdr532Sm, qsiAE_532_1064_V1, ...
    'clearThresBsc1064', PollyConfig.clear_thres_par_beta_1064, ...
    'turbidThresBsc1064', PollyConfig.turbid_thres_par_beta_1064, ...
    'turbidThresBsc532', PollyConfig.turbid_thres_par_beta_532, ...
    'dropletThresPDR', PollyConfig.droplet_thres_par_depol, ...
    'spheriodThresPDR', PollyConfig.spheroid_thres_par_depol, ...
    'unspheroidThresPDR', PollyConfig.unspheroid_thres_par_depol, ...
    'iceThresVDR', PollyConfig.ice_thres_vol_depol, ...
    'iceThresPDR', PollyConfig.ice_thres_par_depol, ...
    'largeThresAE', PollyConfig.large_thres_ang, ...
    'smallThresAE', PollyConfig.small_thres_ang, ...
    'cloudThresBsc1064', PollyConfig.cloud_thres_par_beta_1064, ...
    'minAttnRatioBsc1064', PollyConfig.min_atten_par_beta_1064, ...
    'searchCloudAbove', PollyConfig.search_cloud_above, ...
    'searchCloudBelow', PollyConfig.search_cloud_below, ...
    'hFullOL', max(PollyConfig.heightFullOverlap(flag532T), PollyConfig.heightFullOverlap(flag1064)));

    %% set the value during the depolarization calibration period or in fog conditions to 0
    tcMaskV1(:, data.depCalMask | data.fogMask) = 0;

    %% set the value with low SNR to 0
    tcMaskV1((quality_mask_532 ~= 0) | (quality_mask_1064 ~= 0) | (quality_mask_vdr_532 ~= 0)) = 0;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Quasi-retrieval (V2)

% quasi-retrieved backscatter at 355 nm (V2)
flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
qsiBsc355V2 = NaN(length(data.height), length(data.mTime));
att_beta_355_qsi = att_beta_355;
att_beta_387_qsi = att_beta_387;
if (sum(flag355) == 1) && (sum(flag387) == 1)
    att_beta_355_qsi(quality_mask_355 ~= 0) = NaN;
    att_beta_387_qsi(quality_mask_387 ~= 0) = NaN;
    att_beta_355_qsi = smooth2(att_beta_355_qsi, PollyConfig.quasi_smooth_h(flag355), PollyConfig.quasi_smooth_t(flag355));
    att_beta_387_qsi = smooth2(att_beta_387_qsi, PollyConfig.quasi_smooth_h(flag387), PollyConfig.quasi_smooth_t(flag387));

    % Rayleigh scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, pressure, temperature + 273.17, 380, 70);
    [~, mExt387] = rayleigh_scattering(387, pressure, temperature + 273.17, 380, 70);
    mBsc355 = repmat(transpose(mBsc355), 1, length(data.mTime));
    mExt355 = repmat(transpose(mExt355), 1, length(data.mTime));
    mExt387 = repmat(transpose(mExt387), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    [qsiBsc355V2, ~] = quasiRetrieval2(data.height, att_beta_355_qsi, att_beta_387_qsi, 355, mExt355, mBsc355, mExt387, 0.5, PollyConfig.LR355, 'nIters', 3);
    qsiBsc355V2 = smooth2(qsiBsc355V2, PollyConfig.quasi_smooth_h(flag355), PollyConfig.quasi_smooth_t(flag355));
end

% quasi-retrieved backscatter at 532 nm (V2)
flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
qsiBsc532V2 = NaN(length(data.height), length(data.mTime));
att_beta_532_qsi = att_beta_532;
att_beta_607_qsi = att_beta_607;
if (sum(flag532) == 1) && (sum(flag607) == 1)
    att_beta_532_qsi(quality_mask_532 ~= 0) = NaN;
    att_beta_607_qsi(quality_mask_607 ~= 0) = NaN;
    att_beta_532_qsi = smooth2(att_beta_532_qsi, PollyConfig.quasi_smooth_h(flag532), PollyConfig.quasi_smooth_t(flag532));
    att_beta_607_qsi = smooth2(att_beta_607_qsi, PollyConfig.quasi_smooth_h(flag607), PollyConfig.quasi_smooth_t(flag607));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    [~, mExt607] = rayleigh_scattering(607, pressure, temperature + 273.17, 380, 70);
    mBsc532 = repmat(transpose(mBsc532), 1, length(data.mTime));
    mExt532 = repmat(transpose(mExt532), 1, length(data.mTime));
    mExt607 = repmat(transpose(mExt607), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    [qsiBsc532V2, ~] = quasiRetrieval2(data.height, att_beta_532_qsi, att_beta_607_qsi, 532, mExt532, mBsc532, mExt607, 0.5, PollyConfig.LR532, 'nIters', 3);
    qsiBsc532V2 = smooth2(qsiBsc532V2, PollyConfig.quasi_smooth_h(flag532), PollyConfig.quasi_smooth_t(flag532));
end

% quasi-retrieved backscatter at 1064 nm (V2)
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
qsiBsc1064V2 = NaN(length(data.height), length(data.mTime));
att_beta_1064_qsi = att_beta_1064;
att_beta_607_qsi = att_beta_607;
if (sum(flag1064) == 1) && (sum(flag607) == 1)
    att_beta_1064_qsi(quality_mask_1064 ~= 0) = NaN;
    att_beta_607_qsi(quality_mask_607 ~= 0) = NaN;
    att_beta_1064_qsi = smooth2(att_beta_1064_qsi, PollyConfig.quasi_smooth_h(flag1064), PollyConfig.quasi_smooth_t(flag1064));
    att_beta_607_qsi = smooth2(att_beta_607_qsi, PollyConfig.quasi_smooth_h(flag607), PollyConfig.quasi_smooth_t(flag607));

    % Rayleigh scattering
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.17, 380, 70);
    [~, mExt607] = rayleigh_scattering(607, pressure, temperature + 273.17, 380, 70);
    mBsc1064 = repmat(transpose(mBsc1064), 1, length(data.mTime));
    mExt1064 = repmat(transpose(mExt1064), 1, length(data.mTime));
    mExt607 = repmat(transpose(mExt607), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    [qsiBsc1064V2, ~] = quasiRetrieval2(data.height, att_beta_1064_qsi, att_beta_607_qsi, 1064, mExt1064, mBsc1064, mExt607, 0.5, PollyConfig.LR1064, 'nIters', 3);
    qsiBsc1064V2 = smooth2(qsiBsc1064V2, PollyConfig.quasi_smooth_h(flag1064), PollyConfig.quasi_smooth_t(flag1064));
end

% quasi-retrieved particle depolarization ratio at 532 nm (V2)
flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;
qsiPDR532V2 = NaN(length(data.height), length(data.mTime));
if (sum(flag532T) == 1) && (sum(flag532C) == 1)
    sig532T = squeeze(data.signal(flag532T, :, :));
    sig532C = squeeze(data.signal(flag532C, :, :));
    sig532T(:, data.depCalMask) = NaN;
    sig532C(:, data.depCalMask) = NaN;
    sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532T), PollyConfig.quasi_smooth_t(flag532T));
    sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532C), PollyConfig.quasi_smooth_t(flag532C));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    mBsc532 = repmat(transpose(mBsc532), 1, length(data.mTime));
    mExt532 = repmat(transpose(mExt532), 1, length(data.mTime));
    quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    quasiAttri.timestamp = thisMeteorAttri.datetime;

    vdr532Sm = pollyVDR2(sig532TSm, sig532CSm, PollyConfig.TR(flag532T), PollyConfig.TR(flag532C), polCaliFac532);
    qsiPDR532V2 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (qsiBsc532V2 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
    qsiPDR532V2((quality_mask_vdr_532 ~= 0) | (quality_mask_532 ~= 0)) = NaN;
end

% % quasi-retrieved Ångström exponents 355-532 (V2)
% flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
% flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
% flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
% flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
% qsiAE_355_532_V2 = NaN(length(data.height), length(data.mTime));
% if (sum(flag532) == 1) && (sum(flag355) == 1) && (sum(flag387) == 1) && (sum(flag607) == 1)
%     ratio_par_bsc_355_532 = qsiBsc532V2 ./ qsiBsc355V2;
%     ratio_par_bsc_355_532(ratio_par_bsc_355_532 <= 0) = NaN;
%     qsiAE_355_532_V2 = log(ratio_par_bsc_355_532) ./ log(355/532);
% end

% % quasi-retrieved Ångström exponents 355-1064 (V2)
% flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
% flag355 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag355nmChannel;
% flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
% flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
% qsiAE_355_1064_V2 = NaN(length(data.height), length(data.mTime));
% if (sum(flag1064) == 1) && (sum(flag355) == 1) && (sum(flag387) == 1) && (sum(flag607) == 1)
%     ratio_par_bsc_355_1064 = qsiBsc1064V2 ./ qsiBsc355V2;
%     ratio_par_bsc_355_1064(ratio_par_bsc_355_1064 <= 0) = NaN;
%     qsiAE_355_1064_V2 = log(ratio_par_bsc_355_1064) ./ log(355/1064);
% end

% quasi-retrieved Ångström exponents 532-1064 (V2)
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
flag532 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
qsiAE_532_1064_V2 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064) == 1) && (sum(flag532) == 1) && (sum(flag607) == 1)
    ratio_par_bsc_532_1064 = qsiBsc1064V2 ./ qsiBsc532V2;
    ratio_par_bsc_532_1064(ratio_par_bsc_532_1064 <= 0) = NaN;
    qsiAE_532_1064_V2 = log(ratio_par_bsc_532_1064) ./ log(532/1064);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Target classification (V2)
print_msg('Start aerosol/cloud target classification (v2).\n', 'flagTimestamp', true);

tcMaskV2 = zeros(length(data.height), length(data.mTime));
flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
if (sum(flag532T) == 1) && (sum(flag532C) == 1) && (sum(flag1064) == 1) && (sum(flag387) == 1) && (sum(flag607) == 1)
    tcMaskV2 = targetClassify(data.height, att_beta_532, qsiBsc1064V2, qsiBsc532V2, qsiPDR532V2, vdr532Sm, qsiAE_532_1064_V2, ...
    'clearThresBsc1064', PollyConfig.clear_thres_par_beta_1064, ...
    'turbidThresBsc1064', PollyConfig.turbid_thres_par_beta_1064, ...
    'turbidThresBsc532', PollyConfig.turbid_thres_par_beta_532, ...
    'dropletThresPDR', PollyConfig.droplet_thres_par_depol, ...
    'spheriodThresPDR', PollyConfig.spheroid_thres_par_depol, ...
    'unspheroidThresPDR', PollyConfig.unspheroid_thres_par_depol, ...
    'iceThresVDR', PollyConfig.ice_thres_vol_depol, ...
    'iceThresPDR', PollyConfig.ice_thres_par_depol, ...
    'largeThresAE', PollyConfig.large_thres_ang, ...
    'smallThresAE', PollyConfig.small_thres_ang, ...
    'cloudThresBsc1064', PollyConfig.cloud_thres_par_beta_1064, ...
    'minAttnRatioBsc1064', PollyConfig.min_atten_par_beta_1064, ...
    'searchCloudAbove', PollyConfig.search_cloud_above, ...
    'searchCloudBelow', PollyConfig.search_cloud_below, ...
    'hFullOL', 0);

    %% set the value during the depolarization calibration period or in fog conditions to 0
    tcMaskV2(:, data.depCalMask | data.fogMask) = 0;

    %% set the value with low SNR to 0
    tcMaskV2((quality_mask_532 ~= 0) | (quality_mask_1064 ~= 0) | (quality_mask_vdr_532 ~= 0) | (quality_mask_607 ~= 0)) = 0;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Cloud detection
print_msg('Start extracting cloud heights.\n', 'flagTimestamp', true);
MAXCLLAYERS = 10;
clBaseH = NaN(MAXCLLAYERS, length(data.mTime));
clTopH = NaN(MAXCLLAYERS, length(data.mTime));
clPh = zeros(MAXCLLAYERS, length(data.mTime));
clPhProb = zeros(MAXCLLAYERS, length(data.mTime));

flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag1064 = data.flagTotalChannel & data.flagFarRangeChannel & data.flag1064nmChannel;
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;

if (sum(flag532T) == 1) && (sum(flag532C) == 1) && (sum(flag1064) == 1)
    [clBaseH, clTopH, clPh, clPhProb] = cloudGeoExtract(data.mTime, data.height, tcMaskV1, ...
        'minCloudDepth', 100, ...
        'liquidCloudBit', 8, ...
        'iceCloudBit', 9, ...
        'cloudBits', [7, 8, 9, 10, 11]);
elseif PollyConfig.cloudScreenMode == 2
    [clBaseH, clTopH, ~, ~] = cloudGeoExtract(data.mTime, data.height, cloudMask, ...
        'minCloudDepth', 100, ...
        'liquidCloudBit', 1, ...
        'iceCloudBit', 1, ...
        'cloudBits', 1);
    clPh = zeros(size(clBaseH));
    clPhProb = zeros(size(clBaseH));
else
    warning('No cloud geometrical properties available.');
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Saving calibration results
if PicassoConfig.flagEnableCaliResultsOutput
    print_msg('Start saving calibration results.\n', 'flagTimestamp', true);

    flag355T = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
    flag355C = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;
    flag387 = data.flagFarRangeChannel & data.flag387nmChannel;
    flag407 = data.flagFarRangeChannel & data.flag407nmChannel;
    flag532T = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
    flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
    flag607 = data.flagFarRangeChannel & data.flag607nmChannel;
    flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel;

    %% save polarization calibration results
    if (sum(flag355T) == 1) && (sum(flag355C) == 1)
        print_msg('--> saving polarization calibration results at 355 nm...\n', 'flagTimestamp', true);
        saveDepolConst(dbFile, ...
                       polCali355Attri.polCaliFac, ...
                       polCali355Attri.polCaliFacStd, ...
                       polCali355Attri.polCaliStartTime, ...
                       polCali355Attri.polCaliStopTime, ...
                       PollyDataInfo.pollyDataFile, ...
                       CampaignConfig.name, '355');
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    if (sum(flag532T) == 1) && (sum(flag532C) == 1)
        print_msg('--> saving polarization calibration results at 532 nm...\n', 'flagTimestamp', true);
        saveDepolConst(dbFile, ...
                       polCali532Attri.polCaliFac, ...
                       polCali532Attri.polCaliFacStd, ...
                       polCali532Attri.polCaliStartTime, ...
                       polCali532Attri.polCaliStopTime, ...
                       PollyDataInfo.pollyDataFile, ...
                       CampaignConfig.name, '532');
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    %% save lidar calibration results
    print_msg('--> start saving lidar calibration constants.\n', 'flagTimestamp', true);
    saveLiConst(dbFile, LC.LC_klett_355, LC.LCStd_klett_355, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_klett_532, LC.LCStd_klett_532, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_klett_1064, LC.LCStd_klett_1064, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_355, LC.LCStd_raman_355, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_532, LC.LCStd_raman_532, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_1064, LC.LCStd_raman_1064, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_387, LC.LCStd_raman_387, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '387', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_607, LC.LCStd_raman_607, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '607', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_aeronet_355, LC.LCStd_aeronet_355, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_aeronet_532, LC.LCStd_aeronet_532, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_aeronet_1064, LC.LCStd_aeronet_1064, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, LC.LC_raman_355_NR, LC.LCStd_raman_355_NR, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, LC.LC_raman_387_NR, LC.LCStd_raman_387_NR, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '387', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, LC.LC_raman_532_NR, LC.LCStd_raman_532_NR, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, LC.LCStd_raman_607_NR, LC.LCStd_raman_607_NR, ...
                LC.LC_start_time, LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '607', 'Raman_Method', 'near_range');
    print_msg('--> finish.\n', 'flagTimestamp', true);

    %% save water vapor calibration results
    if (sum(flag407) == 1) && (sum(flag387) == 1)
        print_msg('--> start saving water vapor calibration results...\n', 'flagTimestamp', true);
        saveWVConst(dbFile, wvconst, wvconstStd, wvCaliInfo, IWVAttri, PollyDataInfo.pollyDataFile, CampaignConfig.name);
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    print_msg('Finish.\n', 'flagTimestamp', true);
end

data.sigOLCor355 = sigOLCor355;
data.sigOLCor532 = sigOLCor532;
data.sigOLCor1064 = sigOLCor1064;
data.olFunc532 = olFunc532;
data.olFunc355 = olFunc355;
data.olAttri355 = olAttri355;
data.olAttri532 = olAttri532;
data.olFuncDeft355 = olFuncDeft355;
data.olFuncDeft532 = olFuncDeft532;
data.polCaliFac355 = polCaliFac355;
data.polCaliFacStd355 = polCaliFacStd355;
data.polCaliFac532 = polCaliFac532;
data.polCaliFacStd532 = polCaliFacStd532;
data.aerBsc355_klett = aerBsc355_klett;
data.aerBsc532_klett = aerBsc532_klett;
data.aerBsc1064_klett = aerBsc1064_klett;
data.aerExt355_klett = aerExt355_klett;
data.aerExt532_klett = aerExt532_klett;
data.aerExt1064_klett = aerExt1064_klett;
data.aerBsc355_aeronet = aerBsc355_aeronet;
data.aerBsc532_aeronet = aerBsc532_aeronet;
data.aerBsc1064_aeronet = aerBsc1064_aeronet;
data.aerExt355_aeronet = aerExt355_aeronet;
data.aerExt532_aeronet = aerExt532_aeronet;
data.aerExt1064_aeronet = aerExt1064_aeronet;
data.LR355_aeronet = LR355_aeronet;
data.LR532_aeronet = LR532_aeronet;
data.LR1064_aeronet = LR1064_aeronet;
data.aerBsc355_raman = aerBsc355_raman;
data.aerBsc532_raman = aerBsc532_raman;
data.aerBsc1064_raman = aerBsc1064_raman;
data.aerExt355_raman = aerExt355_raman;
data.aerExt532_raman = aerExt532_raman;
data.aerExt1064_raman = aerExt1064_raman;
data.LR355_raman = LR355_raman;
data.LR532_raman = LR532_raman;
data.LR1064_raman = LR1064_raman;
data.vdr355_klett = vdr355_klett;
data.vdr532_klett = vdr532_klett;
data.vdr355_raman = vdr355_raman;
data.vdr532_raman = vdr532_raman;
data.pdr355_klett = pdr355_klett;
data.pdr532_klett = pdr532_klett;
data.pdr355_raman = pdr355_raman;
data.pdr532_raman = pdr532_raman;
data.pdrStd355_klett = pdrStd355_klett;
data.pdrStd532_klett = pdrStd532_klett;
data.pdrStd355_raman = pdrStd355_raman;
data.pdrStd532_raman = pdrStd532_raman;
data.wvmr = wvmr;
data.rh = rh;
data.wvconstUsed = wvconstUsed;
data.wvconstUsedStd = wvconstUsedStd;
data.AE_Bsc_355_532_klett = AE_Bsc_355_532_klett;
data.AE_Bsc_532_1064_klett = AE_Bsc_532_1064_klett;
data.AE_Bsc_355_532_raman = AE_Bsc_355_532_raman;
data.AE_Bsc_532_1064_raman = AE_Bsc_532_1064_raman;
data.AE_Ext_355_532_raman = AE_Ext_355_532_raman;
data.refHInd355 = refHInd355;
data.refHInd532 = refHInd532;
data.refHInd1064 = refHInd1064;
data.deltaAOD355 = deltaAOD355;
data.deltaAOD532 = deltaAOD532;
data.deltaAOD1064 = deltaAOD1064;
data.mdr355 = mdr355;
data.mdr532 = mdr532;
data.IWVAttri = IWVAttri;
data.meteorAttri = meteorAttri;
data.refBeta_NR_355_klett = refBeta_NR_355_klett;
data.refBeta_NR_532_klett = refBeta_NR_532_klett;
data.refBeta_NR_355_raman = refBeta_NR_355_raman;
data.refBeta_NR_532_raman = refBeta_NR_532_raman;
data.aerBsc355_NR_klett = aerBsc355_NR_klett;
data.aerBsc532_NR_klett = aerBsc532_NR_klett;
data.aerExt355_NR_klett = aerExt355_NR_klett;
data.aerExt532_NR_klett = aerExt532_NR_klett;
data.aerBsc355_NR_raman = aerBsc355_NR_raman;
data.aerBsc532_NR_raman = aerBsc532_NR_raman;
data.aerExt355_NR_raman = aerExt355_NR_raman;
data.aerExt532_NR_raman = aerExt532_NR_raman;
data.LR355_NR_raman = LR355_NR_raman;
data.LR532_NR_raman = LR532_NR_raman;
data.AE_Bsc_355_532_NR_klett = AE_Bsc_355_532_NR_klett;
data.AE_Bsc_355_532_NR_raman = AE_Bsc_355_532_NR_raman;
data.AE_Ext_355_532_NR_raman = AE_Ext_355_532_NR_raman;
data.aerBsc355_OC_klett = aerBsc355_OC_klett;
data.aerBsc532_OC_klett = aerBsc532_OC_klett;
data.aerBsc1064_OC_klett = aerBsc1064_OC_klett;
data.aerExt355_OC_klett = aerExt355_OC_klett;
data.aerExt532_OC_klett = aerExt532_OC_klett;
data.aerExt1064_OC_klett = aerExt1064_OC_klett;
data.aerBsc355_OC_raman = aerBsc355_OC_raman;
data.aerBsc532_OC_raman = aerBsc532_OC_raman;
data.aerBsc1064_OC_raman = aerBsc1064_OC_raman;
data.aerExt355_OC_raman = aerExt355_OC_raman;
data.aerExt532_OC_raman = aerExt532_OC_raman;
data.aerExt1064_OC_raman = aerExt1064_OC_raman;
data.AE_Bsc_355_532_OC_klett = AE_Bsc_355_532_OC_klett;
data.AE_Bsc_532_1064_OC_klett = AE_Bsc_532_1064_OC_klett;
data.AE_Bsc_355_532_OC_raman = AE_Bsc_355_532_OC_raman;
data.AE_Bsc_532_1064_OC_raman = AE_Bsc_532_1064_OC_raman;
data.AE_Ext_355_532_OC_raman = AE_Ext_355_532_OC_raman;
data.LR355_OC_raman = LR355_OC_raman;
data.LR532_OC_raman = LR532_OC_raman;
data.LR1064_OC_raman = LR1064_OC_raman;
data.pdr355_OC_klett = pdr355_OC_klett;
data.pdr532_OC_klett = pdr532_OC_klett;
data.pdr355_OC_raman = pdr355_OC_raman;
data.pdr532_OC_raman = pdr532_OC_raman;
data.pdrStd355_OC_klett = pdrStd355_OC_klett;
data.pdrStd532_OC_klett = pdrStd532_OC_klett;
data.pdrStd355_OC_raman = pdrStd355_OC_raman;
data.pdrStd532_OC_raman = pdrStd532_OC_raman;
data.LC = LC;
data.att_beta_355 = att_beta_355;
data.att_beta_532 = att_beta_532;
data.att_beta_1064 = att_beta_1064;
data.quality_mask_355 = quality_mask_355;
data.quality_mask_532 = quality_mask_532;
data.quality_mask_1064 = quality_mask_1064;
data.quality_mask_387 = quality_mask_387;
data.quality_mask_607 = quality_mask_607;
data.SNR = SNR;
data.LCUsed = LCUsed;
data.att_beta_NR_355 = att_beta_NR_355;
data.att_beta_NR_532 = att_beta_NR_532;
data.att_beta_OC_355 = att_beta_OC_355;
data.att_beta_OC_532 = att_beta_OC_532;
data.att_beta_OC_1064 = att_beta_OC_1064;
data.WVMR = WVMR;
data.RH = RH;
data.quality_mask_WVMR = quality_mask_WVMR;
data.quality_mask_RH = quality_mask_RH;
data.quasiAttri = quasiAttri;
data.qsiBsc355V1 = qsiBsc355V1;
data.qsiBsc532V1 = qsiBsc532V1;
data.qsiBsc1064V1 = qsiBsc1064V1;
data.qsiPDR532V1 = qsiPDR532V1;
data.qsiAE_532_1064_V1 = qsiAE_532_1064_V1;
data.quality_mask_vdr_532 = quality_mask_vdr_532;
data.qsiBsc355V2 = qsiBsc355V2;
data.qsiBsc532V2 = qsiBsc532V2;
data.qsiBsc1064V2 = qsiBsc1064V2;
data.qsiPDR532V2 = qsiPDR532V2;
data.qsiAE_532_1064_V2 = qsiAE_532_1064_V2;
quality_mask_532_V2 = quality_mask_532;
quality_mask_532_V2((quality_mask_532_V2 == 0) & (quality_mask_607 == 1)) = 1;
data.quality_mask_532_V2 = quality_mask_532_V2;
quality_mask_1064_V2 = quality_mask_1064;
quality_mask_1064_V2((quality_mask_1064_V2 == 0) & ((quality_mask_607 == 1) | (quality_mask_532 == 1))) = 1;
data.quality_mask_1064_V2 = quality_mask_1064_V2;
data.tcMaskV1 = tcMaskV1;
data.tcMaskV2 = tcMaskV2;
data.clBaseH = clBaseH;
data.clTopH = clTopH;
data.clPh = clPh;
data.clPhProb = clPhProb;

%% Saving products
if PicassoConfig.flagEnableCaliResultsOutput

    % delete the previous outputs
    % This is only necessary when you run the code on the server, 
    % where the polly data was updated in time. If the 
    % previous outputs were not cleared, it will piled up to a huge amount.
    if PicassoConfig.flagDeletePreOutputs
        print_msg('Start deleting previous netCDF files.\n', 'flagTimestamp', true);
        ncFileList = listfile(fullfile(PicassoConfig.results_folder, ...
                                       CampaignConfig.name, ...
                                       datestr(data.mTime(1), 'yyyy'), ...
                                       datestr(data.mTime(1), 'mm'), ...
                                       datestr(data.mTime(1), 'dd')), ...
                              sprintf('%s.*.nc', rmext(PollyDataInfo.pollyDataFile)));

        for iFile = 1:length(ncFileList)
            delete(ncFileList{iFile});
        end
        print_msg('Finish.\n', 'flagTimestamp', true);
    end

    % saving products
    print_msg('Start saving products.\n', 'flagTimestamp', true);

    for iProd = 1:length(PollyConfig.prodSaveList)
        switch lower(PollyConfig.prodSaveList{iProd})

        case 'overlap'
            print_msg('--> start saving overlap function.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save overlap function
            saveFile = fullfile(PicassoConfig.results_folder, ...
                                CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), ...
                                datestr(data.mTime(1), 'mm'), ...
                                datestr(data.mTime(1), 'dd'), ...
                                sprintf('%s_overlap.nc', rmext(PollyDataInfo.pollyDataFile)));
            pollySaveOverlap(data, saveFile);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'aerproffr'
            print_msg('--> start saving aerosol vertical profiles.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save aerosol optical results
            pollySaveProfiles(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'aerprofnr'
            print_msg('--> start saving aerosol vertical profiles (near-field).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save aerosol optical results
            pollySaveNRProfiles(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'aerprofoc'
            print_msg('--> start saving aerosol vertical profiles (overlap corrected).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save aerosol optical results
            pollySaveOCProfiles(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'aerattbetafr'
            print_msg('--> start saving attenuated backscatter (far-field).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save attenuated backscatter
            pollySaveAttnBeta(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'aerattbetaoc'
            print_msg('--> start saving attenuated backscatter (overlap corrected).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save attenuated backscatter
            pollySaveOCAttnBeta(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'wvmr_rh'
            print_msg('--> start saving water vapor products.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save water vapor mixing ratio and relative humidity
            pollySaveWV(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'voldepol'
            print_msg('--> start saving volume depolarization ratio.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save volume depolarization ratio
            data.vdr355 = vdr355;
            data.vdr532 = vdr532;
            pollySaveVDR(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'quasiv1'
            print_msg('--> start saving quasi-retrieved products (V1).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save quasi results (V1)
            pollySaveQsiV1(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'quasiv2'
            print_msg('--> start saving quasi-retrieved products (V2).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save quasi results (V2)
            pollySaveQsiV2(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'tc'
            print_msg('--> start saving aerosol/cloud target classification mask (V1).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save target classification results (V1)
            pollySaveTCV1(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'tcv2'
            print_msg('--> start saving aerosol/cloud target classification mask (V2).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save target classification results (V2)
            pollySaveTCV2(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        case 'cloudinfo'
            print_msg('--> start saving cloud mask.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            pollySaveCloudInfo(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

        otherwise
            warning('Unknow product %s', PollyConfig.prodSaveList{iProd});
        end
    end

    print_msg('Finish.\n', 'flagTimestamp', true);
end

%% Data visualization
if PicassoConfig.flagEnableDataVisualization

    % delete the previous outputs
    % This is only necessary when you run the code on the server, 
    % where the polly data was updated in time. If the 
    % previous outputs were not cleared, it will piled up to a huge amount.
    if PicassoConfig.flagDeletePreOutputs
        print_msg('Start deleting previous figures.\n', 'flagTimestamp', true);

        % search files associated with the same start time
        picFileList = listfile(fullfile(PicassoConfig.pic_folder, ...
                                     CampaignConfig.name, ...
                                     datestr(data.mTime(1), 'yyyy'), ...
                                     datestr(data.mTime(1), 'mm'), ...
                                     datestr(data.mTime(1), 'dd')), ...
                            sprintf('%s.*.png', rmext(PollyDataInfo.pollyDataFile)));

        % delete the files
        for iFile = 1:length(picFileList)
            delete(picFileList{iFile});
        end

        print_msg('Finish!\n', 'flagTimestamp', true);
    end

    print_msg('Start data visualization\n', 'flagTimestamp', true);

    %% diaplay monitor status
    print_msg('--> start diplaying lidar housekeeping data.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    pollyDisplayHousekeeping(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display range corrected signal
    print_msg('--> start displaying range corrected signal.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    pollyDisplayRCS(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display volume depolarization ratio
    print_msg('--> start displaying volume depolarization ratio.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    pollyDisplayVDR(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display polarization calibration results
    print_msg('--> start displaying polarization calibration results.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    data.polCali355Attri = polCali355Attri;
    data.polCali532Attri = polCali532Attri;
    pollyDisplayPolCali(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display signal status
    print_msg('--> start displaying signal status.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    pollyDisplaySigStatus(data);
    print_msg('--> finish.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

    %% display overlap function
    print_msg('--> start displaying overlap function.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    data.olFunc355 = olFunc355;
    data.olAttri355 = olAttri355;
    data.olFuncDeft355 = olFuncDeft355;
    data.olFunc532 = olFunc532;
    data.olAttri532 = olAttri532;
    data.olFuncDeft532 = olFuncDeft532;
    pollyDisplayOL(data);
    print_msg('--> finish.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

    %% display aerosol vertical profiles
    print_msg('--> start displaying vertical profiles.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayProfiles(data);
    pollyDisplayOCProfiles(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display attenuated backscatter
    print_msg('--> start displaying attenuated backscatter.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayAttnBsc(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display water vapor products
    print_msg('--> start displaying water vapor products.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayWV(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display quasi-retrieved products (V1)
    print_msg('--> start displaying quasi-retrieved products (V1).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayQsiV1(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display quasi-retrieved products (V2)
    print_msg('--> start displaying quasi-retrieved products (V2).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayQsiV2(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display aerosol/cloud target classification mask (V1)
    print_msg('--> start displaying aerosol/cloud target classification mask (V1).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayTCV1(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display aerosol/cloud target classification mask (V2)
    print_msg('--> start displaying aerosol/cloud target classification mask (V2).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayTCV2(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display lidar calibration constants
    print_msg('--> start display lidar calibration constants.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayLC(data);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    %% display long-term lidar calibration results
    print_msg('--> start displaying long-term lidar calibration results.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pollyDisplayLTLCali(data, dbFile);
    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);

    print_msg('Finish!\n', 'flagTimestamp', true);
end

%% Done filelist
if p.Results.flagDonefileList
    print_msg('Start writing done_filelist.\n', 'flagTimestamp', true);
    pollyWriteDonelist(data);
    print_msg('Finish.\n', 'flagTimestamp', true);
end

tEnd = now();
tUsage = (tEnd - tStart) * 24 * 3600;
report{end + 1} = tStart;
report{end + 1} = tUsage;
print_msg('\n%%------------------------------------------------------%%\n');
print_msg('Finish pollynet processing chain\n', 'flagTimestamp', true);
print_msg('%%------------------------------------------------------%%\n');

%% Clean
fclose(LogConfig.logFid);

%% Enable the usage of matlab toolbox
if PicassoConfig.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'enable');
    print_msg('Enable the usage of matlab statistics_toolbox\n', ...
              'flagSimpleMsg', true);
end

end