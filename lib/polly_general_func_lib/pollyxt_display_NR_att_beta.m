function pollyxt_display_NR_att_beta(data, taskInfo, config)
%POLLYXT_DISPLAY_NR_ATT_BETA display attenuated signal
%Example:
%   pollyxt_display_NR_att_beta(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%History:
%   2018-12-30. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global defaults processInfo campaignInfo

%% read data
ATT_BETA_355 = data.att_beta_NR_355;
ATT_BETA_532 = data.att_beta_NR_532;
height = data.height;
time = data.mTime;
figDPI = processInfo.figDPI;
flagLC355 = char(config.LCCalibrationStatus{data.LCUsed.LCUsedTag355NR + 1});
flagLC532 = char(config.LCCalibrationStatus{data.LCUsed.LCUsedTag532NR + 1});
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
att_beta_cRange_355 = config.zLim_att_beta_355;
att_beta_cRange_532 = config.zLim_att_beta_532;
yLim_att_beta = config.yLim_att_beta_NR;
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')

    %% parameter initialize
    fileATT_BETA_355 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_ATT_BETA_NR_355.%s', rmext(taskInfo.dataFilename), imgFormat));
    fileATT_BETA_532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_ATT_BETA_NR_532.%s', rmext(taskInfo.dataFilename), imgFormat));

    %% visualization
    load('myjet_colormap.mat')
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, ATT_BETA_355 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(att_beta_cRange_355);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_att_beta);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Attenuated Backscatter at %snm %s for %s at %s', '355', 'Far-Range', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_att_beta(1), yLim_att_beta(2), 6), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version %s\nCalibration %s', processInfo.programVersion, flagLC355), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'Mm^{-1}*sr^{-1}', 'FontSize', 6);

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileATT_BETA_355, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    p1 = pcolor(data.mTime, data.height, ATT_BETA_532 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(att_beta_cRange_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_att_beta);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Attenuated Backscatter at %snm %s for %s at %s', '532', 'Far-Range', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_att_beta(1), yLim_att_beta(2), 6), 'yminortick', 'on', 'FontSize', 6);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version %s\nCalibration %s', processInfo.programVersion, flagLC532), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.20, 0.02, 0.65]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'Mm^{-1}*sr^{-1}', 'FontSize', 6);

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileATT_BETA_532, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
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
    save(tmpFile, 'figDPI', 'ATT_BETA_355', 'ATT_BETA_532', 'height', 'time', 'flagLC355', 'flagLC532', 'att_beta_cRange_355', 'att_beta_cRange_532', 'yLim_att_beta', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'imgFormat', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_display_NR_att_beta.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_display_NR_att_beta.py');
    end
    delete(tmpFile);

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end