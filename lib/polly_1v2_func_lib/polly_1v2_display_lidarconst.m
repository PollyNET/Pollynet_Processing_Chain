function [] = polly_1v2_display_lidarconst(data, taskInfo, config)
%polly_1v2_display_lidarconst Display the lidar constants.
%   Example:
%       [] = polly_1v2_display_lidarconst(data, taskInfo, config)
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

%% initialization
fileLC532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename)));

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
ylim(config.LC532Range);

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

end