function [] = polly_1v2_display_retrieving(data, taskInfo, config)
%polly_1v2_display_retrieving display aerosol optical products
%   Example:
%       [] = polly_1v2_display_retrieving(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

flagChannel532 = config.isFR & config.is532nm & config.isTot;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% signal
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);
        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        sig532 = squeeze(mean(data.signal(flagChannel532, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
        rcs532 = sig532 .* data.height.^2;
        rcs532(rcs532 <= 0) = NaN;

        % molecule signal
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        molRCS532 = data.LCUsed.LCUsed532 * molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)])) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = semilogx(rcs532 / 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', 'FR 532nm'); hold on;
        p5 = semilogx(molRCS532 / 1e6, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 532nm'); hold on;

        % highlight reference height
        p7 = semilogx([1], [1], 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Reference Height');
        if ~ isnan(data.refHIndx532(iGroup, 1))
            refHIndx = data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2);
            refL = semilogx(rcs532(refHIndx) / 1e6, data.height(refHIndx), 'Color', 'k', 'LineWidth', 1);
        end

        xlim(config.RCSProfileRange);
        ylim([0, 15000]);

        xlabel('Range-Corrected Signal [MHz*m^2 (10^6)]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid()
        l = legend([p2, p5, p7], 'Location', 'NorthEast');
        set(l, 'FontSize', 8);
        
        text(-0.1, -0.07, sprintf(['Version %s'], processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% backscatter klett
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerBsc532_klett = data.aerBsc532_klett(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerBsc532_klett * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerBscProfileRange);
        ylim([0, 15000]);

        xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% backscatter raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerBsc532_raman = data.aerBsc532_raman(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerBsc532_raman * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerBscProfileRange);
        ylim([0, 15000]);

        xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% backscatter raman with RR signal
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerBsc532_RR = data.aerBsc532_RR(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerBsc532_RR * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerBscProfileRange);
        ylim([0, 15000]);

        xlabel('Backscatter Coefficient [Mm^{-1}*Sr^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'RR'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% extinction klett
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerExt532_klett = data.aerExt532_klett(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerExt532_klett * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerExtProfileRange);
        ylim([0, 15000]);

        xlabel('Extinction Coefficient [Mm^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% extinction raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerExt532_raman = data.aerExt532_raman(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerExt532_raman * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerExtProfileRange);
        ylim([0, 15000]);

        xlabel('Extinction Coefficient [Mm^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% extinction raman with RR signal
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        aerExt532_RR = data.aerExt532_RR(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(aerExt532_RR * 1e6, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerExtProfileRange);
        ylim([0, 15000]);

        xlabel('Extinction Coefficient [Mm^{-1}]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'RR'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% Lidar ratio raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_LR_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        LR532_raman = data.LR532_raman(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(LR532_raman, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerLRProfileRange);
        ylim([0, 5000]);

        xlabel('Lidar Ratio [Sr]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:500:5000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% Lidar ratio raman with RR signal
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_LR_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        LR532_RR = data.LR532_RR(iGroup, :);

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(LR532_RR, data.height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532nm'); hold on;

        xlim(config.aerLRProfileRange);
        ylim([0, 5000]);

        xlabel('Lidar Ratio [Sr]');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:500:5000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'RR'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% depol ratio klett
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_DepRatio_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        voldepol532_klett = data.voldepol532_klett(iGroup, :);
        voldepol532_raman = data.voldepol532_raman(iGroup, :);
        pardepol532_klett = data.pardepol532_klett(iGroup, :);
        pardepolStd532_klett = data.pardepolStd532_klett(iGroup, :);
        pardepol532_klett((abs(pardepolStd532_klett./pardepol532_klett) >= 0.3) | (pardepol532_klett < 0)) = NaN;

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p4 = plot(pardepol532_klett, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim([0, 15000]);

        xlabel('Depolarization Ratio');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2, p4], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% depol ratio Raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_DepRatio_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        voldepol532_klett = data.voldepol532_klett(iGroup, :);
        voldepol532_raman = data.voldepol532_raman(iGroup, :);
        pardepol532_raman = data.pardepol532_raman(iGroup, :);
        pardepolStd532_raman = data.pardepolStd532_raman(iGroup, :);
        pardepol532_raman(abs((pardepolStd532_raman./pardepol532_raman) >= 0.3) | (pardepol532_raman < 0)) = NaN;

        % visualization
        figure('Position', [0, 0, 400, 600], 'Units', 'Pixels', 'Visible', 'off');
        p2 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p4 = plot(pardepol532_raman, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim([0, 15000]);

        xlabel('Depolarization Ratio');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p2, p4], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% meteorological paramters Temperature
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Meteor_T.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% meteorological paramters Pressure
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Meteor_P.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end
   
elseif strcmpi(processInfo.visualizationMode, 'python')
    fprintf('Display the results with Python.\n');
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    for iGroup = 1:size(data.cloudFreeGroups, 1)
        
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        if isfield('config', 'smoothWin_klett_532')
            smoothWin_532 = config.smoothWin_532;
        else
            smoothWin_532 = 20;
        end

        sig532 = squeeze(mean(data.signal(flagChannel532, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
        rcs532 = sig532 .* data.height.^2;
        rcs532 = transpose(smooth(rcs532, smoothWin_532));

        height = data.height;
        time = data.mTime;
        figDPI = processInfo.figDPI;

        % molecule signal
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        molRCS532 = molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));

        % normalize the range-corrected signal to molecular signal
        if ~ isnan(data.refHIndx532(iGroup, 1))
            % according to the ratio at the reference height
            factor_532 = sum(molRCS532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2))) / sum(rcs532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
            rcs532 = rcs532 * factor_532;
        else 
            % if no reference height was found, using the lidar constants
            rcs532 = rcs532 / data.LCUsed.LCUsed532 * mean(data.mShots(flagChannel532, startIndx:endIndx), 2) / 150 * data.hRes;
        end
        
        % reference height
        refHIndx532 = [data.refHIndx532(iGroup, 1), data.refHIndx532(iGroup, 2)];

        % backscatter
        aerBsc_532_klett = data.aerBsc532_klett(iGroup, :);
        aerBsc_532_raman = data.aerBsc532_raman(iGroup, :);
        aerBsc_532_RR = data.aerBsc532_RR(iGroup, :);

        % extinction
        aerExt_532_klett = data.aerExt532_klett(iGroup, :);
        aerExt_532_raman = data.aerExt532_raman(iGroup, :);
        aerExt_532_RR = data.aerExt532_RR(iGroup, :);

        % lidar ratio
        LR532_raman = data.LR532_raman(iGroup, :);
        LR532_RR = data.LR532_RR(iGroup, :);
        
        % depol ratio
        voldepol532_klett = data.voldepol532_klett(iGroup, :);
        voldepol532_raman = data.voldepol532_raman(iGroup, :);
        pardepol532_klett = data.pardepol532_klett(iGroup, :);
        pardepolStd532_klett = data.pardepolStd532_klett(iGroup, :);
        pardepol532_klett((abs(pardepolStd532_klett./pardepol532_klett) >= 1) | (pardepol532_klett < 0) | (pardepolStd532_klett >= 0.4)) = NaN;
        pardepol532_raman = data.pardepol532_raman(iGroup, :);
        pardepolStd532_raman = data.pardepolStd532_raman(iGroup, :);
        pardepol532_raman((abs(pardepolStd532_raman./pardepol532_raman) >= 1) | (pardepol532_raman < 0) | (pardepolStd532_raman >= 0.4)) = NaN;

        % meteor data
        meteorSource = data.meteorAttri.dataSource{iGroup};
        temperature = data.temperature(iGroup, :);
        pressure = data.pressure(iGroup, :);

        % display range
        yLim_Profi_Ext = config.yLim_Profi_Ext;
        yLim_Profi_LR = config.yLim_Profi_LR;
        yLim_Profi_DR = config.yLim_Profi_DR;
        yLim_Profi_Bsc = config.yLim_Profi_Bsc;
        yLim_FR_RCS = config.yLim_FR_RCS;
        yLim_NR_RCS = config.yLim_NR_RCS;
        xLim_Profi_Bsc = config.xLim_Profi_Bsc
        xLim_Profi_NR_Bsc = config.xLim_Profi_NR_Bsc;
        xLim_Profi_Ext = config.xLim_Profi_Ext;
        xLim_Profi_NR_Ext = config.xLim_Profi_NR_Ext;
        xLim_Profi_RCS = config.xLim_Profi_RCS;
        xLim_Profi_LR = config.xLim_Profi_LR;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        
        %% display rcs 
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startIndx', 'endIndx', 'rcs532', 'height', 'time', 'molRCS532', 'refHIndx532', 'aerBsc_532_klett', 'aerBsc_532_raman', 'aerBsc_532_RR', 'aerExt_532_klett', 'aerExt_532_raman', 'aerExt_532_RR', 'LR532_raman', 'LR532_RR', 'voldepol532_klett', 'voldepol532_raman', 'pardepol532_klett', 'pardepolStd532_klett', 'pardepol532_raman', 'pardepolStd532_raman', 'meteorSource', 'temperature', 'pressure', 'processInfo', 'campaignInfo', 'taskInfo', 'yLim_Profi_LR', 'yLim_Profi_DR', 'yLim_Profi_Bsc', 'yLim_FR_RCS', 'yLim_NR_RCS', 'xLim_Profi_Bsc', 'xLim_Profi_NR_Bsc', 'xLim_Profi_Ext', 'xLim_Profi_NR_Ext', 'xLim_Profi_RCS', 'xLim_Profi_LR', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'polly_1v2_display_retrieving.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'polly_1v2_display_retrieving.py');
        end
        delete(tmpFile);
    end
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end