function [] = polly_1v2_display_att_beta(data, taskInfo, config)
%polly_1v2_display_att_beta display attenuated signal
%   Example:
%       [] = polly_1v2_display_att_beta(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo campaignInfo

%% parameter initialize
fileATT_BETA_532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_ATT_BETA_532.png', rmext(taskInfo.dataFilename)));

%% visualization
load('chiljet_colormap.mat')

% 532 nm FR
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

ATT_BETA_532 = data.att_beta_532;
ATT_BETA_532(data.quality_mask_532 > 0) = NaN;
p1 = pcolor(data.mTime, data.height, ATT_BETA_532 * 1e6); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 5]);
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

end