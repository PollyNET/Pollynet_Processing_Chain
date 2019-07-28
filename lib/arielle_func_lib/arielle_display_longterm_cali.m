function [] = arielle_display_longterm_cali(taskInfo, config)
%arielle_display_longterm_cali Display the lidar constants.
%   Example:
%       [] = arielle_display_longterm_cali(taskInfo, config)
%   Inputs:
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       
%   History:
%       2019-02-08. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

%% read lidar constant
lcCaliFile = fullfile(processInfo.results_folder, campaignInfo.name, config.lcCaliFile);
LC = arielle_read_LC(lcCaliFile, config.dataFileFormat);
% extract the logbook info till the current measurement
flagTillNow = LC.LCTime <= taskInfo.dataTime;
LCTime = LC.LCTime(flagTillNow);
LC355Status = LC.LC355Status(flagTillNow);
LC532Status = LC.LC532Status(flagTillNow);
LC1064Status = LC.LC1064Status(flagTillNow);
LC387Status = LC.LC387Status(flagTillNow);
LC607Status = LC.LC607Status(flagTillNow);
LC355History = LC.LC355History(flagTillNow);
LCStd355History = LC.LCStd355History(flagTillNow);
LC532History = LC.LC532History(flagTillNow);
LCStd532History = LC.LCStd532History(flagTillNow);
LC1064History = LC.LC1064History(flagTillNow);
LCStd1064History = LC.LCStd1064History(flagTillNow);
LC387History = LC.LC387History(flagTillNow);
LCStd387History = LC.LCStd387History(flagTillNow);
LC607History = LC.LC607History(flagTillNow);
LCStd607History = LC.LCStd607History(flagTillNow);

%% read wv calibration constant
wvCaliFile = fullfile(processInfo.results_folder, campaignInfo.name, config.wvCaliFile);
[WVCaliTime, WVConst] = arielle_read_wvconst(wvCaliFile);
flagTillNow = WVCaliTime <= taskInfo.dataTime;
WVConst = WVConst(flagTillNow);
WVCaliTime = WVCaliTime(flagTillNow);

%% read depol calibration constant
% 355 nm
depolCaliFile355 = fullfile(processInfo.results_folder, campaignInfo.name, config.depolCaliFile355);
[depolCaliTime355, depolCaliConst355] = arielle_read_depolconst(depolCaliFile355);
flagTillNow = depolCaliTime355 <= taskInfo.dataTime;
depolCaliTime355 = depolCaliTime355(flagTillNow);
depolCaliConst355 = depolCaliConst355(flagTillNow);

% 532 nm
depolCaliFile532 = fullfile(processInfo.results_folder, campaignInfo.name, config.depolCaliFile532);
[depolCaliTime532, depolCaliConst532] = arielle_read_depolconst(depolCaliFile532);
flagTillNow = depolCaliTime532 <= taskInfo.dataTime;
depolCaliTime532 = depolCaliTime532(flagTillNow);
depolCaliConst532 = depolCaliConst532(flagTillNow);

%% read logbook file
if ~ isfield(config, 'logbookFile')
    % if 'logbookFile' was no set
    config.logbookFile = '';
end
logbookInfo = read_logbook(config.logbookFile, numel(config.first_range_gate_indx));
flagLogbookTillNow = (logbookInfo.datetime <= taskInfo.dataTime);
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
flagCH355FR = config.is355nm & config.isFR & config.isTot;
flagCH532FR = config.is532nm & config.isFR & config.isTot;
flagCH1064FR = config.is1064nm & config.isFR & config.isTot;
flagCH387FR = config.is387nm & config.isFR;
flagCH607FR = config.is607nm & config.isFR;
flagCH407FR = config.is407nm & config.isFR;
flagCH355FR_X = config.is355nm & config.isFR & config.isCross;
flagCH532FR_X = config.is532nm & config.isFR & config.isCross;

% yLim setting
yLim355 = config.LC355Range;
yLim532 = config.LC532Range;
yLim1064 = config.LC1064Range;
wvLim = config.WVConstRange;
depolConstLim355 = config.depolConstRange355;
depolConstLim532 = config.depolConstRange532;

