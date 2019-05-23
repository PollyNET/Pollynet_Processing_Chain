function [] = pollyxt_fmi_display_rcs(data, taskInfo, config)
%pollyxt_fmi_display_rcs display the range corrected signal, vol-depol at 355 and 532 nm
%   Example:
%       [] = pollyxt_fmi_display_rcs(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%
%   History:
%       2018-12-29. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    fileRCS355FR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_355.png', rmext(taskInfo.dataFilename)));
    fileRCS532FR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_532.png', rmext(taskInfo.dataFilename)));
    fileRCS1064FR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_1064.png', rmext(taskInfo.dataFilename)));
    fileRCS532NR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_NR_532.png', rmext(taskInfo.dataFilename)));
    fileVolDepol355 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_VDR_355.png', rmext(taskInfo.dataFilename)));
    fileVolDepol532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_VDR_532.png', rmext(taskInfo.dataFilename)));
    flagChannel355 = config.isFR & config.is355nm & config.isTot;
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
    flagChannel532NR = config.isNR & config.is532nm & config.isTot;

    %% visualization
    load('chiljet_colormap.mat')

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_355 = squeeze(data.signal(flagChannel355, :, :)) ./ repmat(data.mShots(flagChannel355, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_355(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([3e5, 2e7]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '355', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u]');

    colormap(chiljet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileRCS355FR, '-transparent', '-r300', '-painters');
    close();

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_532 = squeeze(data.signal(flagChannel532, :, :)) ./ repmat(data.mShots(flagChannel532, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_532(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([3e5, 2e7]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '532', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u]');

    colormap(chiljet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileRCS532FR, '-transparent', '-r300', '-painters');
    close()

    % 1064 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_1064 = squeeze(data.signal(flagChannel1064, :, :)) ./ repmat(data.mShots(flagChannel1064, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_1064(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_1064); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([3e5, 2e7]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '1064', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u]');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    colormap(chiljet);
    export_fig(gcf, fileRCS1064FR, '-transparent', '-r300', '-painters');
    close()

    % 532 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_NR_532 = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_NR_532(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_NR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([1e5, 2e6]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 3000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '532', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:500:3000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u]');

    colormap(chiljet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileRCS532NR, '-transparent', '-r300', '-painters');
    close();

    % 532 nm vol depol
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, data.volDepol_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 0.4]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Volume Depolarization Ratio at %snm for %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');

    colormap(chiljet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileVolDepol532, '-transparent', '-r300', '-painters');
    close();

    % 355 nm vol depol
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, data.volDepol_355); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 0.4]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Volume Depolarization Ratio at %snm for %s at %s', '355', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');

    colormap(chiljet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileVolDepol355, '-transparent', '-r300', '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% preparing the data
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    flagChannel355 = config.isFR & config.is355nm & config.isTot;
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
    flagChannel532NR = config.isNR & config.is532nm & config.isTot;
    flagChannel355NR = config.isNR & config.is355nm & config.isTot;
    mTime = data.mTime;
    height = data.height;
    figDPI = processInfo.figDPI;
    depCalMask = data.depCalMask;
    fogMask = data.fogMask;
    RCS_FR_355 = squeeze(data.signal(flagChannel355, :, :)) ./ repmat(data.mShots(flagChannel355, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_532 = squeeze(data.signal(flagChannel532, :, :)) ./ repmat(data.mShots(flagChannel532, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_1064 = squeeze(data.signal(flagChannel1064, :, :)) ./ repmat(data.mShots(flagChannel1064, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;    
    RCS_NR_532 = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2; 
    RCS_NR_355 = squeeze(data.signal(flagChannel355NR, :, :)) ./ repmat(data.mShots(flagChannel355NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    volDepol_355 = data.volDepol_355;
    volDepol_532 = data.volDepol_532;
    
    %% display rcs 
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'RCS_FR_355', 'RCS_FR_532', 'RCS_FR_1064', 'RCS_NR_355', 'RCS_NR_532', 'volDepol_355', 'volDepol_532', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_fmi_display_rcs.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_fmi_display_rcs.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end