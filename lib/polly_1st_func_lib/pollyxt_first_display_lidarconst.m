function [] = pollyxt_first_display_lidarconst(data, taskInfo, config)
%pollyxt_first_display_lidarconst Display the lidar constants.
%   Example:
%       [] = pollyxt_first_display_lidarconst(data, taskInfo, config)
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
LC532_klett = data.LC.LC_klett_532;
LC532_raman = data.LC.LC_raman_532;
LC532_aeronet = data.LC.LC_aeronet_532;
LC607_raman = data.LC.LC_raman_607;

if strcmpi(processInfo.visualizationMode, 'matlab')

    %% initialization
    fileLC532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename)));
    fileLC607 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_LC_607.png', rmext(taskInfo.dataFilename)));

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
    
    %% 607 nm
    figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

    p1 = plot(thisTime, LC607_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;

    xlim([data.mTime(1), data.mTime(end)]);
    ylim(config.LC607Range);

    xlabel('UTC');
    ylabel('C');
    title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '607', campaignInfo.name, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    set(gca, 'YMinorTick', 'on');
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    l = legend([p1], 'Location', 'NorthEast');
    set(l, 'FontSize', 7);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
    export_fig(gcf, fileLC607, '-transparent', sprintf('-r%d', processInfo.figDPI));
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    time = data.mTime;
    figDPI = processInfo.figDPI;
    yLim532 = config.LC532Range;
    yLim607 = config.LC607Range;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'thisTime', 'LC532_klett', 'LC532_raman', 'LC607_raman', 'LC532_aeronet', 'yLim532', 'yLim607', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_first_display_lidarconst.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_first_display_lidarconst.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end