function [] = pollyxt_uw_display_retrieving(data, taskInfo, config)
%pollyxt_uw_display_retrieving display aerosol optical products
%   Example:
%       [] = pollyxt_uw_display_retrieving(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

%% signal
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);
    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    sig355 = squeeze(mean(data.signal(flagChannel355, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel355, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs355 = sig355 .* data.height.^2;
    rcs355(rcs355 <= 0) = NaN;
    sig532 = squeeze(mean(data.signal(flagChannel532, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs532 = sig532 .* data.height.^2;
    rcs532(rcs532 <= 0) = NaN;
    sig1064 = squeeze(mean(data.signal(flagChannel1064, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs1064 = sig1064 .* data.height.^2;
    rcs1064(rcs1064 <= 0) = NaN;

    % molecule signal
    [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    molRCS355 = data.LCUsed.LCUsed355 * molBsc355 .* exp(- 2 * cumsum(molExt355 .* [data.distance0(1), diff(data.distance0)])) / mean(data.mShots(flagChannel355, startIndx:endIndx), 2) * 150 / data.hRes;
    molRCS532 = data.LCUsed.LCUsed532 * molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)])) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
    molRCS1064 = data.LCUsed.LCUsed1064 * molBsc1064 .* exp(- 2 * cumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)])) / mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) * 150 / data.hRes;

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = semilogx(rcs355 / 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', 'FR 355nm'); hold on;
    p2 = semilogx(rcs532 / 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'FR 532nm'); hold on;
    p3 = semilogx(rcs1064 / 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', 'FR 1064nm'); hold on;
    p4 = semilogx(molRCS355 / 1e6, data.height, 'Color', 'b', 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 355nm'); hold on;
    p5 = semilogx(molRCS532 / 1e6, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 532nm'); hold on;
    p6 = semilogx(molRCS1064 / 1e6, data.height, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 1064nm'); hold on;

    % highlight reference height
    p7 = semilogx([1], [1], 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Reference Height');
    if ~ isnan(data.refHIndx355(iGroup, 1))
        refHIndx = data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2);
        refL = semilogx(rcs355(refHIndx) / 1e6, data.height(refHIndx), 'Color', 'k', 'LineWidth', 1);
    end
    if ~ isnan(data.refHIndx532(iGroup, 1))
        refHIndx = data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2);
        refL = semilogx(rcs532(refHIndx) / 1e6, data.height(refHIndx), 'Color', 'k', 'LineWidth', 1);
    end
    if ~ isnan(data.refHIndx1064(iGroup, 1))
        refHIndx = data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2);
        refL = semilogx(rcs1064(refHIndx) / 1e6, data.height(refHIndx), 'Color', 'k', 'LineWidth', 1);
    end

    xlim(config.RCSProfileRange);
    ylim([0, 15000]);

    xlabel('Range-Corrected Signal [MHz*m^2 (10^6)]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid()
    l = legend([p1, p2, p3, p4, p5, p6, p7], 'Location', 'NorthEast');
    set(l, 'FontSize', 8);
    
    text(-0.1, -0.07, sprintf(['Version %s'], processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% backscatter klett
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerBsc355_klett = data.aerBsc355_klett(iGroup, :);
    aerBsc532_klett = data.aerBsc532_klett(iGroup, :);
    aerBsc1064_klett = data.aerBsc1064_klett(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerBsc355_klett * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerBsc532_klett * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;
    p3 = plot(aerBsc1064_klett * 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', '1064nm'); hold on;

    xlim(config.aerBscProfileRange);
    ylim([0, 15000]);

    xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% backscatter raman
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerBsc355_raman = data.aerBsc355_raman(iGroup, :);
    aerBsc532_raman = data.aerBsc532_raman(iGroup, :);
    aerBsc1064_raman = data.aerBsc1064_raman(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerBsc355_raman * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerBsc532_raman * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;
    p3 = plot(aerBsc1064_raman * 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', '1064nm'); hold on;

    xlim(config.aerBscProfileRange);
    ylim([0, 15000]);

    xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% backscatter Constrained-AOD
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerBsc355_aeronet = data.aerBsc355_aeronet(iGroup, :);
    aerBsc532_aeronet = data.aerBsc532_aeronet(iGroup, :);
    aerBsc1064_aeronet = data.aerBsc1064_aeronet(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerBsc355_aeronet * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerBsc532_aeronet * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;
    p3 = plot(aerBsc1064_aeronet * 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', '1064nm'); hold on;

    xlim(config.aerBscProfileRange);
    ylim([0, 15000]);

    xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% extinction klett
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerExt355_klett = data.aerExt355_klett(iGroup, :);
    aerExt532_klett = data.aerExt532_klett(iGroup, :);
    aerExt1064_klett = data.aerExt1064_klett(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerExt355_klett * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerExt532_klett * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;
    p3 = plot(aerExt1064_klett * 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', '1064nm'); hold on;

    xlim(config.aerExtProfileRange);
    ylim([0, 15000]);

    xlabel('Extinction Coefficient [Mm^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% extinction raman
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerExt355_raman = data.aerExt355_raman(iGroup, :);
    aerExt532_raman = data.aerExt532_raman(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerExt355_raman * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerExt532_raman * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

    xlim(config.aerExtProfileRange);
    ylim([0, 15000]);

    xlabel('Extinction Coefficient [Mm^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% extinction Constrained-AOD
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    aerExt355_aeronet = data.aerExt355_aeronet(iGroup, :);
    aerExt532_aeronet = data.aerExt532_aeronet(iGroup, :);
    aerExt1064_aeronet = data.aerExt1064_aeronet(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(aerExt355_aeronet * 1e6, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(aerExt532_aeronet * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;
    p3 = plot(aerExt1064_aeronet * 1e6, data.height, 'Color', 'r', 'LineWidth', 1, 'DisplayName', '1064nm'); hold on;

    xlim(config.aerExtProfileRange);
    ylim([0, 15000]);

    xlabel('Extinction Coefficient [Mm^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% Lidar ratio raman
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_LR_raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    LR355_raman = data.LR355_raman(iGroup, :);
    LR532_raman = data.LR532_raman(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(LR355_raman, data.height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355nm'); hold on;
    p2 = plot(LR532_raman, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

    xlim(config.aerLRProfileRange);
    ylim([0, 5000]);

    xlabel('Lidar Ratio [Sr]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:500:5000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% angstroem exponent klett
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_ANGEXP_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    ang_bsc_355_532_klett = data.ang_bsc_355_532_klett(iGroup, :);
    ang_bsc_532_1064_klett = data.ang_bsc_532_1064_klett(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(ang_bsc_355_532_klett, data.height, 'Color', [255, 128, 0]/255, 'LineWidth', 1, 'DisplayName', 'BSC-355-532'); hold on;
    p2 = plot(ang_bsc_532_1064_klett, data.height, 'Color', [255, 0, 255]/255, 'LineWidth', 1, 'DisplayName', 'BSC-532-1064'); hold on;

    xlim([-1, 2]);
    ylim([0, 5000]);

    xlabel('Angtroem Exponent');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:500:5000, 'xtick', -1:0.5:2);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% angstroem exponent raman
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_ANGEXP_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    ang_bsc_355_532_raman = data.ang_bsc_355_532_raman(iGroup, :);
    ang_bsc_532_1064_raman = data.ang_bsc_532_1064_raman(iGroup, :);
    ang_ext_355_532_raman = data.ang_ext_355_532_raman(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(ang_bsc_355_532_raman, data.height, 'Color', [255, 128, 0]/255, 'LineWidth', 1, 'DisplayName', 'BSC-355-532'); hold on;
    p2 = plot(ang_bsc_532_1064_raman, data.height, 'Color', [255, 0, 255]/255, 'LineWidth', 1, 'DisplayName', 'BSC-532-1064'); hold on;
    p3 = plot(ang_ext_355_532_raman, data.height, 'Color', [0, 0, 0]/255, 'LineWidth', 1, 'DisplayName', 'EXT-355-532'); hold on;

    xlim([-1, 2]);
    ylim([0, 5000]);

    xlabel('Angtroem Exponent');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:500:5000, 'xtick', -1:0.5:2);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% depol ratio klett
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    voldepol355 = data.voldepol355(iGroup, :);
    voldepol532 = data.voldepol532(iGroup, :);
    pardepol355_klett = data.pardepol355_klett(iGroup, :);
    pardepol532_klett = data.pardepol532_klett(iGroup, :);
    pardepolStd355_klett = data.pardepolStd355_klett(iGroup, :);
    pardepolStd532_klett = data.pardepolStd532_klett(iGroup, :);
    pardepol355_klett((abs(pardepolStd355_klett./pardepol355_klett) >= 0.3) | (pardepol355_klett < 0)) = NaN;
    pardepol532_klett((abs(pardepolStd532_klett./pardepol532_klett) >= 0.3) | (pardepol532_klett < 0)) = NaN;

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(voldepol355, data.height, 'Color', 'b', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 355}'); hold on;
    p2 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
    p3 = plot(pardepol355_klett, data.height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 355}'); hold on;
    p4 = plot(pardepol532_klett, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

    xlim([-0.01, 0.4]);
    ylim([0, 15000]);

    xlabel('Depolarization Ratio');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% depol ratio Raman
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    voldepol355 = data.voldepol355(iGroup, :);
    voldepol532 = data.voldepol532(iGroup, :);
    pardepol355_raman = data.pardepol355_raman(iGroup, :);
    pardepol532_raman = data.pardepol532_raman(iGroup, :);
    pardepolStd355_raman = data.pardepolStd355_raman(iGroup, :);
    pardepolStd532_raman = data.pardepolStd532_raman(iGroup, :);
    pardepol355_raman(abs((pardepolStd355_raman./pardepol355_raman) >= 0.3) | (pardepol355_raman < 0)) = NaN;
    pardepol532_raman(abs((pardepolStd532_raman./pardepol532_raman) >= 0.3) | (pardepol532_raman < 0)) = NaN;

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(voldepol355, data.height, 'Color', 'b', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 355}'); hold on;
    p2 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
    p3 = plot(pardepol355_raman, data.height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 355}'); hold on;
    p4 = plot(pardepol532_raman, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

    xlim([-0.01, 0.4]);
    ylim([0, 15000]);

    xlabel('Depolarization Ratio');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% WVMR
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_WVMR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    wvmr = data.wvmr(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(wvmr, data.height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1); hold on;

    xlim(config.WVMRProfileRange);
    ylim([0, 7000]);

    xlabel('Water Vapor Mixing Ratio [g*kg^{-1}]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:1000:7000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    
    flagCalibratedStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Calibrated?: %s'], processInfo.programVersion, flagCalibratedStr{1}), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% RH (meteorological data and lidar)
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_RH.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    rh = data.rh(iGroup, :);
    rh_meteor = data.relh(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(rh, data.height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', taskInfo.pollyVersion); hold on;
    p2 = plot(rh_meteor, data.height, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', data.meteorAttri.dataSource{iGroup});

    xlim([0, 100]);
    ylim([0, 7000]);

    xlabel('Relative Humidity [%]');
    ylabel('Height (m)');
    title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:1000:7000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    l = legend([p1, p2], 'Location', 'NorthEast');
    set(l, 'interpreter', 'none');
    calibratedStr = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Calibrated?: %s'], processInfo.programVersion, calibratedStr{1}), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% meteorological paramters Temperature
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_T.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    temperature = data.temperature(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(temperature, data.height, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1); hold on;

    xlim([-100, 50]);
    ylim([0, 15000]);

    xlabel('Temperature [\circC]');
    ylabel('Height (m)');
    title(sprintf(['Meteorological Parameters at %s' char(10) '%s-%s'], campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'From: %s'], processInfo.programVersion, data.meteorAttri.dataSource{iGroup}), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end

%% meteorological paramters Pressure
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_P.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

    pressure = data.pressure(iGroup, :);

    % visualization
    figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
    p1 = plot(pressure, data.height, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1); hold on;

    xlim([0, 1000]);
    ylim([0, 15000]);

    xlabel('Pressure [hPa]');
    ylabel('Height (m)');
    title(sprintf(['Meteorological Parameters at %s' char(10) '%s-%s'], campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
    set(gca, 'Box', 'on', 'TickDir', 'out');
    set(gca, 'ytick', 0:2500:15000);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

    grid();
    
    text(-0.1, -0.07, sprintf(['Version %s' char(10) 'From: %s'], processInfo.programVersion, data.meteorAttri.dataSource{iGroup}), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

    set(findall(gcf, '-property', 'fontname'), 'fontname', 'Times New Roman');
    export_fig(gcf, picFile, '-transparent', '-r300');
    close()
    
end
end