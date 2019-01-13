function [] = polly_1v2_display_saturation(data, taskInfo, config)
%polly_1v2_display_saturation display the saturation mask.
%   Example:
%       [] = polly_1v2_display_saturation(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-29. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% initialization 
    fileStatus532FR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_FR_532.png', rmext(taskInfo.dataFilename)));
    fileStatus532NR = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_NR_532.png', rmext(taskInfo.dataFilename)));
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel532NR = config.isFR & config.is532nm & config.isTot;

    %% visualization
    load('status_colormap.mat')

    % 532 nm FR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.7, 0.75]);   % mainframe

    SAT_FR_532 = double(squeeze(data.flagSaturation(flagChannel532, :, :)));
    SAT_FR_532(data.lowSNRMask(flagChannel532, :, :)) = 2;
    p1 = pcolor(data.mTime, data.height, SAT_FR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 2]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 15000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Signal Status at %snm %s for %s at %s', '532', 'Far-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    tickLabels = {'Good signal', ...
                'Saturated', ...
                'Low SNR'};
    c = colorbar('position', [0.82, 0.15, 0.02, 0.75]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', (0.5:1:2.5)/3*2, 'yticklabel', tickLabels);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileStatus532FR, '-transparent', '-r300', '-painters');
    close();

    %% 532 nm NR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.7, 0.75]);   % mainframe

    SAT_NR_532 = double(squeeze(data.flagSaturation(flagChannel532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flagChannel532NR, :, :)) = 2;
    p1 = pcolor(data.mTime, data.height, SAT_NR_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 2]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim([0, 3000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Signal Status at %snm %s for %s at %s', '532', 'Near-Range', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:500:3000, 'yminortick', 'on');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal');
    text(0.90, -0.13, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal');

    % colorbar
    tickLabels = {'Good signal', ...
    'Saturated', ...
    'Low SNR'};
    c = colorbar('position', [0.82, 0.15, 0.02, 0.75]); 
    colormap(status_colormap);
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '');
    set(c, 'TickDir', 'out', 'Box', 'on');
    set(c, 'ytick', (0.5:1:2.5)/3*2, 'yticklabel', tickLabels);

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');

    export_fig(gcf, fileStatus532NR, '-transparent', '-r300', '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
        
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel532NR = flagChannel532;

    time = data.mTime;
    height = data.height;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    SAT_FR_532 = double(squeeze(data.flagSaturation(flagChannel532, :, :)));
    SAT_FR_532(data.lowSNRMask(flagChannel532, :, :)) = 2;
    SAT_NR_532 = double(squeeze(data.flagSaturation(flagChannel532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flagChannel532NR, :, :)) = 2;

    save(fullfile(tmpFolder, 'tmp.mat'), 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_532', 'SAT_NR_532', 'processInfo', 'campaignInfo', 'taskInfo');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_saturation.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'polly_1v2_display_saturation.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end