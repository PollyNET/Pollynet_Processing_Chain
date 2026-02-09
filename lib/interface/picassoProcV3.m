function [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile, varargin)
% PICASSOPROCV3 Picasso processing main program (Version 3.0).
%End changed to UNIX Line changed to LF
% USAGE:
%    % Usecase 1: process polly data
%    [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile)
%
%    % Usecase 2: process polly data and laserlogbook
%    [report] = picassoProcV3(pollyDataFile, pollyType, PicassoConfigFile, 'pollyLaserlogbook', pollyLaserlogbook)
%
% INPUTS:
%    pollyDataFile: char
%        absolute path of polly data.
%    pollyType: char
%        polly type.
%        - arielle
%        - Polly
%        - Polly_1V2
%        - PollyXT_CGE
%        - PollyXT_DWD
%        - PollyXT_FMI
%        - PollyXT_IFT
%        - PollyXT_LACROS
%        - PollyXT_NIER
%        - PollyXT_NOA
%        - PollyXT_TROPOS
%        - PollyXT_UW
%        - PollyXT_TJK
%        - PollyXT_TAU
%        - PollyXT_CYP
%    PicassoConfigFile: char
%        absolute path of Picasso configuration file.
%
% KEYWORDS:
%    defaultPicassoConfigFile: char
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
%
% OUTPUTS:
%    report: cell
%        processing report.
%
% HISTORY:
%    - 2021-06-25: first edition by Zhenping Yin
%    - 2023-06-06: Overlap function using Raman method was added by Cristofer Jimenez
%    - 2023-06-14: POLIPHON method (step 1) added by Athena Floutsi
%    - 2024-08-28: GHK formalism for depol calculation implemented by Moritz Haarig
%    - 2025-02-19: Smoothing added into meteo profiles, read all meteo data for HR products and interpolate, recalculation of signals using mean shot_number by Cristofer Jimenez 
%    - 2025-03-14: Compute and save attenuated backscatter co and cross polarized by Cristofer Jimenez
%    - 2026-02-09: POLIPHON step 2 added
%
% .. Authors: - zhenping@tropos.de, jimenez@tropos.de, floutsi@tropos.de, haarig@tropos.de

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
addParameter(p, 'defaultPicassoConfigFile', fullfile(PicassoDir, 'lib', 'config', 'pollynet_processing_chain_config.json'), @ischar);
addParameter(p, 'pollyGlobalConfigFile', fullfile(PicassoDir, 'lib', 'config', 'polly_global_config.json'), @ischar);
addParameter(p, 'pollyZipFile', '', @ischar);
addParameter(p, 'pollyZipFileSize', 0, @isnumeric);
addParameter(p, 'pollyLaserlogbook', '', @ischar);
addParameter(p, 'flagDonefileList', false, @islogical);

parse(p, pollyDataFile, pollyType, PicassoConfigFile, varargin{:});

%% Parameter initialization
defaultPicassoConfigFile = p.Results.defaultPicassoConfigFile;
pollyGlobalConfigFile = p.Results.pollyGlobalConfigFile;
report = cell(0);

%% Input check
if ~ exist('PicassoConfigFile', 'var')
    PicassoConfigFile = defaultPicassoConfigFile;
end

%% Set PollyDataInfo
PollyDataInfo.pollyType = pollyType;
PollyDataInfo.pollyDataFile = pollyDataFile;
PollyDataInfo.zipFile = p.Results.pollyZipFile;
PollyDataInfo.dataSize = p.Results.pollyZipFileSize;
disp(pollyDataFile)
disp(basename(pollyDataFile))
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
PicassoConfig = loadConfig(PicassoConfigFile, defaultPicassoConfigFile);
PicassoConfig.PicassoVersion = PicassoVersion;
PicassoConfig.PicassoRootDir = PicassoDir;

pollyGlobalConfigFile = PicassoConfig.polly_global_config;
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
            'dataFileFormat', PollyConfig.dataFileFormat, ...
            'deltaT', PollyConfig.deltaT);
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
data = pollyPreprocess(data, ...
            'deltaT', PollyConfig.deltaT, ...
            'flagForceMeasTime', PollyConfig.flagForceMeasTime, ...
            'maxHeightBin', PollyConfig.max_height_bin, ...
            'firstBinIndex', PollyConfig.first_range_gate_indx, ...
            'firstBinHeight', PollyConfig.first_range_gate_height, ...
            'pollyType', CampaignConfig.name, ...
            'flagDeadTimeCorrection', PollyConfig.flagDTCor, ...
            'deadtimeCorrectionMode', PollyConfig.dtCorMode, ...
            'deadtimeParams', PollyConfig.dt, ...
            'flagSigTempCor', PollyConfig.flagSigTempCor, ...
            'tempCorFunc', PollyConfig.tempCorFunc, ...
            'meteorDataSource', PollyConfig.meteorDataSource, ...
            'gdas1Site', PollyConfig.gdas1Site, ...
            'meteo_folder', PollyConfig.meteo_folder, ...
            'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
            'radiosondeFolder', PollyConfig.radiosondeFolder, ...
            'radiosondeType', PollyConfig.radiosondeType, ...
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
            'flag355nmRotRaman', data.flag355nmChannel & data.flagRotRamanChannel, ...
            'flag532nmRotRaman', data.flag532nmChannel & data.flagRotRamanChannel, ...
            'flag1064nmRotRaman', data.flag1064nmChannel & data.flagRotRamanChannel, ...
            'isUseLatestGDAS', PollyConfig.flagUseLatestGDAS);
print_msg('Finish.\n', 'flagTimestamp', true);

if isempty(data.signal) || (size(data.signal, 3) <= 1)
    warning('Empty or only 1 profile was remained after quality control!');
    return;
end

%% Saturation detection
print_msg('Start detecting signal saturation.\n', 'flagTimestamp', true);
flagSaturation = pollySaturationDetect(data, ...
    'hFullOverlap', PollyConfig.heightFullOverlap, ...
    'sigSaturateThresh', PollyConfig.saturate_thresh);
data.flagSaturation = flagSaturation;
print_msg('Finish.\n', 'flagTimestamp', true);
clearvars flagSaturation
%% Transmission ratios to GHK paramters
%Channel flags
flag355t = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel; 
flag355c = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel; 
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel; 
flag407 = data.flagFarRangeChannel & data.flag407nmChannel; 
flag532t = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel; 
flag532c = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel; 
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel; 
flag1064t = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel; 
flag1064c = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagCrossChannel;
flag532NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag532nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
flag355NR = data.flagNearRangeChannel & data.flagTotalChannel & data.flag355nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
flag355RR = data.flag355nmChannel & data.flagRotRamanChannel;
flag532RR = data.flag532nmChannel & data.flagRotRamanChannel;
flag1064RR = data.flag1064nmChannel & data.flagRotRamanChannel;

%%%% to be put in config file:
sigma_angstroem=0.2
MC_count=3;

if isempty(PollyConfig.H)
    print_msg('Using transmission ratios instead of GHK.\n', 'flagTimestamp', true);
    flagGHK = 0;
