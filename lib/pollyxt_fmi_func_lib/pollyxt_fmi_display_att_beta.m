function [] = pollyxt_fmi_display_att_beta(data, taskInfo, config)
%pollyxt_fmi_display_att_beta display attenuated signal
%   Example:
%       [] = pollyxt_fmi_display_att_beta(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    fileATT_BETA_355 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_ATT_BETA_355.png', rmext(taskInfo.dataFilename)));
    fileATT_BETA_532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_ATT_BETA_532.png', rmext(taskInfo.dataFilename)));
    fileATT_BETA_1064 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_ATT_BETA_1064.png', rmext(taskInfo.dataFilename)));

    %% visualization
    load('chiljet_colormap.mat')

    % 355 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    ATT_BETA_355 = data.att_beta_355;
    ATT_BETA_355(data.quality_mask_355 > 0) = NaN;
    p1 = pcolor(data.mTime, data.height, ATT_BETA_355 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(config.att_beta_cRange_355);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Attenuated Backscatter at %snm %s for %s at %s', '355', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
    text(0.90, -0.18, sprintf('Calibration %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1}), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'Mm^{-1}*Sr^{-1}');

    colormap(chiljet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileATT_BETA_355, '-transparent', '-r300', '-painters');
    close();

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    ATT_BETA_532 = data.att_beta_532;
    ATT_BETA_532(data.quality_mask_532 > 0) = NaN;
    p1 = pcolor(data.mTime, data.height, ATT_BETA_532 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(config.att_beta_cRange_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Attenuated Backscatter at %snm %s for %s at %s', '532', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
    text(0.90, -0.18, sprintf('Calibration %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1}), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'Mm^{-1}*Sr^{-1}');

    colormap(chiljet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileATT_BETA_532, '-transparent', '-r300', '-painters');
    close();

    % 1064 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    ATT_BETA_1064 = data.att_beta_1064;
    ATT_BETA_1064(data.quality_mask_1064 > 0) = NaN;
    p1 = pcolor(data.mTime, data.height, ATT_BETA_1064 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(config.att_beta_cRange_1064);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Attenuated Backscatter at %snm %s for %s at %s', '1064', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
    text(0.90, -0.18, sprintf('Calibration %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1}), 'Units', 'Normal');

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'Mm^{-1}*Sr^{-1}');

    colormap(chiljet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileATT_BETA_1064, '-transparent', '-r300', '-painters');
    close();
elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    ATT_BETA_355 = data.att_beta_355;
    ATT_BETA_532 = data.att_beta_532;
    ATT_BETA_1064 = data.att_beta_1064;
    quality_mask_355 = data.quality_mask_355;
    quality_mask_532 = data.quality_mask_532;
    quality_mask_1064 = data.quality_mask_1064;
    height = data.height;
    time = data.mTime;
    figDPI = processInfo.figDPI;
    flagLC355 = config.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1};
    flagLC532 = config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1};
    flagLC1064 = config.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1};
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    att_beta_cRange_355 = config.att_beta_cRange_355;
    att_beta_cRange_532 = config.att_beta_cRange_532;
    att_beta_cRange_1064 = config.att_beta_cRange_1064;

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display rcs 
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'ATT_BETA_355', 'ATT_BETA_532', 'ATT_BETA_1064', 'quality_mask_355', 'quality_mask_532', 'quality_mask_1064', 'height', 'time', 'flagLC355', 'flagLC532', 'flagLC1064', 'att_beta_cRange_355', 'att_beta_cRange_532', 'att_beta_cRange_1064', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_fmi_display_att_beta.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_fmi_display_att_beta.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end