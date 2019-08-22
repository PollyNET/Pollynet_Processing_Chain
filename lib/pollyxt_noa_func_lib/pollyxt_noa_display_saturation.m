function [] = pollyxt_noa_display_saturation(data, taskInfo, config)
%pollyxt_noa_display_saturation display the saturation mask.
%   Example:
%       [] = pollyxt_noa_display_saturation(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-29. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
%% initialization 
    fileStatus355FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_355.png', rmext(taskInfo.dataFilename)));
    fileStatus532FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_532.png', rmext(taskInfo.dataFilename)));
    fileStatus1064FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_1064.png', rmext(taskInfo.dataFilename)));
    fileStatus532NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_532.png', rmext(taskInfo.dataFilename)));
    fileStatus355NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_NR_355.png', rmext(taskInfo.dataFilename)));
    fileStatus407FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_SAT_FR_407.png', rmext(taskInfo.dataFilename)));
    flagChannel355 = config.isFR & config.is355nm & config.isTot;
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
    flagChannel532NR = config.isNR & config.is532nm & config.isTot;
    flagChannel355NR = config.isNR & config.is355nm & config.isTot;
    flagChannel407 = config.isFR & config.is407nm;

    %% visualization
    load('status_colormap.mat')
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.12, 0.15, 0.7, 0.75]);   % mainframe

    SAT_FR_355 = double(squeeze(data.flagSaturation(flagChannel355, :, :)));
    SAT_FR_355(data.lowSNRMask(flagChannel355, :, :)) = 2;
    p1 = pcolor(data.mTime, data.height, SAT_FR_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '355', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on', 'FontSize', 6);
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

    SAT_FR_532 = double(squeeze(data.flagSaturation(flagChannel532, :, :)));
    SAT_FR_532(data.lowSNRMask(flagChannel532, :, :)) = 2;
    p1 = pcolor(double(data.mTime), data.height, SAT_FR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '532', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on', 'FontSize', 6);
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

    SAT_FR_1064 = double(squeeze(data.flagSaturation(flagChannel1064, :, :)));
    SAT_FR_1064(data.lowSNRMask(flagChannel1064, :, :)) = 2;
    p1 = pcolor(double(data.mTime), data.height, SAT_FR_1064); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '1064', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on', 'FontSize', 6);
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

    SAT_NR_355 = double(squeeze(data.flagSaturation(flagChannel355NR, :, :)));
    SAT_NR_355(data.lowSNRMask(flagChannel355NR, :, :)) = 2;
    p1 = pcolor(double(data.mTime), data.height, SAT_NR_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 3000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '355', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:1000:3000, 'yminortick', 'on', 'FontSize', 6);
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

    SAT_NR_532 = double(squeeze(data.flagSaturation(flagChannel532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flagChannel532NR, :, :)) = 2;
    p1 = pcolor(double(data.mTime), data.height, SAT_NR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 3000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '532', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:1000:3000, 'yminortick', 'on', 'FontSize', 6);
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

    SAT_FR_407 = double(squeeze(data.flagSaturation(flagChannel407, :, :)));
    SAT_FR_407(data.lowSNRMask(flagChannel407, :, :)) = 2;
    p1 = pcolor(double(data.mTime), data.height, SAT_FR_407); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([-0.5, 2.5]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 8000]);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Signal Status at %snm %s from %s at %s', '407', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2000:8000, 'yminortick', 'on', 'FontSize', 6);
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

    flagChannel355 = config.isFR & config.is355nm & config.isTot;
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
    flagChannel532NR = config.isNR & config.is532nm & config.isTot;
    flagChannel355NR = config.isNR & config.is355nm & config.isTot;
    flagChannel407 = config.isFR & config.is407nm;

    time = data.mTime;
    figDPI = processInfo.figDPI;
    height = data.height;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    SAT_FR_355 = double(squeeze(data.flagSaturation(flagChannel355, :, :)));
    SAT_FR_355(data.lowSNRMask(flagChannel355, :, :)) = 2;    
    SAT_FR_532 = double(squeeze(data.flagSaturation(flagChannel532, :, :)));
    SAT_FR_532(data.lowSNRMask(flagChannel532, :, :)) = 2;
    SAT_FR_1064 = double(squeeze(data.flagSaturation(flagChannel1064, :, :)));
    SAT_FR_1064(data.lowSNRMask(flagChannel1064, :, :)) = 2;
    SAT_NR_532 = double(squeeze(data.flagSaturation(flagChannel532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flagChannel532NR, :, :)) = 2;
    SAT_NR_355 = double(squeeze(data.flagSaturation(flagChannel355NR, :, :)));
    SAT_NR_355(data.lowSNRMask(flagChannel355NR, :, :)) = 2;
    SAT_FR_407 = double(squeeze(data.flagSaturation(flagChannel407, :, :)));
    SAT_FR_407(data.lowSNRMask(flagChannel407, :, :)) = 2;

    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_355', 'SAT_FR_532', 'SAT_FR_1064', 'SAT_NR_532', 'SAT_NR_355', 'SAT_FR_407', 'processInfo', 'campaignInfo', 'taskInfo', '-v7');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_noa_display_saturation.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_noa_display_saturation.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end