function [] = pollyxt_fmi_display_quasiretrieving(data, taskInfo, config)
%pollyxt_fmi_display_quasiretrieving display the quasi retrievings results
%   Example:
%       [] = pollyxt_fmi_display_quasiretrieving(data, taskInfo, config)
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
file_quasi_bsc_532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_Bsc_532.png', rmext(taskInfo.dataFilename)));
file_quasi_bsc_1064 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_Bsc_1064.png', rmext(taskInfo.dataFilename)));
file_quasi_parDepol_532 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_PDR_532.png', rmext(taskInfo.dataFilename)));
file_quasi_AngExp_532_1064 = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_ANGEXP_532_1064.png', rmext(taskInfo.dataFilename)));

%% visualization
load('chiljet_colormap.mat')

% Quasi Bsc 532 nm 
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

quasi_bsc_532 = data.quasi_par_beta_532;
quasi_bsc_532(data.quality_mask_532 ~= 0) = NaN;
p1 = pcolor(data.mTime, data.height, quasi_bsc_532 * 1e6); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 3]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 12000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Quasi Backscatter Coefficient at %snm for %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

% colorbar
c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
set(gca, 'TickDir', 'out', 'Box', 'on');
titleHandle = get(c, 'Title');
set(titleHandle, 'string', 'Mm^{-1}*Sr^{-1}');

colormap(chiljet);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

export_fig(gcf, file_quasi_bsc_532, '-transparent', '-r300', '-painters');
close();

% Quasi Bsc 1064 nm 
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

quasi_bsc_1064 = data.quasi_par_beta_1064;
quasi_bsc_1064(data.quality_mask_1064 ~= 0) = NaN;
p1 = pcolor(data.mTime, data.height, quasi_bsc_1064 * 1e6); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 3]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 12000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Quasi Backscatter Coefficient at %snm for %s at %s', '1064', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

% colorbar
c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
set(gca, 'TickDir', 'out', 'Box', 'on');
titleHandle = get(c, 'Title');
set(titleHandle, 'string', 'Mm^{-1}*Sr^{-1}');

colormap(chiljet);

set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

export_fig(gcf, file_quasi_bsc_1064, '-transparent', '-r300', '-painters');
close();

% Quasi particle depolarization ratio at 532 nm 
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

quasi_pardepol_532 = data.quasi_parDepol_532;
quasi_pardepol_532(data.quality_mask_532 ~= 0) = NaN;
p1 = pcolor(data.mTime, data.height, quasi_pardepol_532); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 0.4]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 12000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Quasi Particle Depolarization Ratio at %snm for %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
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

export_fig(gcf, file_quasi_parDepol_532, '-transparent', '-r300', '-painters');
close();

% Quasi angstroem exponent 532-1064 nm
figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

quasi_ang_532_1064 = data.quasi_ang_532_1064;
quasi_ang_532_1064(data.quality_mask_532 ~= 0) = NaN;
p1 = pcolor(data.mTime, data.height, quasi_ang_532_1064); hold on;
set(p1, 'EdgeColor', 'none');
caxis([0, 2]);
xlim([data.mTime(1), data.mTime(end)]);
ylim([0, 12000]);
xlabel('UTC');
ylabel('Height (m)');
title(sprintf('Quasi BSC Angstroem Exponent 532-1064 for %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
set(gca, 'Box', 'on', 'TickDir', 'out');
set(gca, 'ytick', 0:2000:12000, 'yminortick', 'on');
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

export_fig(gcf, file_quasi_AngExp_532_1064, '-transparent', '-r300', '-painters');
close();

end