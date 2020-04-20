function pollyxt_ift_display_quasiretrieving_V2(data, taskInfo, config)
%POLLYXT_IFT_DISPLAY_QUASIRETRIEVING_V2 display the quasi retrievings results
%Example:
%   pollyxt_ift_display_quasiretrieving_V2(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%History:
%   2018-12-30. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global defaults processInfo campaignInfo

%% read data
quasi_bsc_532 = data.quasi_par_beta_532_V2;
quality_mask_532 = data.quality_mask_532_V2;
quasi_bsc_355 = data.quasi_par_beta_355_V2;
quality_mask_355 = data.quality_mask_355_V2;
quasi_bsc_1064 = data.quasi_par_beta_1064_V2;
quality_mask_1064 = data.quality_mask_1064_V2;
quasi_pardepol_532 = data.quasi_parDepol_532_V2;
quasi_ang_532_1064 = data.quasi_ang_532_1064_V2;
height = data.height;
time = data.mTime;
figDPI = processInfo.figDPI;
yLim_Quasi_Params = config.yLim_Quasi_Params;
quasi_Par_DR_cRange_532 = config.zLim_quasi_Par_DR_532;
quasi_beta_cRange_355 = config.zLim_quasi_beta_355;
quasi_beta_cRange_532 = config.zLim_quasi_beta_532;
quasi_beta_cRange_1064 = config.zLim_quasi_beta_1064;
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    file_quasi_bsc_355 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_Quasi_Bsc_355_V2.%s', rmext(taskInfo.dataFilename), imgFormat));
    file_quasi_bsc_532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_Quasi_Bsc_532_V2.%s', rmext(taskInfo.dataFilename), imgFormat));
    file_quasi_bsc_1064 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_Quasi_Bsc_1064_V2.%s', rmext(taskInfo.dataFilename), imgFormat));
    file_quasi_parDepol_532 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_Quasi_PDR_532_V2.%s', rmext(taskInfo.dataFilename), imgFormat));
    file_quasi_AngExp_532_1064 = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_Quasi_ANGEXP_532_1064_V2.%s', rmext(taskInfo.dataFilename), imgFormat));

    %% visualization
    load('myjet_colormap.mat')

    % Quasi Bsc 355 nm 
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    quasi_bsc_355(quality_mask_355 ~= 0) = NaN;
    p1 = pcolor(data.mTime, data.height, quasi_bsc_355 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(quasi_beta_cRange_355);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_Quasi_Params);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Quasi Backscatter Coefficient (V2) at %snm from %s at %s', '355', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_Quasi_Params(1), yLim_Quasi_Params(2), 7), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version: %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on', 'FontSize', 5);
    titleHandle = get(c, 'Title');
    set(titleHandle,'FontSize', 5, 'string', 'Mm^{-1}*sr^{-1}');

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, file_quasi_bsc_355, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % Quasi Bsc 532 nm 
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    quasi_bsc_532(quality_mask_532 ~= 0) = NaN;
    p1 = pcolor(data.mTime, data.height, quasi_bsc_532 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(quasi_beta_cRange_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_Quasi_Params);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Quasi Backscatter Coefficient (V2) at %snm from %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_Quasi_Params(1), yLim_Quasi_Params(2), 7), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version: %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on', 'FontSize', 5);
    titleHandle = get(c, 'Title');
    set(titleHandle,'FontSize', 5, 'string', 'Mm^{-1}*sr^{-1}');

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, file_quasi_bsc_532, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % Quasi Bsc 1064 nm 
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    quasi_bsc_1064(quality_mask_1064 ~= 0) = NaN;
    p1 = pcolor(data.mTime, data.height, quasi_bsc_1064 * 1e6); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(quasi_beta_cRange_1064);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_Quasi_Params);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Quasi Backscatter Coefficient (V2) at %snm from %s at %s', '1064', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_Quasi_Params(1), yLim_Quasi_Params(2), 7), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version: %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on', 'FontSize', 5);
    titleHandle = get(c, 'Title');
    set(titleHandle,'FontSize', 5, 'string', 'Mm^{-1}*sr^{-1}');

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, file_quasi_bsc_1064, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % Quasi particle depolarization ratio at 532 nm 
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    quasi_pardepol_532(quality_mask_532 ~= 0) = NaN;
    p1 = pcolor(data.mTime, data.height, quasi_pardepol_532); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(quasi_Par_DR_cRange_532);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_Quasi_Params);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Quasi Particle Depolarization Ratio (V2) at %snm from %s at %s', '532', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_Quasi_Params(1), yLim_Quasi_Params(2), 7), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version: %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on', 'FontSize', 5);
    titleHandle = get(c, 'Title');
    set(titleHandle,'FontSize', 5, 'string', '');

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, file_quasi_parDepol_532, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

    % Quasi angstroem exponent 532-1064 nm
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    quasi_ang_532_1064((quality_mask_532 ~= 0) | (quality_mask_1064 ~= 0)) = NaN;
    p1 = pcolor(data.mTime, data.height, quasi_ang_532_1064); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis([0, 2]);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_Quasi_Params);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Quasi BSC Angstroem Exponent 532-1064 (V2) from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_Quasi_Params(1), yLim_Quasi_Params(2), 7), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 5);
    text(0.90, -0.13, sprintf('Version: %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 5);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on', 'FontSize', 5);
    titleHandle = get(c, 'Title');
    set(titleHandle,'FontSize', 5, 'string', '');

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, file_quasi_AngExp_532_1064, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')

    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_bsc_355', 'quality_mask_355', 'quasi_bsc_532', 'quality_mask_532', 'quasi_bsc_1064', 'quality_mask_1064', 'quasi_pardepol_532', 'quasi_ang_532_1064', 'quasi_Par_DR_cRange_532', 'quasi_beta_cRange_355', 'quasi_beta_cRange_532', 'quasi_beta_cRange_1064', 'yLim_Quasi_Params', 'height', 'time', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'imgFormat', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_ift_display_quasiretrieving_V2.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_ift_display_quasiretrieving_V2.py');
    end
    delete(tmpFile);

else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end