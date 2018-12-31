function [] = pollyxt_lacros_display_overlap(data, taskInfo, attri, config)
%pollyxt_lacros_display_overlap display the overlap function.
%   Example:
%       [] = pollyxt_lacros_display_overlap(alt, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, campaignInfo)
%   Inputs:
%       alt: array
%           alt above surface. [m]
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
%       campaignInfo: struct
%           global attribute.
%   Outputs:
%       
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

%% extract the overlap calbration results from attribute
overlap355 = attri.overlap355;
overlap532 = attri.overlap532;
overlap355Defaults = attri.overlap355DefaultInterp;
overlap532Defaults = attri.overlap532DefaultInterp;
sig355FR = attri.sig355FR;
sig355NR = attri.sig355NR;
sigRatio355 = attri.sigRatio355;
normRange355 = attri.normRange355;
sig532FR = attri.sig532FR;
sig532NR = attri.sig532NR;
sigRatio532 = attri.sigRatio532;
normRange532 = attri.normRange532;
alt = data.alt;

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
if isempty(sig355FR)
    sig355FR = NaN(size(height));
end
if isempty(sig355NR)
    sig355NR = NaN(size(height));
end
if isempty(sig532FR)
    sig532FR = NaN(size(height));
end
if isempty(sig532NR)
    sig532NR = NaN(size(height));
end
if isempty(sigRatio355)
    sig355Gl = NaN(size(height));
else
    sig355Gl = sig355FR ./ overlap355;
end
if isempty(sigRatio532)
    sig532Gl = NaN(size(height));
else
    sig532Gl = sig532FR ./ overlap532;
end

overlapPicFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_overlap.png', rmext(taskInfo.dataFilename)));

figure('Position', [0, 0, 600, 400], 'Units', 'Pixels', 'Visible', 'off');

% overlap
subplot(121);
p1 = plot(overlap532, alt, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', 'overlap 532'); hold on;
p2 = plot(overlap355, alt, 'Color', config.overlap355Color/255, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', 'overlap 355'); hold on;
p3 = plot(overlap532Defaults, alt, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'default overlap 532'); hold on;
p4 = plot(overlap355Defaults, alt, 'Color', config.overlap355Color/255, 'LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'default overlap 355'); hold on;

l1 = plot([1, 1], [alt(1), alt(end)], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');

xlim([-0.05, 1.1]);
ylim([0, 3000]);
xlabel('Overlap');
ylabel('Altitude (m)');
text(1.2, 1.04, sprintf('Overlap-%s-%s at %s', taskInfo.pollyVersion, campaignInfo.location, datestr(taskInfo.dataTime, 'yyyymmdd HH:MM')), 'FontSize', 9, 'FontWeight', 'bold', 'interpreter', 'none', 'HorizontalAlignment', 'center', 'Units', 'normal');

set(gca, 'XMinorTick', 'on', 'XTick', 0:0.2:1, 'YTick', 500:500:3000, 'YMinorTick', 'on');
l = legend([p1, p2, p3, p4], 'Location', 'NorthWest');

% signal gluing
subplot(122)
sig355FR(sig355FR <= 0) = NaN;
sig355NR(sig355NR <= 0) = NaN;
sig355Gl(sig355Gl <= 0) = NaN;
sig532FR(sig532FR <= 0) = NaN;
sig532NR(sig532NR <= 0) = NaN;
sig532Gl(sig532Gl <= 0) = NaN;
p1 = semilogx(sig355FR, alt, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', 'FR 355nm'); hold on;
p2 = semilogx(sig355NR, alt, 'Color', 'b', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', 'NR 355nm'); hold on;
p3 = semilogx(sig355Gl, alt, 'Color', 'b', 'LineStyle', '-.', 'LineWidth', 1, 'DisplayName', 'FR Glued 355nm'); hold on;
p4 = semilogx(sig532FR, alt, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', 'FR 532nm'); hold on;
p5 = semilogx(sig532NR, alt, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', 'NR 532nm'); hold on;
p6 = semilogx(sig532Gl, alt, 'Color', 'g', 'LineStyle', '-.', 'LineWidth', 1, 'DisplayName', 'FR Glued 532nm'); hold on;

if ~ isempty(attri.normRange355)
    l1 = plot([1e-2, 1e3], [alt(normRange355(1)), alt(normRange355(1))], '--b');
    l2 = plot([1e-2, 1e3], [alt(normRange355(end)), alt(normRange355(end))], '--b');
end
if ~ isempty(attri.normRange532)
    l1 = plot([1e-2, 1e3], [alt(normRange532(1)), alt(normRange532(1))], '--g');
    l2 = plot([1e-2, 1e3], [alt(normRange532(end)), alt(normRange532(end))], '--g');
end

xlim([1e-2, 1e3]);
ylim([0, 3000]);
xlabel('Signal [MHz]');
text(0.2, 0.2, sprintf('Cloud-free assured'), 'Units', 'normal', 'color', 'r', 'fontsize', 5);

set(gca, 'XTick', logspace(-2, 3, 6), 'XMinorTick', 'on', 'YTick', 500:500:3000, 'YMinorTick', 'on');
l = legend([p1, p2, p3, p4, p5, p6], 'Location', 'NorthEast');

text(0.74, -0.10, sprintf(['%s' char(10) '%s' char(10) 'Version %s'], campaignInfo.location, taskInfo.pollyVersion, processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

%% save figure
export_fig(gcf, overlapPicFile, '-transparent', '-r300', '-painters');
close();

end