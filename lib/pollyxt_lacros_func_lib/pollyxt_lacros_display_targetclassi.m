function [] = pollyxt_lacros_display_targetclassi(data, taskInfo, config)
%pollyxt_lacros_display_targetclassi display the target classification reuslts
%   Example:
%       [] = pollyxt_lacros_display_targetclassi(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

%% initialization 
fileTC = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_TC.png', rmext(taskInfo.dataFilename)));

%% visualization
load('TC_colormap.mat')

% 355 nm FR
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.6, 0.6]);   % mainframe

TC_mask = double(data.tc_mask);
p1 = pcolor(data.mTime, data.height, TC_mask); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 11]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 12000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Target Classification for %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

% colorbar
TC_TickLabels = {'No signal', ...
                'Clean atmosphere', ...
                'Non-typed particles/low conc.', ...
                'Aerosol: small', ...
                'Aerosol: large, spherical', ...
                'Aerosol: mixture, partly non-spherical', ...
                'Aerosol: large, non-spherical', ...
                'Cloud: non-typed', ...
                'Cloud: water droplets', ...
                'Cloud: likely water droplets', ...
                'Cloud: ice crystals', ...
                'Cloud: likely ice crystals'};
c = colorbar('position', [0.71, 0.15, 0.01, 0.6]); 
colormap(TC_colormap);
titleHandle = get(c, 'Title');
set(titleHandle, 'string', '');
set(c, 'TickDir', 'out', 'Box', 'on');
set(c, 'ytick', (0.5:1:11.5)/12*11, 'yticklabel', TC_TickLabels);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

export_fig(gcf, fileTC, '-transparent', '-r300', '-painters');
close();

end