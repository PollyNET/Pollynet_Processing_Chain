function [] = pollyxt_lacros_display_overlap(height, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, taskInfo, globalAttri)
%pollyxt_lacros_display_overlap display the overlap function.
%   Example:
%       [] = pollyxt_lacros_display_overlap(height, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, globalAttri)
%   Inputs:
%       height: array
%           height above surface. [m]
%       overlap532: array
%           calculated overlap for 532 nm far range total channel.
%       overlap355: array
%           calculated overlap for 355 nm far range total channel.
%       overlap532Defaults: array
%           default overlap for 532 nm far range total channel.
%       overlap355Defaults: array
%           default overlap for 355 nm far range total channel.
%       file: char
%           file to save the displayed figure.
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%       taskInfo: struct
%           the present processed task information. Go to fileinfo_new.txt for more details.
%       globalAttri: struct
%           global attribute.
%   Outputs:
%       
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

%% convert the empty array to default filled values
if isempty(overlap532)
    overlap532 = NaN(size(height));
end
if isempty(overlap355)
    overlap355 = NaN(size(height));
end
if isempty(overlap355Defaults)
    overlap355Defaults = NaN(size(height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = NaN(size(height));
end

figure('Position', [0, 0, 600, 600], 'Units', 'Pixels', 'Visible', 'off');

subplot(121);
p1 = plot(overlap532, height, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', 'overlap 532'); hold on;
p2 = plot(overlap355, height, 'Color', config.overlap355Color/255, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', 'overlap 355'); hold on;
p3 = plot(overlap532Defaults, height, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'default overlap 532'); hold on;
p4 = plot(overlap355Defaults, height, 'Color', config.overlap355Color/255, 'LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'default overlap 355'); hold on;

l1 = plot([1, 1], [height(1), height(end)], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');

xlim([-0.05, 1.1]);
ylim([0, 3000]);
xlabel('Overlap');
ylabel('Height (m)');
title(sprintf('%s - %s - %s', taskInfo.pollyVersion, globalAttri.location, datestr(taskInfo.dataTime, 'yyyymmdd HH:MM')), 'FontSize', 7, 'FontWeight', 'bold');

set(gca, 'XMinorTick', 'on', 'XTick', 0:0.2:1, 'YTick', 500:500:3000);

set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

%% save figure
saveas(gcf, file);
close();

end