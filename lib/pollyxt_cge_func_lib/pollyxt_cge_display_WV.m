    function [] = pollyxt_cge_display_WV(data, taskInfo, config)
%pollyxt_cge_display_WV display the water vapor mixing ratio and relative humidity.
%   Example:
%       [] = pollyxt_cge_display_WV(data, taskInfo, config)
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

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% parameter initialize
    fileWVMR = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_WVMR.png', rmext(taskInfo.dataFilename)));
    fileRH = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_RH.png', rmext(taskInfo.dataFilename)));

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
    title(sprintf('Water vapor mixing ratio from %s at %s', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
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
    ylim([0, 8000]);
    xlabel('UTC');
    ylabel('Height (m)');
    title(sprintf('Relative humidity from %s at %s', campaignInfo.name, campaignInfo.location), 'fontweight', 'bold', 'interpreter', 'none');
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

    set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);

    export_fig(gcf, fileRH, '-transparent', sprintf('-r%d', processInfo.figDPI), '-painters');
    close();

elseif strcmpi(processInfo.visualizationMode, 'python')
    
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    WVMR = data.WVMR;
    RH = data.RH;
    lowSNRMask = (squeeze(data.lowSNRMask(flagChannel387, :, :)) | squeeze(data.lowSNRMask(flagChannel407, :, :)));
    flagCalibrated = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    flagCalibrated = flagCalibrated{1};
    height = data.height;
    time = data.mTime;
    figDPI = processInfo.figDPI;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
       save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'WVMR', 'RH', 'lowSNRMask', 'flagCalibrated', 'meteorSource', 'height', 'time', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', '-v7');
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_cge_display_WV.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_cge_display_WV.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end