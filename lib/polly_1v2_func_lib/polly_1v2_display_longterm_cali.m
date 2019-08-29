function [] = polly_1v2_display_longterm_cali(taskInfo, config)
%polly_1v2_display_longterm_cali Display the lidar constants.
%   Example:
%       [] = polly_1v2_display_longterm_cali(taskInfo, config)
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
LC = polly_1v2_read_LC(lcCaliFile, config.dataFileFormat);
% extract the logbook info till the current measurement
flagTillNow = LC.LCTime <= taskInfo.dataTime;
LCTime = LC.LCTime(flagTillNow);
LC532Status = LC.LC532Status(flagTillNow);
LC532History = LC.LC532History(flagTillNow);
LCStd532History = LC.LCStd532History(flagTillNow);
LC607Status = LC.LC607Status(flagTillNow);
LC607History = LC.LC607History(flagTillNow);
LCStd607History = LC.LCStd607History(flagTillNow);

%% read depol calibration constant
% 532 nm
depolCaliFile532 = fullfile(processInfo.results_folder, campaignInfo.name, config.depolCaliFile532);
[depolCaliTime532, depolCaliConst532] = polly_1v2_read_depolconst(depolCaliFile532);
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
flagCH532FR = config.is532nm & config.isFR & config.isTot;
flagCH532FR_X = config.is532nm & config.isFR & config.isCross;
flagCH607FR = config.is607nm & config.isFR & config.isTot;

% yLim setting
yLim532 = config.LC532Range;
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
    figPos = subfigPos([0.1, 0.1, 0.85, 0.8], 3, 1);
    
    %% 532 nm
    subplot('Position', figPos(1, :), 'Units', 'Normalized');
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

    %% 532/607 nm
    subplot('Position', figPos(2, :), 'Units', 'Normalized');
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
    save(tmpFile, 'figDPI', 'LCTime', 'LC532Status', 'LC532History', 'LCStd532History', 'LC607Status', 'LC607History', 'LCStd607History', 'logbookTime', 'flagOverlap', 'flagWindowwipe', 'flagFlashlamps', 'flagPulsepower', 'flagRestart', 'flag_CH_NDChange', 'flagCH532FR', 'flagCH607FR', 'flagCH532FR_X', 'depolCaliTime532', 'depolCaliConst532', 'depolConstLim532', 'else_time', 'else_label', 'yLim532', 'processInfo', 'campaignInfo', 'taskInfo', '-v7');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_longterm_cali.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'polly_1v2_display_longterm_cali.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end