%% data visualization 
% visualization with matlab (low efficiency and less compatible)
if strcmpi(processInfo.visualizationMode, 'matlab')

    lineColor = struct();
    lineColor.overlap = [244, 143, 66]/255;
    lineColor.windowwipe = [255, 102, 255]/255;
    lineColor.flashlamps = [153, 51, 51]/255;
    lineColor.pulsepower = [153, 0, 153]/255;
    lineColor.restart = [255, 255, 0]/255;
    lineColor.NDChange = [51, 51, 0]/255;
    lineColor.else = [0, 255, 0]/255;

    %% initialization
    fileLC = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'), sprintf('%s_long_term_LC.png', datestr(taskInfo.dataTime, 'yyyymmdd')));

    figure('Position', [0, 0, 800, 1200], 'Units', 'Pixels', 'Visible', 'off');
    figPos = subfigPos([0.1, 0.1, 0.85, 0.8], 5, 1);
    
    %% 355 nm
    subplot('Position', figPos(1, :), 'Units', 'Normalized');
    flagRamanLC = (LC355Status == 2);
    s1 = scatter(LCTime(flagRamanLC), LC355History(flagRamanLC), 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'DisplayName', 'Lidar constants'); hold on;
    
    p1 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2, 'DisplayName', 'overlap');
    p2 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2, 'DisplayName', 'pulsepower');
    p3 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2, 'DisplayName', 'windowwipe');
    p4 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2, 'DisplayName', 'restart');
    p5 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2, 'DisplayName', 'flashlamps');
    p6 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2, 'DisplayName', 'ND Change');
    p7 = plot([datenum(0, 1, 0, 0, 0, 0), datenum(0, 1, 0, 0, 0, 0)], [-1, -2], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2, 'DisplayName', else_label);
    l = legend([s1, p1, p2, p3, p4, p5, p6, p7], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    for iLogbookInfo = 1:numel(logbookTime)
        if flagOverlap(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2);
        end

        if flagPulsepower(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2);
        end
        
        if flagWindowwipe(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2);
        end
        
        if flagRestart(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2);
        end
        
        if flagFlashlamps(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2);
        end
        
        if flag_CH_NDChange(iLogbookInfo, flagCH355FR)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2);
        end
    end

    for iElse = 1:numel(else_time)
        plot([else_time(iElse), else_time(iElse)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2);
    end

    ylabel('LC @ 355 nm');
    title(sprintf('Long term Lidar Constant for %s at %s', campaignInfo.name, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 10);

    set(gca, 'xticklabel', '', 'XMinorTick', 'on', 'Box', 'on');
    set(gca, 'YMinorTick', 'on');
    xlim([double(campaignInfo.startTime) - 2, taskInfo.dataTime + 2]);
    ylim(yLim355);

    %% 532 nm
    subplot('Position', figPos(2, :), 'Units', 'Normalized');
    flagRamanLC = (LC532Status == 2);
    s1 = scatter(LCTime(flagRamanLC), LC532History(flagRamanLC), 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g'); hold on;

    for iLogbookInfo = 1:numel(logbookTime)
        if flagOverlap(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2);
        end

        if flagPulsepower(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2);
        end
        
        if flagWindowwipe(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2);
        end
        
        if flagRestart(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2);
        end
        
        if flagFlashlamps(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2);
        end
        
        if flag_CH_NDChange(iLogbookInfo, flagCH532FR)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2);
        end
    end

    for iElse = 1:numel(else_time)
        plot([else_time(iElse), else_time(iElse)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2);
    end

    ylabel('LC @ 532 nm');

    set(gca, 'xticklabel', '', 'XMinorTick', 'on', 'Box', 'on');
    set(gca, 'YMinorTick', 'on');
    xlim([campaignInfo.startTime - 2, taskInfo.dataTime + 2]);
    ylim(yLim532);

    %% 1064 nm
    subplot('Position', figPos(3, :), 'Units', 'Normalized');
    flagRamanLC = (LC1064Status == 2);
    s1 = scatter(LCTime(flagRamanLC), LC1064History(flagRamanLC), 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r'); hold on;

    for iLogbookInfo = 1:numel(logbookTime)
        if flagOverlap(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2);
        end

        if flagPulsepower(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2);
        end
        
        if flagWindowwipe(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2);
        end
        
        if flagRestart(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2);
        end
        
        if flagFlashlamps(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2);
        end
        
        if flag_CH_NDChange(iLogbookInfo, flagCH1064FR)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2);
        end
    end

    for iElse = 1:numel(else_time)
        plot([else_time(iElse), else_time(iElse)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2);
    end

    ylabel('LC @ 1064 nm');

    set(gca, 'xticklabel', '', 'XMinorTick', 'on', 'Box', 'on');
    set(gca, 'YMinorTick', 'on');
    xlim([campaignInfo.startTime - 2, taskInfo.dataTime + 2]);
    ylim(yLim1064);
    
    %% 355/387 nm
    subplot('Position', figPos(4, :), 'Units', 'Normalized');
    flagRamanLC = (LC387Status == 2) & (LC355Status == 2);
    scatter(LCTime(flagRamanLC), LC355History(flagRamanLC)./LC387History(flagRamanLC) / 1.436, 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b'); hold on;

    for iLogbookInfo = 1:numel(logbookTime)
        if flagOverlap(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2);
        end

        if flagPulsepower(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2);
        end
        
        if flagWindowwipe(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2);
        end
        
        if flagRestart(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2);
        end
        
        if flagFlashlamps(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2);
        end
        
        if flag_CH_NDChange(iLogbookInfo, flagCH387FR) || flag_CH_NDChange(iLogbookInfo, flagCH355FR)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2);
        end
    end

    for iElse = 1:numel(else_time)
        plot([else_time(iElse), else_time(iElse)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2);
    end

    ylabel('Ratio 355/387');

    set(gca, 'xticklabel', '', 'XMinorTick', 'on', 'Box', 'on');
    set(gca, 'YMinorTick', 'on');
    xlim([campaignInfo.startTime - 2, taskInfo.dataTime + 2]);
    ylim([0, 1]);
    
    %% 532/607 nm
    subplot('Position', figPos(5, :), 'Units', 'Normalized');
    flagRamanLC = (LC607Status == 2) & (LC532Status == 2);
    scatter(LCTime(flagRamanLC), LC532History(flagRamanLC)./LC607History(flagRamanLC) / 1.71, 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g'); hold on;

    for iLogbookInfo = 1:numel(logbookTime)
        if flagOverlap(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.overlap, 'LineWidth', 2);
        end

        if flagPulsepower(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.pulsepower, 'LineWidth', 2);
        end
        
        if flagWindowwipe(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.windowwipe, 'LineWidth', 2);
        end
        
        if flagRestart(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.restart, 'LineWidth', 2);
        end
        
        if flagFlashlamps(iLogbookInfo)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.flashlamps, 'LineWidth', 2);
        end
        
        if flag_CH_NDChange(iLogbookInfo, flagCH607FR) || flag_CH_NDChange(iLogbookInfo, flagCH532FR)
            plot([logbookTime(iLogbookInfo), logbookTime(iLogbookInfo)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.NDChange, 'LineWidth', 2);
        end
    end

    for iElse = 1:numel(else_time)
        plot([else_time(iElse), else_time(iElse)], [-1, 1e20], 'LineStyle', '--', 'Color', lineColor.else, 'LineWidth', 2);
    end

    ylabel('Ratio 532/607');
    xlabel('Date (mm-dd)')

    set(gca, 'XMinorTick', 'on', 'Box', 'on');
    set(gca, 'YMinorTick', 'on');
    datetick(gca, 'x', 'mm-dd', 'keepticks');
    xlim([campaignInfo.startTime - 2, taskInfo.dataTime + 2]);
    ylim([0, 1]);
    text(-0.04, -0.17, sprintf('%s', datestr(taskInfo.dataTime, 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.17, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, fileLC, '-transparent', '-r300');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'));
    figDPI = processInfo.figDPI;

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display longterm cali results
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'LCTime', 'LC355Status', 'LC532Status', 'LC1064Status', 'LC387Status', 'LC607Status', 'LC355History', 'LCStd355History', 'LC532History', 'LCStd532History', 'LC1064History', 'LCStd1064History', 'LC387History', 'LCStd387History', 'LC607History', 'LCStd607History', 'logbookTime', 'flagOverlap', 'flagWindowwipe', 'flagFlashlamps', 'flagPulsepower', 'flagRestart', 'flag_CH_NDChange', 'flagCH355FR', 'flagCH532FR', 'flagCH1064FR', 'flagCH387FR', 'flagCH607FR', 'flagCH407FR', 'flagCH355FR_X', 'flagCH532FR_X', 'else_time', 'else_label', 'WVCaliTime', 'WVConst', 'depolCaliTime355', 'depolCaliConst355', 'depolCaliTime532', 'depolCaliConst532', 'yLim355', 'yLim532', 'yLim1064', 'wvLim', 'depolConstLim355', 'depolConstLim532', 'processInfo', 'campaignInfo', 'taskInfo', '-v7');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'arielle_display_longterm_cali.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'arielle_display_longterm_cali.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end