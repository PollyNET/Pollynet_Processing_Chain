function pollyxt_dwd_display_retrieving(data, taskInfo, config)
%POLLYXT_DWD_DISPLAY_RETRIEVING display aerosol optical products
%Example:
%   pollyxt_dwd_display_retrieving(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%Outputs:
%   
%History:
%   2018-12-30. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo defaults campaignInfo

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
imgFormat = config.imgFormat;

if strcmpi(processInfo.visualizationMode, 'matlab')
    %% signal
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);
        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid()
        l = legend([p1, p2, p3, p4, p5, p6, p7], 'Location', 'NorthEast');
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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% backscatter Constrained-AOD
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% extinction klett
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% extinction Constrained-AOD
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% Lidar ratio raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_LR_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:500:5000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% angstroem exponent klett
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_ANGEXP_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:500:5000, 'xtick', -1:0.5:2);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()
        
    end

    %% angstroem exponent raman
    for iGroup = 1:size(data.cloudFreeGroups, 1)
        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);

        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_ANGEXP_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

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
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:500:5000, 'xtick', -1:0.5:2);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 7, 'fontweight', 'bold');

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
        p1 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p2 = plot(pardepol532_klett, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim([0, 15000]);

        xlabel('Depolarization Ratio');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
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
        p1 = plot(voldepol532, data.height, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p2 = plot(pardepol532_raman, data.height, 'Color', 'g', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim([0, 15000]);

        xlabel('Depolarization Ratio');
        ylabel('Height (m)');
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], campaignInfo.name, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out');
        set(gca, 'ytick', 0:2500:15000);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
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

        if isfield('config', 'smoothWin_klett_355')
            smoothWin_355 = config.smoothWin_355;
        else
            smoothWin_355 = 20;
        end
        if isfield('config', 'smoothWin_klett_532')
            smoothWin_532 = config.smoothWin_532;
        else
            smoothWin_532 = 20;
        end
        if isfield('config', 'smoothWin_klett_1064')
            smoothWin_1064 = config.smoothWin_1064;
        else
            smoothWin_1064 = 20;
        end

        startIndx = data.cloudFreeGroups(iGroup, 1);
        endIndx = data.cloudFreeGroups(iGroup, 2);
        sig355 = squeeze(mean(data.signal(flagChannel355, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel355, startIndx:endIndx), 2) * 150 / data.hRes;
        rcs355 = sig355 .* data.height.^2;
        rcs355 = transpose(smooth(rcs355, smoothWin_355));
        sig532 = squeeze(mean(data.signal(flagChannel532, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
        rcs532 = sig532 .* data.height.^2;
        rcs532 = transpose(smooth(rcs532, smoothWin_532));
        sig1064 = squeeze(mean(data.signal(flagChannel1064, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) * 150 / data.hRes;
        rcs1064 = sig1064 .* data.height.^2;
        rcs1064 = transpose(smooth(rcs1064, smoothWin_1064));

        height = data.height;
        time = data.mTime;
        figDPI = processInfo.figDPI;

        % molecule signal
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        molRCS355 = molBsc355 .* exp(- 2 * cumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]));
        molRCS532 = molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));
        molRCS1064 = molBsc1064 .* exp(- 2 * cumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]));  

        % normalize the range-corrected signal to molecular signal
        if ~ isnan(data.refHIndx355(iGroup, 1))
            % according to the ratio at the reference height
            factor_355 = sum(molRCS355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2))) / sum(rcs355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
            rcs355 = rcs355 * factor_355;
        else 
            % if no reference height was found, using the lidar constants
            rcs355 = rcs355 / data.LCUsed.LCUsed355 * mean(data.mShots(flagChannel355, startIndx:endIndx), 2) / 150 * data.hRes;
        end
        if ~ isnan(data.refHIndx532(iGroup, 1))
            % according to the ratio at the reference height
            factor_532 = sum(molRCS532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2))) / sum(rcs532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
            rcs532 = rcs532 * factor_532;
        else 
            % if no reference height was found, using the lidar constants
            rcs532 = rcs532 / data.LCUsed.LCUsed532 * mean(data.mShots(flagChannel532, startIndx:endIndx), 2) / 150 * data.hRes;
        end
        if ~ isnan(data.refHIndx1064(iGroup, 1))
            % according to the ratio at the reference height
            factor_1064 = sum(molRCS1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2))) / sum(rcs1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
            rcs1064 = rcs1064 * factor_1064;
        else 
            % if no reference height was found, using the lidar constants
            rcs1064 = rcs1064 / data.LCUsed.LCUsed1064 * mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) / 150 * data.hRes;
        end
        
        % reference height
        refHIndx355 = [data.refHIndx355(iGroup, 1), data.refHIndx355(iGroup, 2)];
        refHIndx532 = [data.refHIndx532(iGroup, 1), data.refHIndx532(iGroup, 2)];
        refHIndx1064 = [data.refHIndx1064(iGroup, 1), data.refHIndx1064(iGroup, 2)];

        % backscatter
        aerBsc_355_klett = data.aerBsc355_klett(iGroup, :);
        aerBsc_532_klett = data.aerBsc532_klett(iGroup, :);
        aerBsc_1064_klett = data.aerBsc1064_klett(iGroup, :);
        aerBsc_355_raman = data.aerBsc355_raman(iGroup, :);
        aerBsc_532_raman = data.aerBsc532_raman(iGroup, :);
        aerBsc_1064_raman = data.aerBsc1064_raman(iGroup, :);
        aerBsc_355_aeronet = data.aerBsc355_aeronet(iGroup, :);
        aerBsc_532_aeronet = data.aerBsc532_aeronet(iGroup, :);
        aerBsc_1064_aeronet = data.aerBsc1064_aeronet(iGroup, :);

        % extinction
        aerExt_355_klett = data.aerExt355_klett(iGroup, :);
        aerExt_532_klett = data.aerExt532_klett(iGroup, :);
        aerExt_1064_klett = data.aerExt1064_klett(iGroup, :);
        aerExt_355_raman = data.aerExt355_raman(iGroup, :);
        aerExt_532_raman = data.aerExt532_raman(iGroup, :);
        aerExt_1064_raman = data.aerExt1064_raman(iGroup, :);
        aerExt_355_aeronet = data.aerExt355_aeronet(iGroup, :);
        aerExt_532_aeronet = data.aerExt532_aeronet(iGroup, :);
        aerExt_1064_aeronet = data.aerExt1064_aeronet(iGroup, :);

        % lidar ratio
        LR355_raman = data.LR355_raman(iGroup, :);
        LR532_raman = data.LR532_raman(iGroup, :);

        % angstroem exponent
        ang_bsc_355_532_klett = data.ang_bsc_355_532_klett(iGroup, :);
        ang_bsc_532_1064_klett = data.ang_bsc_532_1064_klett(iGroup, :);
        ang_bsc_355_532_raman = data.ang_bsc_355_532_raman(iGroup, :);
        ang_bsc_532_1064_raman = data.ang_bsc_532_1064_raman(iGroup, :);
        ang_ext_355_532_raman = data.ang_ext_355_532_raman(iGroup, :);
        
        % depol ratio
        voldepol532_klett = data.voldepol532_klett(iGroup, :);
        voldepol532_raman = data.voldepol532_raman(iGroup, :);
        pardepol532_klett = data.pardepol532_klett(iGroup, :);
        pardepolStd532_klett = data.pardepolStd532_klett(iGroup, :);
        flag_pardepol532_klett = (abs(pardepolStd532_klett ./ pardepol532_klett) > 0.6) | ...
                                 (pardepolStd532_klett > 0.5) | ...
                                 (voldepol532_klett < data.moldepol532(iGroup)) | ...
                                 (pardepol532_klett <= 0);
        pardepol532_klett(flag_pardepol532_klett) = NaN;
        pardepol532_raman = data.pardepol532_raman(iGroup, :);
        pardepolStd532_raman = data.pardepolStd532_raman(iGroup, :);
        flag_pardepol532_raman = (abs(pardepolStd532_raman ./ pardepol532_raman) > 0.6) | ...
                                 (pardepolStd532_raman > 0.5) | ...
                                 (voldepol532_raman < data.moldepol532(iGroup)) | ...
                                 (pardepol532_raman <= 0);
        pardepol532_raman(flag_pardepol532_raman) = NaN;

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
        xLim_Profi_Bsc = config.xLim_Profi_Bsc;
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
        save(tmpFile, 'figDPI', 'startIndx', 'endIndx', 'rcs355', 'rcs532', 'rcs1064', 'height', 'time', 'molRCS355', 'molRCS532', 'molRCS1064', 'refHIndx355', 'refHIndx532', 'refHIndx1064', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'aerBsc_355_aeronet', 'aerBsc_532_aeronet', 'aerBsc_1064_aeronet', 'aerExt_355_klett', 'aerExt_532_klett', 'aerExt_1064_klett', 'aerExt_355_raman', 'aerExt_532_raman', 'aerExt_1064_raman', 'aerExt_355_aeronet', 'aerExt_532_aeronet', 'aerExt_1064_aeronet', 'LR355_raman', 'LR532_raman', 'ang_bsc_355_532_klett', 'ang_bsc_532_1064_klett', 'ang_bsc_355_532_raman', 'ang_bsc_532_1064_raman', 'ang_ext_355_532_raman', 'voldepol532_klett', 'voldepol532_raman', 'pardepol532_klett', 'pardepolStd532_klett', 'pardepol532_raman', 'pardepolStd532_raman', 'meteorSource', 'temperature', 'pressure', 'processInfo', 'campaignInfo', 'taskInfo', 'yLim_Profi_Ext', 'yLim_Profi_LR', 'yLim_Profi_DR', 'yLim_Profi_Bsc', 'yLim_FR_RCS', 'yLim_NR_RCS', 'xLim_Profi_Bsc', 'xLim_Profi_NR_Bsc', 'xLim_Profi_Ext', 'xLim_Profi_NR_Ext', 'xLim_Profi_RCS', 'xLim_Profi_LR', 'imgFormat', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_dwd_display_retrieving.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyxt_dwd_display_retrieving.py');
        end
        delete(tmpFile);
    end
else
    error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
end

end