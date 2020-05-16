function pollyxt_dwd_display_rcs(data, taskInfo, config)
%POLLYXT_DWD_DISPLAY_RCS display the range corrected signal, vol-depol at 355 and 532 nm
%Example:
%   pollyxt_dwd_display_rcs(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%History:
%   2018-12-29. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global defaults processInfo campaignInfo

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel532NR = config.isNR & config.is532nm & config.isTot;
flagChannel355NR = config.isFR & config.is355nm & config.isTot;

%% preparing the data
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
mTime = data.mTime;
height = data.height;
figDPI = processInfo.figDPI;
depCalMask = data.depCalMask;
fogMask = data.fogMask;

if sum(flagChannel355) ~= 0
    % if both near- and far-range channels exist
    RCS_FR_355 = squeeze(data.signal(flagChannel355, :, :)) ./ repmat(data.mShots(flagChannel355, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
else
    % if either near- and far-range channel is missing
    RCS_FR_355 = NaN(size(data.signal, 2), size(data.signal, 3));
end

if sum(flagChannel532) ~= 0
    % if both near- and far-range channels exist
    RCS_FR_532 = squeeze(data.signal(flagChannel532, :, :)) ./ repmat(data.mShots(flagChannel532, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
else
    % if either near- and far-range channel is missing
    RCS_FR_532 = NaN(size(data.signal, 2), size(data.signal, 3));
end

if sum(flagChannel1064) ~= 0
    % if both near- and far-range channels exist
    RCS_FR_1064 = squeeze(data.signal(flagChannel1064, :, :)) ./ repmat(data.mShots(flagChannel1064, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
else
    % if either near- and far-range channel is missing
    RCS_FR_1064 = NaN(size(data.signal, 2), size(data.signal, 3));
end  

if sum(flagChannel355NR) ~= 0
    % if both near- and far-range channels exist
    RCS_NR_355 = squeeze(data.signal(flagChannel355NR, :, :)) ./ repmat(data.mShots(flagChannel355NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
else
    % if either near- and far-range channel is missing
    RCS_NR_355 = NaN(size(data.signal, 2), size(data.signal, 3));
end

if sum(flagChannel532NR) ~= 0
    % if both near- and far-range channels exist
    RCS_NR_532 = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
else
    % if either near- and far-range channel is missing
    RCS_NR_532 = NaN(size(data.signal, 2), size(data.signal, 3));
end

yLim_FR_RCS = config.yLim_FR_RCS;
yLim_NR_RCS = config.yLim_NR_RCS;
yLim_FR_DR = config.yLim_FR_DR;
volDepol_532 = data.volDepol_532;
% RCS355FRColorRange = config.zLim_FR_RCS_355;
RCS355FRColorRange = auto_RCS_cRange(data.height, RCS_FR_355, 'hRange', [0, 4000]) ./ 1e6;
% RCS532FRColorRange = config.zLim_FR_RCS_532;
RCS532FRColorRange = auto_RCS_cRange(data.height, RCS_FR_532, 'hRange', [0, 4000]) ./ 1e6;
% RCS1064FRColorRange = config.zLim_FR_RCS_1064;
RCS1064FRColorRange = auto_RCS_cRange(data.height, RCS_FR_1064, 'hRange', [0, 4000]) ./ 1e6;
% RCS532NRColorRange = config.zLim_NR_RCS_532;
RCS532NRColorRange = auto_RCS_cRange(data.height, RCS_NR_532, 'hRange', [0, 3000]) ./ 1e6;
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    fileRCS355FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_355.png', rmext(taskInfo.dataFilename)));
    fileRCS532FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_532.png', rmext(taskInfo.dataFilename)));
    fileRCS1064FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_1064.png', rmext(taskInfo.dataFilename)));
    fileRCS355NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_NR_355.png', rmext(taskInfo.dataFilename)));
    fileRCS532NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_NR_532.png', rmext(taskInfo.dataFilename)));
    fileVolDepol532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_VDR_532.png', rmext(taskInfo.dataFilename)));

    %% visualization
    load('myjet_colormap.mat')   % load colormap
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_355 = squeeze(data.signal(flagChannel355, :, :)) ./ repmat(data.mShots(flagChannel355, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_355(:, (data.depCalMask ~= 0) | data.fogMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_355/1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(RCS355FRColorRange);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Range-Corrected Signal at %snm Far-Range from %s at %s', '355', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 7);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u.]', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS355FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_532 = squeeze(data.signal(flagChannel532, :, :)) ./ repmat(data.mShots(flagChannel532, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_532(:, (data.depCalMask ~= 0) | data.fogMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_532/1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(RCS532FRColorRange);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Range-Corrected Signal at %snm Far-Range from %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 7);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u.]', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS532FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 1064 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_1064 = squeeze(data.signal(flagChannel1064, :, :)) ./ repmat(data.mShots(flagChannel1064, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_FR_1064(:, (data.depCalMask ~= 0) | data.fogMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_1064/1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(RCS1064FRColorRange);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Range-Corrected Signal at %snm Far-Range from %s at %s', '1064', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 7), 'yminortick', 'on', 'FontSize', 7);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u.]', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS1064FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 355 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_NR_355 = squeeze(data.signal(flagChannel355NR, :, :)) ./ repmat(data.mShots(flagChannel355NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_NR_355(:, (data.depCalMask ~= 0) | data.fogMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_NR_355/1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(RCS355NRColorRange);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_NR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Range-Corrected Signal at %snm Near-Range from %s at %s', '355', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', yLim_NR_RCS(1):1000:yLim_NR_RCS(2), 'yminortick', 'on', 'FontSize', 7);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u.]', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS355NR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_NR_532 = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
    RCS_NR_532(:, (data.depCalMask ~= 0) | data.fogMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_NR_532/1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(RCS532NRColorRange);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_NR_RCS);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Range-Corrected Signal at %snm Near-Range from %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', yLim_NR_RCS(1):1000:yLim_NR_RCS(2), 'yminortick', 'on', 'FontSize', 7);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[a.u.]', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS532NR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm vol depol
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    volDepol_532 = data.volDepol_532;
    volDepol_532(:, (data.depCalMask ~= 0) | (data.fogMask)) = NaN;
    p1 = pcolor(data.mTime, data.height, volDepol_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 0.4]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_DR);
    xlabel('UTC', 'FontSize', 7);
    ylabel('Height (m)', 'FontSize', 7);
    title(sprintf('Volume Depolarization Ratio at %snm from %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 7);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_DR(1), yLim_FR_DR(2), 7), 'yminortick', 'on');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 7);
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 7);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '', 'FontSize', 6);

    colormap(myjet);
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileVolDepol532, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
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

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_RCS', 'yLim_NR_RCS', 'yLim_FR_DR', 'RCS_FR_355', 'RCS_FR_532', 'RCS_FR_1064', 'RCS_NR_355', 'RCS_NR_532', 'volDepol_532', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'RCS355FRColorRange', 'RCS532FRColorRange', 'RCS1064FRColorRange', 'RCS532NRColorRange', 'imgFormat', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_dwd_display_rcs.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_dwd_display_rcs.py');
    end
    delete(tmpFile);

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end