function [] = polly_1v2_display_rcs(data, taskInfo, config)
%polly_1v2_display_rcs display the range corrected signal, vol-depol at 355 and 532 nm
%   Example:
%       [] = polly_1v2_display_rcs(data, config)
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

%% parameter initialize
fileRCS532FR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_FR_532.png', rmext(taskInfo.dataFilename)));
fileRCS532NR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_NR_532.png', rmext(taskInfo.dataFilename)));
fileVolDepol532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_VDR_532.png', rmext(taskInfo.dataFilename)));
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel532NR = config.isFR & config.is532nm & config.isTot;

%% visualization
load('chiljet_colormap.mat')

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

end