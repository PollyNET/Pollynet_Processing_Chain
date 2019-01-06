function [] = arielle_display_monitor(data, taskInfo, config)
%arielle_display_monitor display the values of sensors.
%   Example:
%       [] = arielle_display_monitor(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-05. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo defaults processInfo

if isempty(data.rawSignal)
    return;
end

picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_monitor.png', rmext(taskInfo.dataFilename)));

%% data filter
flagQaulity = true(size(data.monitorStatus.time));
flagQaulity((data.monitorStatus.Temp1 < -10) | (data.monitorStatus.Temp1 > 100) | (data.monitorStatus.Temp2 < -10) | (data.monitorStatus.Temp2 > 100) | (data.monitorStatus.Temp1064 < -200) | (data.monitorStatus.Temp1064 > 0) | (data.monitorStatus.ExtPyro < 0) | (data.monitorStatus.OutsideT < -40)) = false;

figure('Position', [0, 0, 900, 900], 'Units', 'Pixels', 'Visible', 'off');

% ExtPyro
subplot('Position', [0.07, 0.75, 0.88, 0.20], 'Units', 'normalized');
p1 = plot(data.monitorStatus.time(flagQaulity), data.monitorStatus.ExtPyro(flagQaulity), 'Color', [128, 0, 255]/255);
ylabel('ExtPyro [mJ]');
ylim([0, 40]);
xlim([data.mTime(1), data.mTime(end)]);
title(sprintf('%s embedded sensors data at %s', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 10);
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', '');
set(gca, 'YMinorTick', 'on', 'YTick', 5:5:35);

subplot('Position', [0.07, 0.55, 0.88, 0.20], 'Units', 'normalized');
p1 = plot(data.monitorStatus.time(flagQaulity), data.monitorStatus.Temp1(flagQaulity), 'Color', [0, 128, 64]/255, 'DisplayName', 'Temp1'); hold on;
p2 = plot(data.monitorStatus.time(flagQaulity), data.monitorStatus.Temp2(flagQaulity), 'Color', [255, 128, 64]/255, 'DisplayName', 'Temp2'); hold on;
p3 = plot(data.monitorStatus.time(flagQaulity), data.monitorStatus.OutsideT(flagQaulity), 'Color', [255, 0, 255]/255, 'DisplayName', 'Temp Out'); hold on;
ylabel('Temperature [\circC]');
ylim([10, 40]);
xlim([data.mTime(1), data.mTime(end)]);
set(gca, 'xtick', xtick, 'xticklabel', '');
set(gca, 'YMinorTick', 'on', 'YTick', 15:5:35);
l = legend([p1, p2, p3], 'Location', 'NorthWest');
set(l, 'FontSize', 7);

subplot('Position', [0.07, 0.35, 0.88, 0.20], 'Units', 'normalized');
p1 = plot(data.monitorStatus.time(flagQaulity), data.monitorStatus.Temp1064(flagQaulity), 'Color', [255, 0, 0]/255, 'DisplayName', 'Temp1064'); hold on;
ylabel('PMT T at 1064 [\circC]');
ylim([-40, -20]);
xlim([data.mTime(1), data.mTime(end)]);
set(gca, 'xtick', xtick, 'xticklabel', '');
set(gca, 'YMinorTick', 'on', 'YTick', -35:5:-25);

subplot('Position', [0.07, 0.15, 0.88, 0.20], 'Units', 'normalized');
matrixStatus = [transpose(data.monitorStatus.roof(flagQaulity)); transpose(data.monitorStatus.rain(flagQaulity)); transpose(data.monitorStatus.shutter(flagQaulity))];
p1 = imagesc(data.monitorStatus.time(flagQaulity), [1, 2, 3], matrixStatus); hold on;
l1 = plot([data.mTime(1), data.mTime(end)], [1.5, 1.5], 'Color', 'w', 'LineWidth', 3);
l2 = plot([data.mTime(1), data.mTime(end)], [2.5, 2.5], 'Color', 'w', 'LineWidth', 3);
xlabel('UTC');
xlim([data.mTime(1), data.mTime(end)]);
text(-0.04, -0.20, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.20, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
set(gca, 'ytick', [1, 2, 3], 'yticklabel', {'roof', 'rain', 'shutter'});
set(gca,'YDir','normal');
set(gca,'tickdir','out');

colormap([[255, 51, 0]/255;[0, 153, 51]/255]);

set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
export_fig(gcf, picFile, '-transparent', '-r300', '-opengl');
close();

end