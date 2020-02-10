function [] = pollyxt_tau_display_WV(data, taskInfo, config)
%pollyxt_tau_display_WV display the water vapor mixing ratio and relative humidity.
%   Example:
%       [] = pollyxt_tau_display_WV(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo campaignInfo

flagChannel407 = config.is407nm & config.isFR;
flagChannel387 = config.is387nm & config.isFR;

%% read data
WVMR = data.WVMR;
RH = data.RH;
lowSNRMask = (squeeze(data.lowSNRMask(flagChannel387, :, :)) | squeeze(data.lowSNRMask(flagChannel407, :, :)));
flagCalibrated = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
flagCalibrated = flagCalibrated{1};
height = data.height;
time = data.mTime;
yLim_WV_RH = config.yLim_WV_RH;
figDPI = processInfo.figDPI;
xLim_Profi_WV_RH = config.xLim_Profi_WV_RH;
meteorSource = data.quasiAttri.meteorSource;
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    fileWVMR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_WVMR.png', rmext(taskInfo.dataFilename)));
    fileRH = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RH.png', rmext(taskInfo.dataFilename)));

    %% visualization
    load('myjet_colormap.mat');

    % WVMR
    figure('Units', 'Pixels', 'Position', [0, 0, 800, 400], 'Visible', 'off');

    subplot('Position', [0.1, 0.15, 0.8, 0.75]);   % mainframe

    WVMR = data.WVMR;
    WVMR(squeeze(data.lowSNRMask(flagChannel387, :, :) | data.lowSNRMask(flagChannel407, :, :))) = NaN;
    p1 = pcolor(data.mTime, data.height, WVMR); hold on;
    set(p1, 'EdgeColor', 'none');
    caxis(xLim_Profi_WV_RH);
    xlim([data.mTime(1), data.mTime(end)]);
    ylim(yLim_WV_RH);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Water vapor mixing ratio from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none', 'FontSize', 6);
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(yLim_WV_RH(1), yLim_WV_RH(2), 6), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s\nMeteor Data: %s',  datestr(data.mTime(1), 'yyyy-mm-dd'), meteorSource), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version: %s\nCalibration: %s', processInfo.programVersion, flagCalibrated), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', 'g*kg^{-1}', 'FontSize', 5);

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileWVMR, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
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
    ylim(yLim_WV_RH);
    xlabel('UTC', 'FontSize', 6);
    ylabel('Height (m)', 'FontSize', 6);
    title(sprintf('Relative humidity from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', linspace(xLim_Profi_WV_RH(1), xLim_Profi_WV_RH(2), 6), 'yminortick', 'on', 'FontSize', 5);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr);
    text(-0.04, -0.13, sprintf('%s\nMeteor Source: %s', datestr(data.mTime(1), 'yyyy-mm-dd'), meteorSource), 'Units', 'Normal', 'FontSize', 6);
    text(0.90, -0.13, sprintf('Version: %s\nCalibration: %s', processInfo.programVersion, flagCalibrated), 'Units', 'Normal', 'FontSize', 6);

    % colorbar
    c = colorbar('Position', [0.92, 0.15, 0.02, 0.75]);
    set(gca, 'TickDir', 'out', 'Box', 'on');
    titleHandle = get(c, 'Title');
    set(titleHandle, 'string', '[%]', 'FontSize', 5);

    colormap(myjet);

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRH, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
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
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'WVMR', 'RH', 'lowSNRMask', 'flagCalibrated', 'meteorSource', 'height', 'time', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'xLim_Profi_WV_RH', 'yLim_WV_RH', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_tau_display_WV.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_tau_display_WV.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end