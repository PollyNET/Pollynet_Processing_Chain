function [] = pollyxt_lacros_display_lidarconst(data, taskInfo, config)
%pollyxt_lacros_display_lidarconst Display the lidar constants.
%   Example:
%       [] = pollyxt_lacros_display_lidarconst(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

%% initialization
fileLC355 = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_355.png', rmext(taskInfo.dataFilename)));
fileLC532 = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename)));
fileLC1064 = fullfile(processInfo.results_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_1064.png', rmext(taskInfo.dataFilename)));

%% 355 nm
thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
LC355_klett = data.LC.LC_klett_355;
LC355_raman = data.LC.LC_raman_355;
LC355_aeronet = data.LC.LC_aeronet_355;

figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

p1 = plot(thisTime, LC355_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
p2 = plot(thisTime, LC355_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
p3 = plot(thisTime, LC355_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

xlim([data.mTime(1), data.mTime(end)]);
ylim([0.5e13, 1e14]);

xlabel('UTC');
ylabel('C');
title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '355', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
set(gca, 'YMinorTick', 'on');
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

l = legend([p1, p2, p3], 'Location', 'NorthEast');
set(l, 'FontSize', 7);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
export_fig(gcf, fileLC355, '-transparent', '-r300');
close();

%% 532 nm
thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
LC532_klett = data.LC.LC_klett_532;
LC532_raman = data.LC.LC_raman_532;
LC532_aeronet = data.LC.LC_aeronet_532;

figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

p1 = plot(thisTime, LC532_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
p2 = plot(thisTime, LC532_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
p3 = plot(thisTime, LC532_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

xlim([data.mTime(1), data.mTime(end)]);
ylim([1e13, 2e14]);

xlabel('UTC');
ylabel('C');
title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '532', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
set(gca, 'YMinorTick', 'on');
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

l = legend([p1, p2, p3], 'Location', 'NorthEast');
set(l, 'FontSize', 7);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
export_fig(gcf, fileLC532, '-transparent', '-r300');
close();

%% 1064 nm
thisTime = mean(data.mTime(data.cloudFreeGroups), 2);
LC1064_klett = data.LC.LC_klett_1064;
LC1064_raman = data.LC.LC_raman_1064;
LC1064_aeronet = data.LC.LC_aeronet_1064;

figure('Position', [0, 0, 500, 300], 'Units', 'Pixels', 'Visible', 'off');

p1 = plot(thisTime, LC1064_klett, 'Color', 'r', 'LineStyle', '--', 'Marker', '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'DisplayName', 'Klett Method'); hold on;
p2 = plot(thisTime, LC1064_raman, 'Color', 'b', 'LineStyle', '--', 'Marker', '*', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raman Method'); hold on;
p3 = plot(thisTime, LC1064_aeronet, 'Color', 'g', 'LineStyle', '--', 'Marker', 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'DisplayName', 'Constrained-AOD Method'); hold on;

xlim([data.mTime(1), data.mTime(end)]);
ylim([1e13, 7e14]);

xlabel('UTC');
ylabel('C');
title(sprintf('Lidar Constant %s-%snm for %s at %s', 'Far-Range', '1064', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 7);

[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
set(gca, 'YMinorTick', 'on');
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

l = legend([p1, p2, p3], 'Location', 'NorthEast');
set(l, 'FontSize', 7);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
export_fig(gcf, fileLC1064, '-transparent', '-r300');
close();

end