function [] = arielle_display_quasiretrieving(data, taskInfo, config)
%arielle_display_quasiretrieving display the quasi retrievings results
%   Example:
%       [] = arielle_display_quasiretrieving(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de
    
global defaults processInfo campaignInfo

if strcmpi(processInfo.visualizationMode, 'matlab')
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
    caxis(config.quasi_beta_cRange_532);
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
    caxis(config.quasi_beta_cRange_1064);
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
    caxis(config.quasi_Par_DR_cRange_532);
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

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'));

    quasi_bsc_532 = data.quasi_par_beta_532;
    quality_mask_532 = data.quality_mask_532;
    quasi_bsc_1064 = data.quasi_par_beta_1064;
    quality_mask_1064 = data.quality_mask_1064;
    quasi_pardepol_532 = data.quasi_parDepol_532;
    quasi_ang_532_1064 = data.quasi_ang_532_1064;
    height = data.height;
    time = data.mTime;
    figDPI = processInfo.figDPI;
    quasi_Par_DR_cRange_532 = config.quasi_Par_DR_cRange_532;
    quasi_beta_cRange_532 = config.quasi_beta_cRange_532;
    quasi_beta_cRange_1064 = config.quasi_beta_cRange_1064;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    %% display quasi results
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'quasi_bsc_532', 'quality_mask_532', 'quasi_bsc_1064', 'quality_mask_1064', 'quasi_pardepol_532', 'quasi_ang_532_1064', 'quasi_Par_DR_cRange_532', 'quasi_beta_cRange_532', 'quasi_beta_cRange_1064', 'height', 'time', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr');
    tmpFile = fullfile(tmpFolder, 'tmp.mat');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'arielle_display_quasiretrieving.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'arielle_display_quasiretrieving.py');
    end
    delete(fullfile(tmpFolder, 'tmp.mat'));
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end