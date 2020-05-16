function polly_1v2_display_rcs(data, taskInfo, config)
%POLLY_1V2_DISPLAY_RCS display the range corrected signal, vol-depol at 355 and 532 nm
%Example:
%   polly_1v2_display_rcs(data, config)
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

%% preparing the data
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel532NR = flagChannel532;
mTime = data.mTime;
height = data.height;
figDPI = processInfo.figDPI;
depCalMask = data.depCalMask;
fogMask = data.fogMask;
RCS_FR_532 = squeeze(data.signal(flagChannel532, :, :)) ./ repmat(data.mShots(flagChannel532, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS_NR_532 = squeeze(data.signal(flagChannel532NR, :, :)) ./ repmat(data.mShots(flagChannel532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

volDepol_532 = data.volDepol_532;
yLim_FR_RCS = config.yLim_FR_RCS;
yLim_NR_RCS = config.yLim_NR_RCS;
yLim_FR_DR = config.yLim_FR_DR;
% RCS532FRColorRange = config.zLim_FR_RCS_532;
RCS532FRColorRange = auto_RCS_cRange(data.height, RCS_FR_532, 'hRange', [0, 5000]) ./ 1e6;
% RCS532NRColorRange = config.zLim_NR_RCS_532;
RCS355FRColorRange = auto_RCS_cRange(data.height, RCS_FR_355, 'hRange', [0, 5000]) ./ 1e6;
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')

    %% parameter initialize
    fileRCS532FR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_FR_532.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileRCS532NR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RCS_NR_532.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileVolDepol532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_VDR_532.%s', rmext(taskInfo.dataFilename), imgFormat));

    %% visualization
    load('chiljet_colormap.mat')

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_FR_532(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_FR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(zLim_FR_RCS_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_RCS);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '532', 'Far-Range', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_RCS(1), yLim_FR_RCS(2), 6), 'yminortick', 'on');
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
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS532FR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close()

    % 532 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    RCS_NR_532(:, data.depCalMask) = NaN;
    p1 = pcolor(data.mTime, data.height, RCS_NR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(zLim_NR_RCS_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_NR_RCS);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Range-Corrected Signal at %snm %s for %s at %s', '532', 'Near-Range', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_NR_RCS(1), yLim_NR_RCS(2), 6), 'yminortick', 'on');
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
    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRCS532NR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm vol depol
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, data.volDepol_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 0.4]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_FR_DR);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Volume Depolarization Ratio at %snm for %s at %s', '532', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_FR_DR(1), yLim_FR_DR(2), 6), 'yminortick', 'on');
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
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_RCS', 'yLim_NR_RCS', 'yLim_FR_DR', 'RCS_FR_532', 'RCS_NR_532', 'volDepol_532', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'RCS532FRColorRange', 'RCS532NRColorRange', 'imgFormat', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_rcs.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'polly_1v2_display_rcs.py');
    end
    delete(tmpFile);

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end