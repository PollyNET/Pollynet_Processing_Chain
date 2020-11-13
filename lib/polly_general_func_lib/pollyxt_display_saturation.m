function pollyxt_display_saturation(data, taskInfo, config)
%POLLYXT_DISPLAY_SATURATION display the saturation mask.
%Example:
%   pollyxt_display_saturation(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%History:
%   2018-12-29. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo defaults campaignInfo

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel532NR = config.isNR & config.is532nm & config.isTot;
flagChannel355NR = config.isNR & config.is355nm & config.isTot;
flagChannel407 = config.isFR & config.is407nm;
flagChannel387 = config.isFR & config.is387nm;
flagChannel607 = config.isFR & config.is607nm;
flagChannel387NR = config.isNR & config.is387nm;
flagChannel607NR = config.isNR & config.is607nm;
flagChannel355s = config.isFR & config.is355nm & config.isCross;
flagChannel532s = config.isFR & config.is532nm & config.isCross;

time = data.mTime;
figDPI = processInfo.figDPI;
partnerLabel = config.partnerLabel;
flagWatermarkOn = processInfo.flagWatermarkOn;
height = data.height;
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
SAT_FR_355 = double(squeeze(data.flagSaturation(flagChannel355, :, :)));
SAT_FR_355(data.lowSNRMask(flagChannel355, :, :)) = 2;    
SAT_FR_532 = double(squeeze(data.flagSaturation(flagChannel532, :, :)));
SAT_FR_532(data.lowSNRMask(flagChannel532, :, :)) = 2;
SAT_FR_1064 = double(squeeze(data.flagSaturation(flagChannel1064, :, :)));
SAT_FR_1064(data.lowSNRMask(flagChannel1064, :, :)) = 2;
if any(flagChannel532NR)
    SAT_NR_532 = double(squeeze(data.flagSaturation(flagChannel532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flagChannel532NR, :, :)) = 2;
else
    SAT_NR_532 = NaN(size(data.signal, 2), size(data.signal, 3));
end
if any(flagChannel355NR)
    SAT_NR_355 = double(squeeze(data.flagSaturation(flagChannel355NR, :, :)));
    SAT_NR_355(data.lowSNRMask(flagChannel355NR, :, :)) = 2;
else
    SAT_NR_355 = NaN(size(data.signal, 2), size(data.signal, 3));
end
SAT_FR_407 = double(squeeze(data.flagSaturation(flagChannel407, :, :)));
SAT_FR_407(data.lowSNRMask(flagChannel407, :, :)) = 2;
SAT_FR_387 = double(squeeze(data.flagSaturation(flagChannel387, :, :)));
SAT_FR_387(data.lowSNRMask(flagChannel387, :, :)) = 2;
SAT_FR_607 = double(squeeze(data.flagSaturation(flagChannel607, :, :)));
SAT_FR_607(data.lowSNRMask(flagChannel607, :, :)) = 2;
if any(flagChannel387NR)
    SAT_NR_387 = double(squeeze(data.flagSaturation(flagChannel387NR, :, :)));
    SAT_NR_387(data.lowSNRMask(flagChannel387NR, :, :)) = 2;
else
    SAT_NR_387 = NaN(size(data.signal, 2), size(data.signal, 3));
end
if any(flagChannel607NR)
    SAT_NR_607 = double(squeeze(data.flagSaturation(flagChannel607NR, :, :)));
    SAT_NR_607(data.lowSNRMask(flagChannel607NR, :, :)) = 2;
else
    SAT_NR_607 = NaN(size(data.signal, 2), size(data.signal, 3));
end
SAT_FR_355s = double(squeeze(data.flagSaturation(flagChannel355s, :, :)));
SAT_FR_355s(data.lowSNRMask(flagChannel355s, :, :)) = 2;    
SAT_FR_532s = double(squeeze(data.flagSaturation(flagChannel532s, :, :)));
SAT_FR_532s(data.lowSNRMask(flagChannel532s, :, :)) = 2;

yLim_FR_RCS = config.yLim_FR_RCS;
yLim_NR_RCS = config.yLim_NR_RCS;
yLim_WV_RH = config.yLim_WV_RH;
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')

    %% initialization 
    fileStatus355FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_355.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus532FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_532.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus1064FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_1064.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus532NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_532.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus355NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_355.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus407FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_407.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus387FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_387.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus607FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_607.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus387NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_387.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus607NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_607.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus355FRs = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_355s.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileStatus532FRs = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_532s.%s', rmext(taskInfo.dataFilename), imgFormat));

    %% visualization
    load('status_colormap.mat')
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, SAT_FR_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '355', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus355FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_FR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '532', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus532FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 1064 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_FR_1064); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '1064', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus1064FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 355 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_NR_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_NR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '355', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_NR_RCS(1), yLim_NR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus355NR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_NR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_NR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '532', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_NR_RCS(1), yLim_NR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus532NR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 407 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_FR_407); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_WV_RH);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '407', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_WV_RH(1), yLim_WV_RH(2), 6), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus407FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();     % 387 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_FR_387); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_WV_RH);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '387', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_WV_RH(1), yLim_WV_RH(2), 6), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

     % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus387FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

     % 607 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    p1 = pcolor(double(data.mTime), data.height, SAT_FR_607); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_WV_RH);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '607', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_WV_RH(1), yLim_WV_RH(2), 6), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.83, 0.20, 0.02, 0.65]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', 0:2, 'yticklabel', tickLabels, 'FontSize', 5);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileStatus607FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
        
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_355', 'SAT_FR_532', 'SAT_FR_1064', 'SAT_NR_532', 'SAT_NR_355', 'SAT_FR_407','SAT_FR_387','SAT_FR_607','SAT_NR_387','SAT_NR_607','SAT_FR_355s', 'SAT_FR_532s', 'yLim_FR_RCS', 'yLim_NR_RCS', 'yLim_WV_RH', 'processInfo', 'campaignInfo', 'taskInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_display_saturation.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_display_saturation.py');
    end
    delete(tmpFile);
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end