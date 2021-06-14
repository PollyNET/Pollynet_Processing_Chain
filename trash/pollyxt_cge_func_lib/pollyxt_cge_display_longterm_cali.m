function pollyxt_cge_display_longterm_cali(dbFile, taskInfo, config)
%POLLYXT_CGE_DISPLAY_LONGTERM_CALI Display the lidar constants.
%Example:
%   pollyxt_cge_display_longterm_cali(taskInfo, config)
%Inputs:
%   taskInfo: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%History:
%   2019-02-08. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo campaignInfo

%% read lidar constant
[LC355History, LCStd355History, startTime355, stopTime355] = ...
    load_liconst(taskInfo.dataTime, dbFile, campaignInfo.name, '355', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC532History, LCStd532History, startTime532, stopTime532] = ...
    load_liconst(taskInfo.dataTime, dbFile, campaignInfo.name, '532', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC1064History, LCStd1064History, startTime1064, stopTime1064] = ...
    load_liconst(taskInfo.dataTime, dbFile, campaignInfo.name, '1064', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC387History, LCStd387History, startTime387, stopTime387] = ...
    load_liconst(taskInfo.dataTime, dbFile, campaignInfo.name, '387', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
[LC607History, LCStd607History, startTime607, stopTime607] = ...
    load_liconst(taskInfo.dataTime, dbFile, campaignInfo.name, '607', ...
        'Raman_Method', 'far_range', 'flagBeforeQuery', true);
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
flagCH532FR_X = config.is532nm & config.isFR & config.isCross;

% yLim setting
yLim355 = config.yLim_LC_355;
yLim532 = config.yLim_LC_532;
yLim1064 = config.yLim_LC_1064;
yLim_LC_ratio_355_387 = config.yLim_LC_ratio_355_387;
yLim_LC_ratio_532_607 = config.yLim_LC_ratio_532_607;
wvLim = config.yLim_WVConst;
depolConstLim355 = config.yLim_depolConst_355;
depolConstLim532 = config.yLim_depolConst_532;
imgFormat = config.imgFormat;
partnerLabel = config.partnerLabel;
flagWatermarkOn = processInfo.flagWatermarkOn;

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
    fileLC = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'), sprintf('%s_long_term_LC.%s', datestr(taskInfo.dataTime, 'yyyymmdd'), imgFormat));

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
    scatter(LCTime(flagRamanLC), LC355History(flagRamanLC)./LC387History(flagRamanLC), 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b'); hold on;

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
    scatter(LCTime(flagRamanLC), LC532History(flagRamanLC)./LC607History(flagRamanLC), 'sizedata', 7, 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g'); hold on;

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

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
    export_fig(gcf, fileLC, '-transparent', sprintf('-r%d', processInfo.figDPI));
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')

    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(taskInfo.dataTime, 'yyyy'), datestr(taskInfo.dataTime, 'mm'), datestr(taskInfo.dataTime, 'dd'));
    figDPI = processInfo.figDPI;

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display longterm cali results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'LCTime355', 'LCTime532', 'LCTime1064', 'LCTime387', 'LCTime607', 'LC355Status', 'LC532Status', 'LC1064Status', 'LC387Status', 'LC607Status', 'LC355History', 'LCStd355History', 'LC532History', 'LCStd532History', 'LC1064History', 'LCStd1064History', 'LC387History', 'LCStd387History', 'LC607History', 'LCStd607History', 'logbookTime', 'flagOverlap', 'flagWindowwipe', 'flagFlashlamps', 'flagPulsepower', 'flagRestart', 'flag_CH_NDChange', 'flagCH355FR', 'flagCH532FR', 'flagCH1064FR', 'flagCH387FR', 'flagCH607FR', 'flagCH532FR_X', 'else_time', 'else_label', 'yLim355', 'yLim532', 'yLim1064', 'yLim_LC_ratio_355_387', 'yLim_LC_ratio_532_607', 'depolConstLim355', 'depolConstLim532', 'processInfo', 'campaignInfo', 'taskInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_cge_display_longterm_cali.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_cge_display_longterm_cali.py');
    end
    delete(tmpFile);

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end