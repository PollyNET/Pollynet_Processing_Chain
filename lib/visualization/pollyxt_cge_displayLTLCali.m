function pollyxt_cge_displayLTLCali(data, dbFile)
% POLLYXT_CGE_DISPLAYLTLCALI display long-term lidar calibration results.
% USAGE:
%    pollyxt_cge_displayLTLCali(data, dbFile)
% INPUTS:
%    data: struct
%    dbFile: char
% EXAMPLE:
% HISTORY:
%    2021-06-11: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

%% read lidar constant
[LC355History, LCStd355History, startTime355, stopTime355] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '355', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC532History, LCStd532History, startTime532, stopTime532] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '532', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC1064History, LCStd1064History, startTime1064, stopTime1064] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '1064', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC387History, LCStd387History, startTime387, stopTime387] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '387', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC607History, LCStd607History, startTime607, stopTime607] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '607', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);

if (length(startTime355) ~= length(startTime387))
    [~, indTime355, indTime387] = intersect(startTime355, startTime387);
    LC355History = LC355History(indTime355);
    LCStd355History = LCStd355History(indTime355);
    startTime355 = startTime355(indTime355);
    stopTime355 = stopTime607(indTime355);
    LC387History = LC387History(indTime387);
    LCStd387History = LCStd387History(indTime387);
    startTime387 = startTime387(indTime387);
    stopTime387 = stopTime607(indTime387);
end

if (length(startTime532) ~= length(startTime607))
    [~, indTime532, indTime607] = intersect(startTime532, startTime607);
    LC532History = LC532History(indTime532);
    LCStd532History = LCStd532History(indTime532);
    startTime532 = startTime532(indTime532);
    stopTime532 = stopTime607(indTime532);
    LC607History = LC607History(indTime607);
    LCStd607History = LCStd607History(indTime607);
    startTime607 = startTime607(indTime607);
    stopTime607 = stopTime607(indTime607);
end

if ~ isempty(startTime355)
    LCTime355 = mean([startTime355; stopTime355], 1);
else
    LCTime355 = [];
end
LC355Status = 2 * ones(size(startTime355));
if ~ isempty(startTime532)
    LCTime532 = mean([startTime532; stopTime532], 1);
else
    LCTime532 = [];
end
LC532Status = 2 * ones(size(startTime532));
if ~ isempty(startTime1064)
    LCTime1064 = mean([startTime1064; stopTime1064], 1);
else
    LCTime1064 = [];
end
LC1064Status = 2 * ones(size(startTime1064));
if ~ isempty(startTime387)
    LCTime387 = mean([startTime387; stopTime387], 1);
else
    LCTime387 = [];
end
LC387Status = 2 * ones(size(startTime387));
if ~ isempty(startTime607)
    LCTime607 = mean([startTime607; stopTime607], 1);
else
    LCTime607 = [];
end
LC607Status = 2 * ones(size(startTime607));

%% read logbook file
if ~ isfield(PollyConfig, 'logbookFile')
    % if 'logbookFile' was no set
    PollyConfig.logbookFile = '';
end
logbookInfo = readLogBook(PollyConfig.logbookFile, numel(PollyConfig.first_range_gate_indx));
flagLogbookTillNow = (logbookInfo.datetime <= PollyDataInfo.dataTime);
logbookTime = logbookInfo.datetime(flagLogbookTillNow);
flagOverlap = logbookInfo.changes.flagOverlap(flagLogbookTillNow);
flagWindowwipe = logbookInfo.changes.flagWindowwipe(flagLogbookTillNow);
flagFlashlamps = logbookInfo.changes.flagFlashlamps(flagLogbookTillNow);
flagPulsepower = logbookInfo.changes.flagPulsepower(flagLogbookTillNow);
flagRestart = logbookInfo.changes.flagRestart(flagLogbookTillNow);
flag_CH_NDChange = logbookInfo.flag_CH_NDChange(flagLogbookTillNow, :);

%% leave a 'else' category for future development
else_time = [];
else_label = 'else';

% channel info
flagCH355FR = data.flag355nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
flagCH532FR = data.flag532nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
flagCH1064FR = data.flag1064nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
flagCH387FR = data.flag387nmChannel & data.flagFarRangeChannel;
flagCH607FR = data.flag607nmChannel & data.flagFarRangeChannel;
flagCH532FR_X = data.flag532nmChannel & data.flagFarRangeChannel & data.flagCrossChannel;

% yLim setting
yLim355 = PollyConfig.yLim_LC_355;
yLim532 = PollyConfig.yLim_LC_532;
yLim1064 = PollyConfig.yLim_LC_1064;
yLim_LC_ratio_355_387 = PollyConfig.yLim_LC_ratio_355_387;
yLim_LC_ratio_532_607 = PollyConfig.yLim_LC_ratio_532_607;
wvLim = PollyConfig.yLim_WVConst;
depolConstLim355 = PollyConfig.yLim_depolConst_355;
depolConstLim532 = PollyConfig.yLim_depolConst_532;
imgFormat = PollyConfig.imgFormat;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;

%% data visualization 
pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(PollyDataInfo.dataTime, 'yyyy'), datestr(PollyDataInfo.dataTime, 'mm'), datestr(PollyDataInfo.dataTime, 'dd'));
figDPI = PicassoConfig.figDPI;

% create tmp folder by force, if it does not exist.
if ~ exist(tmpFolder, 'dir')
    fprintf('Create the tmp folder to save the temporary results.\n');
    mkdir(tmpFolder);
end

%% display longterm cali results
tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
save(tmpFile, 'figDPI', 'LCTime355', 'LCTime532', 'LCTime1064', 'LCTime387', 'LCTime607', 'LC355Status', 'LC532Status', 'LC1064Status', 'LC387Status', 'LC607Status', 'LC355History', 'LCStd355History', 'LC532History', 'LCStd532History', 'LC1064History', 'LCStd1064History', 'LC387History', 'LCStd387History', 'LC607History', 'LCStd607History', 'logbookTime', 'flagOverlap', 'flagWindowwipe', 'flagFlashlamps', 'flagPulsepower', 'flagRestart', 'flag_CH_NDChange', 'flagCH355FR', 'flagCH532FR', 'flagCH1064FR', 'flagCH387FR', 'flagCH607FR', 'flagCH532FR_X', 'else_time', 'else_label', 'yLim355', 'yLim532', 'yLim1064', 'yLim_LC_ratio_355_387', 'yLim_LC_ratio_532_607', 'depolConstLim355', 'depolConstLim532', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_cge_displayLTLCali.py'), tmpFile, saveFolder));
if flag ~= 0
    warning('Error in executing %s', 'pollyxt_cge_displayLTLCali.py');
end
delete(tmpFile);

end