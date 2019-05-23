    function [] = polly_1v2_display_WV(data, taskInfo, config)
%polly_1v2_display_WV display the water vapor mixing ratio and relative humidity.
%   Example:
%       [] = polly_1v2_display_WV(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo campaignInfo

%% parameter initialize
fileWVMR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_WVMR.png', rmext(taskInfo.dataFilename)));
fileRH = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RH.png', rmext(taskInfo.dataFilename)));

flagChannel407 = config.is407nm & config.isFR;
flagChannel387 = config.is387nm & config.isFR;

%% visualization
load('chiljet_colormap.mat');

% WVMR
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

WVMR = data.WVMR;
WVMR(squeeze(data.lowSNRMask(flagChannel387, :, :) | data.lowSNRMask(flagChannel407, :, :))) = NaN;
p1 = pcolor(data.mTime, data.height, WVMR); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 8]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 8000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Water vapor mixing ratio from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:1000:8000, 'yminortick', 'on');
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
flagCalibratedStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
text(0.90, -0.18, sprintf('Calibration %s', flagCalibratedStr{1}), 'Units', 'Normal');

% colorbar
c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
set(gca, 'TickDir', 'out', 'Box', 'on');
titleHandle = get(c, 'Title');
set(titleHandle, 'string', 'g*kg^{-1}');

colormap(chiljet);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

export_fig(gcf, fileWVMR, '-transparent', '-r300', '-painters');
close();

% RH
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

RH = data.RH;
RH(squeeze(data.lowSNRMask(flagChannel387, :, :) | data.lowSNRMask(flagChannel407, :, :))) = NaN;
p1 = pcolor(data.mTime, data.height, RH); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 100]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 8000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Relative humidity from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:1000:8000, 'yminortick', 'on');
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');
text(0.90, -0.18, sprintf('Meteor Info %s', 'GDAS1'), 'Units', 'Normal');

% colorbar
c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
set(gca, 'TickDir', 'out', 'Box', 'on');
titleHandle = get(c, 'Title');
set(titleHandle, 'string', '%');

colormap(chiljet);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

export_fig(gcf, fileRH, '-transparent', '-r300', '-painters');
close();

end