elseif (PollyConfig.H ~= -999) 
    print_msg('Using GHK from config file.\n', 'flagTimestamp', true);
    flagGHK = 1;
    if (PollyConfig.voldepol_error_355 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 355 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_355(1) = PollyDefaults.volDepolerror355; %assume a constant default value
        PollyConfig.voldepol_error_355(2) = 0.0;
        PollyConfig.voldepol_error_355(3) = 0.0;
    end
    if (PollyConfig.voldepol_error_532 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 532 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_532(1) = PollyDefaults.volDepolerror532; %assume a constant default value
        PollyConfig.voldepol_error_532(2) = 0.0;
        PollyConfig.voldepol_error_532(3) = 0.0;
    end
    if (PollyConfig.voldepol_error_1064 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 1064 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_1064(1) = PollyDefaults.volDepolerror1064; %assume a constant default value
        PollyConfig.voldepol_error_1064(2) = 0.0;
        PollyConfig.voldepol_error_1064(3) = 0.0;
    end
else
    print_msg('Calculating GHK from transmission ratios in config file.\n', 'flagTimestamp', true);
    PollyConfig.K(flag355t) = 1.0;
    PollyConfig.K(flag532t) = 1.0;  
    PollyConfig.K(flag1064t) = 1.0;
        
    PollyConfig.G(flag355t) = 1.0;
    PollyConfig.G(flag355c) = 1.0;
    PollyConfig.G(flag532t) = 1.0;
    PollyConfig.G(flag532c) = 1.0;    
    PollyConfig.G(flag1064t) = 1.0;
    PollyConfig.G(flag1064c) = 1.0;  

    PollyConfig.H(flag355t) = (1-PollyConfig.TR(flag355t))/(1+PollyConfig.TR(flag355t));
    PollyConfig.H(flag355c) = (1-PollyConfig.TR(flag355c))/(1+PollyConfig.TR(flag355c));
    PollyConfig.H(flag532t) = (1-PollyConfig.TR(flag532t))/(1+PollyConfig.TR(flag532t));
    PollyConfig.H(flag532c) = (1-PollyConfig.TR(flag532c))/(1+PollyConfig.TR(flag532c));    
    PollyConfig.H(flag1064t) = (1-PollyConfig.TR(flag1064t))/(1+PollyConfig.TR(flag1064t));
    PollyConfig.H(flag1064c) = (1-PollyConfig.TR(flag1064c))/(1+PollyConfig.TR(flag1064c));  
    flagGHK =1; 
    if (PollyConfig.voldepol_error_355 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 355 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_355(1) = PollyDefaults.volDepolerror355; %assume a constant default value
        PollyConfig.voldepol_error_355(2) = 0.0;
        PollyConfig.voldepol_error_355(3) = 0.0;
    end
    if (PollyConfig.voldepol_error_532 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 532 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_532(1) = PollyDefaults.volDepolerror532; %assume a constant default value
        PollyConfig.voldepol_error_532(2) = 0.0;
        PollyConfig.voldepol_error_532(3) = 0.0;
    end
    if (PollyConfig.voldepol_error_1064 == -999)
        print_msg('No info about uncertainty of volume depolarization ratio at 1064 nm, assuming constant default value.\n', 'flagTimestamp', true);
        PollyConfig.voldepol_error_1064(1) = PollyDefaults.volDepolerror1064; %assume a constant default value
        PollyConfig.voldepol_error_1064(2) = 0.0;
        PollyConfig.voldepol_error_1064(3) = 0.0;
    end
end
       
%% Polarization calibration
print_msg('Polarization calibration. \n', 'flagTimestamp', true);
data.polCaliFac355=NaN;
data.polCaliFac532=NaN;
data.polCaliFac1064=NaN;
if flagGHK
    if ~ PollyConfig.flagMolDepolCali
        print_msg('Start polarization calibration using GHK.\n', 'flagTimestamp', true);
        %355 nm
        if (any(flag355t)) && (any(flag355c))
            wavelength = '355nm';
            [data.polCaliEta355, data.polCaliEtaStd355, data.polCaliTime, data.polCali355Attri] = pollyPolCaliGHK(data, PollyConfig.K(flag355t), flag355t, flag355c,wavelength, ...
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
            'default_polCaliEta', PollyDefaults.polCaliEta355, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd355);
            %Taking the eta with lowest standard deviation
            [~, index_min] = min(data.polCali355Attri.polCaliEtaStd);
            data.polCaliEta355=data.polCali355Attri.polCaliEta(index_min);
            print_msg('Depol cali 355 etas: \n');
            disp(data.polCali355Attri.polCaliEta);
            print_msg('Depol Cali eta used355:\n');
            disp(data.polCaliEta355);
        else
            warning('Cross or total channel at 355 nm does not exist.');
            data.polCaliEta355=NaN;
            data.polCaliEtaStd355=NaN;
            data.polCaliTime=NaN;
            data.polCali355Attri.polCaliEta = data.polCaliEta355;  %
            data.polCali355Attri.polCaliEtaStd = data.polCaliEtaStd355;
        end
        if (any(flag532t)) && (any(flag532c))
            wavelength = '532nm';
            [data.polCaliEta532, data.polCaliEtaStd532, data.polCaliTime, data.polCali532Attri] = pollyPolCaliGHK(data, PollyConfig.K(flag532t), flag532t, flag532c, wavelength, ...
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
            'default_polCaliEta', PollyDefaults.polCaliEta532, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd532);
            %print_msg('eta532.\n', 'flagTimestamp', true);
            %data.polCaliEta532
            %Taking the eta with lowest standard deviation
            [~, index_min] = min(data.polCali532Attri.polCaliEtaStd);
            data.polCaliEta532=data.polCali532Attri.polCaliEta(index_min);
            print_msg('Depol cali 532 etas: \n');
            disp(data.polCali532Attri.polCaliEta);
            print_msg('Depol Cali eta used532:\n');
            disp(data.polCaliEta532);
        else
            warning('Cross or total channel at 532 nm does not exist.');
            data.polCaliEta532=NaN;
            data.polCaliEtaStd532=NaN;
            data.polCaliTime=NaN;
            data.polCali532Attri.polCaliEta = data.polCaliEta532;  %
            data.polCali532Attri.polCaliEtaStd = data.polCaliEtaStd532;
        end
        %print_msg('eta532.\n', 'flagTimestamp', true);
        %data.polCaliEta532
        if (any(flag1064t)) && (any(flag1064c))
            wavelength = '1064nm';
            [data.polCaliEta1064, data.polCaliEtaStd1064, data.polCaliTime, data.polCali1064Attri] = pollyPolCaliGHK(data, PollyConfig.K(flag1064t), flag1064t, flag1064c, wavelength, ...
            'depolCaliMinBin', PollyConfig.depol_cal_minbin_1064, ...
            'depolCaliMaxBin', PollyConfig.depol_cal_maxbin_1064, ...
            'depolCaliMinSNR', PollyConfig.depol_cal_SNRmin_1064, ...
            'depolCaliMaxSig', PollyConfig.depol_cal_sigMax_1064, ...
            'relStdDPlus', PollyConfig.rel_std_dplus_1064, ...
            'relStdDMinus', PollyConfig.rel_std_dminus_1064, ...
            'depolCaliSegLen', PollyConfig.depol_cal_segmentLen_1064, ...
            'depolCaliSmWin', PollyConfig.depol_cal_smoothWin_1064, ...
            'dbFile', dbFile, ...
            'pollyType', CampaignConfig.name, ...
            'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
            'flagDepolCali', PollyConfig.flagDepolCali, ...
            'default_polCaliEta', PollyDefaults.polCaliEta1064, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd1064);
            %Taking the eta with lowest standard deviation
            [~, index_min] = min(data.polCali1064Attri.polCaliEtaStd);
            data.polCaliEta1064=data.polCali1064Attri.polCaliEta(index_min);
            print_msg('Depol cali 1064 etas: \n');
            disp(data.polCali1064Attri.polCaliEta);
            print_msg('Depol Cali eta used1064:\n');
            disp(data.polCaliEta1064);
        else
            warning('Cross or total channel at 1064 nm does not exist.')
            data.polCaliEta1064=NaN;
            data.polCaliEtaStd1064=NaN;
            data.polCaliTime=NaN;
            data.polCali1064Attri.polCaliEta = data.polCaliEta1064;  %
            data.polCali1064Attri.polCaliEtaStd = data.polCaliEtaStd1064;
       end
    end
else
    if ~ PollyConfig.flagMolDepolCali
        print_msg('Start polarization calibration.\n', 'flagTimestamp', true);
        [data.polCaliEta355, data.polCaliEtaStd355, data.polCaliFac355, data.polCaliFacStd355, ~, data.polCali355Attri] = pollyPolCali(data, PollyConfig.TR, ...
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
            'default_polCaliEta', PollyDefaults.polCaliEta355, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd355);
        [data.polCaliEta532, data.polCaliEtaStd532, data.polCaliFac532, data.polCaliFacStd532, ~, data.polCali532Attri] = pollyPolCali(data, PollyConfig.TR, ...
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
            'default_polCaliEta', PollyDefaults.polCaliEta532, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd532);
        [data.polCaliEta1064, data.polCaliEtaStd1064, data.polCaliFac1064, data.polCaliFacStd1064, ~, data.polCali1064Attri] = pollyPolCali(data, PollyConfig.TR, ...
            'wavelength', '1064nm', ...
            'depolCaliMinBin', PollyConfig.depol_cal_minbin_1064, ...
            'depolCaliMaxBin', PollyConfig.depol_cal_maxbin_1064, ...
            'depolCaliMinSNR', PollyConfig.depol_cal_SNRmin_1064, ...
            'depolCaliMaxSig', PollyConfig.depol_cal_sigMax_1064, ...
            'relStdDPlus', PollyConfig.rel_std_dplus_1064, ...
            'relStdDMinus', PollyConfig.rel_std_dminus_1064, ...
            'depolCaliSegLen', PollyConfig.depol_cal_segmentLen_1064, ...
            'depolCaliSmWin', PollyConfig.depol_cal_smoothWin_1064, ...
            'dbFile', dbFile, ...
            'pollyType', CampaignConfig.name, ...
            'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
            'flagDepolCali', PollyConfig.flagDepolCali, ...
            'default_polCaliEta', PollyDefaults.polCaliEta1064, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd1064);
        print_msg('Finish.\n', 'flagTimestamp', true);
    end
end


%% Cloud screen
print_msg('Start cloud screening.\n', 'flagTimestamp', true);

PCRate = data.signal ./ repmat(reshape(data.mShots, size(data.mShots, 1), 1, []), ...
        1, size(data.signal, 2), 1) * 150 / data.hRes;
flagCloudFree = true(size(data.mTime));

if sum(flag532t) == 1
    % with only one far-range total channel at 532 nm
    [flagCloudFree_FR, cloudMask] = cloudScreen(data.mTime, data.height, ...
        squeeze(PCRate(flag532t, :, :)), ...
        'mode', PollyConfig.cloudScreenMode, ...
        'detectRange', [PollyConfig.heightFullOverlap(flag532t), 7000], ...
        'slope_thres', PollyConfig.maxSigSlope4FilterCloud, ...
        'background', squeeze(data.bg(flag532t, 1, :)), ...
        'heightFullOverlap', PollyConfig.heightFullOverlap(flag532t), ...
        'minSNR', 2);
end

if sum(flag532NR) == 1
    % with only one near-range total channel at 532 nm
    [flagCloudFree_NR, cloudMask] = cloudScreen(data.mTime, data.height, ...
        squeeze(PCRate(flag532NR, :, :)), ...
        'mode', PollyConfig.cloudScreenMode, ...
        'detectRange', [PollyConfig.heightFullOverlap(flag532NR), 2000], ...
        'slope_thres', PollyConfig.maxSigSlope4FilterCloud, ...
        'background', squeeze(data.bg(flag532NR, 1, :)), ...
        'heightFullOverlap', PollyConfig.heightFullOverlap(flag532NR), ...
        'minSNR', 2);
end
clearvars PCRate
if (sum(flag532t) == 1) && (sum(flag532NR) == 1)
    % combined cloud mask from near-range and far-range channels
    flagCloudFree = flagCloudFree_FR & flagCloudFree_NR & (~ data.shutterOnMask);
elseif (sum(flag532t) == 1)
    % cloud-mask from far-range channel
    flagCloudFree = flagCloudFree_FR & (~ data.shutterOnMask);
else
    print_msg('No cloud mask available\n', 'flagSimpleMsg', false);
end
print_msg('Finish.\n', 'flagTimestamp', true);



%% Cloud-free profiles segmentation
%%%%This is the part interesting for Georg!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_msg('Start cloud-free profiles segmentation.\n', 'flagTimestamp', true);

flagValPrf = flagCloudFree & (~ data.fogMask) & (~ data.depCalMask) & (~ data.shutterOnMask);
clFreGrps = clFreeSeg(flagValPrf, PollyConfig.intNProfiles, PollyConfig.minIntNProfiles);
data.clFreGrps = clFreGrps;
%%%%This is the part interesting for Georg end!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(clFreGrps)
    print_msg('No cloud-free groups were found.\n', 'flagSimpleMsg', true);
else
    print_msg('%d cloud-free groups were found.\n', 'flagSimpleMsg', true);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Meteorological data loading
print_msg('Start loading meteorological data.\n', 'flagTimestamp', true);

clFreGrpTimes = nanmean(data.mTime(clFreGrps), 2);
[temp, pres, relh, ~, ~, data.meteorAttri] = loadMeteor(clFreGrpTimes, data.alt, ...
    'meteorDataSource', PollyConfig.meteorDataSource, ...
    'gdas1Site', PollyConfig.gdas1Site, ...
    'meteo_folder', PollyConfig.meteo_folder, ...
    'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
    'radiosondeFolder', PollyConfig.radiosondeFolder, ...
    'radiosondeType', PollyConfig.radiosondeType, ...
    'method', 'linear', ...
    'isUseLatestGDAS', PollyConfig.flagUseLatestGDAS);
data.temperature = temp;
data.pressure = pres;
data.relh = relh;
%data.meteorAttri = meteorAttri;

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

%% Calculate molecular scattering properties
for iGrp = 1:size(clFreGrps, 1)
        [mBsc355(iGrp,:), mExt355(iGrp,:)] = rayleigh_scattering(355,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc387(iGrp,:), mExt387(iGrp,:)] = rayleigh_scattering(387,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc407(iGrp,:), mExt407(iGrp,:)] = rayleigh_scattering(407,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc532(iGrp,:), mExt532(iGrp,:)] = rayleigh_scattering(532,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc607(iGrp,:), mExt607(iGrp,:)] = rayleigh_scattering(607,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc1058(iGrp,:), mExt1058(iGrp,:)] = rayleigh_scattering(1058,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        [mBsc1064(iGrp,:), mExt1064(iGrp,:)] = rayleigh_scattering(1064,  data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15, 380, 70);
        number_density(iGrp,:) = number_density_at_pt(data.pressure(iGrp, :), data.temperature(iGrp, :)+ 273.15, 70, true);
        data.molBsc355(iGrp,:)= mBsc355(iGrp,:);
        data.molBsc532(iGrp,:)= mBsc532(iGrp,:);
        data.molBsc1064(iGrp,:)= mBsc1064(iGrp,:);
end


%% Rayleigh fitting

print_msg('Start Rayleigh fitting.\n', 'flagTimestamp', true);
data.refHInd355 = [];   % reference height range at 355 nm
data.refHInd532 = [];   % reference height range at 532 nm
data.refHInd1064 = [];   % reference height range at 1064 nm
DPInd355 = {};   % points decomposed by Douglas-Peucker method at 355 nm
DPInd532 = {};   % points decomposed by Douglas-Peucker method at 532 nm
DPInd1064 = {};   % points decomposed by Douglas-Peucker method at 1064 nm

for iGrp = 1:size(clFreGrps, 1)

    tInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
    
    % 532 nm
    if (sum(flag532t) == 1) && (~ PollyConfig.flagUseManualRefH)
        sig532 = squeeze(sum(data.signal(flag532t, :, tInd), 3));   % photon count
        bg532 = squeeze(sum(data.bg(flag532t, :, tInd), 3));
        nShots532 = nansum(data.mShots(flag532t, tInd), 2);
        pcr532 = sig532 / nShots532 * (150 / data.hRes);

        % Rayleigh scattering
        mSig532 = mBsc532(iGrp,:) .* exp(-2 * cumsum(mExt532(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));

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
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag532t), ...
            'flagSameRef', false, ...
            'defaultRefH', [NaN, NaN], 'defaultDPInd', []);
    elseif PollyConfig.flagUseManualRefH
        % use pre-defined reference height
        if length(PollyConfig.refH_FR_532) == 2
            refBaseIdx = find(data.height >= PollyConfig.refH_FR_532(1), 1);
            refTopIdx = find(data.height >= PollyConfig.refH_FR_532(2), 1);

            if (isempty(refBaseIdx) || isempty(refTopIdx))
                warning('refH_FR_532 is out of range.');
                thisRefH532 = [NaN, NaN];
            else
                thisRefH532 = [refBaseIdx, refTopIdx];
            end
            thisDPInd532 = [];
        else
            warning('refH_FR_532 should be 2-element array');
            thisRefH532 = [NaN, NaN];
            thisDPInd532 = [];
        end
    else
        thisRefH532 = [NaN, NaN];
        thisDPInd532 = [];
    end

    % 355 nm
    if (sum(flag355t) == 1) && (~ PollyConfig.flagUseManualRefH)
        sig355 = squeeze(sum(data.signal(flag355t, :, tInd), 3));   % photon count
        bg355 = squeeze(sum(data.bg(flag355t, :, tInd), 3));
        nShots355 = nansum(data.mShots(flag355t, tInd), 2);
        pcr355 = sig355 / nShots355 * (150 / data.hRes);

        % Rayleigh scattering
        mSig355 = mBsc355(iGrp,:) .* exp(-2 * cumsum(mExt355(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));

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
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag355t), ...
            'flagSameRef', PollyConfig.flagUseSameRefH, ...
            'defaultRefH', thisRefH532, 'defaultDPInd', thisDPInd532);
    elseif PollyConfig.flagUseManualRefH
        % use pre-defined reference height
        if length(PollyConfig.refH_FR_355) == 2
            refBaseIdx = find(data.height >= PollyConfig.refH_FR_355(1), 1);
            refTopIdx = find(data.height >= PollyConfig.refH_FR_355(2), 1);

            if (isempty(refBaseIdx) || isempty(refTopIdx))
                warning('refH_FR_355 is out of range.');
                thisRefH355 = [NaN, NaN];
            else
                thisRefH355 = [refBaseIdx, refTopIdx];
            end
            thisDPInd355 = [];
        else
            warning('refH_FR_355 should be 2-element array');
            thisRefH355 = [NaN, NaN];
            thisDPInd355 = [];
        end
    else
        thisRefH355 = [NaN, NaN];
        thisDPInd355 = [];
    end

    % 1064 nm
    if (sum(flag1064t) == 1) && (~ PollyConfig.flagUseManualRefH)
        sig1064 = squeeze(sum(data.signal(flag1064t, :, tInd), 3));   % photon count
        bg1064 = squeeze(sum(data.bg(flag1064t, :, tInd), 3));
        nShots1064 = nansum(data.mShots(flag1064t, tInd), 2);
        pcr1064 = sig1064 / nShots1064 * (150 / data.hRes);

        % Rayleigh scattering
        mSig1064 = mBsc1064(iGrp,:) .* exp(-2 * cumsum(mExt1064(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));

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
            'heightFullOverlap', PollyConfig.heightFullOverlap(flag1064t), ...
            'flagSameRef', PollyConfig.flagUseSameRefH, ...
            'defaultRefH', thisRefH532, 'defaultDPInd', thisDPInd532);
    elseif PollyConfig.flagUseManualRefH
        % use pre-defined reference height
        if length(PollyConfig.refH_FR_1064) == 2
            refBaseIdx = find(data.height >= PollyConfig.refH_FR_1064(1), 1);
            refTopIdx = find(data.height >= PollyConfig.refH_FR_1064(2), 1);

            if (isempty(refBaseIdx) || isempty(refTopIdx))
                warning('refH_FR_1064 is out of range.');
                thisRefH1064 = [NaN, NaN];
            else
                thisRefH1064 = [refBaseIdx, refTopIdx];
            end
            thisDPInd1064 = [];
        else
            warning('refH_FR_1064 should be 2-element array');
            thisRefH1064 = [NaN, NaN];
            thisDPInd1064 = [];
        end
    else
        thisRefH1064 = [NaN, NaN];
        thisDPInd1064 = [];
    end

    data.refHInd355 = cat(1, data.refHInd355, thisRefH355);
    data.refHInd532 = cat(1, data.refHInd532, thisRefH532);
    data.refHInd1064 = cat(1, data.refHInd1064, thisRefH1064);
    DPInd355 = cat(2, DPInd355, thisDPInd355);
    DPInd532 = cat(2, DPInd532, thisDPInd532);
    DPInd1064 = cat(2, DPInd1064, thisDPInd1064);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Polarization calibration with reference signal from molecule
if PollyConfig.flagMolDepolCali
    print_msg('Start polarization calibration with molecule signal.\n', 'flagTimestamp', true);

    % 355 nm
    data.polCaliEta355 = [];
    data.polCaliEtaStd355 = [];
    data.polCaliFac355 = [];
    data.polCaliFacStd355 = [];
    polCaliStartTime = [];
    polCaliStopTime = [];
    data.polCali355Attri = struct();
    for iGrp = 1:size(data.clFreGrps, 1)
        prfInd = data.clFreGrps(iGrp, 1):data.clFreGrps(iGrp, 2);
        if (sum(flag355t) ~= 1) || (sum(flag355c) ~= 1) || (isnan(data.refHInd355(iGrp, 1)))
            continue;
        end

        sig355T = squeeze(sum(data.signal(flag355t, :, prfInd), 3));
        bg355T = squeeze(sum(data.bg(flag355t, :, prfInd), 3));
        sig355C = squeeze(sum(data.signal(flag355c, :, prfInd), 3));
        bg355C = squeeze(sum(data.bg(flag355c, :, prfInd), 3));

        refHIndArr = data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2);
        [thisPolCaliEta, thisPolCaliEtaStd, thisPolCaliFac, thisPolCaliFacStd] = pollyMolPolCali(sig355T(refHIndArr), ...
            bg355T(refHIndArr), sig355C(refHIndArr), bg355C(refHIndArr), PollyConfig.TR(flag355t), 0, PollyConfig.TR(flag355c), 0, 10, PollyDefaults.molDepol355, PollyDefaults.molDepolStd355);

        data.polCaliEta355 = cat(2, data.polCaliEta355, thisPolCaliEta);
        data.polCaliEtaStd355 = cat(2, data.polCaliEtaStd355, thisPolCaliEtaStd);
        data.polCaliFac355 = cat(2, data.polCaliFac355, thisPolCaliFac);
        data.polCaliFacStd355 = cat(2, data.polCaliFacStd355, thisPolCaliFacStd);
        polCaliStartTime = cat(2, polCaliStartTime, data.mTime(prfInd(1)));
        polCaliStopTime = cat(2, polCaliStopTime, data.mTime(prfInd(end)));
    end

    data.polCali355Attri.polCaliEta = data.polCaliEta355;
    data.polCali355Attri.polCaliEtaStd = data.polCaliEtaStd355;
    data.polCali355Attri.polCaliFac = data.polCaliFac355;
    data.polCali355Attri.polCaliFacStd = data.polCaliFacStd355;
    data.polCali355Attri.polCaliStartTime = polCaliStartTime;
    data.polCali355Attri.polCaliStopTime = polCaliStopTime;

    % determine the most suitable polarization calibration factor
    if exist(dbFile, 'file') == 2
        [data.polCaliEta355, data.polCaliEtaStd355, ~, ~] = selectDepolConst(...
            data.polCaliEta355, data.polCaliEtaStd355, ...
            polCaliStartTime, polCaliStopTime, ...
            mean(data.mTime), dbFile, CampaignConfig.name, '355', ...
            'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
            'flagDepolCali', PollyConfig.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', PollyDefaults.polCaliEta355, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd355);
        data.polCaliFac355 = (1 + PollyConfig.TR(flag355t)) ./ (1 + PollyConfig.TR(flag355c)) * data.polCaliEta355;
        data.polCaliFacStd355 = (1 + PollyConfig.TR(flag355t)) ./ (1 + PollyConfig.TR(flag355c)) * data.polCaliEtaStd355;
    else
        data.polCaliEta355 = PollyDefaults.polCaliEta355;
        data.polCaliEtaStd355 = PollyDefaults.polCaliEtaStd355;
        data.polCaliFac355 = (1 + PollyConfig.TR(flag355t)) ./ (1 + PollyConfig.TR(flag355c)) * data.polCaliEta355;
        data.polCaliFacStd355 = (1 + PollyConfig.TR(flag355t)) ./ (1 + PollyConfig.TR(flag355c)) * data.polCaliEtaStd355;
    end

    % 532 nm
    data.polCaliEta532 = [];
    data.polCaliEtaStd532 = [];
    data.polCaliFac532 = [];
    data.polCaliFacStd532 = [];
    polCaliStartTime = [];
    polCaliStopTime = [];
    data.polCali532Attri = struct();
    for iGrp = 1:size(data.clFreGrps, 1)
        prfInd = data.clFreGrps(iGrp, 1):data.clFreGrps(iGrp, 2);

        if (sum(flag532t) ~= 1) || (sum(flag532c) ~= 1) || (isnan(data.refHInd532(iGrp, 1)))
            continue;
        end

        sig532T = squeeze(sum(data.signal(flag532t, :, prfInd), 3));
        bg532T = squeeze(sum(data.bg(flag532t, :, prfInd), 3));
        sig532C = squeeze(sum(data.signal(flag532c, :, prfInd), 3));
        bg532C = squeeze(sum(data.bg(flag532c, :, prfInd), 3));

        refHIndArr = data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2);
        [thisPolCaliEta, thisPolCaliEtaStd, thisPolCaliFac, thisPolCaliFacStd] = pollyMolPolCali(sig532T(refHIndArr), ...
            bg532T(refHIndArr), sig532C(refHIndArr), bg532C(refHIndArr), PollyConfig.TR(flag532t), 0, PollyConfig.TR(flag532c), 0, 10, PollyDefaults.molDepol532, PollyDefaults.molDepolStd532);

        data.polCaliEta532 = cat(2, data.polCaliEta532, thisPolCaliEta);
        data.polCaliEtaStd532 = cat(2, data.polCaliEtaStd532, thisPolCaliEtaStd);
        data.polCaliFac532 = cat(2, data.polCaliFac532, thisPolCaliFac);
        data.polCaliFacStd532 = cat(2, data.polCaliFacStd532, thisPolCaliFacStd);
        polCaliStartTime = cat(2, polCaliStartTime, data.mTime(prfInd(1)));
        polCaliStopTime = cat(2, polCaliStopTime, data.mTime(prfInd(end)));
    end

    data.polCali532Attri.polCaliEta = data.polCaliEta532;
    data.polCali532Attri.polCaliEtaStd = data.polCaliEtaStd532;
    data.polCali532Attri.polCaliFac = data.polCaliFac532;
    data.polCali532Attri.polCaliFacStd = data.polCaliFacStd532;
    data.polCali532Attri.polCaliStartTime = polCaliStartTime;
    data.polCali532Attri.polCaliStopTime = polCaliStopTime;

    % determine the most suitable polarization calibration factor
    if exist(dbFile, 'file') == 2
        [data.polCaliEta532, data.polCaliEtaStd532, ~, ~] = selectDepolConst(...
            data.polCaliEta532, data.polCaliEtaStd532, ...
            polCaliStartTime, polCaliStopTime, ...
            mean(data.mTime), dbFile, CampaignConfig.name, '532', ...
            'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
            'flagDepolCali', PollyConfig.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', PollyDefaults.polCaliEta532, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd532);
        data.polCaliFac532 = (1 + PollyConfig.TR(flag532t)) ./ (1 + PollyConfig.TR(flag532c)) * data.polCaliEta532;
        data.polCaliFacStd532 = (1 + PollyConfig.TR(flag532t)) ./ (1 + PollyConfig.TR(flag532c)) * data.polCaliEtaStd532;
    else
        data.polCaliEta532 = PollyDefaults.polCaliEta532;
        data.polCaliEtaStd532 = PollyDefaults.polCaliEtaStd532;
        data.polCaliFac532 = (1 + PollyConfig.TR(flag532t)) ./ (1 + PollyConfig.TR(flag532c)) * data.polCaliEta532;
        data.polCaliFacStd532 = (1 + PollyConfig.TR(flag532t)) ./ (1 + PollyConfig.TR(flag532c)) * data.polCaliEtaStd532;
    end

    % 1064 nm
    data.polCaliEta1064 = [];
    data.polCaliEtaStd1064 = [];
    data.polCaliFac1064 = [];
    data.polCaliFacStd1064 = [];
    polCaliStartTime = [];
    polCaliStopTime = [];
    data.polCali1064Attri = struct();
    for iGrp = 1:size(data.clFreGrps, 1)
        prfInd = data.clFreGrps(iGrp, 1):data.clFreGrps(iGrp, 2);
        if (sum(flag1064t) ~= 1) || (sum(flag1064c) ~= 1) || (isnan(data.refHInd1064(iGrp, 1)))
            continue;
        end

        sig1064T = squeeze(sum(data.signal(flag1064t, :, prfInd), 3));
        bg1064T = squeeze(sum(data.bg(flag1064t, :, prfInd), 3));
        sig1064C = squeeze(sum(data.signal(flag1064c, :, prfInd), 3));
        bg1064C = squeeze(sum(data.bg(flag1064c, :, prfInd), 3));

        refHIndArr = data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2);
        [thisPolCaliEta, thisPolCaliEtaStd, thisPolCaliFac, thisPolCaliFacStd] = pollyMolPolCali(sig1064T(refHIndArr), ...
            bg1064T(refHIndArr), sig1064C(refHIndArr), bg1064C(refHIndArr), PollyConfig.TR(flag1064t), 0, PollyConfig.TR(flag1064c), 0, 10, PollyDefaults.molDepol1064, PollyDefaults.molDepolStd1064);

        data.polCaliEta1064 = cat(2, data.polCaliEta1064, thisPolCaliEta);
        data.polCaliEtaStd1064 = cat(2, data.polCaliEtaStd1064, thisPolCaliEtaStd);
        data.polCaliFac1064 = cat(2, data.polCaliFac1064, thisPolCaliFac);
        data.polCaliFacStd1064 = cat(2, data.polCaliFacStd1064, thisPolCaliFacStd);
        polCaliStartTime = cat(2, polCaliStartTime, data.mTime(prfInd(1)));
        polCaliStopTime = cat(2, polCaliStopTime, data.mTime(prfInd(end)));
    end
%%%%can be maybe deleted
    data.polCali1064Attri.polCaliEta = data.polCaliEta1064;  %
    data.polCali1064Attri.polCaliEtaStd = data.polCaliEtaStd1064;
    data.polCali1064Attri.polCaliFac = data.polCaliFac1064;
    data.polCali1064Attri.polCaliFacStd = data.polCaliFacStd1064;
%%%%end
    data.polCali1064Attri.polCaliStartTime = polCaliStartTime;
    data.polCali1064Attri.polCaliStopTime = polCaliStopTime;

    % determine the most suitable polarization calibration factor
    if exist(dbFile, 'file') == 2
        [data.polCaliEta1064, data.polCaliEtaStd1064, ~, ~] = selectDepolConst(...
            data.polCaliEta1064, data.polCaliEtaStd1064, ...
            polCaliStartTime, polCaliStopTime, ...
            mean(data.mTime), dbFile, CampaignConfig.name, '1064', ...
            'flagUsePrevDepolConst', PollyConfig.flagUsePreviousDepolCali, ...
            'flagDepolCali', PollyConfig.flagDepolCali, ...
            'deltaTime', datenum(0, 1, 7), ...
            'default_polCaliEta', PollyDefaults.polCaliEta1064, ...
            'default_polCaliEtaStd', PollyDefaults.polCaliEtaStd1064);
        data.polCaliFac1064 = (1 + PollyConfig.TR(flag1064t)) ./ (1 + PollyConfig.TR(flag1064c)) * data.polCaliEta1064;
        data.polCaliFacStd1064 = (1 + PollyConfig.TR(flag1064t)) ./ (1 + PollyConfig.TR(flag1064c)) * data.polCaliEtaStd1064;
    else
        data.polCaliEta1064 = PollyDefaults.polCaliEta1064;
        data.polCaliEtaStd1064 = PollyDefaults.polCaliEtaStd1064;
        data.polCaliFac1064 = (1 + PollyConfig.TR(flag1064t)) ./ (1 + PollyConfig.TR(flag1064c)) * data.polCaliEta1064;
        data.polCaliFacStd1064 = (1 + PollyConfig.TR(flag1064t)) ./ (1 + PollyConfig.TR(flag1064c)) * data.polCaliEtaStd1064;
    end

    print_msg('Finish.\n', 'flagTimestamp', true);
end
    
%% Lidar retrievals for aerosol optical properties
print_msg('Start retrieving aerosol optical properties.\n', 'flagTimestamp', true);

meteorStr = '';
for iMeteor = 1:length(data.meteorAttri.dataSource)
    meteorStr = cat(2, meteorStr, ' ', data.meteorAttri.dataSource{iMeteor});
end

print_msg(sprintf('Meteorological file : %s.\n', meteorStr), 'flagSimpleMsg', true);

%% Transmission correction
if flagGHK
     % 355 nm
     if (sum(flag355t) == 1) && (sum(flag355c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el355, bgEl355] = transCorGHK(squeeze(data.signal(flag355t, :, :)), ...
            squeeze(data.bg(flag355t, :, :)), ...
            squeeze(data.signal(flag355c, :, :)), ...
            squeeze(data.bg(flag355c, :, :)), ...
            'transGT', PollyConfig.G(flag355t), ...
            'transGR', PollyConfig.G(flag355c),...
            'transHT', PollyConfig.H(flag355t), ...
            'transHR', PollyConfig.H(flag355c), ...
            'polCaliEta', data.polCaliEta355, ...
            'polCaliEtaStd', data.polCali355Attri.polCaliEtaStd );
    elseif (sum(flag355t) == 1) && (sum(flag355c ~= 1))
        % disable transmission correction
        el355 = squeeze(data.signal(flag355t, :, :));
        bgEl355 = squeeze(data.bg(flag355t, :, :));
    else
        el355 = [];
        bgEl355 = [];
     end
     %532 nm
     if (sum(flag532t) == 1) && (sum(flag532c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el532, bgEl532] = transCorGHK(squeeze(data.signal(flag532t, :, :)), ...
            squeeze(data.bg(flag532t, :, :)), ...
            squeeze(data.signal(flag532c, :, :)), ...
            squeeze(data.bg(flag532c, :, :)), ...
            'transGT', PollyConfig.G(flag532t), ...
            'transGR', PollyConfig.G(flag532c),...
            'transHT', PollyConfig.H(flag532t), ...
            'transHR', PollyConfig.H(flag532c), ...
            'polCaliEta', data.polCaliEta532, ...
            'polCaliEtaStd', data.polCali532Attri.polCaliEtaStd);
    elseif (sum(flag532t) == 1) && (sum(flag532c ~= 1))
        % disable transmission correction
        el532 = squeeze(data.signal(flag532t, :, :));
        bgEl532 = squeeze(data.bg(flag532t, :, :));
    else
        el532 = [];
        bgEl532 = [];
     end
    
     % 1064 nm
     if (sum(flag1064t) == 1) && (sum(flag1064c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el1064, bgEl1064] = transCorGHK(squeeze(data.signal(flag1064t, :, :)), ...
            squeeze(data.bg(flag1064t, :, :)), ...
            squeeze(data.signal(flag1064c, :, :)), ...
            squeeze(data.bg(flag1064c, :, :)), ...
            'transGT', PollyConfig.G(flag1064t), ...
            'transGR', PollyConfig.G(flag1064c),...
            'transHT', PollyConfig.H(flag1064t), ...
            'transHR', PollyConfig.H(flag1064c), ...
            'polCaliEta', data.polCaliEta1064, ...
            'polCaliEtaStd', data.polCali1064Attri.polCaliEtaStd);
    elseif (sum(flag1064t) == 1) && (sum(flag1064c ~= 1))
        % disable transmission correction
        el1064 = squeeze(data.signal(flag1064t, :, :));
        bgEl1064 = squeeze(data.bg(flag1064t, :, :));
    else
        el1064 = [];
        bgEl1064 = [];
    end
else

    if (sum(flag355t) == 1) && (sum(flag355c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el355, bgEl355] = transCor(squeeze(data.signal(flag355t, :, :)), ...
            squeeze(data.bg(flag355t, :, :)), ...
            squeeze(data.signal(flag355c, :, :)), ...
            squeeze(data.bg(flag355c, :, :)), ...
            'transRatioTotal', PollyConfig.TR(flag355t), ...
            'transRatioTotalStd', 0, ...
            'transRatioCross', PollyConfig.TR(flag355c), ...
            'transRatioCrossStd', 0, ...
            'polCaliFactor', data.polCaliFac355, ...
            'polCaliFacStd', data.polCaliFacStd355);
    elseif (sum(flag355t) == 1) && (sum(flag355c ~= 1))
        % disable transmission correction
        el355 = squeeze(data.signal(flag355t, :, :));
        bgEl355 = squeeze(data.bg(flag355t, :, :));
    else
        el355 = [];
        bgEl355 = [];
    end

    %% Transmission correction at 532 nm
    if (sum(flag532t) == 1) && (sum(flag532c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el532, bgEl532] = transCor(squeeze(data.signal(flag532t, :, :)), ...
            squeeze(data.bg(flag532t, :, :)), ...
            squeeze(data.signal(flag532c, :, :)), ...
            squeeze(data.bg(flag532c, :, :)), ...
            'transRatioTotal', PollyConfig.TR(flag532t), ...
            'transRatioTotalStd', 0, ...
            'transRatioCross', PollyConfig.TR(flag532c), ...
            'transRatioCrossStd', 0, ...
            'polCaliFactor', data.polCaliFac532, ...
            'polCaliFacStd', data.polCaliFacStd532);
    elseif (sum(flag532t) == 1) && (sum(flag532c ~= 1))
        % disable transmission correction
        el532 = squeeze(data.signal(flag532t, :, :));
        bgEl532 = squeeze(data.bg(flag532t, :, :));
    else
        el532 = [];
        bgEl532 = [];
    end

    %% Transmission correction at 1064 nm
   

    if (sum(flag1064t) == 1) && (sum(flag1064c) == 1) && PollyConfig.flagTransCor
        % transmission correction
        [el1064, bgEl1064] = transCor(squeeze(data.signal(flag1064t, :, :)), ...
            squeeze(data.bg(flag1064t, :, :)), ...
            squeeze(data.signal(flag1064c, :, :)), ...
            squeeze(data.bg(flag1064c, :, :)), ...
            'transRatioTotal', PollyConfig.TR(flag1064t), ...
            'transRatioTotalStd', 0, ...
            'transRatioCross', PollyConfig.TR(flag1064c), ...
            'transRatioCrossStd', 0, ...
            'polCaliFactor', data.polCaliFac1064, ...
            'polCaliFacStd', data.polCaliFacStd1064);
    elseif (sum(flag1064t) == 1) && (sum(flag1064c ~= 1))
        % disable transmission correction
        el1064 = squeeze(data.signal(flag1064t, :, :));
        bgEl1064 = squeeze(data.bg(flag1064t, :, :));
    else
        el1064 = [];
        bgEl1064 = [];
    end
end
%% Klett method at 355 nm

data.aerBsc355_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd355(iGrp, 1)) || (sum(flag355t) ~= 1)
        continue;
    end

    sig355 = transpose(squeeze(sum(el355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg355 = transpose(squeeze(sum(bgEl355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];
    
    [thisAerBsc355_klett, thisAerBscStd355_klett] = pollyFernald(data.distance0, sig355, bg355, PollyConfig.LR355, refH355, PollyConfig.refBeta355, mBsc355(iGrp,:), PollyConfig.smoothWin_klett_355);
    thisAerExt355_klett = PollyConfig.LR355 * thisAerBsc355_klett;
    thisAerExtStd355_klett = PollyConfig.LR355 * thisAerBscStd355_klett;

    data.aerBsc355_klett(iGrp, :) = thisAerBsc355_klett;
    data.aerBscStd355_klett(iGrp, :) = thisAerBscStd355_klett;
    data.aerExt355_klett(iGrp, :) = thisAerExt355_klett;
    data.aerExtStd355_klett(iGrp, :) = thisAerExtStd355_klett;
end

%% Klett method at 532 nm
data.aerBsc532_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd532(iGrp, 1)) || (sum(flag532t) ~= 1)
        continue;
    end

    sig532 = transpose(squeeze(sum(el532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg532 = transpose(squeeze(sum(bgEl532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];
    
    [thisAerBsc532_klett, thisAerBscStd532_klett] = pollyFernald(data.distance0, sig532, bg532, PollyConfig.LR532, refH532, PollyConfig.refBeta532, mBsc532(iGrp,:), PollyConfig.smoothWin_klett_532);
    thisAerExt532_klett = PollyConfig.LR532 * thisAerBsc532_klett;
    thisAerExtStd532_klett = PollyConfig.LR532 * thisAerBscStd532_klett;

    data.aerBsc532_klett(iGrp, :) = thisAerBsc532_klett;
    data.aerBscStd532_klett(iGrp, :) = thisAerBscStd532_klett;
    data.aerExt532_klett(iGrp, :) = thisAerExt532_klett;
    data.aerExtStd532_klett(iGrp, :) = thisAerExtStd532_klett;
end

%% Klett method at 1064 nm
data.aerBsc1064_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd1064(iGrp, 1)) || (sum(flag1064t) ~= 1)
        continue;
    end

    sig1064 = transpose(squeeze(sum(el1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg1064 = transpose(squeeze(sum(bgEl1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
   
    [thisAerBsc1064_klett, thisAerBscStd1064_klett] = pollyFernald(data.distance0, sig1064, bg1064, PollyConfig.LR1064, refH1064, PollyConfig.refBeta1064, mBsc1064(iGrp,:), PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_klett = PollyConfig.LR1064 * thisAerBsc1064_klett;
    thisAerExtStd1064_klett = PollyConfig.LR1064 * thisAerBscStd1064_klett;

    data.aerBsc1064_klett(iGrp, :) = thisAerBsc1064_klett;
    data.aerBscStd1064_klett(iGrp, :) = thisAerBscStd1064_klett;
    data.aerExt1064_klett(iGrp, :) = thisAerExt1064_klett;
    data.aerExtStd1064_klett(iGrp, :) = thisAerExtStd1064_klett;
end

%% Klett method at 355 nm (near-field)
data.aerBsc355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.refBeta_NR_355_klett = NaN(1, size(clFreGrps, 1));
refH355 = PollyConfig.refH_NR_355;

for iGrp = 1:size(clFreGrps, 1)

    % determine the existence of near-field data
    if isnan(data.refHInd355(iGrp, 1)) || (sum(flag355NR) ~= 1)
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
    else
        refBeta355 = mean(data.aerBsc355_klett(iGrp, refHBaseInd355:refHTopInd355), 2); %here the refereence value is calculated from the far field

        [thisAerBsc355_NR_klett, thisAerBscStd355_NR_klett] = pollyFernald(data.distance0, sig355, bg355, PollyConfig.LR_NR_355, refH355, refBeta355, mBsc355(iGrp,:), PollyConfig.smoothWin_klett_NR_355);
        thisAerExt355_NR_klett = PollyConfig.LR_NR_355 * thisAerBsc355_NR_klett;
        thisAerExtStd355_NR_klett = PollyConfig.LR_NR_355 * thisAerBscStd355_NR_klett;

        data.aerBsc355_NR_klett(iGrp, :) = thisAerBsc355_NR_klett;
        data.aerBscStd355_NR_klett(iGrp, :) = thisAerBscStd355_NR_klett;
        data.aerExt355_NR_klett(iGrp, :) = thisAerExt355_NR_klett;
        data.aerExtStd355_NR_klett(iGrp, :) = thisAerExtStd355_NR_klett;
        data.refBeta_NR_355_klett(iGrp) = refBeta355;
    end
end

%% Klett method at 532 nm (near-field)
data.aerBsc532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.refBeta_NR_532_klett = NaN(1, size(clFreGrps, 1));
refH532 = PollyConfig.refH_NR_532;

for iGrp = 1:size(clFreGrps, 1)

    % determine the existence of near-field data
    if isnan(data.refHInd532(iGrp, 1)) || (sum(flag532NR) ~= 1)
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
    else
        refBeta532 = mean(data.aerBsc532_klett(iGrp, refHBaseInd532:refHTopInd532), 2);%here the refereence value is calculated from the far field

        [thisAerBsc532_NR_klett, thisAerBscStd532_NR_klett] = pollyFernald(data.distance0, sig532, bg532, PollyConfig.LR_NR_532, refH532, refBeta532, mBsc532(iGrp,:), PollyConfig.smoothWin_klett_NR_532);
        thisAerExt532_NR_klett = PollyConfig.LR_NR_532 * thisAerBsc532_NR_klett;
        thisAerExtStd532_NR_klett = PollyConfig.LR_NR_532 * thisAerBscStd532_NR_klett;

        data.aerBsc532_NR_klett(iGrp, :) = thisAerBsc532_NR_klett;
        data.aerBscStd532_NR_klett(iGrp, :) = thisAerBscStd532_NR_klett;
        data.aerExt532_NR_klett(iGrp, :) = thisAerExt532_NR_klett;
        data.aerExtStd532_NR_klett(iGrp, :) = thisAerExtStd532_NR_klett;
        data.refBeta_NR_532_klett(iGrp) = refBeta532;
    end
end



%% Constrained-AOD Klett method at 355 nm (far-field)
data.aerBsc355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.LR355_aeronet = NaN(size(clFreGrps, 1), 1);
data.deltaAOD355 = NaN(size(clFreGrps, 1), 1);
for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd355(iGrp, 1)) || (sum(flag355t) ~= 1)
        continue;
    end

    sig355 = squeeze(sum(el355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg355 = squeeze(sum(bgEl355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR355 = pollySNR(sig355, bg355);
    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];
    
    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_355_aeronet = interp_AERONET_AOD(340, AERONET.AOD_340(AERONETInd), 380, AERONET.AOD_380(AERONETInd), 355);

    % constrained Klett method
    [thisAerBsc355_aeronet, thisLR_355, thisDeltaAOD355, ~] = pollyConstrainedKlett(data.distance0, sig355, SNR355, refH355, PollyConfig.refBeta355, mBsc355(iGrp,:), PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_355_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag355t), PollyConfig.mask_SNRmin(flag355t), PollyConfig.smoothWin_klett_355);
    thisAerExt355_aeronet = thisAerBsc355_aeronet * thisLR_355;

    data.aerBsc355_aeronet(iGrp, :) = thisAerBsc355_aeronet;
    data.aerBscStd355_aeronet(iGrp, :) = 0.2 * thisAerBsc355_aeronet;
    data.aerExt355_aeronet(iGrp, :) = thisAerExt355_aeronet;
    data.aerExtStd355_aeronet(iGrp, :) = thisAerExt355_aeronet;
    data.LR355_aeronet(iGrp) = thisLR_355;
    data.deltaAOD355(iGrp) = thisDeltaAOD355;
end

%% Constrained-AOD Klett method at 532 nm (far-field)
data.aerBsc532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.LR532_aeronet = NaN(size(clFreGrps, 1), 1);
data.deltaAOD532 = NaN(size(clFreGrps, 1), 1);
for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd532(iGrp, 1)) || (sum(flag532t) ~= 1)
        continue;
    end

    sig532 = squeeze(sum(el532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg532 = squeeze(sum(bgEl532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR532 = pollySNR(sig532, bg532);
    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];
   
    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_532_aeronet = interp_AERONET_AOD(500, AERONET.AOD_500(AERONETInd), 675, AERONET.AOD_675(AERONETInd), 532);

    % constrained Klett method
    [thisAerBsc532_aeronet, thisLR_532, thisDeltaAOD532, ~] = pollyConstrainedKlett(data.distance0, sig532, SNR532, refH532, PollyConfig.refBeta532, mBsc532(iGrp,:), PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_532_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag532t), PollyConfig.mask_SNRmin(flag532t), PollyConfig.smoothWin_klett_532);
    thisAerExt532_aeronet = thisAerBsc532_aeronet * thisLR_532;

    data.aerBsc532_aeronet(iGrp, :) = thisAerBsc532_aeronet;
    data.aerBscStd532_aeronet(iGrp, :) = 0.2 * thisAerBsc532_aeronet;
    data.aerExt532_aeronet(iGrp, :) = thisAerExt532_aeronet;
    data.aerExtStd532_aeronet(iGrp, :) = 0.2 * thisAerExt532_aeronet;
    data.LR532_aeronet(iGrp) = thisLR_532;
    data.deltaAOD532(iGrp) = thisDeltaAOD532;
end

%% Constrained-AOD Klett method at 1064 nm
data.aerBsc1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_aeronet = NaN(size(clFreGrps, 1), length(data.height));
data.LR1064_aeronet = NaN(size(clFreGrps, 1), 1);
data.deltaAOD1064 = NaN(size(clFreGrps, 1), 1);
for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd1064(iGrp, 1)) || (sum(flag1064t) ~= 1)
        continue;
    end

    sig1064 = squeeze(sum(el1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg1064 = squeeze(sum(bgEl1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR1064 = pollySNR(sig1064, bg1064);
    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
    
    AERONETInd = search_AERONET_AOD(mean(data.mTime(clFreGrps(iGrp, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

    if isempty(AERONETInd)
        continue;
    end

    AOD_1064_aeronet = interp_AERONET_AOD(1020, AERONET.AOD_1020(AERONETInd), 1640, AERONET.AOD_1640(AERONETInd), 1064);

    % constrained Klett method
    [thisAerBsc1064_aeronet, thisLR_1064, thisDeltaAOD1064, ~] = pollyConstrainedKlett(data.distance0, sig1064, SNR1064, refH1064, PollyConfig.refBeta1064, mBsc1064(iGrp,:), PollyConfig.maxIterConstrainFernald, PollyConfig.minLRConstrainFernald, PollyConfig.maxLRConstrainFernald, AOD_1064_aeronet, PollyConfig.minDeltaAOD, PollyConfig.heightFullOverlap(flag1064t), PollyConfig.mask_SNRmin(flag1064t), PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_aeronet = thisAerBsc1064_aeronet * thisLR_1064;

    data.aerBsc1064_aeronet(iGrp, :) = thisAerBsc1064_aeronet;
    data.aerBscStd1064_aeronet(iGrp, :) = 0.2 * thisAerBsc1064_aeronet;
    data.aerExt1064_aeronet(iGrp, :) = thisAerExt1064_aeronet;
    data.aerExtStd1064_aeronet(iGrp, :) = 0.2 * thisAerExt1064_aeronet;
    data.LR1064_aeronet(iGrp) = thisLR_1064;
    data.deltaAOD1064(iGrp) = thisDeltaAOD1064;
end

%% Raman method (355 nm)
data.aerBsc355_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR355_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd355_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask387Off);
    if (sum(flag355t) ~= 1) || (sum(flag387FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig355 = transpose(squeeze(sum(el355(:, flagClFre), 2)));
    bg355 = transpose(squeeze(sum(bgEl355(:, flagClFre), 2)));
    sig387 = squeeze(sum(data.signal(flag387FR, :, flagClFre), 3));
    bg387 = squeeze(sum(data.bg(flag387FR, :, flagClFre), 3));

    [thisAerExt355_raman, thisAerExtStd355_raman] = pollyRamanExt_smart_MC(data.distance0, sig387, 355, 387, mExt355(iGrp,:), mExt387(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_355, 'moving',15,bg387);
    data.aerExt355_raman(iGrp, :) = thisAerExt355_raman;
    data.aerExtStd355_raman(iGrp, :) = thisAerExtStd355_raman;

    if isnan(data.refHInd355(iGrp, 1))
        continue;
    end

    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355t) + PollyConfig.smoothWin_raman_355/2 * data.hRes, 1);

    if isempty(hBaseInd355)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd355 = 100;
    end

    SNRRef355 = pollySNR(sum(sig355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));

    if (SNRRef355 < PollyConfig.minRamanRefSNR355) || (SNRRef387 < PollyConfig.minRamanRefSNR387)
        continue;
    end
%here the lower end of the exitncion profiles is set to contant values
%according to the value at full overlap + smoothing window/2 --> should be
%the mean value in future?
    thisAerExt355_raman_tmp = thisAerExt355_raman;
    thisAerExt355_raman(1:hBaseInd355) = thisAerExt355_raman(hBaseInd355);
    [thisAerBsc355_raman, thisAerBscStd355_raman, ~] = pollyRamanBsc_smart_MC(data.distance0, sig355, sig387, thisAerExt355_raman, PollyConfig.angstrexp, mExt355(iGrp,:), mBsc355(iGrp,:),mExt387(iGrp,:), mBsc387(iGrp,:), refH355,      PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355,  true, 355, 387,  bg355, bg387, thisAerExtStd355_raman, sigma_angstroem, MC_count, 'monte-carlo');
        
    % lidar ratio
    [thisLR355_raman, thisLRStd355_raman] = pollyLR(thisAerExt355_raman_tmp, thisAerBsc355_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd355_raman, 'aerBscStd', thisAerBscStd355_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_355, 'smoothWInBsc', PollyConfig.smoothWin_raman_355);

    data.aerBsc355_raman(iGrp, :) = thisAerBsc355_raman;
    data.aerBscStd355_raman(iGrp, :) = thisAerBscStd355_raman;
    data.LR355_raman(iGrp, :) = thisLR355_raman;
    data.LRStd355_raman(iGrp, :) = thisLRStd355_raman;

end
%clear vars here
clearvars thisAerBsc355_raman thisAerBscStd355_raman thisAerExt355_raman thisAerExt355_raman_tmp thisAerExtStd355_raman
%% Raman method (532 nm)
data.aerBsc532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd532_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag532t) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig532 = transpose(squeeze(sum(el532(:, flagClFre), 2)));
    bg532 = transpose(squeeze(sum(bgEl532(:, flagClFre), 2)));
    sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607FR, :, flagClFre), 3));

    [thisAerExt532_raman,thisAerExtStd532_raman] = pollyRamanExt_smart_MC(data.distance0, sig607, 532, 607, mExt532(iGrp,:), mExt607(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_532, 'moving',15,bg607);
    data.aerExt532_raman(iGrp, :) = thisAerExt532_raman;
    data.aerExtStd532_raman(iGrp, :) = thisAerExtStd532_raman;

    if isnan(data.refHInd532(iGrp, 1))
        continue;
    end

    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532t) + PollyConfig.smoothWin_raman_532/2 * data.hRes, 1);

    if isempty(hBaseInd532)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd532 = 100;
    end

    SNRRef532 = pollySNR(sum(sig532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));

    if (SNRRef532 < PollyConfig.minRamanRefSNR532) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt532_raman_tmp = thisAerExt532_raman;
    thisAerExt532_raman(1:hBaseInd532) = thisAerExt532_raman(hBaseInd532);
    [thisAerBsc532_raman, thisAerBscStd532_raman, ~] = pollyRamanBsc_smart_MC(data.distance0, sig532, sig607, thisAerExt532_raman, PollyConfig.angstrexp, mExt532(iGrp,:), mBsc532(iGrp,:),mExt607(iGrp,:), mBsc607(iGrp,:), refH532,      PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532,  true, 532, 607,  bg532, bg607, thisAerExtStd532_raman, sigma_angstroem, MC_count, 'monte-carlo');

    % lidar ratio
    [thisLR532_raman, thisLRStd532_raman] = pollyLR(thisAerExt532_raman_tmp, thisAerBsc532_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd532_raman, 'aerBscStd', thisAerBscStd532_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_532, 'smoothWInBsc', PollyConfig.smoothWin_raman_532);

    data.aerBsc532_raman(iGrp, :) = thisAerBsc532_raman;
    data.aerBscStd532_raman(iGrp, :) = thisAerBscStd532_raman;
    data.LR532_raman(iGrp, :) = thisLR532_raman;
    data.LRStd532_raman(iGrp, :) = thisLRStd532_raman;

end

%% Raman method (1064 nm)
data.aerBsc1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd1064_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag1064t) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig1064 = transpose(squeeze(sum(el1064(:, flagClFre), 2)));
    bg1064 = transpose(squeeze(sum(bgEl1064(:, flagClFre), 2)));
    sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607FR, :, flagClFre), 3));
    
    [thisAerExt532_raman, thisAerExtStd532_raman]  = pollyRamanExt_smart_MC(data.distance0, sig607, 532, 607, mExt532(iGrp,:), mExt607(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_1064, 'moving',15,bg607);
    thisAerExt1064_raman = thisAerExt532_raman / (1064/532).^PollyConfig.angstrexp;
    data.aerExt1064_raman(iGrp, :) = thisAerExt1064_raman;
    thisAerExtStd1064_raman = thisAerExtStd532_raman / (1064/532).^PollyConfig.angstrexp;
    data.aerExtStd1064_raman(iGrp, :) = thisAerExtStd1064_raman;

    if isnan(data.refHInd1064(iGrp, 1))
        continue;
    end

    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
    hBaseInd1064 = find(data.height >= PollyConfig.heightFullOverlap(flag1064t) + PollyConfig.smoothWin_raman_1064/2 * data.hRes, 1);

    if isempty(hBaseInd1064)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd1064 = 100;
    end

    SNRRef1064 = pollySNR(sum(sig1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg607(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));

    if (SNRRef1064 < PollyConfig.minRamanRefSNR1064) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt1064_raman_tmp = thisAerExt1064_raman;
    thisAerExt1064_raman(1:hBaseInd1064) = thisAerExt1064_raman(hBaseInd1064);
    [thisAerBsc1064_raman, thisAerBscStd1064_raman, ~] = pollyRamanBsc_smart_MC(data.distance0, sig1064, sig607, thisAerExt1064_raman, PollyConfig.angstrexp, mExt1064(iGrp,:), mBsc1064(iGrp,:),mExt607(iGrp,:), mBsc607(iGrp,:), refH1064,      PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064,  true, 1064, 607,  bg1064, bg607, thisAerExtStd1064_raman, sigma_angstroem, MC_count, 'monte-carlo');

    % lidar ratio
    [thisLR1064_raman, thisLRStd1064_raman] = pollyLR(thisAerExt1064_raman_tmp, thisAerBsc1064_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', data.aerExtStd1064_raman(iGrp, :), 'aerBscStd', thisAerBscStd1064_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_1064, 'smoothWInBsc', PollyConfig.smoothWin_raman_1064);

    data.aerBsc1064_raman(iGrp, :) = thisAerBsc1064_raman;
    data.aerBscStd1064_raman(iGrp, :) = thisAerBscStd1064_raman;
    data.LR1064_raman(iGrp, :) = thisLR1064_raman;
    data.LRStd1064_raman(iGrp, :) = thisLRStd1064_raman;

end

%% rotation Raman method (355 nm)
data.aerBsc355_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LR355_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd355_RR = NaN(size(clFreGrps, 1), length(data.height));



for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask355RROff);

    if (sum(flag355t) ~= 1) || (sum(flag355RR) ~= 1) || (sum(flagClFre) == 0)
        continue;
    end


    sig355 = transpose(squeeze(sum(el355(:, flagClFre), 2)));
    bg355 = transpose(squeeze(sum(bgEl355(:, flagClFre), 2)));
    sig355RR = squeeze(sum(data.signal(flag355RR, :, flagClFre), 3));
    bg355RR = squeeze(sum(data.bg(flag355RR, :, flagClFre), 3));

    [thisAerExt355_RR,thisAerExtStd355_RR]    = pollyRamanExt_smart_MC(data.distance0, sig355RR, 355, 355, mExt355(iGrp,:), mExt355(iGrp,:),number_density(iGrp, :), PollyConfig.angstrexp,PollyConfig.smoothWin_raman_355, 'moving',15,bg355RR);
    data.aerExt355_RR(iGrp, :) = thisAerExt355_RR;
    data.aerExtStd355_RR(iGrp, :) = thisAerExtStd355_RR;

    if isnan(data.refHInd355(iGrp, 1))
        continue;
    end

    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355t) + PollyConfig.smoothWin_raman_355/2 * data.hRes, 1);

    if isempty(hBaseInd355)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd355 = 100;
    end

    SNRRef355 = pollySNR(sum(sig355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));
    SNRRef355RR = pollySNR(sum(sig355RR(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg355RR(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));

    if (SNRRef355 < PollyConfig.minRamanRefSNR355) || (SNRRef355RR < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt355_RR_tmp = thisAerExt355_RR;
    thisAerExt355_RR(1:hBaseInd355) = thisAerExt355_RR(hBaseInd355);
    [thisAerBsc355_RR, thisAerBscStd355_RR, ~] = pollyRamanBsc_smart_MC(data.distance0, sig355, sig355RR, thisAerExt355_RR, PollyConfig.angstrexp, mExt355(iGrp,:), mBsc355(iGrp,:), mExt355(iGrp,:), mBsc355(iGrp,:), refH355,      PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355, true, 355, 355,  bg355, bg355RR, thisAerExtStd355_RR, sigma_angstroem, MC_count, 'monte-carlo');
    
    % lidar ratio
    [thisLR355_RR, thisLRStd355_RR] = pollyLR(thisAerExt355_RR_tmp, thisAerBsc355_RR, ...
        'hRes', data.hRes, ...
        'aerExtStd', data.aerExtStd355_RR(iGrp, :), 'aerBscStd', thisAerBscStd355_RR, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_355, 'smoothWInBsc', PollyConfig.smoothWin_raman_355);

    data.aerBsc355_RR(iGrp, :) = thisAerBsc355_RR;
    data.aerBscStd355_RR(iGrp, :) = thisAerBscStd355_RR;
    data.LR355_RR(iGrp, :) = thisLR355_RR;
    data.LRStd355_RR(iGrp, :) = thisLRStd355_RR;

end
clearvars sig355 bg355 sig355RR bg355RR el355 bgEl355

%% rotation Raman method (532 nm)
data.aerBsc532_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LR532_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd532_RR = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask532RROff);

    if (sum(flag532t) ~= 1) || (sum(flag532RR) ~= 1) || (sum(flagClFre) == 0)
        continue;
    end


    sig532 = transpose(squeeze(sum(el532(:, flagClFre), 2)));
    bg532 = transpose(squeeze(sum(bgEl532(:, flagClFre), 2)));
    sig532RR = squeeze(sum(data.signal(flag532RR, :, flagClFre), 3));
    bg532RR = squeeze(sum(data.bg(flag532RR, :, flagClFre), 3));
    
    [thisAerExt532_RR,thisAerExtStd532_RR]  = pollyRamanExt_smart_MC(data.distance0, sig532RR, 532, 532, mExt532(iGrp,:), mExt532(iGrp,:),number_density(iGrp, :),PollyConfig.angstrexp, PollyConfig.smoothWin_raman_532, 'moving',15,bg532RR);
    data.aerExt532_RR(iGrp, :) = thisAerExt532_RR;
    data.aerExtStd532_RR(iGrp, :) = thisAerExtStd532_RR;

    if isnan(data.refHInd532(iGrp, 1))
        continue;
    end

    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532t) + PollyConfig.smoothWin_raman_532/2 * data.hRes, 1);

    if isempty(hBaseInd532)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd532 = 100;
    end

    SNRRef532 = pollySNR(sum(sig532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));
    SNRRef532RR = pollySNR(sum(sig532RR(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg532RR(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));

    if (SNRRef532 < PollyConfig.minRamanRefSNR532) || (SNRRef532RR < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt532_RR_tmp = thisAerExt532_RR;
    thisAerExt532_RR(1:hBaseInd532) = thisAerExt532_RR(hBaseInd532);
    [thisAerBsc532_RR, thisAerBscStd532_RR, ~] = pollyRamanBsc_smart_MC(data.distance0, sig532, sig532RR, thisAerExt532_RR, PollyConfig.angstrexp, mExt532(iGrp,:), mBsc532(iGrp,:), mExt532(iGrp,:), mBsc532(iGrp,:), refH532,      PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532, true, 532, 532,  bg532, bg532RR, thisAerExtStd532_RR, sigma_angstroem, MC_count, 'monte-carlo');
   
    % lidar ratio
    [thisLR532_RR, thisLRStd532_RR] = pollyLR(thisAerExt532_RR_tmp, thisAerBsc532_RR, ...
        'hRes', data.hRes, ...
        'aerExtStd', data.aerExtStd532_RR(iGrp, :), 'aerBscStd', thisAerBscStd532_RR, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_532, 'smoothWInBsc', PollyConfig.smoothWin_raman_532);

    data.aerBsc532_RR(iGrp, :) = thisAerBsc532_RR;
    data.aerBscStd532_RR(iGrp, :) = thisAerBscStd532_RR;
    data.LR532_RR(iGrp, :) = thisLR532_RR;
    data.LRStd532_RR(iGrp, :) = thisLRStd532_RR;

end
clearvars bg532RR bg532 sig532RR sig532 thisAerExt532_RR thisAerExtStd532_RR SNRRef532 SNRRef532RR thisAerExt532_RR_tmp bgEl532
%% rotation Raman method (1064 nm)
data.aerBsc1064_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_RR = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LR1064_RR = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd1064_RR = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask1064RROff);

    if (sum(flag1064t) ~= 1) || (sum(flag1064RR) ~= 1) || (sum(flagClFre) == 0)
        continue;
    end

    sig1064 = transpose(squeeze(sum(el1064(:, flagClFre), 2)));
    bg1064 = transpose(squeeze(sum(bgEl1064(:, flagClFre), 2)));
    sig1064RR = squeeze(sum(data.signal(flag1064RR, :, flagClFre), 3));
    bg1064RR = squeeze(sum(data.bg(flag1064RR, :, flagClFre), 3));

     [thisAerExt1064_RR,thisAerExtStd1064_RR]  =     pollyRamanExt_smart_MC(data.distance0, sig1064RR, 1064, 1058, mExt1064(iGrp,:), mExt1058(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_1064, 'moving',15,bg1064RR);
    data.aerExt1064_RR(iGrp, :) = thisAerExt1064_RR;
    data.aerExtStd1064_RR(iGrp, :) = thisAerExtStd1064_RR;

    if isnan(data.refHInd1064(iGrp, 1))
        continue;
    end

    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
    hBaseInd1064 = find(data.height >= PollyConfig.heightFullOverlap(flag1064t) + PollyConfig.smoothWin_raman_1064/2 * data.hRes, 1);

    if isempty(hBaseInd1064)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd1064 = 100;
    end

    SNRRef1064 = pollySNR(sum(sig1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));
    SNRRef1064RR = pollySNR(sum(sig1064RR(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg1064RR(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));

    if (SNRRef1064 < PollyConfig.minRamanRefSNR1064) || (SNRRef1064RR < PollyConfig.minRamanRefSNR1064)
        continue;
    end

    thisAerExt1064_RR_tmp = thisAerExt1064_RR;
    thisAerExt1064_RR(1:hBaseInd1064) = thisAerExt1064_RR(hBaseInd1064);
    [thisAerBsc1064_RR, thisAerBscStd1064_RR, ~] = pollyRamanBsc_smart_MC(data.distance0, sig1064, sig1064RR, thisAerExt1064_RR, PollyConfig.angstrexp, mExt1064(iGrp,:), mBsc1064(iGrp,:), mExt1058(iGrp,:), mBsc1058(iGrp,:), refH1064,      PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064, true, 1064, 1058,  bg1064, bg1064RR, thisAerExtStd1064_RR, sigma_angstroem, MC_count, 'monte-carlo');

    % lidar ratio
    [thisLR1064_RR, thisLRStd1064_RR] = pollyLR(thisAerExt1064_RR_tmp, thisAerBsc1064_RR, ...
        'hRes', data.hRes, ...
        'aerExtStd', data.aerExtStd1064_RR(iGrp, :), 'aerBscStd', thisAerBscStd1064_RR, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_1064, 'smoothWInBsc', PollyConfig.smoothWin_raman_1064);

    data.aerBsc1064_RR(iGrp, :) = thisAerBsc1064_RR;
    data.aerBscStd1064_RR(iGrp, :) = thisAerBscStd1064_RR;
    data.LR1064_RR(iGrp, :) = thisLR1064_RR;
    data.LRStd1064_RR(iGrp, :) = thisLRStd1064_RR;

end
clearvars el1064 bgEl1064 thisAerExt1064_RR_tmp thisLR1064_RR thisLRStd1064_RR thisAerExt1064_RR thisAerBsc1064_RR thisAerBscStd1064_RR
%% Raman method (near-field 355 nm)
data.aerBsc355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd355_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.refBeta_NR_355_raman = NaN(1, size(clFreGrps, 1));
refH355_NR = PollyConfig.refH_NR_355;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag355NR) ~= 1) || (sum(flag387NR) ~= 1)
        continue;        
    end

    % search index for reference height
    if (refH355_NR(1) < data.height(1)) || (refH355_NR(1) > data.height(end)) || ...
       (refH355_NR(2) < data.height(1)) || (refH355_NR(2) > data.height(end))
        print_msg(sprintf('refH_NR_355 (%f - %f m) in the polly config file is out of range.\n', ...
            refH355_NR(1), refH355_NR(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_355 to [2500 - 3000 m]\n');
        refH355_NR = [2500, 3000];
    end

    mask387Off = pollyIs387Off(squeeze(data.signal(flag387NR, :, :)));
    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ mask387Off);
    if sum(flagClFre) == 0
        continue;
    end

    sig355 = squeeze(sum(data.signal(flag355NR, :, flagClFre), 3));
    bg355 = squeeze(sum(data.bg(flag355NR, :, flagClFre), 3));
    sig387 = squeeze(sum(data.signal(flag387NR, :, flagClFre), 3));
    bg387 = squeeze(sum(data.bg(flag387NR, :, flagClFre), 3));
    
    [thisAerExt355_NR_raman,thisAerExtStd355_NR_raman] = pollyRamanExt_smart_MC(data.distance0, sig387, 355, 387, mExt355(iGrp,:), mExt387(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_NR_355, 'moving',15,bg387);
    data.aerExt355_NR_raman(iGrp, :) = thisAerExt355_NR_raman;
    data.aerExtStd355_NR_raman(iGrp, :) = thisAerExtStd355_NR_raman;

    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355NR) + PollyConfig.smoothWin_raman_NR_355/2 * data.hRes, 1);
    if isempty(hBaseInd355)
        print_msg('Failure in searching the index of minimum height for near-field channel. Set the index of the minimum integral range to be 40\n', 'flagSimpleMsg', true);
        hBaseInd355 =40;
    end

    if (refH355_NR(1) < data.height(1)) || (refH355_NR(1) > data.height(end)) || ...
       (refH355_NR(2) < data.height(1)) || (refH355_NR(2) > data.height(end))
       print_msg(sprintf('refH_NR_355 (%f - %f) m in the polly config file is out of range.\n', refH355_NR(1), refH355_NR(2)), 'flagSimpleMsg', true);
       print_msg('Set refH_NR_355 to [2500 - 3000] m', 'flagSimpleMsg', true);
       refH355_NR = [2500, 3000];
    end
    refHTopInd355 = find(data.height <= refH355_NR(2), 1, 'last');
    refHBaseInd355 = find(data.height >= refH355_NR(1), 1, 'first');

    if isnan(data.refHInd355(iGrp, 1)) || isnan(data.refHInd355(iGrp, 2))
        continue;
    end

    SNRRef355 = pollySNR(sum(sig355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));
    refBeta355_NF = mean(data.aerBsc355_raman(iGrp, refHBaseInd355:refHTopInd355), 2);%here the refereence value is calculated from the far field

    if (SNRRef355 < PollyConfig.minRefSNR_NR_355) || (SNRRef387 < PollyConfig.minRamanRefSNR387) || isnan(refBeta355_NF)
        continue;
    end

    thisAerExt355_NR_raman_tmp = thisAerExt355_NR_raman;
    thisAerExt355_NR_raman(1:hBaseInd355) = thisAerExt355_NR_raman(hBaseInd355);
   [thisAerBsc355_NR_raman, thisAerBscStd355_NR_raman, ~] = pollyRamanBsc_smart_MC(data.distance0, sig355, sig387, thisAerExt355_NR_raman, PollyConfig.angstrexp, mExt355(iGrp,:), mBsc355(iGrp,:),mExt387(iGrp,:), mBsc387(iGrp,:), refH355_NR,      refBeta355_NF, PollyConfig.smoothWin_raman_NR_355, true, 355, 387,  bg355, bg387, thisAerExtStd355_NR_raman, sigma_angstroem, MC_count, 'monte-carlo');

    % lidar ratio
    [thisLR355_NR_raman, thisLRStd355_NR_raman] = pollyLR(thisAerExt355_NR_raman_tmp, thisAerBsc355_NR_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd355_NR_raman, 'aerBscStd', thisAerBscStd355_NR_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_NR_355, 'smoothWInBsc', PollyConfig.smoothWin_raman_NR_355);

    data.aerBsc355_NR_raman(iGrp, :) = thisAerBsc355_NR_raman;
    data.aerBscStd355_NR_raman(iGrp, :) = thisAerBscStd355_NR_raman;
    data.LR355_NR_raman(iGrp, :) = thisLR355_NR_raman;
    data.LRStd355_NR_raman(iGrp, :) = thisLRStd355_NR_raman;
    data.refBeta_NR_355_raman(iGrp) = refBeta355_NF;

end

%% Raman method (near-field 532 nm)
data.aerBsc532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.refBeta_NR_532_raman = NaN(1, size(clFreGrps, 1));
refH532_NR = PollyConfig.refH_NR_532;

for iGrp = 1:size(clFreGrps, 1)

    if (sum(flag532NR) ~= 1) || (sum(flag607NR) ~= 1)
        continue;
    end

    % search index for reference height
    if (refH532_NR(1) < data.height(1)) || (refH532_NR(1) > data.height(end)) || ...
       (refH532_NR(2) < data.height(1)) || (refH532_NR(2) > data.height(end))
        print_msg(sprintf('refH_NR_532 (%f - %f m) in the polly config file is out of range.\n', ...
            refH532_NR(1), refH532_NR(2)), 'flagSimpleMsg', true);
        print_msg('Set refH_NR_532 to [2500 - 3000 m]\n');
        refH532_NR = [2500, 3000];
    end

    mask607Off = pollyIs607Off(squeeze(data.signal(flag607NR, :, :)));
    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ mask607Off);
    if sum(flagClFre) == 0
        continue;
    end

    sig532 = squeeze(sum(data.signal(flag532NR, :, flagClFre), 3));
    bg532 = squeeze(sum(data.bg(flag532NR, :, flagClFre), 3));
    sig607 = squeeze(sum(data.signal(flag607NR, :, flagClFre), 3));
    bg607 = squeeze(sum(data.bg(flag607NR, :, flagClFre), 3));

    [thisAerExt532_NR_raman, thisAerExtStd532_NR_raman] = pollyRamanExt_smart_MC(data.distance0, sig607, 532, 607, mExt532(iGrp,:), mExt607(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_NR_532, 'moving',15,bg607);
    data.aerExt532_NR_raman(iGrp, :) = thisAerExt532_NR_raman;
    data.aerExtStd532_NR_raman(iGrp, :) = thisAerExtStd532_NR_raman;

    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532NR) + PollyConfig.smoothWin_raman_NR_532/2 * data.hRes, 1);
    if isempty(hBaseInd532)
        print_msg('Failure in searching the index of minimum height for near-field channel. Set the index of the minimum integral range to be 40\n', 'flagSimpleMsg', true);
        hBaseInd532 =40;
    end

    if (refH532_NR(1) < data.height(1)) || (refH532_NR(1) > data.height(end)) || ...
       (refH532_NR(2) < data.height(1)) || (refH532_NR(2) > data.height(end))
       print_msg(sprintf('refH_NR_532 (%f - %f) m in the polly config file is out of range.\n', refH532_NR(1), refH532_NR(2)), 'flagSimpleMsg', true);
       print_msg('Set refH_NR_532 to [2500 - 3000] m', 'flagSimpleMsg', true);
       refH532_NR = [2500, 3000];
    end
    refHTopInd532 = find(data.height <= refH532_NR(2), 1, 'last');
    refHBaseInd532 = find(data.height >= refH532_NR(1), 1, 'first');

    if isnan(data.refHInd532(iGrp, 1)) || isnan(data.refHInd532(iGrp, 2))
        continue;
    end

    SNRRef532 = pollySNR(sum(sig532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));
    refBeta532_NR = mean(data.aerBsc532_raman(iGrp, refHBaseInd532:refHTopInd532), 2);%here the refereence value is calculated from the far field

    if (SNRRef532 < PollyConfig.minRefSNR_NR_532) || (SNRRef607 < PollyConfig.minRamanRefSNR607) || isnan(refBeta532_NR)
        continue;
    end

    thisAerExt532_NR_raman_tmp = thisAerExt532_NR_raman;
    thisAerExt532_NR_raman(1:hBaseInd532) = thisAerExt532_NR_raman(hBaseInd532);
    
    [thisAerBsc532_NR_raman, thisAerBscStd532_NR_raman, ~] = pollyRamanBsc_smart_MC(data.distance0, sig532, sig607, thisAerExt532_NR_raman, PollyConfig.angstrexp, mExt532(iGrp,:), mBsc532(iGrp,:),mExt607(iGrp,:), mBsc607(iGrp,:), refH532_NR,      refBeta532_NR, PollyConfig.smoothWin_raman_NR_532, true, 532, 607,  bg532, bg607, thisAerExtStd532_NR_raman, sigma_angstroem, MC_count, 'monte-carlo');
    % lidar ratio
    [thisLR532_NR_raman, thisLRStd532_NR_raman] = pollyLR(thisAerExt532_NR_raman_tmp, thisAerBsc532_NR_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd532_NR_raman, 'aerBscStd', thisAerBscStd532_NR_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_NR_532, 'smoothWInBsc', PollyConfig.smoothWin_raman_NR_532);

    data.aerBsc532_NR_raman(iGrp, :) = thisAerBsc532_NR_raman;
    data.aerBscStd532_NR_raman(iGrp, :) = thisAerBscStd532_NR_raman;
    data.LR532_NR_raman(iGrp, :) = thisLR532_NR_raman;
    data.LRStd532_NR_raman(iGrp, :) = thisLRStd532_NR_raman;
    data.refBeta_NR_532_raman(iGrp) = refBeta532_NR;

end





%% Overlap estimation
print_msg('Start overlap estimation (near to Far range method).\n', 'flagTimestamp', true);

% 355 nm
data.olAttri355 = struct();
data.olAttri355.sigFR = [];
data.olAttri355.sigNR = [];
data.olAttri355.sigRatio = [];
data.olAttri355.normRange = [];
data.olAttri355.time = NaN;
data.olFunc355 = NaN(length(data.height), 1);
% olStd355 = NaN(length(data.height), 1);
if (sum(flag355t) == 1) && (sum(flag355NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flag355t, flagCloudFree_NR)) / 150;
    PC2PCRNR = data.hRes * sum(data.mShots(flag355NR,flagCloudFree_NR)) / 150;
    sig355NR = squeeze(sum(data.signal(flag355NR, :, flagCloudFree_NR), 3));
    bg355NR = squeeze(sum(data.bg(flag355NR, :, flagCloudFree_NR), 3));
    sig355FR = squeeze(sum(data.signal(flag355t, :, flagCloudFree_NR), 3));
    bg355FR = squeeze(sum(data.bg(flag355t, :, flagCloudFree_NR), 3));
    [data.olFunc355, ~, data.olAttri355] = pollyOVLCalc(data.distance0, ...
        sig355FR, sig355NR, bg355FR, bg355NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag355t), ...
        'PC2PCR', PC2PCR);
    data.olAttri355.time = nanmean(data.mTime);
end

% 387 nm
olAttri387 = struct();
olAttri387.sigFR = [];
olAttri387.sigNR = [];
olAttri387.sigRatio = [];
olAttri387.normRange = [];
olAttri387.time = NaN;
olFunc387 = NaN(length(data.height), 1);
% olStd387 = NaN(length(data.height), 1);
if (sum(flag387FR) == 1) && (sum(flag387NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flag387FR, flagCloudFree_NR)) / 150;
    PC2PCRNR = data.hRes * sum(data.mShots(flag387NR,flagCloudFree_NR)) / 150;
    sig387NR = squeeze(sum(data.signal(flag387NR, :, flagCloudFree_NR), 3));
    bg387NR = squeeze(sum(data.bg(flag387NR, :, flagCloudFree_NR), 3));
    sig387FR = squeeze(sum(data.signal(flag387FR, :, flagCloudFree_NR), 3));
    bg387FR = squeeze(sum(data.bg(flag387FR, :, flagCloudFree_NR), 3));
    [olFunc387, ~, olAttri387] = pollyOVLCalc(data.distance0, ...
        sig387FR, sig387NR, bg387FR, bg387NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag387FR), ...
        'PC2PCR', PC2PCR);
    olAttri387.time = nanmean(data.mTime);
end

% 532 nm
data.olAttri532 = struct();
data.olAttri532.sigFR = [];
data.olAttri532.sigNR = [];
data.olAttri532.sigRatio = [];
data.olAttri532.normRange = [];
data.olAttri532.time = NaN;
data.olFunc532 = NaN(length(data.height), 1);
% olStd532 = NaN(length(data.height), 1);
if (sum(flag532t) == 1) && (sum(flag532NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flag532t,flagCloudFree_NR)) / 150;
    PC2PCRNR = data.hRes * sum(data.mShots(flag532NR,flagCloudFree_NR)) / 150;
    sig532NR = squeeze(sum(data.signal(flag532NR, :, flagCloudFree_NR), 3));
    bg532NR = squeeze(sum(data.bg(flag532NR, :, flagCloudFree_NR), 3));
    sig532FR = squeeze(sum(data.signal(flag532t, :, flagCloudFree_NR), 3));
    bg532FR = squeeze(sum(data.bg(flag532t, :, flagCloudFree_NR), 3));
    [data.olFunc532, ~, data.olAttri532] = pollyOVLCalc(data.distance0, ...
        sig532FR, sig532NR, bg532FR, bg532NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag532t), ...
        'PC2PCR', PC2PCR);
    data.olAttri532.time = nanmean(data.mTime);
end

% 607 nm
olAttri607 = struct();
olAttri607.sigFR = [];
olAttri607.sigNR = [];
olAttri607.sigRatio = [];
olAttri607.normRange = [];
olAttri607.time = [];
olFunc607 = NaN(length(data.height), 1);
% olStd607 = NaN(length(data.height), 1);
if (sum(flag607FR) == 1) && (sum(flag607NR) == 1)
    PC2PCR = data.hRes * sum(data.mShots(flag607FR, flagCloudFree_NR)) / 150;
    PC2PCRNR = data.hRes * sum(data.mShots(flag607NR,flagCloudFree_NR)) / 150;
    sig607NR = squeeze(sum(data.signal(flag607NR, :, flagCloudFree_NR), 3));
    bg607NR = squeeze(sum(data.bg(flag607NR, :, flagCloudFree_NR), 3));
    sig607FR = squeeze(sum(data.signal(flag607FR, :, flagCloudFree_NR), 3));
    bg607FR = squeeze(sum(data.bg(flag607FR, :, flagCloudFree_NR), 3));
    [olFunc607, ~, olAttri607] = pollyOVLCalc(data.distance0, ...
        sig607FR, sig607NR, bg607FR, bg607NR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag607FR), ...
        'PC2PCR', PC2PCR);
    olAttri607.time = nanmean(data.mTime);
end

% 1064 nm
olAttri1064 = struct();
olAttri1064.sigFR = [];
olAttri1064.sigNR = [];
olAttri1064.sigRatio = [];
olAttri1064.normRange = [];
olAttri1064.time = NaN;
olFunc1064 = NaN(length(data.height), 1);
% olStd1064 = NaN(length(data.height), 1);
if (sum(flag1064t) == 1) && (sum(flag532t) == 1) && (sum(flag532NR) == 1)
    olFunc1064 = data.olFunc532;
    % olStd1064 = olStd532;
    olAttri1064 = data.olAttri532;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Overlap estimation (Raman method)
print_msg('Start overlap estimation (near to Far range method).\n', 'flagTimestamp', true);

%355
data.olAttri355Raman = struct();
data.olAttri355Raman.sigFRel = [];
data.olAttri355Raman.sigFRRa= [];
data.olAttri355Raman.LR_derived= NaN;
data.olAttri355Raman.time = NaN;
data.olFunc355Raman = NaN(length(data.height), 1);
data.olFunc355Raman_raw= NaN(length(data.height), 1);

if (sum(flag355t) == 1) && (sum(flag387FR) == 1 && ~isempty(data.aerBsc355_raman))
    PC2PCR = data.hRes * sum(data.mShots(flag355t,flagCloudFree_FR)) / 150;
    sig387FR = squeeze(sum(data.signal(flag387FR, :, flagCloudFree_FR), 3));
    bg387FR = squeeze(sum(data.bg(flag387FR, :, flagCloudFree_FR), 3));
    sig355FR = squeeze(sum(data.signal(flag355t, :, flagCloudFree_FR), 3));
    bg355FR = squeeze(sum(data.bg(flag355t, :, flagCloudFree_FR), 3));
    
    
    [data.olFunc355Raman, ~,data.olFunc355Raman_raw, data.olAttri355Raman] = pollyOVLCalcRaman(355,387, data.distance0, ...
        sig355FR, sig387FR, bg355FR, bg387FR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag355t), ...
        'PC2PCR', PC2PCR,'aerBsc', data.aerBsc355_raman, 'hres',data.hRes, ...
        'pressure',data.pressure,'temperature', data.temperature, ...
        'AE',PollyConfig.angstrexp,'smoothbins',PollyConfig.overlapSmoothBins-3, ...
        'refH', data.refHInd355, 'refbeta',PollyConfig.refBeta355, 'smooth_klett',PollyConfig.smoothWin_klett_355);
    data.olAttri355Raman.time = nanmean(data.mTime);
end


%532
data.olAttri532Raman = struct();
data.olAttri532Raman.sigFRel = [];
data.olAttri532Raman.sigFRRa= [];
data.olAttri532Raman.LR_derived= NaN;
data.olAttri532Raman.time = NaN;
data.olFunc532Raman = NaN(length(data.height), 1);
data.olFunc532Raman_raw= NaN(length(data.height), 1);


if (sum(flag532t) == 1) && (sum(flag607FR) == 1 && ~isempty(data.aerBsc532_raman))
    PC2PCR = data.hRes * sum(data.mShots(flag532t,flagCloudFree_FR)) / 150;
    sig607FR = squeeze(sum(data.signal(flag607FR, :, flagCloudFree_FR), 3));
    bg607FR = squeeze(sum(data.bg(flag607FR, :, flagCloudFree_FR), 3));
    
    
    sig532FR = squeeze(sum(data.signal(flag532t, :, flagCloudFree_FR), 3)); %why two times? sig532FR
    %sig532FR = squeeze(sum(el532(:, flagCloudFree_FR), 2));
    
    bg532FR = squeeze(sum(data.bg(flag532t, :, flagCloudFree_FR), 3));
    
    [data.olFunc532Raman, ~,data.olFunc532Raman_raw, data.olAttri532Raman] = pollyOVLCalcRaman(532,607, data.distance0, ...
        sig532FR, sig607FR, bg532FR, bg607FR, ...
        'hFullOverlap', PollyConfig.heightFullOverlap(flag532t), ...
        'PC2PCR', PC2PCR,'aerBsc', data.aerBsc532_raman, 'hres',data.hRes, ...
        'pressure',data.pressure,'temperature', data.temperature, ...
        'AE',PollyConfig.angstrexp,'smoothbins',PollyConfig.overlapSmoothBins-3, ...
        'refH', data.refHInd532, 'refbeta',PollyConfig.refBeta532, 'smoothklett',PollyConfig.smoothWin_klett_532);
    data.olAttri532Raman.time = nanmean(data.mTime);
end
clearvars el532
%% Overlap correction
print_msg('Start overlap correction.\n', 'flagTimestamp', true);
%%%%%%%%%%%%%@ andi + Maria %%%%%%%%%%% 
%%%%%%%%%here signal merging should be implemented here with a new flag:
%%%%%%%%%Overlap correction mode 4 --> then you go into the function
%%%%%%%%%pollyOLCor and implement it there.
%%%%%%%%%%%%%%%%%%%%Later it can be moved to an own product, not called _OC
%%%%%%%%%%%%%%%%%%%%but _merged or so
%Input PR2


% 355 nm
data.sigOLCor355 = [];
bgOLCor355 = [];
data.olFuncDeft355 = NaN(length(data.height), 1);
% flagOLDeft355 = false;
if (sum(flag355t) == 1)
    sig355FR = squeeze(data.signal(flag355t, :, :));
    bg355FR = squeeze(data.bg(flag355t, :, :));
    sig355NR = squeeze(data.signal(flag355NR, :, :));
    bg355NR = squeeze(data.bg(flag355NR, :, :));
    [data.sigOLCor355, bgOLCor355, data.olFuncDeft355, ~] = pollyOLCor(data.height, sig355FR, bg355FR, ...
        'signalNR', sig355NR, 'bgNR', bg355NR, ...
        'signalRatio', data.olAttri355.sigRatio, 'normRange', data.olAttri355.normRange, ...
        'overlap', data.olFunc355, 'overlap_Raman',data.olFunc355Raman, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
        'overlapCorMode', PollyConfig.overlapCorMode, 'overlapCalMode', PollyConfig.overlapCalMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end
clearvars bg355FR bg355NR sig355FR sig355NR
% 387 nm
sigOLCor387 = [];
bgOLCor387 = [];
% olFuncDeft387 = NaN(length(data.height), 1);
% flagOLDeft387 = false;
if (sum(flag387FR) == 1)
    sig387FR = squeeze(data.signal(flag387FR, :, :));
    bg387FR = squeeze(data.bg(flag387FR, :, :));
    sig387NR = squeeze(data.signal(flag387NR, :, :));
    bg387NR = squeeze(data.bg(flag387NR, :, :));
    [sigOLCor387, bgOLCor387, ~, ~] = pollyOLCor(data.height, sig387FR, bg387FR, ...
        'signalNR', sig387NR, 'bgNR', bg387NR, ...
        'signalRatio', olAttri387.sigRatio, 'normRange', olAttri387.normRange, ...
        'overlap', olFunc387,'overlap_Raman',data.olFunc355Raman, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile355), ...
        'overlapCorMode', PollyConfig.overlapCorMode, 'overlapCalMode', PollyConfig.overlapCalMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end
clearvars bg387FR bg387NR sig387FR sig387NR
% 532 nm
data.sigOLCor532 = [];
bgOLCor532 = [];
data.olFuncDeft532 = NaN(length(data.height), 1);
% flagOLDeft532 = false;
if (sum(flag532t) == 1)
    sig532FR = squeeze(data.signal(flag532t, :, :));
    bg532FR = squeeze(data.bg(flag532t, :, :));
    sig532NR = squeeze(data.signal(flag532NR, :, :));
    bg532NR = squeeze(data.bg(flag532NR, :, :));
    [data.sigOLCor532, bgOLCor532, data.olFuncDeft532, ~] = pollyOLCor(data.height, sig532FR, bg532FR, ...
        'signalNR', sig532NR, 'bgNR', bg532NR, ...
        'signalRatio', data.olAttri532.sigRatio, 'normRange', data.olAttri532.normRange, ...
        'overlap', data.olFunc532, 'overlap_Raman',data.olFunc532Raman, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, 'overlapCalMode', PollyConfig.overlapCalMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end
clearvars bg532FR bg532NR sig532FR sig532NR
% 607 nm
sigOLCor607 = [];
bgOLCor607 = [];
% olFuncDeft607 = NaN(length(data.height), 1);
% flagOLDeft607 = false;
if (sum(flag607FR) == 1)
    sig607FR = squeeze(data.signal(flag607FR, :, :));
    bg607FR = squeeze(data.bg(flag607FR, :, :));
    sig607NR = squeeze(data.signal(flag607NR, :, :));
    bg607NR = squeeze(data.bg(flag607NR, :, :));
    [sigOLCor607, bgOLCor607, ~, ~] = pollyOLCor(data.height, sig607FR, bg607FR, ...
        'signalNR', sig607NR, 'bgNR', bg607NR, ...
        'signalRatio', olAttri607.sigRatio, 'normRange', olAttri607.normRange, ...
        'overlap', olFunc607, 'overlap_Raman',data.olFunc532Raman, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, 'overlapCalMode', PollyConfig.overlapCalMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end
clearvars bg607FR bg607NR sig607FR sig607NR
% 1064 nm
data.sigOLCor1064 = [];
bgOLCor1064 = [];
% olFuncDeft1064 = NaN(length(data.height), 1);
% flagOLDeft1064 = false;
if (sum(flag1064t) == 1) && (sum(flag532t) == 1)
    sig1064FR = squeeze(data.signal(flag1064t, :, :));
    bg1064FR = squeeze(data.bg(flag1064t, :, :));
    sig1064NR = [];
    bg1064NR = [];
    [data.sigOLCor1064, bgOLCor1064, ~, ~] = pollyOLCor(data.height, sig1064FR, bg1064FR, ...
        'signalNR', sig1064NR, 'bgNR', bg1064NR, ...
        'signalRatio', olAttri1064.sigRatio, 'normRange', olAttri1064.normRange, ...
        'overlap', olFunc1064, 'overlap_Raman',data.olFunc532Raman, ...
        'defaultOLFile', fullfile(PicassoConfig.defaultFile_folder, PollyDefaults.overlapFile532), ...
        'overlapCorMode', PollyConfig.overlapCorMode, 'overlapCalMode', PollyConfig.overlapCalMode, ...
        'overlapSmWin', PollyConfig.overlapSmoothBins);
end
clearvars bg1064FR bg1064NR sig1064FR sig1064NR
print_msg('Finish.\n', 'flagTimestamp', true);


%% Klett method at 355 nm (overlap corrected)
data.aerBsc355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd355(iGrp, 1)) || (sum(flag355t) ~= 1)
        continue;
    end

    sig355 = transpose(squeeze(sum(data.sigOLCor355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg355 = transpose(squeeze(sum(bgOLCor355(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];

    [thisAerBsc355_OC_klett, thisAerBscStd355_OC_klett] = pollyFernald(data.distance0, sig355, bg355, PollyConfig.LR355, refH355, PollyConfig.refBeta355, mBsc355(iGrp,:), PollyConfig.smoothWin_klett_355);
    thisAerExt355_OC_klett = PollyConfig.LR355 * thisAerBsc355_OC_klett;
    thisAerExtStd355_OC_klett = PollyConfig.LR355 * thisAerBscStd355_OC_klett;

    data.aerBsc355_OC_klett(iGrp, :) = thisAerBsc355_OC_klett;
    data.aerBscStd355_OC_klett(iGrp, :) = thisAerBscStd355_OC_klett;
    data.aerExt355_OC_klett(iGrp, :) = thisAerExt355_OC_klett;
    data.aerExtStd355_OC_klett(iGrp, :) = thisAerExtStd355_OC_klett;
end

%% Klett method at 532 nm (overlap corrected)
data.aerBsc532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd532(iGrp, 1)) || (sum(flag532t) ~= 1)
        continue;
    end

    sig532 = transpose(squeeze(sum(data.sigOLCor532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg532 = transpose(squeeze(sum(bgOLCor532(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];

    [thisAerBsc532_OC_klett, thisAerBscStd532_OC_klett] = pollyFernald(data.distance0, sig532, bg532, PollyConfig.LR532, refH532, PollyConfig.refBeta532, mBsc532(iGrp,:), PollyConfig.smoothWin_klett_532);
    thisAerExt532_OC_klett = PollyConfig.LR532 * thisAerBsc532_OC_klett;
    thisAerExtStd532_OC_klett = PollyConfig.LR532 * thisAerBscStd532_OC_klett;

    data.aerBsc532_OC_klett(iGrp, :) = thisAerBsc532_OC_klett;
    data.aerBscStd532_OC_klett(iGrp, :) = thisAerBscStd532_OC_klett;
    data.aerExt532_OC_klett(iGrp, :) = thisAerExt532_OC_klett;
    data.aerExtStd532_OC_klett(iGrp, :) = thisAerExtStd532_OC_klett;
end

%% Klett method at 1064 nm (overlap corrected)
data.aerBsc1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    if isnan(data.refHInd1064(iGrp, 1)) || (sum(flag1064t) ~= 1)
        continue;
    end

    sig1064 = transpose(squeeze(sum(data.sigOLCor1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));
    bg1064 = transpose(squeeze(sum(bgOLCor1064(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2)));

    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
    
    [thisAerBsc1064_OC_klett, thisAerBscStd1064_OC_klett] = pollyFernald(data.distance0, sig1064, bg1064, PollyConfig.LR1064, refH1064, PollyConfig.refBeta1064, mBsc1064(iGrp,:), PollyConfig.smoothWin_klett_1064);
    thisAerExt1064_OC_klett = PollyConfig.LR1064 * thisAerBsc1064_OC_klett;
    thisAerExtStd1064_OC_klett = PollyConfig.LR1064 * thisAerBscStd1064_OC_klett;

    data.aerBsc1064_OC_klett(iGrp, :) = thisAerBsc1064_OC_klett;
    data.aerBscStd1064_OC_klett(iGrp, :) = thisAerBscStd1064_OC_klett;
    data.aerExt1064_OC_klett(iGrp, :) = thisAerExt1064_OC_klett;
    data.aerExtStd1064_OC_klett(iGrp, :) = thisAerExtStd1064_OC_klett;
end



%% Raman method (overlap corrected at 355 nm)
data.aerBsc355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask387Off);
    if (sum(flag355t) ~= 1) || (sum(flag387FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig355 = transpose(squeeze(sum(data.sigOLCor355(:, flagClFre), 2)));
    bg355 = transpose(squeeze(sum(bgOLCor355(:, flagClFre), 2)));
    sig387 = transpose(squeeze(sum(sigOLCor387(:, flagClFre), 2)));
    bg387 = transpose(squeeze(sum(bgOLCor387(:, flagClFre), 2)));
    
    [thisAerExt355_OC_raman,thisAerExtStd355_OC_raman] = pollyRamanExt_smart_MC(data.distance0, sig387, 355, 387, mExt355(iGrp,:), mExt387(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_355, 'moving',15,bg387);
    data.aerExt355_OC_raman(iGrp, :) = thisAerExt355_OC_raman;
    data.aerExtStd355_OC_raman(iGrp, :) = thisAerExtStd355_OC_raman;

    if isnan(data.refHInd355(iGrp, 1))
        continue;
    end

    refH355 = [data.distance0(data.refHInd355(iGrp, 1)), data.distance0(data.refHInd355(iGrp, 2))];
    hBaseInd355 = find(data.height >= PollyConfig.heightFullOverlap(flag355t) + PollyConfig.smoothWin_raman_355/2 * data.hRes, 1);

    if isempty(hBaseInd355)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd355 = 100;
    end

    SNRRef355 = pollySNR(sum(sig355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));
    SNRRef387 = pollySNR(sum(sig387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))), sum(bg387(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))));

    if (SNRRef355 < PollyConfig.minRamanRefSNR355) || (SNRRef387 < PollyConfig.minRamanRefSNR387)
        continue;
    end

    thisAerExt355_OC_raman_tmp = thisAerExt355_OC_raman;
    thisAerExt355_OC_raman(1:hBaseInd355) = thisAerExt355_OC_raman(hBaseInd355);
    [thisAerBsc355_OC_raman, ~] = pollyRamanBsc(data.distance0, sig355, sig387, thisAerExt355_OC_raman, PollyConfig.angstrexp, mExt355(iGrp,:), mBsc355(iGrp,:), refH355, 355, PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355, true);
    thisAerBscStd355_OC_raman = pollyRamanBscStd(data.distance0, sig355, bg355, sig387, bg387, thisAerExt355_OC_raman, thisAerExtStd355_OC_raman, PollyConfig.angstrexp, 0.2, mExt355(iGrp,:), mBsc355(iGrp,:), refH355, 355, PollyConfig.refBeta355, PollyConfig.smoothWin_raman_355, true);

    % lidar ratio
    [thisLR355_OC_raman, thisLRStd355_OC_raman] = pollyLR(thisAerExt355_OC_raman_tmp, thisAerBsc355_OC_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd355_OC_raman, 'aerBscStd', thisAerBscStd355_OC_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_355, 'smoothWInBsc', PollyConfig.smoothWin_raman_355);

    data.aerBsc355_OC_raman(iGrp, :) = thisAerBsc355_OC_raman;
    data.aerBscStd355_OC_raman(iGrp, :) = thisAerBscStd355_OC_raman;
    data.LR355_OC_raman(iGrp, :) = thisLR355_OC_raman;
    data.LRStd355_OC_raman(iGrp, :) = thisLRStd355_OC_raman;

end
clearvars bgOLCor355 bgOLCor355 bgOLCor387 sigOLCor387
%% Raman method (overlap corrected 532 nm)
data.aerBsc532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag532t) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig532 = transpose(squeeze(sum(data.sigOLCor532(:, flagClFre), 2)));
    bg532 = transpose(squeeze(sum(bgOLCor532(:, flagClFre), 2)));
    sig607 = transpose(squeeze(sum(sigOLCor607(:, flagClFre), 2)));
    bg607 = transpose(squeeze(sum(bgOLCor607(:, flagClFre), 2)));

    [thisAerExt532_OC_raman,thisAerExtStd532_OC_raman] = pollyRamanExt_smart_MC(data.distance0, sig607, 532, 607, mExt532(iGrp,:), mExt607(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_532, 'moving',15,bg607);
    data.aerExt532_OC_raman(iGrp, :) = thisAerExt532_OC_raman;
    data.aerExtStd532_OC_raman(iGrp, :) = thisAerExtStd532_OC_raman;

    if isnan(data.refHInd532(iGrp, 1))
        continue;
    end

    refH532 = [data.distance0(data.refHInd532(iGrp, 1)), data.distance0(data.refHInd532(iGrp, 2))];
    hBaseInd532 = find(data.height >= PollyConfig.heightFullOverlap(flag532t) + PollyConfig.smoothWin_raman_532/2 * data.hRes, 1);

    if isempty(hBaseInd532)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd532 = 100;
    end

    SNRRef532 = pollySNR(sum(sig532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))), sum(bg607(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))));

    if (SNRRef532 < PollyConfig.minRamanRefSNR532) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt532_OC_raman_tmp = thisAerExt532_OC_raman;
    thisAerExt532_OC_raman(1:hBaseInd532) = thisAerExt532_OC_raman(hBaseInd532);
    [thisAerBsc532_OC_raman, ~] = pollyRamanBsc(data.distance0, sig532, sig607, thisAerExt532_OC_raman, PollyConfig.angstrexp, mExt532(iGrp,:), mBsc532(iGrp,:), refH532, 532, PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532, true);
    thisAerBscStd532_OC_raman = pollyRamanBscStd(data.distance0, sig532, bg532, sig607, bg607, thisAerExt532_OC_raman, thisAerExtStd532_OC_raman, PollyConfig.angstrexp, 0.2, mExt532(iGrp,:), mBsc532(iGrp,:), refH532, 532, PollyConfig.refBeta532, PollyConfig.smoothWin_raman_532, true);

    % lidar ratio
    [thisLR532_OC_raman, thisLRStd532_OC_raman] = pollyLR(thisAerExt532_OC_raman_tmp, thisAerBsc532_OC_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', thisAerExtStd532_OC_raman, 'aerBscStd', thisAerBscStd532_OC_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_532, 'smoothWInBsc', PollyConfig.smoothWin_raman_532);

    data.aerBsc532_OC_raman(iGrp, :) = thisAerBsc532_OC_raman;
    data.aerBscStd532_OC_raman(iGrp, :) = thisAerBscStd532_OC_raman;
    data.LR532_OC_raman(iGrp, :) = thisLR532_OC_raman;
    data.LRStd532_OC_raman(iGrp, :) = thisLRStd532_OC_raman;

end
clearvars bgOLCor532 
%% Raman method (overlap corrected 1064 nm)
data.aerBsc1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerBscStd1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExt1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.aerExtStd1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LR1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.LRStd1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    flagClFre = false(size(data.mTime));
    flagClFre(clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)) = true;
    flagClFre = flagClFre & (~ data.mask607Off);
    if (sum(flag1064t) ~= 1) || (sum(flag607FR) ~= 1) || (sum(flagClFre) == 0)
        print_msg(sprintf('No Raman measurement during %s - %s\n', datestr(data.mTime(clFreGrps(iGrp, 1)), 'HH:MM'), datestr(data.mTime(clFreGrps(iGrp, 2)), 'HH:MM')), 'flagSimpleMsg', true);

        continue;
    end

    sig1064 = transpose(squeeze(sum(data.sigOLCor1064(:, flagClFre), 2)));
    bg1064 = transpose(squeeze(sum(bgOLCor1064(:, flagClFre), 2)));
    sig607 = transpose(squeeze(sum(sigOLCor607(:, flagClFre), 2)));
    bg607 = transpose(squeeze(sum(bgOLCor607(:, flagClFre), 2)));
    
    [thisAerExt1064_OC_raman,thisAerExtStd1064_OC_raman] = pollyRamanExt_smart_MC(data.distance0, sig607, 532, 607, mExt532(iGrp,:), mExt607(iGrp,:), number_density(iGrp, :), PollyConfig.angstrexp, PollyConfig.smoothWin_raman_1064, 'moving',15,bg607);
    thisAerExt1064_OC_raman = thisAerExt1064_OC_raman / (1064/532).^PollyConfig.angstrexp;
    data.aerExt1064_OC_raman(iGrp, :) = thisAerExt1064_OC_raman;
    data.aerExtStd1064_OC_raman(iGrp, :) = thisAerExtStd1064_OC_raman;

    if isnan(data.refHInd1064(iGrp, 1))
        continue;
    end

    refH1064 = [data.distance0(data.refHInd1064(iGrp, 1)), data.distance0(data.refHInd1064(iGrp, 2))];
    hBaseInd1064 = find(data.height >= PollyConfig.heightFullOverlap(flag1064t) + PollyConfig.smoothWin_raman_1064/2 * data.hRes, 1);

    if isempty(hBaseInd1064)
        print_msg(sprintf('Failure in searching index of mininum height. Set the index of the minimum integral range to be 100.\n'), 'flagSimpleMsg', true);
        hBaseInd1064 = 100;
    end

    SNRRef1064 = pollySNR(sum(sig1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));
    SNRRef607 = pollySNR(sum(sig607(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))), sum(bg607(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))));

    if (SNRRef1064 < PollyConfig.minRamanRefSNR1064) || (SNRRef607 < PollyConfig.minRamanRefSNR607)
        continue;
    end

    thisAerExt1064_OC_raman_tmp = thisAerExt1064_OC_raman;
    thisAerExt1064_OC_raman(1:hBaseInd1064) = thisAerExt1064_OC_raman(hBaseInd1064);
    [thisAerBsc1064_OC_raman, ~] = pollyRamanBsc(data.distance0, sig1064, sig607, thisAerExt1064_OC_raman, PollyConfig.angstrexp, mExt1064(iGrp,:), mBsc1064(iGrp,:), refH1064, 1064, PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064, true);
    thisAerBscStd1064_OC_raman = pollyRamanBscStd(data.distance0, sig1064, bg1064, sig607, bg607, thisAerExt1064_OC_raman, thisAerExtStd1064_OC_raman, PollyConfig.angstrexp, 0.2, mExt1064(iGrp,:), mBsc1064(iGrp,:), refH1064, 1064, PollyConfig.refBeta1064, PollyConfig.smoothWin_raman_1064, true);

    % lidar ratio
    [thisLR1064_OC_raman, thisLRStd1064_OC_raman] = pollyLR(thisAerExt1064_OC_raman_tmp, thisAerBsc1064_OC_raman, ...
        'hRes', data.hRes, ...
        'aerExtStd', data.aerExtStd1064_OC_raman(iGrp, :), 'aerBscStd', thisAerBscStd1064_OC_raman, ...
        'smoothWinExt', PollyConfig.smoothWin_raman_1064, 'smoothWInBsc', PollyConfig.smoothWin_raman_1064);
%HB check why above data.aerExtStd1064_OC_raman(iGrp, :) is used and not thisaerExtStd1064_OC_raman
    data.aerBsc1064_OC_raman(iGrp, :) = thisAerBsc1064_OC_raman;
    data.aerBscStd1064_OC_raman(iGrp, :) = thisAerBscStd1064_OC_raman;
    data.LR1064_OC_raman(iGrp, :) = thisLR1064_OC_raman;
    data.LRStd1064_OC_raman(iGrp, :) = thisLRStd1064_OC_raman;

end
clearvars bgOLCor607 bgOLCor1064 sigOLCor607
%% Volume depolarization ratio new implemantation 
if flagGHK
    print_msg('Calculating volume depolarization ratio with GHK.\n', 'flagTimestamp', true);
    % 355 nm
    %%Klett
    smoothWin=PollyConfig.smoothWin_klett_355;
    [data.vdr355_klett,data.vdrStd355_klett] = pollyVDRModuleGHK(data,clFreGrps,flag355t,flag355c,data.polCaliEta355, PollyConfig.voldepol_error_355, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_355;
    [data.vdr355_raman,data.vdrStd355_raman] = pollyVDRModuleGHK(data,clFreGrps,flag355t,flag355c,data.polCaliEta355, PollyConfig.voldepol_error_355, smoothWin, PollyConfig);
    
    % 532 nm
    %%Klett
    smoothWin=PollyConfig.smoothWin_klett_532;
    [data.vdr532_klett,data.vdrStd532_klett] = pollyVDRModuleGHK(data,clFreGrps,flag532t,flag532c,data.polCaliEta532, PollyConfig.voldepol_error_532, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_532;
    [data.vdr532_raman,data.vdrStd532_raman] = pollyVDRModuleGHK(data,clFreGrps,flag532t,flag532c,data.polCaliEta532, PollyConfig.voldepol_error_532, smoothWin, PollyConfig);

    % 1064 nm
    %%Klett
    smoothWin=PollyConfig.smoothWin_klett_1064;
    [data.vdr1064_klett,data.vdrStd1064_klett] = pollyVDRModuleGHK(data,clFreGrps,flag1064t,flag1064c,data.polCaliEta1064, PollyConfig.voldepol_error_1064, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_1064;
    [data.vdr1064_raman,data.vdrStd1064_raman] = pollyVDRModuleGHK(data,clFreGrps,flag1064t,flag1064c,data.polCaliEta1064, PollyConfig.voldepol_error_1064, smoothWin, PollyConfig);

else
    %%Klett
    polCaliFac=data.polCaliFac355;
    polCaliFacStd= data.polCaliFacStd355;
    smoothWin=PollyConfig.smoothWin_klett_355;
    [data.vdr355_klett,data.vdrStd355_klett] = pollyVDRModule(data,clFreGrps,flag355t,flag355c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_355;
    [data.vdr355_raman,data.vdrStd355_raman] = pollyVDRModule(data,clFreGrps,flag355t,flag355c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);

    %% Volume depolarization ratio at 532 nm new implemantation 
    %%Klett
    polCaliFac=data.polCaliFac532;
    polCaliFacStd= data.polCaliFacStd532;
    smoothWin=PollyConfig.smoothWin_klett_532;
    [data.vdr532_klett,data.vdrStd532_klett] = pollyVDRModule(data,clFreGrps,flag532t,flag532c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_532;
    [data.vdr532_raman,data.vdrStd532_raman] = pollyVDRModule(data,clFreGrps,flag532t,flag532c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);

    %% Volume depolarization ratio at 1064 nm new implemantation 
    %%Klett
    polCaliFac=data.polCaliFac1064;
    polCaliFacStd= data.polCaliFacStd1064;
    smoothWin=PollyConfig.smoothWin_klett_1064;
    [data.vdr1064_klett,data.vdrStd1064_klett] = pollyVDRModule(data,clFreGrps,flag1064t,flag1064c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);
    %Raman
    smoothWin=PollyConfig.smoothWin_raman_1064;
    [data.vdr1064_raman,data.vdrStd1064_raman] = pollyVDRModule(data,clFreGrps,flag1064t,flag1064c,polCaliFac, polCaliFacStd, smoothWin, PollyConfig);
end


%% Particle depolarization ratio at 355 nm

if flagGHK
    data.pdr355_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr355 = NaN(size(clFreGrps, 1), 1);
    mdrStd355 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr355 = true(size(clFreGrps, 1), 1);
    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag355t) ~= 1) || (sum(flag355c) ~= 1) || isnan(data.refHInd355(iGrp, 1))
            continue;
        end

        sig355T = squeeze(sum(data.signal(flag355t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg355T = squeeze(sum(data.bg(flag355t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig355C = squeeze(sum(data.signal(flag355c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg355C = squeeze(sum(data.bg(flag355c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

        [thisMdr355, thisMdrStd355, thisFlagDeftMdr355] = pollyMDRGHK(...
            sig355T(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            bg355T(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            sig355C(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            bg355C(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            flag355t,flag355c, ...
            data.polCaliEta355, PollyConfig.voldepol_error_355, 10, ...
            PollyDefaults.molDepol355, PollyDefaults.molDepolStd355, PollyConfig);
        data.mdr355(iGrp) = thisMdr355;
        mdrStd355(iGrp) = thisMdrStd355;
        flagDeftMdr355(iGrp) = thisFlagDeftMdr355;
        if PollyConfig.flagUseTheoreticalMDR
            thisMdr355 = PollyDefaults.molDepol355; % to do: implement the temperature dependence of the molecular depolarization ratio
        end
        % still the "adapted" method is implemented where the MDR in the reference height is used to calculate the PDR (instead of the temperature dependent theoretical MDR)
        if ~ isnan(data.aerBsc355_klett(iGrp, 80))
            [thisPdr355_klett, thisPdrStd355_klett] = pollyPDR(data.vdr355_klett(iGrp, :), data.vdrStd355_klett(iGrp, :), data.aerBsc355_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_klett(iGrp, :) = thisPdr355_klett;
            data.pdrStd355_klett(iGrp, :) = thisPdrStd355_klett;
        end

        if ~ isnan(data.aerBsc355_raman(iGrp, 80))
            [thisPdr355_raman, thisPdrStd355_raman] = pollyPDR(data.vdr355_raman(iGrp, :), data.vdrStd355_raman(iGrp, :), data.aerBsc355_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_raman(iGrp, :) = thisPdr355_raman;
            data.pdrStd355_raman(iGrp, :) = thisPdrStd355_raman;
        end

        if ~ isnan(data.aerBsc355_OC_klett(iGrp, 80))
            [thisPdr355_OC_klett, thisPdrStd355_OC_klett] = pollyPDR(data.vdr355_klett(iGrp, :), data.vdrStd355_klett(iGrp, :), data.aerBsc355_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_OC_klett(iGrp, :) = thisPdr355_OC_klett;
            data.pdrStd355_OC_klett(iGrp, :) = thisPdrStd355_OC_klett;
        end

        if ~ isnan(data.aerBsc355_OC_raman(iGrp, 80))
            [thisPdr355_OC_raman, thisPdrStd355_OC_raman] = pollyPDR(data.vdr355_raman(iGrp, :), data.vdrStd355_raman(iGrp, :), data.aerBsc355_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_OC_raman(iGrp, :) = thisPdr355_OC_raman;
            data.pdrStd355_OC_raman(iGrp, :) = thisPdrStd355_OC_raman;
        end
    end
else
    data.pdr355_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd355_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr355 = NaN(size(clFreGrps, 1), 1);
    mdrStd355 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr355 = true(size(clFreGrps, 1), 1);
    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag355t) ~= 1) || (sum(flag355c) ~= 1) || isnan(data.refHInd355(iGrp, 1))
            continue;
        end

        sig355T = squeeze(sum(data.signal(flag355t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg355T = squeeze(sum(data.bg(flag355t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig355C = squeeze(sum(data.signal(flag355c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg355C = squeeze(sum(data.bg(flag355c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

        [thisMdr355, thisMdrStd355, thisFlagDeftMdr355] = pollyMDR(...
            sig355T(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            bg355T(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            sig355C(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            bg355C(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)), ...
            PollyConfig.TR(flag355t), 0, ...
            PollyConfig.TR(flag355c), 0, ...
            data.polCaliFac355, data.polCaliFacStd355, 10, ...
            PollyDefaults.molDepol355, PollyDefaults.molDepolStd355);
        data.mdr355(iGrp) = thisMdr355;
        mdrStd355(iGrp) = thisMdrStd355;
        flagDeftMdr355(iGrp) = thisFlagDeftMdr355;

        if ~ isnan(data.aerBsc355_klett(iGrp, 80))
            [thisPdr355_klett, thisPdrStd355_klett] = pollyPDR(data.vdr355_klett(iGrp, :), data.vdrStd355_klett(iGrp, :), data.aerBsc355_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_klett(iGrp, :) = thisPdr355_klett;
            data.pdrStd355_klett(iGrp, :) = thisPdrStd355_klett;
        end

        if ~ isnan(data.aerBsc355_raman(iGrp, 80))
            [thisPdr355_raman, thisPdrStd355_raman] = pollyPDR(data.vdr355_raman(iGrp, :), data.vdrStd355_raman(iGrp, :), data.aerBsc355_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_raman(iGrp, :) = thisPdr355_raman;
            data.pdrStd355_raman(iGrp, :) = thisPdrStd355_raman;
        end

        if ~ isnan(data.aerBsc355_OC_klett(iGrp, 80))
            [thisPdr355_OC_klett, thisPdrStd355_OC_klett] = pollyPDR(data.vdr355_klett(iGrp, :), data.vdrStd355_klett(iGrp, :), data.aerBsc355_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_OC_klett(iGrp, :) = thisPdr355_OC_klett;
            data.pdrStd355_OC_klett(iGrp, :) = thisPdrStd355_OC_klett;
        end

        if ~ isnan(data.aerBsc355_OC_raman(iGrp, 80))
            [thisPdr355_OC_raman, thisPdrStd355_OC_raman] = pollyPDR(data.vdr355_raman(iGrp, :), data.vdrStd355_raman(iGrp, :), data.aerBsc355_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc355(iGrp,:), thisMdr355, thisMdrStd355);
            data.pdr355_OC_raman(iGrp, :) = thisPdr355_OC_raman;
            data.pdrStd355_OC_raman(iGrp, :) = thisPdrStd355_OC_raman;
        end
    end
end
    %% Particle depolarization ratio at 532 nm
if flagGHK
    data.pdr532_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr532 = NaN(size(clFreGrps, 1), 1);
    mdrStd532 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr532 = true(size(clFreGrps, 1), 1);

    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag532t) ~= 1) || (sum(flag532c) ~= 1) || isnan(data.refHInd532(iGrp, 1))
            continue;
        end

        sig532T = squeeze(sum(data.signal(flag532t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg532T = squeeze(sum(data.bg(flag532t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig532C = squeeze(sum(data.signal(flag532c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg532C = squeeze(sum(data.bg(flag532c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

       [thisMdr532, thisMdrStd532, thisFlagDeftMdr532] = pollyMDRGHK(...
            sig532T(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            bg532T(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            sig532C(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            bg532C(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            flag532t,flag532c, ...
            data.polCaliEta532, PollyConfig.voldepol_error_532, 10, ...
            PollyDefaults.molDepol532, PollyDefaults.molDepolStd532, PollyConfig);
        data.mdr532(iGrp) = thisMdr532;
        mdrStd532(iGrp) = thisMdrStd532;
        flagDeftMdr532(iGrp) = thisFlagDeftMdr532;
        % still the "adapted" method is implemented where the MDR in the reference height is used to calculate the PDR (instead of the temperature dependent theoretical MDR)
        if PollyConfig.flagUseTheoreticalMDR
            thisMdr532 = PollyDefaults.molDepol532; % to do: implement the temperature dependence of the molecular depolarization ratio
        end
        if ~ isnan(data.aerBsc532_klett(iGrp, 80))
            [thisPdr532_klett, thisPdrStd532_klett] = pollyPDR(data.vdr532_klett(iGrp, :), data.vdrStd532_klett(iGrp, :), data.aerBsc532_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_klett(iGrp, :) = thisPdr532_klett;
            data.pdrStd532_klett(iGrp, :) = thisPdrStd532_klett;
        end

        if ~ isnan(data.aerBsc532_raman(iGrp, 80))
            [thisPdr532_raman, thisPdrStd532_raman] = pollyPDR(data.vdr532_raman(iGrp, :), data.vdrStd532_raman(iGrp, :), data.aerBsc532_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_raman(iGrp, :) = thisPdr532_raman;
            data.pdrStd532_raman(iGrp, :) = thisPdrStd532_raman;
        end

        if ~ isnan(data.aerBsc532_OC_klett(iGrp, 80))
            [thisPdr532_OC_klett, thisPdrStd532_OC_klett] = pollyPDR(data.vdr532_klett(iGrp, :), data.vdrStd532_klett(iGrp, :), data.aerBsc532_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_OC_klett(iGrp, :) = thisPdr532_OC_klett;
            data.pdrStd532_OC_klett(iGrp, :) = thisPdrStd532_OC_klett;
        end

        if ~ isnan(data.aerBsc532_OC_raman(iGrp, 80))
            [thisPdr532_OC_raman, thisPdrStd532_OC_raman] = pollyPDR(data.vdr532_raman(iGrp, :), data.vdrStd532_raman(iGrp, :), data.aerBsc532_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_OC_raman(iGrp, :) = thisPdr532_OC_raman;
            data.pdrStd532_OC_raman(iGrp, :) = thisPdrStd532_OC_raman;
        end
    end
else
    data.pdr532_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr532 = NaN(size(clFreGrps, 1), 1);
    mdrStd532 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr532 = true(size(clFreGrps, 1), 1);

    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag532t) ~= 1) || (sum(flag532c) ~= 1) || isnan(data.refHInd532(iGrp, 1))
            continue;
        end

        sig532T = squeeze(sum(data.signal(flag532t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg532T = squeeze(sum(data.bg(flag532t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig532C = squeeze(sum(data.signal(flag532c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg532C = squeeze(sum(data.bg(flag532c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

       [thisMdr532, thisMdrStd532, thisFlagDeftMdr532] = pollyMDR(...
            sig532T(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            bg532T(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            sig532C(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            bg532C(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)), ...
            PollyConfig.TR(flag532t), 0, ...
            PollyConfig.TR(flag532c), 0, ...
            data.polCaliFac532, data.polCaliFacStd532, 10, ...
            PollyDefaults.molDepol532, PollyDefaults.molDepolStd532);
        data.mdr532(iGrp) = thisMdr532;
        mdrStd532(iGrp) = thisMdrStd532;
        flagDeftMdr532(iGrp) = thisFlagDeftMdr532;

        if ~ isnan(data.aerBsc532_klett(iGrp, 80))
            [thisPdr532_klett, thisPdrStd532_klett] = pollyPDR(data.vdr532_klett(iGrp, :), data.vdrStd532_klett(iGrp, :), data.aerBsc532_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_klett(iGrp, :) = thisPdr532_klett;
            data.pdrStd532_klett(iGrp, :) = thisPdrStd532_klett;
        end

        if ~ isnan(data.aerBsc532_raman(iGrp, 80))
            [thisPdr532_raman, thisPdrStd532_raman] = pollyPDR(data.vdr532_raman(iGrp, :), data.vdrStd532_raman(iGrp, :), data.aerBsc532_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_raman(iGrp, :) = thisPdr532_raman;
            data.pdrStd532_raman(iGrp, :) = thisPdrStd532_raman;
        end

        if ~ isnan(data.aerBsc532_OC_klett(iGrp, 80))
            [thisPdr532_OC_klett, thisPdrStd532_OC_klett] = pollyPDR(data.vdr532_klett(iGrp, :), data.vdrStd532_klett(iGrp, :), data.aerBsc532_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_OC_klett(iGrp, :) = thisPdr532_OC_klett;
            data.pdrStd532_OC_klett(iGrp, :) = thisPdrStd532_OC_klett;
        end

        if ~ isnan(data.aerBsc532_OC_raman(iGrp, 80))
            [thisPdr532_OC_raman, thisPdrStd532_OC_raman] = pollyPDR(data.vdr532_raman(iGrp, :), data.vdrStd532_raman(iGrp, :), data.aerBsc532_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc532(iGrp,:), thisMdr532, thisMdrStd532);
            data.pdr532_OC_raman(iGrp, :) = thisPdr532_OC_raman;
            data.pdrStd532_OC_raman(iGrp, :) = thisPdrStd532_OC_raman;
        end
    end
end
%% Particle depolarization ratio at 1064 nm
if flagGHK
    data.pdr1064_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd1064_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr1064_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd1064_raman = NaN(size(clFreGrps, 1), length(data.height));
    pdr1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    pdr1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    pdrStd1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    pdrStd1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr1064 = NaN(size(clFreGrps, 1), 1);
    mdrStd1064 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr1064 = true(size(clFreGrps, 1), 1);

    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag1064t) ~= 1) || (sum(flag1064c) ~= 1) || isnan(data.refHInd1064(iGrp, 1))
            continue;
        end

        sig1064T = squeeze(sum(data.signal(flag1064t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg1064T = squeeze(sum(data.bg(flag1064t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig1064C = squeeze(sum(data.signal(flag1064c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg1064C = squeeze(sum(data.bg(flag1064c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

        [thisMdr1064, thisMdrStd1064, thisFlagDeftMdr1064] = pollyMDRGHK(...
            sig1064T(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            bg1064T(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            sig1064C(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            bg1064C(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            flag532t,flag532c, ...
            data.polCaliEta1064, PollyConfig.voldepol_error_1064, 10, ...
            PollyDefaults.molDepol1064, PollyDefaults.molDepolStd1064, PollyConfig);
        data.mdr1064(iGrp) = thisMdr1064;
        mdrStd1064(iGrp) = thisMdrStd1064;
        flagDeftMdr1064(iGrp) = thisFlagDeftMdr1064;
        % still the "adapted" method is implemented where the MDR in the reference height is used to calculate the PDR (instead of the temperature dependent theoretical MDR)
        if PollyConfig.flagUseTheoreticalMDR
            thisMdr1064 = PollyDefaults.molDepol1064; % to do: implement the temperature dependence of the molecular depolarization ratio
        end
        if ~ isnan(data.aerBsc1064_klett(iGrp, 80))
            [thisPdr1064_klett, thisPdrStd1064_klett] = pollyPDR(data.vdr1064_klett(iGrp, :), data.vdrStd1064_klett(iGrp, :), data.aerBsc1064_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            data.pdr1064_klett(iGrp, :) = thisPdr1064_klett;
            data.pdrStd1064_klett(iGrp, :) = thisPdrStd1064_klett;
        end

        if ~ isnan(data.aerBsc1064_raman(iGrp, 80))
            [thisPdr1064_raman, thisPdrStd1064_raman] = pollyPDR(data.vdr1064_raman(iGrp, :), data.vdrStd1064_raman(iGrp, :), data.aerBsc1064_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            data.pdr1064_raman(iGrp, :) = thisPdr1064_raman;
            data.pdrStd1064_raman(iGrp, :) = thisPdrStd1064_raman;
        end

        if ~ isnan(data.aerBsc1064_OC_klett(iGrp, 80))
            [thisPdr1064_OC_klett, thisPdrStd1064_OC_klett] = pollyPDR(data.vdr1064_klett(iGrp, :), data.vdrStd1064_klett(iGrp, :), data.aerBsc1064_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            pdr1064_OC_klett(iGrp, :) = thisPdr1064_OC_klett;
            pdrStd1064_OC_klett(iGrp, :) = thisPdrStd1064_OC_klett;
        end

        if ~ isnan(data.aerBsc1064_OC_raman(iGrp, 80))
            [thisPdr1064_OC_raman, thisPdrStd1064_OC_raman] = pollyPDR(data.vdr1064_raman(iGrp, :), data.vdrStd1064_raman(iGrp, :), data.aerBsc1064_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            pdr1064_OC_raman(iGrp, :) = thisPdr1064_OC_raman;
            pdrStd1064_OC_raman(iGrp, :) = thisPdrStd1064_OC_raman;
        end
    end
    
else
    data.pdr1064_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd1064_klett = NaN(size(clFreGrps, 1), length(data.height));
    data.pdr1064_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.pdrStd1064_raman = NaN(size(clFreGrps, 1), length(data.height));
    pdr1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    pdr1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    pdrStd1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
    pdrStd1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
    data.mdr1064 = NaN(size(clFreGrps, 1), 1);
    mdrStd1064 = NaN(size(clFreGrps, 1), 1);
    flagDeftMdr1064 = true(size(clFreGrps, 1), 1);

    for iGrp = 1:size(clFreGrps, 1)

        if (sum(flag1064t) ~= 1) || (sum(flag1064c) ~= 1) || isnan(data.refHInd1064(iGrp, 1))
            continue;
        end

        sig1064T = squeeze(sum(data.signal(flag1064t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg1064T = squeeze(sum(data.bg(flag1064t, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        sig1064C = squeeze(sum(data.signal(flag1064c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
        bg1064C = squeeze(sum(data.bg(flag1064c, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

        [thisMdr1064, thisMdrStd1064, thisFlagDeftMdr1064] = pollyMDR(...
            sig1064T(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            bg1064T(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            sig1064C(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            bg1064C(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)), ...
            PollyConfig.TR(flag1064t), 0, ...
            PollyConfig.TR(flag1064c), 0, ...
            data.polCaliFac1064, data.polCaliFacStd1064, 10, ...
            PollyDefaults.molDepol1064, PollyDefaults.molDepolStd1064);
        data.mdr1064(iGrp) = thisMdr1064;
        mdrStd1064(iGrp) = thisMdrStd1064;
        flagDeftMdr1064(iGrp) = thisFlagDeftMdr1064;

        if ~ isnan(data.aerBsc1064_klett(iGrp, 80))
            [thisPdr1064_klett, thisPdrStd1064_klett] = pollyPDR(data.vdr1064_klett(iGrp, :), data.vdrStd1064_klett(iGrp, :), data.aerBsc1064_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            data.pdr1064_klett(iGrp, :) = thisPdr1064_klett;
            data.pdrStd1064_klett(iGrp, :) = thisPdrStd1064_klett;
        end

        if ~ isnan(data.aerBsc1064_raman(iGrp, 80))
            [thisPdr1064_raman, thisPdrStd1064_raman] = pollyPDR(data.vdr1064_raman(iGrp, :), data.vdrStd1064_raman(iGrp, :), data.aerBsc1064_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            data.pdr1064_raman(iGrp, :) = thisPdr1064_raman;
            data.pdrStd1064_raman(iGrp, :) = thisPdrStd1064_raman;
        end

        if ~ isnan(data.aerBsc1064_OC_klett(iGrp, 80))
            [thisPdr1064_OC_klett, thisPdrStd1064_OC_klett] = pollyPDR(data.vdr1064_klett(iGrp, :), data.vdrStd1064_klett(iGrp, :), data.aerBsc1064_OC_klett(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            pdr1064_OC_klett(iGrp, :) = thisPdr1064_OC_klett;
            pdrStd1064_OC_klett(iGrp, :) = thisPdrStd1064_OC_klett;
        end

        if ~ isnan(data.aerBsc1064_OC_raman(iGrp, 80))
            [thisPdr1064_OC_raman, thisPdrStd1064_OC_raman] = pollyPDR(data.vdr1064_raman(iGrp, :), data.vdrStd1064_raman(iGrp, :), data.aerBsc1064_OC_raman(iGrp, :), ones(1, length(data.height)) * 1e-7, mBsc1064(iGrp,:), thisMdr1064, thisMdrStd1064);
            pdr1064_OC_raman(iGrp, :) = thisPdr1064_OC_raman;
            pdrStd1064_OC_raman(iGrp, :) = thisPdrStd1064_OC_raman;
        end
    end
end
%% (Near-field) Angstroem exponent (Klett/Fernald/Raman method retrieved parameters)
data.AE_Bsc_355_532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_NR_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Ext_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Ext_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_NR_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Angstroem exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(data.aerExt355_NR_klett(iGrp, 60))) && (~ isnan(data.aerExt355_NR_klett(iGrp, 60)))  %check what the 60 mean HB
        [thisAE_Bsc_355_532_NR_klett, thisAEStd_Bsc_355_532_NR_klett] = pollyAE(data.aerBsc355_NR_klett(iGrp, :), zeros(size(data.height)), data.aerBsc532_NR_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_NR_532);
        data.AE_Bsc_355_532_NR_klett(iGrp, :) = thisAE_Bsc_355_532_NR_klett;
        data.AEStd_Bsc_355_532_NR_klett(iGrp, :) = thisAEStd_Bsc_355_532_NR_klett;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerExt355_NR_raman(iGrp, 80))) && (~ isnan(data.aerExt532_NR_raman(iGrp, 80)))
        [thisAE_Ext_355_532_NR_raman, thisAEStd_Ext_355_532_NR_raman] = pollyAE(data.aerExt355_NR_raman(iGrp, :), zeros(size(data.height)), data.aerExt532_NR_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_NR_532);
        data.AE_Ext_355_532_NR_raman(iGrp, :) = thisAE_Ext_355_532_NR_raman;
        data.AEStd_Ext_355_532_NR_raman(iGrp, :) = thisAEStd_Ext_355_532_NR_raman;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerBsc355_NR_raman(iGrp, 80))) && (~ isnan(data.aerBsc532_NR_raman(iGrp, 80)))
        [thisAE_Bsc_355_532_NR_raman, thisAEStd_Bsc_355_532_NR_raman] = pollyAE(data.aerBsc355_NR_raman(iGrp, :), zeros(size(data.height)), data.aerBsc532_NR_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_NR_532);
        data.AE_Bsc_355_532_NR_raman(iGrp, :) = thisAE_Bsc_355_532_NR_raman;
        data.AEStd_Bsc_355_532_NR_raman(iGrp, :) = thisAEStd_Bsc_355_532_NR_raman;
    end
end

% Angstroem exponent (Klett/Fernald/Raman method retrieved parameters)
data.AE_Bsc_355_532_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_532_1064_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_532_1064_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Ext_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Ext_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_532_1064_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_532_1064_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Angstroem exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(data.refHInd355(iGrp, 1))) && (~ isnan(data.refHInd532(iGrp, 1)))
        [thisAE_Bsc_355_532_klett, thisAEStd_Bsc_355_532_klett] = pollyAE(data.aerBsc355_klett(iGrp, :), zeros(size(data.height)), data.aerBsc532_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_532);
        data.AE_Bsc_355_532_klett(iGrp, :) = thisAE_Bsc_355_532_klett;
        data.AEStd_Bsc_355_532_klett(iGrp, :) = thisAEStd_Bsc_355_532_klett;
    end

    % Angstroem exponent 532-1064 (based on parameters by Klett method)
    if (~ isnan(data.refHInd532(iGrp, 1))) && (~ isnan(data.refHInd1064(iGrp, 1)))
        [thisAE_Bsc_532_1064_klett, thisAEStd_Bsc_532_1064_klett] = pollyAE(data.aerBsc532_klett(iGrp, :), zeros(size(data.height)), data.aerBsc1064_klett(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_klett_1064);
        data.AE_Bsc_532_1064_klett(iGrp, :) = thisAE_Bsc_532_1064_klett;
        data.AEStd_Bsc_532_1064_klett(iGrp, :) = thisAEStd_Bsc_532_1064_klett;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerExt355_raman(iGrp, 80))) && (~ isnan(data.aerExt532_raman(iGrp, 80)))
        [thisAE_Ext_355_532_raman, thisAEStd_Ext_355_532_raman] = pollyAE(data.aerExt355_raman(iGrp, :), zeros(size(data.height)), data.aerExt532_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        data.AE_Ext_355_532_raman(iGrp, :) = thisAE_Ext_355_532_raman;
        data.AEStd_Ext_355_532_raman(iGrp, :) = thisAEStd_Ext_355_532_raman;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerBsc355_raman(iGrp, 80))) && (~ isnan(data.aerBsc532_raman(iGrp, 80)))
        [thisAE_Bsc_355_532_raman, thisAEStd_Bsc_355_532_raman] = pollyAE(data.aerBsc355_raman(iGrp, :), zeros(size(data.height)), data.aerBsc532_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
       data.AE_Bsc_355_532_raman(iGrp, :) = thisAE_Bsc_355_532_raman;
        data.AEStd_Bsc_355_532_raman(iGrp, :) = thisAEStd_Bsc_355_532_raman;
    end

    % Angstroem exponent 532-1064 (based on parameters by Raman method)
    if (~ isnan(data.aerBsc532_raman(iGrp, 80))) && (~ isnan(data.aerBsc1064_raman(iGrp, 80)))
        [thisAE_Bsc_532_1064_raman, thisAEStd_Bsc_532_1064_raman] = pollyAE(data.aerBsc532_raman(iGrp, :), zeros(size(data.height)), data.aerBsc1064_raman(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_raman_1064);
        data.AE_Bsc_532_1064_raman(iGrp, :) = thisAE_Bsc_532_1064_raman;
        data.AEStd_Bsc_532_1064_raman(iGrp, :) = thisAEStd_Bsc_532_1064_raman;
    end
end

% (Overlap corrected) Angstroem exponent (Klett/Fernald/Raman method retrieved parameters)
data.AE_Bsc_355_532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_532_1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_532_1064_OC_klett = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Ext_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Ext_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_355_532_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AE_Bsc_532_1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));
data.AEStd_Bsc_532_1064_OC_raman = NaN(size(clFreGrps, 1), length(data.height));

for iGrp = 1:size(clFreGrps, 1)

    % Angstroem exponent 355-532 (based on parameters by Klett method)
    if (~ isnan(data.refHInd355(iGrp, 1))) && (~ isnan(data.refHInd532(iGrp, 1)))
        [thisAE_Bsc_355_532_OC_klett, thisAEStd_Bsc_355_532_OC_klett] = pollyAE(data.aerBsc355_OC_klett(iGrp, :), zeros(size(data.height)), data.aerBsc532_OC_klett(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_klett_532);
        data.AE_Bsc_355_532_OC_klett(iGrp, :) = thisAE_Bsc_355_532_OC_klett;
        data.AEStd_Bsc_355_532_OC_klett(iGrp, :) = thisAEStd_Bsc_355_532_OC_klett;
    end

    % Angstroem exponent 532-1064 (based on parameters by Klett method)
    if (~ isnan(data.refHInd532(iGrp, 1))) && (~ isnan(data.refHInd1064(iGrp, 1)))
        [thisAE_Bsc_532_1064_OC_klett, thisAEStd_Bsc_532_1064_OC_klett] = pollyAE(data.aerBsc532_OC_klett(iGrp, :), zeros(size(data.height)), data.aerBsc1064_OC_klett(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_klett_1064);
        data.AE_Bsc_532_1064_OC_klett(iGrp, :) = thisAE_Bsc_532_1064_OC_klett;
        data.AEStd_Bsc_532_1064_OC_klett(iGrp, :) = thisAEStd_Bsc_532_1064_OC_klett;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerExt355_OC_raman(iGrp, 80))) && (~ isnan(data.aerExt532_OC_raman(iGrp, 80)))
        [thisAE_Ext_355_532_OC_raman, thisAEStd_Ext_355_532_OC_raman] = pollyAE(data.aerExt355_OC_raman(iGrp, :), zeros(size(data.height)), data.aerExt532_OC_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        data.AE_Ext_355_532_OC_raman(iGrp, :) = thisAE_Ext_355_532_OC_raman;
        data.AEStd_Ext_355_532_OC_raman(iGrp, :) = thisAEStd_Ext_355_532_OC_raman;
    end

    % Angstroem exponent 355-532 (based on parameters by Raman method)
    if (~ isnan(data.aerBsc355_OC_raman(iGrp, 80))) && (~ isnan(data.aerBsc532_OC_raman(iGrp, 80)))
        [thisAE_Bsc_355_532_OC_raman, thisAEStd_Bsc_355_532_OC_raman] = pollyAE(data.aerBsc355_OC_raman(iGrp, :), zeros(size(data.height)), data.aerBsc532_OC_raman(iGrp, :), zeros(size(data.height)), 355, 532, PollyConfig.smoothWin_raman_532);
        data.AE_Bsc_355_532_OC_raman(iGrp, :) = thisAE_Bsc_355_532_OC_raman;
        data.AEStd_Bsc_355_532_OC_raman(iGrp, :) = thisAEStd_Bsc_355_532_OC_raman;
    end

    % Angstroem exponent 532-1064 (based on parameters by Raman method)
    if (~ isnan(data.aerBsc532_OC_raman(iGrp, 80))) && (~ isnan(data.aerBsc1064_OC_raman(iGrp, 80)))
        [thisAE_Bsc_532_1064_OC_raman, thisAEStd_Bsc_532_1064_OC_raman] = pollyAE(data.aerBsc532_OC_raman(iGrp, :), zeros(size(data.height)), data.aerBsc1064_OC_raman(iGrp, :), zeros(size(data.height)), 532, 1064, PollyConfig.smoothWin_raman_1064);
        data.AE_Bsc_532_1064_OC_raman(iGrp, :) = thisAE_Bsc_532_1064_OC_raman;
        data.AEStd_Bsc_532_1064_OC_raman(iGrp, :) = thisAEStd_Bsc_532_1064_OC_raman;
    end
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% POLIPHON (1-step)
% % print_msg('Start 1-step POLIPHON\n', 'flagTimestamp', true);

[data.POLIPHON1] = poliphon_one ...
    (data.aerBsc355_klett, data.pdr355_klett, ...
    data.aerBsc532_klett, data.pdr532_klett, ...
    data.aerBsc1064_klett, data.pdr1064_klett, ...
    data.aerBsc355_raman, data.pdr355_raman, ...
    data.aerBsc532_raman, data.pdr532_raman, ...
    data.aerBsc1064_raman, data.pdr1064_raman);

print_msg('Finish.\n', 'flagTimestamp', true);

%% POLIPHON (2-step)
[data.POLIPHON2] = poliphon_two ...
    (data.aerBsc355_klett, data.pdr355_klett, ...
    data.aerBsc532_klett, data.pdr532_klett, data.aerBsc1064_klett, data.pdr1064_klett,...
    data.aerBsc355_raman, data.pdr355_raman, data.aerBsc532_raman, data.pdr532_raman,...
    data.aerBsc1064_raman, data.pdr1064_raman);

print_msg('Finish. \n', 'flagTimestamp', true);


%% Signal status
data.SNR = NaN(size(data.signal));
for iCh = 1:size(data.signal, 1)
    signal_sm = smooth2(squeeze(data.signal(iCh, :, :)), PollyConfig.quasi_smooth_h(iCh), PollyConfig.quasi_smooth_t(iCh));
    signal_int = signal_sm * (PollyConfig.quasi_smooth_h(iCh) * PollyConfig.quasi_smooth_t(iCh));
    bg_sm = smooth2(squeeze(data.bg(iCh, :, :)), PollyConfig.quasi_smooth_h(iCh), PollyConfig.quasi_smooth_t(iCh));
    bg_int = bg_sm * (PollyConfig.quasi_smooth_h(iCh) * PollyConfig.quasi_smooth_t(iCh));
    data.SNR(iCh, :, :) = pollySNR(signal_int, bg_int);
end
clearvars bg_int bg_sm signal_int bg_int signal_sm bg_sm

data.quality_mask_355 = zeros(length(data.height), length(data.mTime));
data.quality_mask_NR_355 = zeros(length(data.height), length(data.mTime));
data.quality_mask_532 = zeros(length(data.height), length(data.mTime));
data.quality_mask_NR_532 = zeros(length(data.height), length(data.mTime));
data.quality_mask_1064 = zeros(length(data.height), length(data.mTime));
data.quality_mask_vdr_532 = zeros(length(data.height), length(data.mTime));
data.quality_mask_vdr_355 = zeros(length(data.height), length(data.mTime));
data.quality_mask_vdr_1064 = zeros(length(data.height), length(data.mTime));
data.quality_mask_387 = zeros(length(data.height), length(data.mTime));
data.quality_mask_607 = zeros(length(data.height), length(data.mTime));
% 0 in quality_mask means good data
% 1 in quality_mask means low-SNR data
% 2 in quality_mask means depolarization calibration periods
% 3 in quality_mask means shutter on
% 4 in quality_mask means fog
if (sum(flag355t) == 1)
    data.quality_mask_355(squeeze(data.SNR(flag355t, :, :)) < PollyConfig.mask_SNRmin(flag355t)) = 1;
    data.quality_mask_355(:, data.depCalMask) = 2;
    data.quality_mask_355(:, data.shutterOnMask) = 3;
    data.quality_mask_355(:, data.fogMask) = 4;
end
if (sum(flag355NR) == 1)
    data.quality_mask_NR_355(squeeze(data.SNR(flag355NR, :, :)) < PollyConfig.mask_SNRmin(flag355NR)) = 1;
    data.quality_mask_NR_355(:, data.depCalMask) = 2;
    data.quality_mask_NR_355(:, data.shutterOnMask) = 3;
    data.quality_mask_NR_355(:, data.fogMask) = 4;
end
if (sum(flag532t) == 1)
    data.quality_mask_532(squeeze(data.SNR(flag532t, :, :)) < PollyConfig.mask_SNRmin(flag532t)) = 1;
    data.quality_mask_532(:, data.depCalMask) = 2;
    data.quality_mask_532(:, data.shutterOnMask) = 3;
    data.quality_mask_532(:, data.fogMask) = 4;
end
if (sum(flag532NR) == 1)
    data.quality_mask_NR_532(squeeze(data.SNR(flag532NR, :, :)) < PollyConfig.mask_SNRmin(flag532NR)) = 1;
    data.quality_mask_NR_532(:, data.depCalMask) = 2;
    data.quality_mask_NR_532(:, data.shutterOnMask) = 3;
    data.quality_mask_NR_532(:, data.fogMask) = 4;
end
if (sum(flag1064t) == 1)
    data.quality_mask_1064(squeeze(data.SNR(flag1064t, :, :)) < PollyConfig.mask_SNRmin(flag1064t)) = 1;
    data.quality_mask_1064(:, data.depCalMask) = 2;
    data.quality_mask_1064(:, data.shutterOnMask) = 3;
    data.quality_mask_1064(:, data.fogMask) = 4;
end
if (sum(flag387FR) == 1)
    data.quality_mask_387(squeeze(data.SNR(flag387FR, :, :)) < PollyConfig.mask_SNRmin(flag387FR)) = 1;
    data.quality_mask_387(:, data.depCalMask) = 2;
    data.quality_mask_387(:, data.shutterOnMask) = 3;
    data.quality_mask_387(:, data.fogMask) = 4;
end
if (sum(flag607FR) == 1)
    data.quality_mask_607(squeeze(data.SNR(flag607FR, :, :)) < PollyConfig.mask_SNRmin(flag607FR)) = 1;
    data.quality_mask_607(:, data.depCalMask) = 2;
    data.quality_mask_607(:, data.shutterOnMask) = 3;
    data.quality_mask_607(:, data.fogMask) = 4;
end
if (sum(flag355t) == 1) && (sum(flag355c) == 1)
     data.quality_mask_vdr_355((squeeze(data.SNR(flag355c, :, :)) < PollyConfig.mask_SNRmin(flag355c)) | (squeeze(data.SNR(flag355t, :, :)) < PollyConfig.mask_SNRmin(flag355t))) = 1;
     data.quality_mask_vdr_355(:, data.depCalMask) = 2;
     data.quality_mask_vdr_355(:, data.shutterOnMask) = 3;
     data.quality_mask_vdr_355(:, data.fogMask) = 4;
end
if (sum(flag532t) == 1) && (sum(flag532c) == 1)
    data.quality_mask_vdr_532((squeeze(data.SNR(flag532c, :, :)) < PollyConfig.mask_SNRmin(flag532c)) | (squeeze(data.SNR(flag532t, :, :)) < PollyConfig.mask_SNRmin(flag532t))) = 1;
    data.quality_mask_vdr_532(:, data.depCalMask) = 2;
    data.quality_mask_vdr_532(:, data.shutterOnMask) = 3;
    data.quality_mask_vdr_532(:, data.fogMask) = 4;
end
if (sum(flag1064t) == 1) && (sum(flag1064c) == 1)
    data.quality_mask_vdr_1064((squeeze(data.SNR(flag1064c, :, :)) < PollyConfig.mask_SNRmin(flag1064c)) | (squeeze(data.SNR(flag1064t, :, :)) < PollyConfig.mask_SNRmin(flag1064t))) = 1;
    data.quality_mask_vdr_1064(:, data.depCalMask) = 2;
    data.quality_mask_vdr_1064(:, data.shutterOnMask) = 3;
    data.quality_mask_vdr_1064(:, data.fogMask) = 4;
end

%% Water vapor calibration
print_msg('Start water vapor calibration\n', 'flagTimestamp', true);
% external IWV
wvconst = NaN(size(clFreGrps, 1), 1);
wvconstStd = NaN(size(clFreGrps, 1), 1);
wvCaliInfo = struct();
wvCaliInfo.cali_start_time = NaN(size(clFreGrps, 1), 1);
wvCaliInfo.cali_stop_time = NaN(size(clFreGrps, 1), 1);
wvCaliInfo.WVCaliInfo = cell(1, size(clFreGrps, 1));
wvCaliInfo.IntRange = NaN(size(clFreGrps, 1), 2);

if PollyConfig.flagWVCalibration 
    [IWV, data.IWVAttri] = readIWV(PollyConfig.IWV_instrument, data.mTime(clFreGrps), ...
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
    for iGrp = 1:size(clFreGrps, 1)

        thisCaliStartTime = data.mTime(clFreGrps(iGrp, 1));
        thisCaliStopTime = data.mTime(clFreGrps(iGrp, 2));
        thisWVCaliInfo = '407 off';

        if (sum(flag387FR) ~= 1) || (sum(flag407) ~= 1) || (sum(flag1064t) ~= 1) || isnan(IWV(iGrp))
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

        sig387 = squeeze(sum(data.signal(flag387FR, :, flag407On & flagWVCali & flagLowSolarBG), 3));
        bg387 = squeeze(sum(data.bg(flag387FR, :, flag407On & flagWVCali & flagLowSolarBG), 3));
        sig407 = squeeze(sum(data.signal(flag407, :, flag407On & flagWVCali & flagLowSolarBG), 3));
        [~, closestIndx] = min(abs(data.mTime - data.IWVAttri.datetime(iGrp)));
        print_msg(sprintf('IWV measurement time: %s\nClosest lidar measurement time: %s\n', ...
            datestr(data.IWVAttri.datetime(iGrp), 'HH:MM'), ...
            datestr(data.mTime(closestIndx), 'HH:MM')), 'flagSimpleMsg', true);
        E_tot_1064_IWV = sum(squeeze(data.signal(flag1064t, :, closestIndx)));
        E_tot_1064_cali = sum(squeeze(mean(data.signal(flag1064t, :, flag407On & flagWVCali), 3)));
        E_tot_1064_cali_std = std(squeeze(sum(data.signal(flag1064t, :, flag407On & flagWVCali), 2)));

        trans387 = exp(-cumsum(mExt387(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));
        trans407 = exp(-cumsum(mExt407(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));
        rhoAir = rho_air(data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15);

        [thisWVconst, thisWVconstStd, thisWVAttri] = pollyWVCali(data.height, ...
            sig387, bg387, sig407, E_tot_1064_IWV, E_tot_1064_cali, E_tot_1064_cali_std, ...
            thisCaliStartTime, thisCaliStopTime, IWV(iGrp), flagWVCali, flag407On, ...
            trans387, trans407, rhoAir, sunriseTime, sunsetTime, ...
            'hWVCaliBase', PollyConfig.hWVCaliBase, ...
            'hWVCaliTop', PollyConfig.hWVCaliTop, ...
            'hFullOL387', PollyConfig.heightFullOverlap(flag387FR), ...
            'minSNRWVCali', PollyConfig.minSNRWVCali);

        wvconst(iGrp) = thisWVconst;
        wvconstStd(iGrp) = thisWVconstStd;
        wvCaliInfo.WVCaliInfo{iGrp} = thisWVAttri.WVCaliInfo;
        wvCaliInfo.IntRange(iGrp, :) = thisWVAttri.IntRange;
        wvCaliInfo.cali_start_time(iGrp) = thisWVAttri.cali_start_time;
        wvCaliInfo.cali_stop_time(iGrp) = thisWVAttri.cali_stop_time;
    end
else

    data.IWVAttri = struct();
    data.IWVAttri.source = 'none';
    data.IWVAttri.site = '';
    data.IWVAttri.datetime = [];
    data.IWVAttri.PI = '';
    data.IWVAttri.contact = '';

end
% select water vapor calibration constant
[data.wvconstUsed, data.wvconstUsedStd, data.wvconstUsedInfo] = selectWVConst(...
    wvconst, wvconstStd, data.IWVAttri, ...
    pollyParseFiletime(basename(PollyDataInfo.pollyDataFile), PollyConfig.dataFileFormat), ...
    dbFile, CampaignConfig.name, ...
    'flagUsePrevWVConst', PollyConfig.flagUsePreviousWVconst, ...
    'flagWVCalibration', PollyConfig.flagWVCalibration, ...
    'deltaTime', datenum(0, 1, 7), ...
    'default_wvconst', PollyDefaults.wvconst, ...
    'default_wvconstStd', PollyDefaults.wvconstStd);

% obtain averaged water vapor profiles
data.wvmr = NaN(size(clFreGrps, 1), length(data.height));
data.wvmr_no_QC= NaN(size(clFreGrps, 1), length(data.height));
data.wvmr_error = NaN(size(clFreGrps, 1), length(data.height));
data.wvmr_rel_error = NaN(size(clFreGrps, 1), length(data.height));
data.rh = NaN(size(clFreGrps, 1), length(data.height));
wvPrfInfo = struct();
wvPrfInfo.n407Prfs = NaN(size(clFreGrps, 1), 1);
wvPrfInfo.IWV = NaN(size(clFreGrps, 1), 1);

for iGrp = 1:size(clFreGrps, 1)
    flagClFre = false(size(data.mTime));
    clFreInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
    flagClFre(clFreInd) = true;
    flag407On = flagClFre & (~ data.mask407Off);
    n407OnPrf = sum(flag407On);

    if (n407OnPrf <= 10) || (sum(flag387FR) ~= 1) || (sum(flag407) ~= 1)
        continue;
    end

    sig387 = sum(data.signal(flag387FR, :, flag407On), 3);
    sig407 = sum(data.signal(flag407, :, flag407On), 3);

    trans387 = exp(- cumsum(mExt387(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));
    trans407 = exp(- cumsum(mExt407(iGrp,:) .* [data.distance0(1), diff(data.distance0)]));

    % calculate saturated water vapor pressure
    es = saturated_vapor_pres(data.temperature(iGrp, :));
    rhoAir = rho_air(data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.15);

    % calculate wvmr and rh
    data.wvmr(iGrp, :) = sig407 ./ sig387 .* trans387 ./ trans407 .* data.wvconstUsed;
    
    el387 = squeeze(data.signal(flag387FR, :, :));
    bgEl387 = squeeze(data.bg(flag387FR, :, :));
    sig387 = squeeze(sum(el387(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg387 = squeeze(sum(bgEl387(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR387  = pollySNR(sig387, bg387);
    el407 = squeeze(data.signal(flag407, :, :));
    bgEl407 = squeeze(data.bg(flag407, :, :));
    sig407 = squeeze(sum(el407(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    bg407 = squeeze(sum(bgEl407(:, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 2));
    SNR407  = pollySNR(sig407, bg407);
    %maybe the SNR per interval should be centrlized computed after
    %clFreGrps is defined
    data.wvmr_no_QC(iGrp, :)=data.wvmr(iGrp, :);
    data.wvmr(iGrp, (((squeeze(SNR387)) < PollyConfig.mask_SNRmin(flag387FR)) | (SNR407 < PollyConfig.mask_SNRmin(flag407))))=NaN; 
    data.wvmr_rel_error(iGrp, :) = sqrt((SNR387).^(-2)+(SNR407).^(-2)+((data.wvconstUsedStd).^2)./((data.wvconstUsed).^2));
    data.rh(iGrp, :) = wvmr_2_rh(data.wvmr(iGrp, :), es, data.pressure(iGrp, :));

    % integral water vapor
    if isnan(wvCaliInfo.IntRange(iGrp, 1))
        continue;
    end

    IWVIntRange= wvCaliInfo.IntRange(iGrp, 1):wvCaliInfo.IntRange(iGrp, 2);
    wvPrfInfo.n407Prfs(iGrp) = n407OnPrf;
    wvPrfInfo.IWV(iGrp) = sum(data.wvmr(iGrp, IWVIntRange) .* rhoAir(IWVIntRange) ./ 1e6 .* [data.height(IWVIntRange(1)), diff(data.height(IWVIntRange))]);

end
data.wvmr_error=data.wvmr_rel_error.*data.wvmr;
clearvars bgEl387 bgEl407 el387 el407
%% retrieve high resolution WVMR and RH
data.WVMR = NaN(size(data.signal, 2), size(data.signal, 3));
data.WVMR_no_QC = NaN(size(data.signal, 2), size(data.signal, 3));
data.WVMR_error = NaN(size(data.signal, 2), size(data.signal, 3));
data.WVMR_rel_error = NaN(size(data.signal, 2), size(data.signal, 3));
data.RH = NaN(size(data.signal, 2), size(data.signal, 3));
data.quality_mask_WVMR = 3 * ones(size(data.signal, 2), size(data.signal, 3));
data.quality_mask_RH = 3 * ones(size(data.signal, 2), size(data.signal, 3));
ones_WV=  ones(size(data.signal, 2), size(data.signal, 3));

TimeM=floor(data.mTime(1)*24/3)*3/24-3/24:3/24:ceil(data.mTime(end)*24/3)*3/24+3/24; %timegrid to search gdas files (3h step)

[TimeMg, HeightMg] = meshgrid(data.height, TimeM); %mehsgrids for 2d interpolation
[mTimeg, Heightg] = meshgrid(data.height, data.mTime);

if (sum(flag387FR) == 1) && (sum(flag407 == 1))

    sig387 = squeeze(data.signal(flag387FR, :, :));
    sig387(:, data.depCalMask) = NaN;
    sig407 = squeeze(data.signal(flag407, :, :));
    sig407(:, data.depCalMask) = NaN;

    % quality mask to filter low SNR bits
    data.quality_mask_WVMR = zeros(size(data.signal, 2), size(data.signal, 3));
    data.quality_mask_WVMR((squeeze(data.SNR(flag387FR, :, :)) < PollyConfig.mask_SNRmin(flag387FR)) | (squeeze(data.SNR(flag407, :, :)) < PollyConfig.mask_SNRmin(flag407))) = 1;
    data.quality_mask_WVMR(:, data.depCalMask) = 2;
    data.quality_mask_RH = data.quality_mask_WVMR;

    % mask the signal
    data.quality_mask_WVMR(:, data.mask407Off) = 3;
    sig407_QC = sig407;
    sig407_QC(:, data.depCalMask) = NaN;
    sig407_QC(:, data.mask407Off) = NaN;
    sig387_QC = sig387;
    sig387_QC(:, data.depCalMask) = NaN;
    sig387_QC(:, data.mask407Off) = NaN;

    % smooth the signal
    sig387_QC = smooth2(sig387_QC, PollyConfig.quasi_smooth_h(flag387FR), PollyConfig.quasi_smooth_t(flag387FR));
    sig407_QC = smooth2(sig407_QC, PollyConfig.quasi_smooth_h(flag407), PollyConfig.quasi_smooth_t(flag407));

    % read the meteorological data
    [temp, pres, ~, ~] = loadMeteor(...
                            TimeM, data.alt, ...
                            'meteorDataSource', PollyConfig.meteorDataSource, ...
                            'gdas1Site', PollyConfig.gdas1Site, ...
                            'meteo_folder', PollyConfig.meteo_folder, ...
                            'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
                            'radiosondeFolder', PollyConfig.radiosondeFolder, ...
                            'radiosondeType', PollyConfig.radiosondeType);

    % repmat the array to matrix as the size of data.signal
    temperature = transpose(interp2(TimeMg, HeightMg, temp, mTimeg, Heightg, 'linear'));
    pressure = transpose(interp2(TimeMg, HeightMg, pres, mTimeg, Heightg, 'linear'));
    % calculate the molecule optical properties
    [~, mExt387_highres] = rayleigh_scattering(387, pres, temp + 273.15, 380, 70);
    [~, mExt407_highres] = rayleigh_scattering(407, pres, temp + 273.15, 380, 70);
    trans387 = exp(- cumsum(mExt387_highres .* [data.distance0(1), diff(data.distance0)]));
    trans407 = exp(- cumsum(mExt407_highres .* [data.distance0(1), diff(data.distance0)]));
    TRANS387 = transpose(interp2(TimeMg, HeightMg, trans387, mTimeg, Heightg, 'linear'));
    TRANS407 = transpose(interp2(TimeMg, HeightMg, trans407, mTimeg, Heightg, 'linear'));

    % calculate the saturation water vapor pressure
    ES = saturated_vapor_pres(temperature);


    % rhoAir = rho_air(pressure(:, 1), temperature(:, 1) + 273.15);
    % RHOAIR = repmat(rhoAir, 1, length(data.mTime));
    % DIFFHeight = repmat(transpose([data.height(1), diff(data.height)]), 1, length(data.mTime));

    % calculate wvmr and rh
    data.WVMR = sig407_QC ./ sig387_QC .* TRANS387 ./ TRANS407 .* data.wvconstUsed;
    data.WVMR_no_QC = data.WVMR;
    data.WVMR_rel_error = sqrt((squeeze(data.SNR(flag387FR, :, :))).^(-2)+(squeeze(data.SNR(flag407, :, :))).^(-2)+(ones_WV*((data.wvconstUsedStd).^2)./(data.wvconstUsed).^2));  % SNR bereits f?r smoothing mit ollyConfig.quasi_smooth_h(flag407), PollyConfig.quasi_smooth_t(flag407) gerechnet
    data.WVMR_error = data.WVMR_rel_error.* data.WVMR_no_QC;  % SNR bereits f?r smoothing mit ollyConfig.quasi_smooth_h(flag407), PollyConfig.quasi_smooth_t(flag407) gerechnet
    data.WVMR (data.quality_mask_WVMR>0)=NaN;
    data.RH = wvmr_2_rh(data.WVMR, ES, pressure);
    % IWV = sum(data.WVMR .* RHOAIR .* DIFFHeight .* (data.quality_mask_WVMR == 0), 1) ./ 1e6;   % kg*m^{-2}
end
clearvars ES es ones_WV sig407_QC sig387_QC sig407 TRANS387 TRANS407 

print_msg('Start\n', 'flagTimestamp', true);

%% Lidar calibration
print_msg('Start lidar calibration\n', 'flagTimestamp', true);

data.LC = struct();
data.LC.LC_klett_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_klett_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_klett_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_klett_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_aeronet_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_aeronet_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_aeronet_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_607 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_387 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_klett_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_klett_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_klett_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_aeronet_355 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_aeronet_532 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_aeronet_1064 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_607 = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_387 = NaN(size(clFreGrps, 1), 1);
data.LC.LC_start_time = NaN(size(clFreGrps, 1), 1);
data.LC.LC_stop_time = NaN(size(clFreGrps, 1), 1);

for iGrp = 1:size(clFreGrps, 1)
    data.LC.LC_start_time(iGrp) = data.mTime(clFreGrps(iGrp, 1));
    data.LC.LC_stop_time(iGrp) = data.mTime(clFreGrps(iGrp, 2));

    % 355 nm
    if sum(flag355t) == 1

        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_355/2);

        if ~ isnan(data.aerBsc355_klett(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig355 = squeeze(sum(data.signal(flag355t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt355 = data.aerExt355_klett(iGrp, :);
            aExt355(1:hIndBase) = data.aerExt355_klett(iGrp, hIndBase);
            aBsc355 = data.aerBsc355_klett(iGrp, :);

            aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
            mOT355 = nancumsum(mExt355(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans355 = exp(-2 * (aOT355 + mOT355));
            bsc355 = mBsc355(iGrp,:) + aBsc355;

            % lidar calibration
            LC_klett_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
            [LC_klett_355, ~, lcStd] = mean_stable(LC_klett_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_klett_355 = LC_klett_355 * lcStd;

            data.LC.LC_klett_355(iGrp) = LC_klett_355;
            data.LC.LCStd_klett_355(iGrp) = LCStd_klett_355;
        end
    end

    % 532 nm
    if sum(flag532t) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_532/2);

        if ~ isnan(data.aerBsc532_klett(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig532 = squeeze(sum(data.signal(flag532t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt532 = data.aerExt532_klett(iGrp, :);
            aExt532(1:hIndBase) = data.aerExt532_klett(iGrp, hIndBase);
            aBsc532 = data.aerBsc532_klett(iGrp, :);

            aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
            mOT532 = nancumsum(mExt532(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans532 = exp(-2 * (aOT532 + mOT532));
            bsc532 = mBsc532(iGrp,:) + aBsc532;

            % lidar calibration
            LC_klett_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
            [LC_klett_532, ~, lcStd] = mean_stable(LC_klett_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_klett_532 = LC_klett_532 * lcStd;

            data.LC.LC_klett_532(iGrp) = LC_klett_532;
            data.LC.LCStd_klett_532(iGrp) = LCStd_klett_532;
        end
    end

    % 1064 nm
    if sum(flag1064t) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_1064/2);

        if ~ isnan(data.aerBsc1064_klett(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig1064 = squeeze(sum(data.signal(flag1064t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt1064 = data.aerExt1064_klett(iGrp, :);
            aExt1064(1:hIndBase) = data.aerExt1064_klett(iGrp, hIndBase);
            aBsc1064 = data.aerBsc1064_klett(iGrp, :);

            aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
            mOT1064 = nancumsum(mExt1064(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans1064 = exp(-2 * (aOT1064 + mOT1064));
            bsc1064 = mBsc1064(iGrp,:) + aBsc1064;

            % lidar calibration
            LC_klett_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
            [LC_klett_1064, ~, lcStd] = mean_stable(LC_klett_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_klett_1064 = LC_klett_1064 * lcStd;

            data.LC.LC_klett_1064(iGrp) = LC_klett_1064;
            data.LC.LCStd_klett_1064(iGrp) = LCStd_klett_1064;
        end
    end

    % 355 nm (Raman)
    if sum(flag355t) == 1

        if ~ isnan(data.aerBsc355_raman(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            flagClFre = false(size(data.mTime));
            flagClFre(prfInd) = true;
            flagClFre = flagClFre & (~ data.mask387Off);
            nPrf = sum(flagClFre);
            sig355 = squeeze(sum(data.signal(flag355t, :, flagClFre), 3)) / nPrf;

            % optical thickness (OT)
            aBsc355 = data.aerBsc355_raman(iGrp, :);
            aBsc355(aBsc355 <= 0) = NaN;
            aExt355 = aBsc355 * PollyConfig.LR355;
            aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
            mOT355 = nancumsum(mExt355(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans355 = exp(-2 * (aOT355 + mOT355));
            bsc355 = mBsc355(iGrp,:) + aBsc355;

            % lidar calibration
            LC_raman_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
            LC_raman_355(LC_raman_355 <= 0) = NaN;
            [LC_raman_355, ~, lcStd] = mean_stable(LC_raman_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_raman_355 = LC_raman_355 * lcStd;

            data.LC.LC_raman_355(iGrp) = LC_raman_355;
            data.LC.LCStd_raman_355(iGrp) = LCStd_raman_355;
        end
    end

    % 532 nm (Raman)
    if sum(flag532t) == 1

        if ~ isnan(data.aerBsc532_raman(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            flagClFre = false(size(data.mTime));
            flagClFre(prfInd) = true;
            flagClFre = flagClFre & (~ data.mask607Off);
            nPrf = sum(flagClFre);
            sig532 = squeeze(sum(data.signal(flag532t, :, flagClFre), 3)) / nPrf;

            % optical thickness (OT)
            aBsc532 = data.aerBsc532_raman(iGrp, :);
            aBsc532(aBsc532 <= 0) = NaN;
            aExt532 = aBsc532 * PollyConfig.LR532;
            aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
            mOT532 = nancumsum(mExt532(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans532 = exp(-2 * (aOT532 + mOT532));
            bsc532 = mBsc532(iGrp,:) + aBsc532;

            % lidar calibration
            LC_raman_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
            LC_raman_532(LC_raman_532 <= 0) = NaN;
            [LC_raman_532, ~, lcStd] = mean_stable(LC_raman_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_raman_532 = LC_raman_532 * lcStd;

            data.LC.LC_raman_532(iGrp) = LC_raman_532;
            data.LC.LCStd_raman_532(iGrp) = LCStd_raman_532;
        end
    end

    % 1064 nm (Raman)
    if sum(flag1064t) == 1

        if ~ isnan(data.aerBsc1064_raman(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            flagClFre = false(size(data.mTime));
            flagClFre(prfInd) = true;
            flagClFre = flagClFre & (~ data.mask607Off);
            nPrf = sum(flagClFre);
            sig1064 = squeeze(sum(data.signal(flag1064t, :, flagClFre), 3)) / nPrf;

            % optical thickness (OT)
            aBsc1064 = data.aerBsc1064_raman(iGrp, :);
            aBsc1064(aBsc1064 <= 0) = NaN;
            aExt1064 = aBsc1064 * PollyConfig.LR1064;
            aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
            mOT1064 = nancumsum(mExt1064(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans1064 = exp(-2 * (aOT1064 + mOT1064));
            bsc1064 = mBsc1064(iGrp,:) + aBsc1064;

            % lidar calibration
            LC_raman_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
            LC_raman_1064(LC_raman_1064 <= 0) = NaN;
            [LC_raman_1064, ~, lcStd] = mean_stable(LC_raman_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_raman_1064 = LC_raman_1064 * lcStd;

            data.LC.LC_raman_1064(iGrp) = LC_raman_1064;
            data.LC.LCStd_raman_1064(iGrp) = LCStd_raman_1064;
        end
    end

    % 387 nm (Raman)
    if sum(flag355t) == 1

        if ~ isnan(data.aerBsc355_raman(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            flagClFre = false(size(data.mTime));
            flagClFre(prfInd) = true;
            flagClFre = flagClFre & (~ data.mask387Off);
            nPrf = sum(flagClFre);
            sig387 = squeeze(sum(data.signal(flag387FR, :, flagClFre), 3)) / nPrf;

            % optical thickness (OT)
            aBsc355 = data.aerBsc355_raman(iGrp, :);
            aBsc355(aBsc355 <= 0) = NaN;
            aExt355 = aBsc355 * PollyConfig.LR355;
            aExt387 = aExt355 * (355/387).^PollyConfig.angstrexp;
            aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
            aOT387 = nancumsum(aExt387 .* [data.distance0(1), diff(data.distance0)]);
            mOT355 = nancumsum(mExt355(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);
            mOT387 = nancumsum(mExt387(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans_355_387 = exp(- (aOT355 + mOT355 + aOT387 + mOT387));
            bsc355 = mBsc355(iGrp,:);

            % lidar calibration
            LC_raman_387 = transpose(smooth(sig387 .* data.distance0.^2, PollyConfig.smoothWin_raman_355)) ./ bsc355 ./ trans_355_387;
            LC_raman_387(LC_raman_387 <= 0) = NaN;
            [LC_raman_387, ~, lcStd] = mean_stable(LC_raman_387, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_raman_387 = LC_raman_387 * lcStd;

            data.LC.LC_raman_387(iGrp) = LC_raman_387;
            data.LC.LCStd_raman_387(iGrp) = LCStd_raman_387;
        end
    end

    % 607 nm (Raman)
    if sum(flag532t) == 1

        if ~ isnan(data.aerBsc532_raman(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            flagClFre = false(size(data.mTime));
            flagClFre(prfInd) = true;
            flagClFre = flagClFre & (~ data.mask607Off);
            nPrf = sum(flagClFre);
            sig607 = squeeze(sum(data.signal(flag607FR, :, flagClFre), 3)) / nPrf;

            % optical thickness (OT)
            aBsc532 = data.aerBsc532_raman(iGrp, :);
            aBsc532(aBsc532 <= 0) = NaN;
            aExt532 = aBsc532 * PollyConfig.LR532;
            aExt607 = aExt532 * (532/607).^PollyConfig.angstrexp;
            aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
            aOT607 = nancumsum(aExt607 .* [data.distance0(1), diff(data.distance0)]);
            mOT532 = nancumsum(mExt532(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);
            mOT607 = nancumsum(mExt607(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans_532_607 = exp(- (aOT532 + mOT532 + aOT607 + mOT607));
            bsc532 = mBsc532(iGrp,:);

            % lidar calibration
            LC_raman_607 = transpose(smooth(sig607 .* data.distance0.^2, PollyConfig.smoothWin_raman_532)) ./ bsc532 ./ trans_532_607;
            LC_raman_607(LC_raman_607 <= 0) = NaN;
            [LC_raman_607, ~, lcStd] = mean_stable(LC_raman_607, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_raman_607 = LC_raman_607 * lcStd;

            data.LC.LC_raman_607(iGrp) = LC_raman_607;
            data.LC.LCStd_raman_607(iGrp) = LCStd_raman_607;
        end
    end

    % 355 nm (AOD-constrained Klett)
    if sum(flag355t) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_355/2);

        if ~ isnan(data.aerBsc355_aeronet(iGrp, 80))

             prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig355 = squeeze(sum(data.signal(flag355t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt355 = data.aerExt355_aeronet(iGrp, :);
            aExt355(1:hIndBase) = data.aerExt355_aeronet(iGrp, hIndBase);
            aBsc355 = data.aerBsc355_aeronet(iGrp, :);

            aOT355 = nancumsum(aExt355 .* [data.distance0(1), diff(data.distance0)]);
            mOT355 = nancumsum(mExt355(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans355 = exp(-2 * (aOT355 + mOT355));
            bsc355 = mBsc355(iGrp,:) + aBsc355;

            % lidar calibration
            LC_aeronet_355 = sig355 .* data.distance0.^2 ./ bsc355 ./ trans355;
            [LC_aeronet_355, ~, lcStd] = mean_stable(LC_aeronet_355, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_aeronet_355 = LC_aeronet_355 * lcStd;

            data.LC.LC_aeronet_355(iGrp) = LC_aeronet_355;
            data.LC.LCStd_aeronet_355(iGrp) = LCStd_aeronet_355;
        end
    end

    % 532 nm (AOD-constrained Klett)
    if sum(flag532t) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_532/2);

        if ~ isnan(data.aerBsc532_aeronet(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig532 = squeeze(sum(data.signal(flag532t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt532 = data.aerExt532_aeronet(iGrp, :);
            aExt532(1:hIndBase) = data.aerExt532_aeronet(iGrp, hIndBase);
            aBsc532 = data.aerBsc532_aeronet(iGrp, :);

            aOT532 = nancumsum(aExt532 .* [data.distance0(1), diff(data.distance0)]);
            mOT532 = nancumsum(mExt532(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans532 = exp(-2 * (aOT532 + mOT532));
            bsc532 = mBsc532(iGrp,:) + aBsc532;

            % lidar calibration
            LC_aeronet_532 = sig532 .* data.distance0.^2 ./ bsc532 ./ trans532;
            [LC_aeronet_532, ~, lcStd] = mean_stable(LC_aeronet_532, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_aeronet_532 = LC_aeronet_532 * lcStd;

            data.LC.LC_aeronet_532(iGrp) = LC_aeronet_532;
            data.LC.LCStd_aeronet_532(iGrp) = LCStd_aeronet_532;
        end
    end

    % 1064 nm (AOD-constrained Klett)
    if sum(flag1064t) == 1
        hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064t), 1);

        if isempty(hIndOL)
            hIndOL = 70;
        end

        hIndBase = hIndOL + ceil(PollyConfig.smoothWin_klett_1064/2);

        if ~ isnan(data.aerBsc1064_aeronet(iGrp, 80))

            prfInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);
            nPrf = numel(prfInd);
            sig1064 = squeeze(sum(data.signal(flag1064t, :, prfInd), 3)) / nPrf;

            % optical thickness (OT)

            aExt1064 = data.aerExt1064_aeronet(iGrp, :);
            aExt1064(1:hIndBase) = data.aerExt1064_aeronet(iGrp, hIndBase);
            aBsc1064 = data.aerBsc1064_aeronet(iGrp, :);

            aOT1064 = nancumsum(aExt1064 .* [data.distance0(1), diff(data.distance0)]);
            mOT1064 = nancumsum(mExt1064(iGrp,:) .* [data.distance0(1), diff(data.distance0)]);

            % round-trip transmission
            trans1064 = exp(-2 * (aOT1064 + mOT1064));
            bsc1064 = mBsc1064(iGrp,:) + aBsc1064;

            % lidar calibration
            LC_aeronet_1064 = sig1064 .* data.distance0.^2 ./ bsc1064 ./ trans1064;
            [LC_aeronet_1064, ~, lcStd] = mean_stable(LC_aeronet_1064, PollyConfig.LCMeanWindow, PollyConfig.LCMeanMinIndx, PollyConfig.LCMeanMaxIndx);
            LCStd_aeronet_1064 = LC_aeronet_1064 * lcStd;

            data.LC.LC_aeronet_1064(iGrp) = LC_aeronet_1064;
            data.LC.LCStd_aeronet_1064(iGrp) = LCStd_aeronet_1064;
        end
    end
end

% lidar constants for near-range channels
data.LC.LC_raman_355_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_355_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_387_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_387_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_532_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_532_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LC_raman_607_NR = NaN(size(clFreGrps, 1), 1);
data.LC.LCStd_raman_607_NR = NaN(size(clFreGrps, 1), 1);
if (~ isempty(data.olAttri355.sigRatio)) && (sum(flag355NR) == 1)
    data.LC.LC_raman_355_NR = data.LC.LC_raman_355 .* data.olAttri355.sigRatio;
    data.LC.LCStd_raman_355_NR = data.LC.LCStd_raman_355 .* data.olAttri355.sigRatio;
end
if (~ isempty(olAttri387.sigRatio)) && (sum(flag387NR) == 1)
    data.LC.LC_raman_387_NR = data.LC.LC_raman_387 .* olAttri387.sigRatio;
    data.LC.LCStd_raman_387_NR = data.LC.LCStd_raman_387 .* olAttri387.sigRatio;
end
if (~ isempty(data.olAttri532.sigRatio)) && (sum(flag532NR) == 1)
    data.LC.LC_raman_532_NR = data.LC.LC_raman_532 .* data.olAttri532.sigRatio;
    data.LC.LCStd_raman_532_NR = data.LC.LCStd_raman_532 .* data.olAttri532.sigRatio;
end
if (~ isempty(olAttri607.sigRatio)) && (sum(flag607NR) == 1)
    data.LC.LC_raman_607_NR = data.LC.LC_raman_607 .* olAttri607.sigRatio;
    data.LC.LCStd_raman_607_NR = data.LC.LCStd_raman_607 .* olAttri607.sigRatio;
end

% select lidar calibration constant
data.LCUsed = struct();

%% far-range calibration constants
[data.LCUsed.LCUsed355, ~, data.LCUsed.LCUsedTag355, data.LCUsed.flagLCWarning355] = ...
    selectLiConst(data.LC.LC_raman_355, zeros(size(data.LC.LC_raman_355)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '355', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag355t), ...
        'default_liconstStd', PollyDefaults.LCStd(flag355t));
[data.LCUsed.LCUsed532, ~, data.LCUsed.LCUsedTag532, data.LCUsed.flagLCWarning532] = ...
    selectLiConst(data.LC.LC_raman_532, zeros(size(data.LC.LC_raman_532)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '532', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag532t), ...
        'default_liconstStd', PollyDefaults.LCStd(flag532t));
[data.LCUsed.LCUsed1064, ~, data.LCUsed.LCUsedTag1064, data.LCUsed.flagLCWarning1064] = ...
    selectLiConst(data.LC.LC_raman_1064, zeros(size(data.LC.LC_raman_1064)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '1064', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag1064t), ...
        'default_liconstStd', PollyDefaults.LCStd(flag1064t));
[data.LCUsed.LCUsed387, ~, data.LCUsed.LCUsedTag387, data.LCUsed.flagLCWarning387] = ...
    selectLiConst(data.LC.LC_raman_387, zeros(size(data.LC.LC_raman_387)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '387', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag387FR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag387FR));
[data.LCUsed.LCUsed607, ~, data.LCUsed.LCUsedTag607, data.LCUsed.flagLCWarning607] = ...
    selectLiConst(data.LC.LC_raman_607, zeros(size(data.LC.LC_raman_607)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '607', 'far_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag607FR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag607FR));

%% near-range lidar calibration constants
[data.LCUsed.LCUsed532NR, ~, data.LCUsed.LCUsedTag532NR, data.LCUsed.flagLCWarning532NR] = ...
    selectLiConst(data.LC.LC_raman_532_NR, zeros(size(data.LC.LC_raman_532_NR)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '532', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag532NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag532NR));
[data.LCUsed.LCUsed607NR, ~, data.LCUsed.LCUsedTag607NR, data.LCUsed.flagLCWarning607NR] = ...
    selectLiConst(data.LC.LC_raman_607_NR, zeros(size(data.LC.LC_raman_607_NR)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '607', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag607NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag607NR));
[data.LCUsed.LCUsed355NR, ~, data.LCUsed.LCUsedTag355NR, data.LCUsed.flagLCWarning355NR] = ...
    selectLiConst(data.LC.LC_raman_355_NR, zeros(size(data.LC.LC_raman_355_NR)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '355', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag355NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag355NR));
[data.LCUsed.LCUsed387NR, ~, data.LCUsed.LCUsedTag387NR, data.LCUsed.flagLCWarning387NR] = ...
    selectLiConst(data.LC.LC_raman_387_NR, zeros(size(data.LC.LC_raman_387_NR)), ...
        data.LC.LC_start_time, ...
        data.LC.LC_stop_time, ...
        mean(data.mTime), dbFile, CampaignConfig.name, '387', 'near_range', ...
        'flagUsePrevLC', PollyConfig.flagUsePreviousLC, ...
        'flagLCCalibration', PollyConfig.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', PollyDefaults.LC(flag387NR), ...
        'default_liconstStd', PollyDefaults.LCStd(flag387NR));

print_msg('Finish\n', 'flagTimestamp', true);

%% attenuated backscatter
print_msg('Start calculating attenuated backscatter.\n', 'flagTimestamp', true);

data.att_beta_355 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag355t) == 1)
    data.att_beta_355 = squeeze(data.signal(flag355t, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed355;
    data.att_beta_355(:, data.depCalMask) = NaN;
end

data.att_beta_532 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag532t) == 1)
    data.att_beta_532 = squeeze(data.signal(flag532t, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed532;
    data.att_beta_532(:, data.depCalMask) = NaN;
end

data.att_beta_1064 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag1064t) == 1)
    data.att_beta_1064 = squeeze(data.signal(flag1064t, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed1064;
    data.att_beta_1064(:, data.depCalMask) = NaN;
end

att_beta_387 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag387FR) == 1)
    att_beta_387 = squeeze(data.signal(flag387FR, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed387;
    att_beta_387(:, data.depCalMask) = NaN;
end

att_beta_607 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag607FR) == 1)
    att_beta_607 = squeeze(data.signal(flag607FR, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed607;
    att_beta_607(:, data.depCalMask) = NaN;
end

data.att_beta_OC_355 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag355t) == 1)
    data.att_beta_OC_355 = data.sigOLCor355 .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed355;
    data.att_beta_OC_355(:, data.depCalMask) = NaN;
end

data.att_beta_OC_532 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag532t) == 1)
    data.att_beta_OC_532 = data.sigOLCor532 .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed532;
    data.att_beta_OC_532(:, data.depCalMask) = NaN;
end

data.att_beta_OC_1064 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag1064t) == 1)
    data.att_beta_OC_1064 = data.sigOLCor1064 .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed1064;
    data.att_beta_OC_1064(:, data.depCalMask) = NaN;
end

% att_beta_OC_387 = NaN(length(data.distance0), length(data.mTime));
% if (sum(flag387FR) == 1)
%     att_beta_OC_387 = sigOLCor387 .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed387;
%     att_beta_OC_387(:, data.depCalMask) = NaN;
% end

% att_beta_OC_607 = NaN(length(data.distance0), length(data.mTime));
% if (sum(flag607FR) == 1)
%     att_beta_OC_607 = sigOLCor607 .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed607;
%     att_beta_OC_607(:, data.depCalMask) = NaN;
% end

data.att_beta_NR_355 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag355NR) == 1)
    data.att_beta_NR_355 = squeeze(data.signal(flag355NR, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed355NR;
    data.att_beta_NR_355(:, data.depCalMask) = NaN;
end

data.att_beta_NR_532 = NaN(length(data.distance0), length(data.mTime));
if (sum(flag532NR) == 1)
    data.att_beta_NR_532 = squeeze(data.signal(flag532NR, :, :)) .* repmat(transpose(data.distance0), 1, length(data.mTime)).^2 / data.LCUsed.LCUsed532NR;
    data.att_beta_NR_532(:, data.depCalMask) = NaN;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Volume linear depolarization ratio with high temporal resolution
print_msg('Start calculating volume linear depolarization ratio.\n', 'flagTimestamp', true);
if flagGHK
    data.vdr355 = NaN(length(data.height), length(data.mTime));
    if (sum(flag355t) == 1) && (sum(flag355c) == 1)
        data.vdr355 = pollyVDR2GHK(squeeze(data.signal(flag355t, :, :)), ...
                           squeeze(data.signal(flag355c, :, :)), ...
                           PollyConfig.G(flag355t),PollyConfig.G(flag355c), ...
                           PollyConfig.H(flag355t),PollyConfig.H(flag355c), ... 
                           data.polCaliEta355);
        data.vdr355(:, data.depCalMask) = NaN;
    end

    % 532 nm
    data.vdr532 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        data.vdr532 = pollyVDR2GHK(squeeze(data.signal(flag532t, :, :)), ...
                           squeeze(data.signal(flag532c, :, :)), ...
                           PollyConfig.G(flag532t),PollyConfig.G(flag532c), ...
                           PollyConfig.H(flag532t),PollyConfig.H(flag532c), ... 
                           data.polCaliEta532);
        data.vdr532(:, data.depCalMask) = NaN;
    end
    
    % 1064 nm
    data.vdr1064 = NaN(length(data.height), length(data.mTime));
    if (sum(flag1064t) == 1) && (sum(flag1064c) == 1)
        data.vdr1064 = pollyVDR2GHK(squeeze(data.signal(flag1064t, :, :)), ...
                           squeeze(data.signal(flag1064c, :, :)), ...
                           PollyConfig.G(flag1064t),PollyConfig.G(flag1064c), ...
                           PollyConfig.H(flag1064t),PollyConfig.H(flag1064c), ... 
                           data.polCaliEta1064);
        data.vdr1064(:, data.depCalMask) = NaN;
    end
else
    % 355 nm
    data.vdr355 = NaN(length(data.height), length(data.mTime));
    if (sum(flag355t) == 1) && (sum(flag355c) == 1)
        data.vdr355 = pollyVDR2(squeeze(data.signal(flag355t, :, :)), ...
                           squeeze(data.signal(flag355c, :, :)), ...
                           PollyConfig.TR(flag355t), ...
                           PollyConfig.TR(flag355c), data.polCaliFac355);
        data.vdr355(:, data.depCalMask) = NaN;
    end

    % 532 nm
    data.vdr532 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        data.vdr532 = pollyVDR2(squeeze(data.signal(flag532t, :, :)), ...
                           squeeze(data.signal(flag532c, :, :)), ...
                           PollyConfig.TR(flag532t), ...
                           PollyConfig.TR(flag532c), data.polCaliFac532);
        data.vdr532(:, data.depCalMask) = NaN;
    end

    % 1064 nm
    data.vdr1064 = NaN(length(data.height), length(data.mTime));
    if (sum(flag1064t) == 1) && (sum(flag1064c) == 1)
        data.vdr1064 = pollyVDR2(squeeze(data.signal(flag1064t, :, :)), ...
                           squeeze(data.signal(flag1064c, :, :)), ...
                           PollyConfig.TR(flag1064t), ...
                           PollyConfig.TR(flag1064c), data.polCaliFac1064);
        data.vdr1064(:, data.depCalMask) = NaN;
    end
end
print_msg('Finish.\n', 'flagTimestamp', true);

%% Co (para) and cross (perp) polarized components in attenuated backscatter
print_msg('Start calculating co and cross attenuated backscatter.\n', 'flagTimestamp', true);

data.att_beta_para_355 = NaN(length(data.height), length(data.mTime));
data.att_beta_perp_355 = NaN(length(data.height), length(data.mTime));
if (sum(flag355t) == 1) && (sum(flag355c) == 1)
data.att_beta_para_355=data.att_beta_355./(1+PollyConfig.TR(flag355t)*data.vdr355);
data.att_beta_perp_355=data.att_beta_para_355.*data.vdr355;
end
data.att_beta_para_532 = NaN(length(data.height), length(data.mTime));
data.att_beta_perp_532 = NaN(length(data.height), length(data.mTime));
if (sum(flag532t) == 1) && (sum(flag532c) == 1)
data.att_beta_para_532=data.att_beta_532./(1+PollyConfig.TR(flag532t)*data.vdr532);
data.att_beta_perp_532=data.att_beta_para_532.*data.vdr532;
end
data.att_beta_para_1064 = NaN(length(data.height), length(data.mTime));
data.att_beta_perp_1064 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064t) == 1) && (sum(flag1064c) == 1)
data.att_beta_para_1064=data.att_beta_1064./(1+PollyConfig.TR(flag1064t)*data.vdr1064);
data.att_beta_perp_1064=data.att_beta_para_1064.*data.vdr1064;
end
%% Quasi-retrieval (V1)
print_msg('Start quasi-retrieval (V1).\n', 'flagTimestamp', true);

% load meteorological data
[temperature, pressure, ~, ~, ~, thisMeteorAttri] = loadMeteor(TimeM, data.alt, ...
    'meteorDataSource', PollyConfig.meteorDataSource, ...
    'gdas1Site', PollyConfig.gdas1Site, ...
    'meteo_folder', PollyConfig.meteo_folder, ...
    'radiosondeSitenum', PollyConfig.radiosondeSitenum, ...
    'radiosondeFolder', PollyConfig.radiosondeFolder, ...
    'radiosondeType', PollyConfig.radiosondeType, ...
    'method', 'linear');

data.quasiAttri = struct();
data.quasiAttri.flagGDAS1 = false;
data.quasiAttri.timestamp = [];

%------------------------------------------------------------------------------------------------------------


% quasi-retrieved backscatter at 355 nm
data.qsiBsc355V1 = NaN(length(data.height), length(data.mTime));
att_beta_355_qsi = data.att_beta_355;
if (sum(flag355t) == 1)
    att_beta_355_qsi(data.quality_mask_355 ~= 0) = NaN;
    att_beta_355_qsi = smooth2(att_beta_355_qsi, PollyConfig.quasi_smooth_h(flag355t), PollyConfig.quasi_smooth_t(flag355t));

    % Rayleigh scattering
%---------------achtung
    [mBsc355, mExt355] = rayleigh_scattering(355, pressure, temperature + 273.15, 380, 70);
    mBsc355 = transpose(interp2(TimeMg, HeightMg, mBsc355, mTimeg, Heightg, 'linear'));
    mExt355 = transpose(interp2(TimeMg, HeightMg, mExt355, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag355t), 1);
    if ~ isempty(hIndOL)
        att_beta_355_qsi(1:hIndOL, :) = repmat(att_beta_355_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [data.qsiBsc355V1, ~] = quasiRetrieval(data.height, att_beta_355_qsi, mExt355, mBsc355, PollyConfig.LR355, 'nIters', 6);
end

% quasi-retrieved backscatter at 532 nm
data.qsiBsc532V1 = NaN(length(data.height), length(data.mTime));
att_beta_532_qsi = data.att_beta_532;
if (sum(flag532t) == 1)
    att_beta_532_qsi(data.quality_mask_532 ~= 0) = NaN;
    att_beta_532_qsi = smooth2(att_beta_532_qsi, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
  %achtung
    mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));
    mExt532 = transpose(interp2(TimeMg, HeightMg, mExt532, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag532t), 1);
    if ~ isempty(hIndOL)
        att_beta_532_qsi(1:hIndOL, :) = repmat(att_beta_532_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [data.qsiBsc532V1, ~] = quasiRetrieval(data.height, att_beta_532_qsi, mExt532, mBsc532, PollyConfig.LR532, 'nIters', 6);
end

% quasi-retrieved backscatter at 1064 nm
data.qsiBsc1064V1 = NaN(length(data.height), length(data.mTime));
att_beta_1064_qsi = data.att_beta_1064;
if (sum(flag1064t) == 1)
    att_beta_1064_qsi(data.quality_mask_1064 ~= 0) = NaN;
    att_beta_1064_qsi = smooth2(att_beta_1064_qsi, PollyConfig.quasi_smooth_h(flag1064t), PollyConfig.quasi_smooth_t(flag1064t));

    % Rayleigh scattering
%achtung
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.15, 380, 70);
    mBsc1064 = transpose(interp2(TimeMg, HeightMg, mBsc1064, mTimeg, Heightg, 'linear'));
    mExt1064 = transpose(interp2(TimeMg, HeightMg, mExt1064, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    hIndOL = find(data.height >= PollyConfig.heightFullOverlap(flag1064t), 1);
    if ~ isempty(hIndOL)
        att_beta_1064_qsi(1:hIndOL, :) = repmat(att_beta_1064_qsi(hIndOL, :), hIndOL, 1);
    else
        warning('Full overlap height is too large.');
    end

    [data.qsiBsc1064V1, ~] = quasiRetrieval(data.height, att_beta_1064_qsi, mExt1064, mBsc1064, PollyConfig.LR1064, 'nIters', 6);
end

% quasi-retrieved particle depolarization ratio at 532 nm
if flagGHK
    data.qsiPDR532V1 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        sig532T = squeeze(data.signal(flag532t, :, :));
        sig532C = squeeze(data.signal(flag532c, :, :));
        sig532T(:, data.depCalMask) = NaN;
        sig532C(:, data.depCalMask) = NaN;
        sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
        sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532c), PollyConfig.quasi_smooth_t(flag532c));

        % Rayleigh scattering
        [mBsc532, ~] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
        mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));
        data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
        data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
        data.quasiAttri.timestamp = thisMeteorAttri.datetime;

        vdr532Sm = pollyVDR2GHK(sig532TSm, sig532CSm, ...                           
                           PollyConfig.G(flag532t),PollyConfig.G(flag532c), ...
                           PollyConfig.H(flag532t),PollyConfig.H(flag532c), ... 
                           data.polCaliEta532);
        %data.qsiPDR532V1 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (data.qsiBsc532V1 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V1 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) ./ (data.qsiBsc532V1 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V1((data.quality_mask_vdr_532 ~= 0) | (data.quality_mask_532 ~= 0)) = NaN;
    end
else
    data.qsiPDR532V1 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        sig532T = squeeze(data.signal(flag532t, :, :));
        sig532C = squeeze(data.signal(flag532c, :, :));
        sig532T(:, data.depCalMask) = NaN;
        sig532C(:, data.depCalMask) = NaN;
        sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
        sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532c), PollyConfig.quasi_smooth_t(flag532c));

        % Rayleigh scattering
        [mBsc532, ~] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
        mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));
        data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
        data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
        data.quasiAttri.timestamp = thisMeteorAttri.datetime;

        vdr532Sm = pollyVDR2(sig532TSm, sig532CSm, PollyConfig.TR(flag532t), PollyConfig.TR(flag532c), data.polCaliFac532);
        %data.qsiPDR532V1 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (data.qsiBsc532V1 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V1 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) ./ (data.qsiBsc532V1 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V1((data.quality_mask_vdr_532 ~= 0) | (data.quality_mask_532 ~= 0)) = NaN;
    end
end

% % quasi-retrieved Angstroem exponents 355-532
% qsiAE_355_532 = NaN(length(data.height), length(data.mTime));
% if (sum(flag532t) == 1) && (sum(flag355t) == 1)
%     ratio_par_bsc_355_532 = data.qsiBsc532V1 ./ data.qsiBsc355V1;
%     ratio_par_bsc_355_532(ratio_par_bsc_355_532 <= 0) = NaN;
%     qsiAE_355_532 = log(ratio_par_bsc_355_532) ./ log(355/532);
% end

% % quasi-retrieved Angstroem exponents 355-1064
% qsiAE_355_1064 = NaN(length(data.height), length(data.mTime));
% if (sum(flag1064t) == 1) && (sum(flag355t) == 1)
%     ratio_par_bsc_355_1064 = data.qsiBsc1064V1 ./ data.qsiBsc355V1;
%     ratio_par_bsc_355_1064(ratio_par_bsc_355_1064 <= 0) = NaN;
%     qsiAE_355_1064 = log(ratio_par_bsc_355_1064) ./ log(355/1064);
% end

% quasi-retrieved Angstroem exponents 532-1064
data.qsiAE_532_1064_V1 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064t) == 1) && (sum(flag532t) == 1)
    ratio_par_bsc_532_1064 = data.qsiBsc1064V1 ./ data.qsiBsc532V1;
    ratio_par_bsc_532_1064(ratio_par_bsc_532_1064 <= 0) = NaN;
    data.qsiAE_532_1064_V1 = log(ratio_par_bsc_532_1064) ./ log(532/1064);
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Target classification (V1)
print_msg('Start aerosol/cloud target classification (v1).\n', 'flagTimestamp', true);

data.tcMaskV1 = zeros(length(data.height), length(data.mTime));
if (sum(flag532t) == 1) && (sum(flag532c) == 1) && (sum(flag1064t) == 1)
    data.tcMaskV1 = targetClassify(data.height, data.att_beta_532, data.qsiBsc1064V1, data.qsiBsc532V1, data.qsiPDR532V1, vdr532Sm, data.qsiAE_532_1064_V1, ...
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
    'hFullOL', max(PollyConfig.heightFullOverlap(flag532t), PollyConfig.heightFullOverlap(flag1064t)));

    %% set the value during the depolarization calibration period or in fog conditions to 0
    data.tcMaskV1(:, data.depCalMask | data.fogMask) = 0;

    %% set the value with low SNR to 0
    data.tcMaskV1((data.quality_mask_532 ~= 0) | (data.quality_mask_1064 ~= 0) | (data.quality_mask_vdr_532 ~= 0)) = 0;
end

print_msg('Finish.\n', 'flagTimestamp', true);

%% Quasi-retrieval (V2)

% quasi-retrieved backscatter at 355 nm (V2)
data.qsiBsc355V2 = NaN(length(data.height), length(data.mTime));
att_beta_355_qsi = data.att_beta_355;
att_beta_387_qsi = att_beta_387;
if (sum(flag355t) == 1) && (sum(flag387FR) == 1)
    att_beta_355_qsi(data.quality_mask_355 ~= 0) = NaN;
    att_beta_387_qsi(data.quality_mask_387 ~= 0) = NaN;
    att_beta_355_qsi = smooth2(att_beta_355_qsi, PollyConfig.quasi_smooth_h(flag355t), PollyConfig.quasi_smooth_t(flag355t));
    att_beta_387_qsi = smooth2(att_beta_387_qsi, PollyConfig.quasi_smooth_h(flag387FR), PollyConfig.quasi_smooth_t(flag387FR));

    % Rayleigh scattering
    [mBsc355, mExt355] = rayleigh_scattering(355, pressure, temperature + 273.15, 380, 70);
    [~, mExt387] = rayleigh_scattering(387, pressure, temperature + 273.15, 380, 70);
    mBsc355 = transpose(interp2(TimeMg, HeightMg, mBsc355, mTimeg, Heightg, 'linear'));
    mExt355 = transpose(interp2(TimeMg, HeightMg, mExt355, mTimeg, Heightg, 'linear'));
    mExt387 = transpose(interp2(TimeMg, HeightMg, mExt387, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    [data.qsiBsc355V2, ~] = quasiRetrieval2(data.height, att_beta_355_qsi, att_beta_387_qsi, 355, mExt355, mBsc355, mExt387, 0.5, PollyConfig.LR355, 'nIters', 3);
    data.qsiBsc355V2 = smooth2(data.qsiBsc355V2, PollyConfig.quasi_smooth_h(flag355t), PollyConfig.quasi_smooth_t(flag355t));
end

% quasi-retrieved backscatter at 532 nm (V2)
data.qsiBsc532V2 = NaN(length(data.height), length(data.mTime));
att_beta_532_qsi = data.att_beta_532;
att_beta_607_qsi = att_beta_607;
if (sum(flag532t) == 1) && (sum(flag607FR) == 1)
    att_beta_532_qsi(data.quality_mask_532 ~= 0) = NaN;
    att_beta_607_qsi(data.quality_mask_607 ~= 0) = NaN;
    att_beta_532_qsi = smooth2(att_beta_532_qsi, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
    att_beta_607_qsi = smooth2(att_beta_607_qsi, PollyConfig.quasi_smooth_h(flag607FR), PollyConfig.quasi_smooth_t(flag607FR));

    % Rayleigh scattering
    [mBsc532, mExt532] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
    [~, mExt607] = rayleigh_scattering(607, pressure, temperature + 273.15, 380, 70);
    mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));
    mExt532 = transpose(interp2(TimeMg, HeightMg, mExt532, mTimeg, Heightg, 'linear'));
    mExt607 = transpose(interp2(TimeMg, HeightMg, mExt607, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    [data.qsiBsc532V2, ~] = quasiRetrieval2(data.height, att_beta_532_qsi, att_beta_607_qsi, 532, mExt532, mBsc532, mExt607, 0.5, PollyConfig.LR532, 'nIters', 3);
    data.qsiBsc532V2 = smooth2(data.qsiBsc532V2, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
end

% quasi-retrieved backscatter at 1064 nm (V2)
data.qsiBsc1064V2 = NaN(length(data.height), length(data.mTime));
att_beta_1064_qsi = data.att_beta_1064;
att_beta_607_qsi = att_beta_607;
if (sum(flag1064t) == 1) && (sum(flag607FR) == 1)
    att_beta_1064_qsi(data.quality_mask_1064 ~= 0) = NaN;
    att_beta_607_qsi(data.quality_mask_607 ~= 0) = NaN;
    att_beta_1064_qsi = smooth2(att_beta_1064_qsi, PollyConfig.quasi_smooth_h(flag1064t), PollyConfig.quasi_smooth_t(flag1064t));
    att_beta_607_qsi = smooth2(att_beta_607_qsi, PollyConfig.quasi_smooth_h(flag607FR), PollyConfig.quasi_smooth_t(flag607FR));

    % Rayleigh scattering
    [mBsc1064, mExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.15, 380, 70);
    [~, mExt607] = rayleigh_scattering(607, pressure, temperature + 273.15, 380, 70);
    mBsc1064 = transpose(interp2(TimeMg, HeightMg, mBsc1064, mTimeg, Heightg, 'linear'));
    mExt1064 = transpose(interp2(TimeMg, HeightMg, mExt1064, mTimeg, Heightg, 'linear'));
    mExt607 = transpose(interp2(TimeMg, HeightMg, mExt607, mTimeg, Heightg, 'linear'));
    data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
    data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
    data.quasiAttri.timestamp = thisMeteorAttri.datetime;

    [data.qsiBsc1064V2, ~] = quasiRetrieval2(data.height, att_beta_1064_qsi, att_beta_607_qsi, 1064, mExt1064, mBsc1064, mExt607, 0.5, PollyConfig.LR1064, 'nIters', 3);
    data.qsiBsc1064V2 = smooth2(data.qsiBsc1064V2, PollyConfig.quasi_smooth_h(flag1064t), PollyConfig.quasi_smooth_t(flag1064t));
end
clearvars att_beta_1064_qsi att_beta_355_qsi att_beta_387_qsi att_beta_532_qsi att_beta_607_qsi att_beta_387 att_beta_607;
clearvars  mBsc355 mExt355 mBsc387 mExt387 mBsc407 mExt407 mBsc532 mExt532 mBsc607 mExt607 mBsc1058 mExt1058 mBsc1064 mExt1064 number_density ;
% quasi-retrieved particle depolarization ratio at 532 nm (V2)
if flagGHK
    data.qsiPDR532V2 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        sig532T = squeeze(data.signal(flag532t, :, :));
        sig532C = squeeze(data.signal(flag532c, :, :));
        sig532T(:, data.depCalMask) = NaN;
        sig532C(:, data.depCalMask) = NaN;
        sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
        sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532c), PollyConfig.quasi_smooth_t(flag532c));

        % Rayleigh scattering
        [mBsc532, ~] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
        mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));    
        data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
        data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
        data.quasiAttri.timestamp = thisMeteorAttri.datetime;
        
        vdr532Sm = pollyVDR2GHK(sig532TSm, sig532CSm, ...                           
                           PollyConfig.G(flag532t),PollyConfig.G(flag532c), ...
                           PollyConfig.H(flag532t),PollyConfig.H(flag532c), ... 
                           data.polCaliEta532);
        %data.qsiPDR532V2 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (data.qsiBsc532V2 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V2 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) ./ (data.qsiBsc532V2 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V2((data.quality_mask_vdr_532 ~= 0) | (data.quality_mask_532 ~= 0)) = NaN;
    end
else
    data.qsiPDR532V2 = NaN(length(data.height), length(data.mTime));
    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        sig532T = squeeze(data.signal(flag532t, :, :));
        sig532C = squeeze(data.signal(flag532c, :, :));
        sig532T(:, data.depCalMask) = NaN;
        sig532C(:, data.depCalMask) = NaN;
        sig532TSm = smooth2(sig532T, PollyConfig.quasi_smooth_h(flag532t), PollyConfig.quasi_smooth_t(flag532t));
        sig532CSm = smooth2(sig532C, PollyConfig.quasi_smooth_h(flag532c), PollyConfig.quasi_smooth_t(flag532c));

        % Rayleigh scattering
        [mBsc532, ~] = rayleigh_scattering(532, pressure, temperature + 273.15, 380, 70);
        mBsc532 = transpose(interp2(TimeMg, HeightMg, mBsc532, mTimeg, Heightg, 'linear'));    
        data.quasiAttri.flagGDAS1 = strcmpi(thisMeteorAttri.dataSource, 'gdas1');
        data.quasiAttri.meteorSource = thisMeteorAttri.dataSource;
        data.quasiAttri.timestamp = thisMeteorAttri.datetime;

        vdr532Sm = pollyVDR2(sig532TSm, sig532CSm, PollyConfig.TR(flag532t), PollyConfig.TR(flag532c), data.polCaliFac532);
        %data.qsiPDR532V2 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) .* (data.qsiBsc532V2 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V2 = (vdr532Sm + 1) ./ (mBsc532 .* (PollyDefaults.molDepol532 - vdr532Sm) ./ (data.qsiBsc532V2 .* (1 + PollyDefaults.molDepol532)) + 1) - 1;
        data.qsiPDR532V2((data.quality_mask_vdr_532 ~= 0) | (data.quality_mask_532 ~= 0)) = NaN;
    end
end
% % quasi-retrieved Angstroem exponents 355-532 (V2)
% qsiAE_355_532_V2 = NaN(length(data.height), length(data.mTime));
% if (sum(flag532t) == 1) && (sum(flag355t) == 1) && (sum(flag387FR) == 1) && (sum(flag607FR) == 1)
%     ratio_par_bsc_355_532 = data.qsiBsc532V2 ./ data.qsiBsc355V2;
%     ratio_par_bsc_355_532(ratio_par_bsc_355_532 <= 0) = NaN;
%     qsiAE_355_532_V2 = log(ratio_par_bsc_355_532) ./ log(355/532);
% end

% % quasi-retrieved Angstroem exponents 355-1064 (V2)
% qsiAE_355_1064_V2 = NaN(length(data.height), length(data.mTime));
% if (sum(flag1064t) == 1) && (sum(flag355t) == 1) && (sum(flag387FR) == 1) && (sum(flag607FR) == 1)
%     ratio_par_bsc_355_1064 = data.qsiBsc1064V2 ./ data.qsiBsc355V2;
%     ratio_par_bsc_355_1064(ratio_par_bsc_355_1064 <= 0) = NaN;
%     qsiAE_355_1064_V2 = log(ratio_par_bsc_355_1064) ./ log(355/1064);
% end

% quasi-retrieved Angstroem exponents 532-1064 (V2)
data.qsiAE_532_1064_V2 = NaN(length(data.height), length(data.mTime));
if (sum(flag1064t) == 1) && (sum(flag532t) == 1) && (sum(flag607FR) == 1)
    ratio_par_bsc_532_1064 = data.qsiBsc1064V2 ./ data.qsiBsc532V2;
    ratio_par_bsc_532_1064(ratio_par_bsc_532_1064 <= 0) = NaN;
    data.qsiAE_532_1064_V2 = log(ratio_par_bsc_532_1064) ./ log(532/1064);
end
clearvars ratio_par_bsc_532_1064 sig532C sig532TSm sig532CSm sig532T
print_msg('Finish.\n', 'flagTimestamp', true);

%% Target classification (V2)
print_msg('Start aerosol/cloud target classification (v2).\n', 'flagTimestamp', true);
data.tcMaskV2 = zeros(length(data.height), length(data.mTime));
if (sum(flag532t) == 1) && (sum(flag532c) == 1) && (sum(flag1064t) == 1) && (sum(flag387FR) == 1) && (sum(flag607FR) == 1)
    data.tcMaskV2 = targetClassify(data.height, data.att_beta_532, data.qsiBsc1064V2, data.qsiBsc532V2, data.qsiPDR532V2, vdr532Sm, data.qsiAE_532_1064_V2, ...
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
    data.tcMaskV2(:, data.depCalMask | data.fogMask) = 0;

    %% set the value with low SNR to 0
    data.tcMaskV2((data.quality_mask_532 ~= 0) | (data.quality_mask_1064 ~= 0) | (data.quality_mask_vdr_532 ~= 0) | (data.quality_mask_607 ~= 0)) = 0;
end
clearvars vdr532Sm

data.quality_mask_532_V2 = data.quality_mask_532;
data.quality_mask_532_V2((data.quality_mask_532_V2 == 0) & (data.quality_mask_607 == 1)) = 1;
data.quality_mask_1064_V2 = data.quality_mask_1064;
data.quality_mask_1064_V2((data.quality_mask_1064_V2 == 0) & ((data.quality_mask_607 == 1) | (data.quality_mask_532 == 1))) = 1;

print_msg('Finish.\n', 'flagTimestamp', true);

%% Cloud detection
print_msg('Start extracting cloud heights.\n', 'flagTimestamp', true);
MAXCLLAYERS = 10;
data.clBaseH = NaN(MAXCLLAYERS, length(data.mTime));
data.clTopH = NaN(MAXCLLAYERS, length(data.mTime));
data.clPh = zeros(MAXCLLAYERS, length(data.mTime));
data.clPhProb = zeros(MAXCLLAYERS, length(data.mTime));

if (sum(flag532t) == 1) && (sum(flag532c) == 1) && (sum(flag1064t) == 1)
    [data.clBaseH, data.clTopH, data.clPh, data.clPhProb] = cloudGeoExtract(data.mTime, data.height, data.tcMaskV2, ...
        'minCloudDepth', 100, ...
        'liquidCloudBit', 8, ...
        'iceCloudBit', 9, ...
        'cloudBits', [7, 8, 9, 10, 11]);
elseif PollyConfig.cloudScreenMode == 2
    [data.clBaseH, data.clTopH, ~, ~] = cloudGeoExtract(data.mTime, data.height, cloudMask, ...
        'minCloudDepth', 100, ...
        'liquidCloudBit', 1, ...
        'iceCloudBit', 1, ...
        'cloudBits', 1);
    data.clPh = zeros(size(data.clBaseH));
    data.clPhProb = zeros(size(data.clBaseH));
else
    warning('No cloud geometrical properties available.');
end
clearvars cloudMask
print_msg('Finish.\n', 'flagTimestamp', true);

%% Saving calibration results
if PicassoConfig.flagEnableCaliResultsOutput
    print_msg('Start saving calibration results.\n', 'flagTimestamp', true);

        %% save polarization calibration results
    if (sum(flag355t) == 1) && (sum(flag355c) == 1)
        print_msg('--> saving polarization calibration results at 355 nm...\n', 'flagTimestamp', true);
        saveDepolConst(dbFile, ...
                       data.polCali355Attri.polCaliEta, ...
                       data.polCali355Attri.polCaliEtaStd, ...
                       data.polCali355Attri.polCaliStartTime, ...
                       data.polCali355Attri.polCaliStopTime, ...
                       PollyDataInfo.pollyDataFile, ...
                       CampaignConfig.name, '355');
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    if (sum(flag532t) == 1) && (sum(flag532c) == 1)
        print_msg('--> saving polarization calibration results at 532 nm...\n', 'flagTimestamp', true);
        saveDepolConst(dbFile, ...
                       data.polCali532Attri.polCaliEta, ...
                       data.polCali532Attri.polCaliEtaStd, ...
                       data.polCali532Attri.polCaliStartTime, ...
                       data.polCali532Attri.polCaliStopTime, ...
                       PollyDataInfo.pollyDataFile, ...
                       CampaignConfig.name, '532');
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end
    
    if (sum(flag1064t) == 1) && (sum(flag1064c) == 1)
        print_msg('--> saving polarization calibration results at 1064 nm...\n', 'flagTimestamp', true);
        saveDepolConst(dbFile, ...
                       data.polCali1064Attri.polCaliEta, ...
                       data.polCali1064Attri.polCaliEtaStd, ...
                       data.polCali1064Attri.polCaliStartTime, ...
                       data.polCali1064Attri.polCaliStopTime, ...
                       PollyDataInfo.pollyDataFile, ...
                       CampaignConfig.name, '1064');
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    %% save lidar calibration results
    print_msg('--> start saving lidar calibration constants.\n', 'flagTimestamp', true);
    try
    saveLiConst(dbFile, data.LC.LC_klett_355, data.LC.LCStd_klett_355, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_klett_532, data.LC.LCStd_klett_532, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_klett_1064, data.LC.LCStd_klett_1064, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'Klett_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_355, data.LC.LCStd_raman_355, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_532, data.LC.LCStd_raman_532, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_1064, data.LC.LCStd_raman_1064, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_387, data.LC.LCStd_raman_387, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '387', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_607, data.LC.LCStd_raman_607, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '607', 'Raman_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_aeronet_355, data.LC.LCStd_aeronet_355, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_aeronet_532, data.LC.LCStd_aeronet_532, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_aeronet_1064, data.LC.LCStd_aeronet_1064, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '1064', 'AOD_Constrained_Method', 'far_range');
    saveLiConst(dbFile, data.LC.LC_raman_355_NR, data.LC.LCStd_raman_355_NR, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '355', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, data.LC.LC_raman_387_NR, data.LC.LCStd_raman_387_NR, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '387', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, data.LC.LC_raman_532_NR, data.LC.LCStd_raman_532_NR, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '532', 'Raman_Method', 'near_range');
    saveLiConst(dbFile, data.LC.LCStd_raman_607_NR, data.LC.LCStd_raman_607_NR, ...
                data.LC.LC_start_time, data.LC.LC_stop_time, PollyDataInfo.pollyDataFile, ...
                CampaignConfig.name, '607', 'Raman_Method', 'near_range');
    print_msg('--> finish.\n', 'flagTimestamp', true);
    catch
    print_msg('--> ERROR saving lidar calibration constants.\n', 'flagTimestamp', true);
    end
    %% save water vapor calibration results
    if (sum(flag407) == 1) && (sum(flag387FR) == 1)
        print_msg('--> start saving water vapor calibration results...\n', 'flagTimestamp', true);
        saveWVConst(dbFile, wvconst, wvconstStd, wvCaliInfo, data.IWVAttri, PollyDataInfo.pollyDataFile, CampaignConfig.name);
        print_msg('--> finish.\n', 'flagTimestamp', true);
    end

    print_msg('Finish.\n', 'flagTimestamp', true);
end


%% Saving products
if PicassoConfig.flagEnableResultsOutput
% prepare confugartion information for storing to netcdf
data.PicassoConfig_saving_info=struct2char(PicassoConfig);
data.PollyConfig_saving_info=struct2char(PollyConfig);
data.CampaignConfig_saving_info=struct2char(CampaignConfig);
data.PollyDataInfo_saving_info=struct2char(PollyDataInfo);

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
            display(ncFileList{iFile})
            delete(ncFileList{iFile})
        end
        print_msg('Finish.\n', 'flagTimestamp', true);
    end

    % saving products
    print_msg('Start saving products.\n', 'flagTimestamp', true);

    for iProd = 1:length(PollyConfig.prodSaveList)
        %try
        
        switch lower(PollyConfig.prodSaveList{iProd})

        case 'overlap'
            print_msg('--> start saving overlap function.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save overlap function
            %try
            saveFile = fullfile(PicassoConfig.results_folder, ...
                                CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), ...
                                datestr(data.mTime(1), 'mm'), ...
                                datestr(data.mTime(1), 'dd'), ...
                                sprintf('%s_overlap.nc', rmext(PollyDataInfo.pollyDataFile)));
            pollySaveOverlap(data, saveFile);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'rcs'
            print_msg('--> start saving Range Corrected Signals.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %try
            pollySaveRCS(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'aerproffr'
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving aerosol vertical profiles.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %% save aerosol optical results
                %try
    	            pollySaveProfiles(data);
                     print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    	        %catch
    	        % print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
    	        %end
            end
            %%%%%% Test for storing quality controled information
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving qualtiy controlled aerosol vertical profiles (experimental).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %% save QCaerosol optical results
                try %as this is experimental, the try statement stays
    	          %%%%This is the part interesting for Henriette!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  pollySaveProfiles_QC(data);
                  %%%%This is the part interesting for Henriette end!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                catch
    	          print_msg('--> WARNING, could not save QC with', 'flagSimpleMsg', true, 'flagTimestamp', true);
    	        end
            end
        case 'aerprofnr'
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving aerosol vertical profiles (near-field).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %% save aerosol optical results for near range
              %try
                pollySaveNRProfiles(data);
                print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
              %catch
               % print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
              %end
            end
        case 'aerprofoc'
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving aerosol vertical profiles (overlap corrected).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);

                %% save aerosol optical results(overlap corrected)
                % try
                  pollySaveOCProfiles(data);
                  print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %catch
                  %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %end
            end
            
        case 'aerattbetafr'
            print_msg('--> start saving attenuated backscatter (far-field).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save attenuated backscatter from far-field signal
            %try
            pollySaveAttnBeta(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true)
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'aerattbetaoc'
            print_msg('--> start saving attenuated backscatter (overlap corrected).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save attenuated backscatter from overlap-corrected signal
            %try
            pollySaveOCAttnBeta(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'aerattbetanr'
            print_msg('--> start saving attenuated backscatter (near-field).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save attenuated backscatter from near-field signal
            %try
            pollySaveNRAttnBeta(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'wvmr_rh'
            print_msg('--> start saving water vapor products.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save water vapor mixing ratio and relative humidity
            %try
            pollySaveWV(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'voldepol'
            print_msg('--> start saving volume depolarization ratio.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save volume depolarization ratio
            %try
            pollySaveVDR(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'quasiv1'
            print_msg('--> start saving quasi-retrieved products (V1).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save quasi results (V1)
            %try
            pollySaveQsiV1(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'quasiv2'
            print_msg('--> start saving quasi-retrieved products (V2).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save quasi results (V2)
            %try
            pollySaveQsiV2(data);
            print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'tc'
            print_msg('--> start saving aerosol/cloud target classification mask (V1).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save target classification results (V1)
            %try
            pollySaveTCV1(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'tcv2'
            print_msg('--> start saving aerosol/cloud target classification mask (V2).\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %% save target classification results (V2)
            %try
            pollySaveTCV2(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end

        case 'cloudinfo'
            print_msg('--> start saving cloud mask.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %try
            pollySaveCloudInfo(data);
            print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %catch
            %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
            %end
            
        case 'poliphon_one'
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving 1-step POLIPHON products.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %try
                pollySavePOLIPHON(data, data.POLIPHON1);
                print_msg('--> finsih!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %catch
                %print_msg('--> WARNING, could not save with', 'flagSimpleMsg', true, 'flagTimestamp', true);
                %end
            end
        
        case 'poliphon_two'
            if PicassoConfig.flagSaveProfiles
                print_msg('--> start saving POLIPHON 2 products.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                % try
                pollySavePOLIPHON2(data, data.POLIPHON2);
                print_msg('--> finish!\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
                % catch
                % print_msg('--> WARNING, could not save POLIPHON 2 products.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
            end
        
        otherwise
            warning('Unknow product %s', PollyConfig.prodSaveList{iProd});
        end
        %catch
        %    print_msg('--> Error storing data as netcdf');
        %end
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

%    %% diaplay monitor status
%    print_msg('--> start diplaying lidar housekeeping data.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
%    pollyDisplayHousekeeping(data);
%    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%
%    %% display polarization calibration results
%    print_msg('--> start displaying polarization calibration results.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
%    pollyDisplayPolCali(data);
%    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%
%    %% display overlap function
%    print_msg('--> start displaying overlap function.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
%    pollyDisplayOL(data);
%    print_msg('--> finish.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
%
%    %% display aerosol vertical profiles
%    print_msg('--> start displaying vertical profiles.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%    pollyDisplayProfiles(data);
%    pollyDisplayOCProfiles(data);
%    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%
%    %% display lidar calibration constants
%    print_msg('--> start display lidar calibration constants.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%    pollyDisplayLC(data);
%    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%
%    %% display long-term lidar calibration results
%    print_msg('--> start displaying long-term lidar calibration results.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
%    pollyDisplayLTLCali(data, dbFile);
%    print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);


    %% if flag flagEnableDataVisualization24h exists and is true ... do not plot 3d-plots from here, but use the imshow-method from level1-data
    if PicassoConfig.flagEnableDataVisualization24h
        disp('Flag PicassoConfig.flagEnableDataVisualization24h is true');
        %% call pypolly_display_all.py script
        pyFolder = PicassoConfig.pyBinDir;   % folder of the python scripts for data visualization
        pythonPath = fullfile(pyFolder, 'python');
        %pythonPath = '/lacroshome/cloudnetpy/cloudnetpy-env/bin/python3';
        pythonScript = fullfile(PicassoDir, 'lib', 'visualization', 'pypolly_display_all.py');
        measurement_date = [datestr(PollyDataInfo.dataTime, 'yyyy'), datestr(PollyDataInfo.dataTime, 'mm'), datestr(PollyDataInfo.dataTime, 'dd')];
        pypolly_command = sprintf('%s %s --date %s --device %s --picasso_config_file %s --polly_config_file %s --outdir %s --retrieval all --donefilelist true', pythonPath, pythonScript, measurement_date, pollyType, PicassoConfigFile, PollyConfig.pollyConfigFile, PicassoConfig.pic_folder);
        disp(pypolly_command);
%        [status, output] = system(pypolly_command);
        system(pypolly_command);
    %% if flag flagEnableDataVisualization24h is false ... plot 3d-plots the old way with pcolormesh
    else
        disp('Flag PicassoConfig.flagEnableDataVisualization24h does not exist or is set to false!');
        %% display signal status
        print_msg('--> start displaying signal status.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
        pollyDisplaySigStatus(data);
        print_msg('--> finish.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
    
        %% display attenuated backscatter
        print_msg('--> start displaying attenuated backscatter.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        pollyDisplayAttnBsc(data);
        print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    
        %% display range corrected signal
        print_msg('--> start displaying range corrected signal.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
        pollyDisplayRCS(data);
        print_msg('--> finish.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    
        %% display volume depolarization ratio
        print_msg('--> start displaying volume depolarization ratio.\n', 'flagSimpleMsg', true, 'flagTimestamp', true);
        pollyDisplayVDR(data);
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
    end 

    print_msg('Finish!\n', 'flagTimestamp', true);

    %% Done filelist
    if p.Results.flagDonefileList
        print_msg('Start writing done_filelist.\n', 'flagTimestamp', true);
        pollyWriteDonelist(data);
        print_msg('Finish.\n', 'flagTimestamp', true);
    end
end


tEnd = now();
tUsage = (tEnd - tStart) * 24 * 3600;
report{end + 1} = tStart;
report{end + 1} = tUsage;
print_msg('\n%%------------------------------------------------------%%\n');
print_msg('Finish pollynet processing chain\n', 'flagTimestamp', true);
print_msg('%%------------------------------------------------------%%\n');

%% Clean
if strcmpi(OS, 'linux')
    % Do nothing
else
    % Do nothing
end

fclose(LogConfig.logFid);

%% Enable the usage of matlab toolbox
if PicassoConfig.flagReduceMATLABToolboxDependence
    license('checkout', 'statistics_toolbox', 'enable');
    print_msg('Enable the usage of matlab statistics_toolbox\n', ...
              'flagSimpleMsg', true);
end
%% Clean
% clear;
end