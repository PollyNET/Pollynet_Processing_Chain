sfunction [] = pollyxt_dwd_display_lidarconst(data, taskInfo, config)
%pollyxt_dwd_display_lidarconst Display the lidar constants.
%   Example:
%       [] = pollyxt_dwd_display_lidarconst(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

if isempty(data.cloudFreeGroups)
    return;
end

thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
LC355_klett = data.LC.LC_klett_355;
LC355_raman = data.LC.LC_raman_355;
LC355_aeronet = data.LC.LC_aeronet_355;
LC532_klett = data.LC.LC_klett_532;
LC532_raman = data.LC.LC_raman_532;
LC532_aeronet = data.LC.LC_aeronet_532;
LC1064_klett = data.LC.LC_klett_1064;
LC1064_raman = data.LC.LC_raman_1064;
LC1064_aeronet = data.LC.LC_aeronet_1064;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% initialization
    fileLC355 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_LC_355.png', rmext(taskInfo.dataFilename)));
    fileLC532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename)));
    fileLC1064 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_LC_1064.png', rmext(taskInfo.dataFilename)));

    %% 355 nm
    figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

    p1 = plot(thisTime, LC355_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
    p2 = plot(thisTime, LC355_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
    p3 = plot(thisTime, LC355_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

    xlim([data.mTime(1), data.mTime(end)]);
    ylim(config.LC355Range);

    xlabel('UTC');
    ylabel('C');
    title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '355', campaignInfo.name, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    set(gca, 'YMinorTick', 'on');
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
    export_fig(gcf, fileLC355, '-transparent', sprintf('-r%d', processInfo.figDPI));
    close();

    %% 532 nm
    figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

    p1 = plot(thisTime, LC532_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
    p2 = plot(thisTime, LC532_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
    p3 = plot(thisTime, LC532_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

    xlim([data.mTime(1), data.mTime(end)]);
    ylim(config.LC532Range);

    xlabel('UTC');
    ylabel('C');
    title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '532', campaignInfo.name, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    set(gca, 'YMinorTick', 'on');
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
    export_fig(gcf, fileLC532, '-transparent', sprintf('-r%d', processInfo.figDPI));
    close();

    %% 1064 nm
    figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

    p1 = plot(thisTime, LC1064_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
    p2 = plot(thisTime, LC1064_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
    p3 = plot(thisTime, LC1064_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

    xlim([data.mTime(1), data.mTime(end)]);
    ylim(config.LC1064Range);

    xlabel('UTC');
    ylabel('C');
    title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '1064', campaignInfo.name, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    set(gca, 'YMinorTick', 'on');
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
    export_fig(gcf, fileLC1064, '-transparent', sprintf('-r%d', processInfo.figDPI));
    close();
 
elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    time = data.mTime;
    figDPI = processInfo.figDPI;
    yLim355 = config.LC355Range;
    yLim532 = config.LC532Range;
    yLim1064 = config.LC1064Range;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display rcs 
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'time', 'thisTime', 'LC355_klett', 'LC355_raman', 'LC355_aeronet', 'LC532_klett', 'LC532_raman', 'LC532_aeronet', 'LC1064_klett', 'LC1064_raman', 'LC1064_aeronet', 'yLim355', 'yLim532', 'yLim1064', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', '-v7');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_dwd_display_lidarconst.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_dwd_display_lidarconst.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end