function [] = pollyxt_lacros_display_monitor(data, taskInfo, config)
%pollyxt_lacros_display_monitor display the values of sensors.
%   Example:
%       [] = pollyxt_lacros_display_monitor(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2019-01-05. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo defaults processInfo

if isempty(data.rawSignal)
    return;
end

% go to different visualization mode
if strcmpi(processInfo.visualizationMode, 'matlab')

    picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_monitor.png', rmext(taskInfo.dataFilename)));

    %% read data
    time = data.monitorStatus.time;
    AD = data.monitorStatus.AD;
    EN = data.monitorStatus.EN;
    HT = data.monitorStatus.HT;
    WT = data.monitorStatus.WT;
    shutter2 = data.monitorStatus.LS;
    counts = data.monitorStatus.counts;
    ExtPyro = data.monitorStatus.ExtPyro;
    Temp1064 = data.monitorStatus.Temp1064;
    Temp1 = data.monitorStatus.Temp1;
    Temp2 = data.monitorStatus.Temp2;
    OutsideT = data.monitorStatus.OutsideT;
    OutsideRH = data.monitorStatus.OutsideRH;
    roof = data.monitorStatus.roof;
    rain = data.monitorStatus.rain;
    shutter = data.monitorStatus.shutter;

    %% data filter
    maskHT = (HT <= 990);
    maskWT = (WT <= 990);
    maskExtPyro = (ExtPyro <= 300) & (ExtPyro >= 0);
    maskTemp1064 = (Temp1064 <= 990) & (Temp1064 >= -100);
    maskTemp1 = (Temp1 <= 990) & (Temp1 >= -40);
    maskTemp2 = (Temp2 <= 990) & (Temp2 >= -40);
    maskOutsideT = (OutsideT <= 990) & (OutsideT >= -40);
    maskOutsideRH = (OutsideRH <= 120) & (OutsideRH >= -10);
    maskRoof = (roof <= 10);
    maskRain = (rain <= 10);
    maskShutter = (shutter <= 10);
    maskShutter2 = (shutter2 <= 10);
    maskAD = (AD <= 990) & (AD >= 0);
    maskEN = (EN <= 990) & (EN >= 0);

    figure('Units', 'Inches', 'Position', [0, 0, 11, 14], 'Visible', 'off');
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');   % tick for x-axis

    % AD or EN
    subplot('Position', [0.07, 0.76, 0.88, 0.14], 'Units', 'normalized');
    if sum(maskAD) ~= 0
        % if AD was valid
        p1 = plot(time(maskAD), AD(maskAD), 'Color', [66, 120, 207]/255);
        ylabel('AD [a.u.]', 'FontSize', 8);
        ylim([100, 250]);
    else
        % if AD was invalid, use EN
        p1 = plot(time(maskEN), EN(maskEN), 'Color', [66, 120, 207]/255);
        ylabel('EN [mJ]', 'FontSize', 8);
    end
    xlim([data.mTime(1), data.mTime(end)]);
    title(sprintf('Housekeeping data from %s at %s', taskInfo.pollyVersion, campaignInfo.location), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 8);
    set(gca, 'xtick', xtick, 'xticklabel', '', 'YMinorTick', 'on', 'FontSize', 8);
    grid();

    % ExtPyro
    subplot('Position', [0.07, 0.61, 0.88, 0.13], 'Units', 'normalized');
    p1 = plot(time(maskExtPyro), ExtPyro(maskExtPyro), 'Color', [128, 0, 255]/255);
    ylabel('ExtPyro [mJ]', 'FontUnits', 'Points', 'FontSize', 8);
    % ylim([0, 40]);
    xlim([data.mTime(1), data.mTime(end)]);
    set(gca, 'xtick', xtick, 'xticklabel', '', 'FontSize', 8);
    set(gca, 'YMinorTick', 'on');
    grid();

    % temperature
    subplot('Position', [0.07, 0.41, 0.88, 0.18], 'Units', 'normalized');
    p1 = plot(time(maskHT), HT(maskHT), 'Color', [128, 128, 255]/255, 'DisplayName', 'Laser Head'); hold on;
    p2 = plot(time(maskTemp1), Temp1(maskTemp1), 'Color', [255, 128, 0]/255, 'DisplayName', 'Temp1'); hold on;
    p3 = plot(time(maskTemp2), Temp2(maskTemp2), 'Color', [0, 128, 0]/255, 'DisplayName', 'Temp2'); hold on;
    p4 = plot(time(maskWT), WT(maskWT), 'Color', [128, 128, 128]/255, 'DisplayName', 'Water T'); hold on;
    p5 = plot(time(maskOutsideT), OutsideT(maskOutsideT), 'Color', [128, 0, 128]/255, 'DisplayName', 'Outside T'); hold on;
    ylabel('Temperature [\circC]', 'FontSize', 8);
    ylim([0, 40]);
    xlim([data.mTime(1), data.mTime(end)]);
    set(gca, 'xtick', xtick, 'xticklabel', '', 'FontSize', 8);
    set(gca, 'YMinorTick', 'on', 'YTick', 0:10:40);
    l = legend([p1, p2, p3, p4, p5], 'Location', 'NorthWest');
    set(l, 'FontSize', 6);
    grid();

    subplot('Position', [0.07, 0.26, 0.88, 0.13], 'Units', 'normalized');
    p1 = plot(time(maskTemp1064), Temp1064(maskTemp1064), 'Color', [255, 0, 0]/255); hold on;
    ylabel('Temp 1064 [\circC]', 'FontSize', 8);
    % ylim([-40, -20]);
    xlim([data.mTime(1), data.mTime(end)]);
    set(gca, 'xtick', xtick, 'xticklabel', '', 'FontSize', 8);
    set(gca, 'YMinorTick', 'on');
    grid();

    subplot('Position', [0.07, 0.15, 0.88, 0.1], 'Units', 'normalized');
    roof(~ maskRoof) = NaN;
    rain(~ maskRain) = NaN;
    shutter(~ maskShutter) = NaN;
    shutter2(~ maskShutter2) = NaN;
    matrixStatus = [transpose(roof); transpose(rain); transpose(shutter2); transpose(shutter)];
    p1 = imagesc(time, [1, 2, 3, 4], matrixStatus); hold on;
    caxis([-0.5, 4.5]);
    l1 = plot([data.mTime(1), data.mTime(end)], [1.5, 1.5], 'Color', 'w', 'LineWidth', 3);
    l2 = plot([data.mTime(1), data.mTime(end)], [2.5, 2.5], 'Color', 'w', 'LineWidth', 3);
    l3 = plot([data.mTime(1), data.mTime(end)], [3.5, 3.5], 'Color', 'w', 'LineWidth', 3);
    xlabel('UTC', 'FontSize', 8);
    xlim([data.mTime(1), data.mTime(end)]);
    text(-0.04, -0.5, sprintf('%s', datestr(data.mTime(1), 'yyyy-mm-dd')), 'Units', 'Normal', 'FontSize', 8);
    text(0.90, -0.5, sprintf('Version %s', processInfo.programVersion), 'Units', 'Normal', 'FontSize', 8);
    set(gca, 'xtick', xtick, 'xticklabel', xtickstr, 'FontSize', 8);
    set(gca, 'ytick', [1, 2, 3, 4], 'yticklabel', {'roof', 'rain', 'SH ext', 'SH'});
    set(gca,'YDir','normal');
    set(gca,'tickdir','out');
    % load corlormap
    colormap(jet(5));
    
    cbar = colorbar('Units', 'Normal', 'Position', [0.96, 0.15, 0.01, 0.1]);
    set(cbar, 'ytick', (4.5 - (-0.5))/5/2 * (1:2:10) + (-0.5), 'yticklabel', {'0', '1', '2', '3', '4'});

    set(findall(gcf, '-Property', 'FontName'), 'FontName', processInfo.fontname);
    export_fig(gcf, picFile, sprintf('-r%d', processInfo.figDPI), '-transparent');
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

    %% display monitor status
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    monitorStatus = data.monitorStatus;
    figDPI = processInfo.figDPI;
    mTime = data.mTime;
    save(fullfile(tmpFolder, 'tmp.mat'), 'figDPI', 'monitorStatus', 'processInfo', 'campaignInfo', 'taskInfo', 'xtick', 'xtickstr', 'mTime', '-v7');
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_lacros_display_monitor.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyxt_lacros_display_monitor.py');
    end
    delete(tmpFile);
    
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end