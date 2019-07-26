function [] = polly_1v2_display_overlap(data, taskInfo, attri, config)
%polly_1v2_display_overlap display the overlap function.
%   Example:
%       [] = polly_1v2_display_overlap(data, taskInfo, attri, config)
%   Inputs:
%       data: struct
%       taskInfo: struct
%           the present processed task information. Go to fileinfo_new.txt for more details.
%       attri: struct
%           attributes about overlap function.
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%   Outputs:
%       
%   History:
%       2019-07-16. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

%% extract the overlap calbration results from attribute
overlap532 = attri.overlap532;
overlap532Defaults = attri.overlap532DefaultInterp;
sig532FR = attri.sig532FR;
sig532NR = attri.sig532NR;
sigRatio532 = attri.sigRatio532;
normRange532 = attri.normRange532;
height = data.height;

%% convert the empty array to default filled values
if isempty(overlap532)
    overlap532 = NaN(size(height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = NaN(size(height));
end
if isempty(sig532FR)
    sig532FR = NaN(size(height));
end
if isempty(sig532NR)
    sig532NR = NaN(size(height));
end
if isempty(sigRatio532)
    sig532Gl = NaN(size(height));
else
    sig532Gl = sig532FR ./ overlap532;
end

if strcmpi(processInfo.visualizationMode, 'matlab')

    overlapPicFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_overlap.png', rmext(taskInfo.dataFilename)));

    figure('Position', [0, 0, 600, 400], 'Units', 'Pixels', 'Visible', 'off');

    % overlap
    subplot(121);
    p1 = plot(overlap532, height, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', 'overlap 532'); hold on;
    p2 = plot(overlap532Defaults, height, 'Color', config.overlap532Color/255, 'LineWidth', 1, 'LineStyle', '--', 'DisplayName', 'default overlap 532'); hold on;

    l1 = plot([1, 1], [height(1), height(end)], 'LineWidth', 1, 'LineStyle', '--', 'Color', 'k');

    xlim([-0.05, 1.1]);
    ylim([0, 3000]);
    xlabel('Overlap');
    ylabel('Height (m)');
    text(1.2, 1.04, sprintf('Overlap-%s-%s at %s', campaignInfo.name, campaignInfo.location, datestr(taskInfo.dataTime, 'yyyymmdd HH:MM')), 'FontSize', 9, 'FontWeight', 'bold', 'interpreter', 'none', 'HorizontalAlignment', 'center', 'Units', 'normal');

    set(gca, 'XMinorTick', 'on', 'XTick', 0:0.2:1, 'YTick', 500:500:3000, 'YMinorTick', 'on');
    l = legend([p1, p2], 'Location', 'NorthWest');
    set(l, 'FontSize', 6);

    % signal gluing
    subplot(122)
    sig532FR(sig532FR <= 0) = NaN;
    sig532NR(sig532NR <= 0) = NaN;
    sig532Gl(sig532Gl <= 0) = NaN;
    p1 = semilogx(sig532FR, height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', 'FR 532nm'); hold on;
    p2 = semilogx(sig532NR, height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', 'NR 532nm'); hold on;
    p3 = semilogx(sig532Gl, height, 'Color', 'g', 'LineStyle', '-.', 'LineWidth', 1, 'DisplayName', 'FR Glued 532nm'); hold on;

    if ~ isempty(attri.normRange532)
        l1 = plot([1e-2, 1e3], [height(normRange532(1)), height(normRange532(1))], '--g');
        l2 = plot([1e-2, 1e3], [height(normRange532(end)), height(normRange532(end))], '--g');
    end

    xlim([1e-2, 1e3]);
    ylim([0, 3000]);
    xlabel('Signal [MHz]');
    text(0.2, 0.2, sprintf('Cloud-free assured'), 'Units', 'normal', 'color', 'r', 'fontsize', 5);

    set(gca, 'XTick', logspace(-2, 3, 6), 'XMinorTick', 'on', 'YTick', 500:500:3000, 'YMinorTick', 'on');
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    set(l, 'FontSize', 6);

    text(0.74, -0.10, sprintf(['%s' char(10) '%s' char(10) 'Version %s'], campaignInfo.location, campaignInfo.name, processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman');

    %% save figure
    export_fig(gcf, overlapPicFile, '-transparent', '-r300', '-painters');
    close();
elseif strcmpi(processInfo.visualizationMode, 'python')
        
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    figDPI = processInfo.figDPI;

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'overlap532', 'overlap532Defaults', 'sig532FR', 'sig532NR', 'sig532Gl', 'sigRatio532', 'normRange532', 'height', 'processInfo', 'campaignInfo', 'taskInfo', '-v7');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_overlap.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'polly_1v2_display_overlap.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end