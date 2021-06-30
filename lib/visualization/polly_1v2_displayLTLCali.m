function polly_1v2_displayLTLCali(data, dbFile)
% POLLY_1V2_DISPLAYLTLCALI display long-term lidar calibration results.
% USAGE:
%    polly_1v2_displayLTLCali(data, dbFile)
% INPUTS:
%    data: struct
%    dbFile: char
% EXAMPLE:
% HISTORY:
%    2021-06-11: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

%% read lidar constant
[LC532History, LCStd532History, startTime532, stopTime532] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '532', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC607History, LCStd607History, startTime607, stopTime607] = ...
    loadLiConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '607', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);

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

if ~ isempty(startTime532)
    LCTime532 = mean([startTime532; stopTime532], 1);
else
    LCTime532 = [];
end
LC532Status = 2 * ones(size(startTime532));
if ~ isempty(startTime607)
    LCTime607 = mean([startTime607; stopTime607], 1);
else
    LCTime607 = [];
end
LC607Status = 2 * ones(size(startTime607));

%% read depol calibration constant
% 532 nm
[depolCaliConst532, ~, caliStartTime532, caliStopTime532] = ...
    loadDepolConst(PollyDataInfo.dataTime, dbFile, CampaignConfig.name, '532', 'flagBeforeQuery', true);
if ~ isempty(caliStartTime532)
    depolCaliTime532 = mean([caliStartTime532; caliStopTime532], 1);
else
    depolCaliTime532 = [];
end

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
flagCH532FR = data.flag532nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
flagCH532FR_X = data.flag532nmChannel & data.flagFarRangeChannel & data.flagCrossChannel;
flagCH607FR = data.flag607nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;

% yLim setting
yLim532 = PollyConfig.yLim_LC_532;
yLim_LC_ratio_532_607 = PollyConfig.yLim_LC_ratio_532_607;
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
save(tmpFile, 'figDPI', 'LCTime532', 'LCTime607', 'LC532Status', 'LC532History', 'LCStd532History', 'LC607Status', 'LC607History', 'LCStd607History', 'logbookTime', 'flagOverlap', 'flagWindowwipe', 'flagFlashlamps', 'flagPulsepower', 'flagRestart', 'flag_CH_NDChange', 'flagCH532FR', 'flagCH607FR', 'flagCH532FR_X', 'depolCaliTime532', 'depolCaliConst532', 'depolConstLim532', 'else_time', 'else_label', 'yLim532', 'yLim_LC_ratio_532_607', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_displayLTLCali.py'), tmpFile, saveFolder));
if flag ~= 0
    warning('Error in executing %s', 'polly_1v2_displayLTLCali.py');
end
delete(tmpFile);

end