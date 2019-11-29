function [] = pollyxt_tau_display_retrieving(data, taskInfo, config)
%pollyxt_tau_display_retrieving display aerosol optical products
%   Example:
%       [] = pollyxt_tau_display_retrieving(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       
%   History:
%       2018-12-30. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

%% initial the channels
flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel355_NR = config.isNR & config.is355nm & config.isTot;
flagChannel532_NR = config.isNR & config.is532nm & config.isTot;

%% data visualization for each cloud free period
for iGroup = 1:size(data.cloudFreeGroups, 1)
    % read data
    smoothWin_355 = config.smoothWin_klett_355;
    smoothWin_532 = config.smoothWin_klett_532;
    smoothWin_1064 = config.smoothWin_klett_1064;
    smoothWin_NR_355 = config.smoothWin_klett_355;
    smoothWin_NR_532 = config.smoothWin_klett_532;

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
    sig355_NR = squeeze(mean(data.signal(flagChannel355_NR, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel355_NR, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs355_NR = sig355_NR .* data.height.^2;
    rcs355_NR = transpose(smooth(rcs355_NR, smoothWin_NR_355));
    sig532_NR = squeeze(mean(data.signal(flagChannel532_NR, :, startIndx:endIndx), 3)) / mean(data.mShots(flagChannel532_NR, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs532_NR = sig532_NR .* data.height.^2;
    rcs532_NR = transpose(smooth(rcs532_NR, smoothWin_NR_532));

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
    aerBsc355_NR_klett = data.aerBsc355_NR_klett(iGroup, :);
    aerBsc532_NR_klett = data.aerBsc532_NR_klett(iGroup, :);
    aerBsc355_NR_raman = data.aerBsc355_NR_raman(iGroup, :);
    aerBsc532_NR_raman = data.aerBsc532_NR_raman(iGroup, :);

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
    aerExt355_NR_raman = data.aerExt355_NR_raman(iGroup, :);
    aerExt532_NR_raman = data.aerExt532_NR_raman(iGroup, :);
    aerExt355_NR_klett = data.aerExt355_NR_klett(iGroup, :);
    aerExt532_NR_klett = data.aerExt532_NR_klett(iGroup, :);

    % lidar ratio
    LR355_raman = data.LR355_raman(iGroup, :);
    LR532_raman = data.LR532_raman(iGroup, :);
    LR355_NR_raman = data.LR355_NR_raman(iGroup, :);
    LR532_NR_raman = data.LR532_NR_raman(iGroup, :);

    % angstroem exponent
    ang_bsc_355_532_klett = data.ang_bsc_355_532_klett(iGroup, :);
    ang_bsc_532_1064_klett = data.ang_bsc_532_1064_klett(iGroup, :);
    ang_bsc_355_532_raman = data.ang_bsc_355_532_raman(iGroup, :);
    ang_bsc_532_1064_raman = data.ang_bsc_532_1064_raman(iGroup, :);
    ang_ext_355_532_raman = data.ang_ext_355_532_raman(iGroup, :);
    ang_bsc_355_532_klett_NR = data.ang_bsc_355_532_klett_NR(iGroup, :);
    ang_bsc_355_532_raman_NR = data.ang_bsc_355_532_raman_NR(iGroup, :);
    ang_ext_355_532_raman_NR = data.ang_ext_355_532_raman_NR(iGroup, :);
    
    % depol ratio
    voldepol355_klett = data.voldepol355_klett(iGroup, :);
    voldepol532_klett = data.voldepol532_klett(iGroup, :);
    voldepol355_raman = data.voldepol355_raman(iGroup, :);
    voldepol532_raman = data.voldepol532_raman(iGroup, :);
    pardepol355_klett = data.pardepol355_klett(iGroup, :);
    pardepol532_klett = data.pardepol532_klett(iGroup, :);
    pardepolStd355_klett = data.pardepolStd355_klett(iGroup, :);
    pardepolStd532_klett = data.pardepolStd532_klett(iGroup, :);
    pardepol355_klett((abs(pardepolStd355_klett./pardepol355_klett) >= 0.3) | (pardepol355_klett < 0)) = NaN;
    pardepol532_klett((abs(pardepolStd532_klett./pardepol532_klett) >= 0.3) | (pardepol532_klett < 0)) = NaN;
    pardepol355_raman = data.pardepol355_raman(iGroup, :);
    pardepol532_raman = data.pardepol532_raman(iGroup, :);
    pardepolStd355_raman = data.pardepolStd355_raman(iGroup, :);
    pardepolStd532_raman = data.pardepolStd532_raman(iGroup, :);
    pardepol355_raman(abs((pardepolStd355_raman./pardepol355_raman) >= 0.3) | (pardepol355_raman < 0)) = NaN;
    pardepol532_raman(abs((pardepolStd532_raman./pardepol532_raman) >= 0.3) | (pardepol532_raman < 0)) = NaN;

    % WVMR
    wvmr = data.wvmr(iGroup, :);
    flagWVCalibration = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    flagWVCalibration = flagWVCalibration{1};

    % rh
    rh = data.rh(iGroup, :);
    rh_meteor = data.relh(iGroup, :);
    meteorSource = data.meteorAttri.dataSource{iGroup};

    % meteor data
    temperature = data.temperature(iGroup, :);
    pressure = data.pressure(iGroup, :);

    % display range
    yLim_Profi_Ext = config.yLim_Profi_Ext;
    yLim_Profi_LR = config.yLim_Profi_LR;
    yLim_Profi_DR = config.yLim_Profi_DR;
    yLim_Profi_Bsc = config.yLim_Profi_Bsc;
    yLim_Profi_WV_RH = config.yLim_Profi_WV_RH;
    yLim_FR_RCS = config.yLim_FR_RCS;
    yLim_NR_RCS = config.yLim_NR_RCS;
    xLim_Profi_Bsc = config.xLim_Profi_Bsc
    xLim_Profi_NR_Bsc = config.xLim_Profi_NR_Bsc;
    xLim_Profi_Ext = config.xLim_Profi_Ext;
    xLim_Profi_NR_Ext = config.xLim_Profi_NR_Ext;
    xLim_Profi_WV_RH = config.xLim_Profi_WV_RH;
    xLim_Profi_RCS = config.xLim_Profi_RCS;
    xLim_Profi_LR = config.xLim_Profi_LR;

    if strcmpi(processInfo.visualizationMode, 'matlab')

        % display signal plot
        picFile = fullfile(processInfo.pic_folder, campaignInfo.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));
        
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = semilogx(rcs355 * 1e6, height, 'Color', [0, 128, 255]/255, 'LineWidth', 1, 'DisplayName', 'FR 355 nm'); hold on;
        p2 = semilogx(rcs532 * 6e6, height, 'Color', [128, 255, 0]/255, 'LineWidth', 1, 'DisplayName', 'FR 532 nm'); hold on;
        p3 = semilogx(rcs1064 * 1.2e8, height, 'Color', [255, 96, 96]/255, 'LineWidth', 1, 'DisplayName', 'FR 1064 nm'); hold on;
        p4 = semilogx(molRCS355 * 1e6, height, 'Color', [0, 0, 255]/255, 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 355 nm'); hold on;
        p5 = semilogx(molRCS532 * 6e6, height, 'Color', [0, 179, 0]/255, 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 532 nm'); hold on;
        p6 = semilogx(molRCS1064 * 1.2e8, height, 'Color', [230, 0, 0]/255, 'LineStyle', '--', 'LineWidth', 0.5, 'DisplayName', 'mol 1064 nm'); hold on;

        % highlight reference height
        p7 = semilogx([1], [1], 'Color', 'k', 'LineWidth', 1, 'DisplayName', 'Reference Height');
        if ~ isnan(data.refHIndx355(iGroup, 1))
            refHIndx = data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2);
            refL = semilogx(rcs355(refHIndx) * 1e6, height(refHIndx), 'Color', 'k', 'LineWidth', 1);
        end
        if ~ isnan(data.refHIndx532(iGroup, 1))
            refHIndx = data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2);
            refL = semilogx(rcs532(refHIndx) * 6e6, height(refHIndx), 'Color', 'k', 'LineWidth', 1);
        end
        if ~ isnan(data.refHIndx1064(iGroup, 1))
            refHIndx = data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2);
            refL = semilogx(rcs1064(refHIndx) * 1.2e8, height(refHIndx), 'Color', 'k', 'LineWidth', 1);
        end

        xlim(xLim_Profi_RCS);
        ylim(yLim_FR_RCS);

        xlabel('Range-Corrected Signal [Mm^{-1}sr^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_FR_RCS(1):2500:yLim_FR_RCS(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid()
        l = legend([p1, p2, p3, p4, p5, p6, p7], 'Location', 'NorthEast');
        set(l, 'FontSize', 5);
        
        text(-0.1, -0.07, sprintf('Version: %s', processInfo.programVersion), 'interpreter', 'none', 'units', 'normal', 'fontsize',5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% backscatter klett
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerBsc_355_klett * 1e6, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerBsc_532_klett * 1e6, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;
        p3 = plot(aerBsc_1064_klett * 1e6, height, 'Color', [230, 0, 0]/255, 'LineWidth', 1, 'DisplayName', '1064 nm'); hold on;

        xlim(xLim_Profi_Bsc);
        ylim(yLim_Profi_Bsc);

        xlabel('Backscatter Coefficient [Mm^{-1}*sr^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Bsc(1):2500:yLim_Profi_Bsc(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast', 'FontSize', 6);
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% backscatter raman
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerBsc_355_raman * 1e6, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerBsc_532_raman * 1e6, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;
        p3 = plot(aerBsc_1064_raman * 1e6, height, 'Color', [230, 0, 0]/255, 'LineWidth', 1, 'DisplayName', '1064 nm'); hold on;

        xlim(xLim_Profi_Bsc);
        ylim(yLim_Profi_Bsc);

        xlabel('Backscatter Coefficient [Mm^{-1}*sr^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Bsc(1):2500:yLim_Profi_Bsc(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% backscatter Constrained-AOD
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Bsc_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerBsc_355_aeronet * 1e6, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerBsc_532_aeronet * 1e6, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;
        p3 = plot(aerBsc_1064_aeronet * 1e6, height, 'Color', [230, 0, 0]/255, 'LineWidth', 1, 'DisplayName', '1064 nm'); hold on;

        xlim(xLim_Profi_Bsc);
        ylim(yLim_Profi_Bsc);

        xlabel('Backscatter Coefficient [Mm^{-1}*sr^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Bsc(1):2500:yLim_Profi_Bsc(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% extinction klett
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerExt_355_klett * 1e6, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerExt_532_klett * 1e6, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;
        p3 = plot(aerExt_1064_klett * 1e6, height, 'Color', [230, 0, 0]/255, 'LineWidth', 1, 'DisplayName', '1064 nm'); hold on;

        xlim(xLim_Profi_Ext);
        ylim(yLim_Profi_Ext);

        xlabel('Extinction Coefficient [Mm^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Ext(1):1000:yLim_Profi_Ext(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast', 'FontSize', 6);
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% extinction raman
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerExt_355_raman * 1e6, height, 'Color', 'b', 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerExt_532_raman * 1e6, height, 'Color', 'g', 'LineWidth', 1, 'DisplayName', '532n m'); hold on;

        xlim(xLim_Profi_Ext);
        ylim(yLim_Profi_Ext);

        xlabel('Extinction Coefficient [Mm^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Ext(1):1000:yLim_Profi_Ext(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close();

        %% extinction Constrained-AOD
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Ext_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(aerExt_355_aeronet * 1e6, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355  nm'); hold on;
        p2 = plot(aerExt_532_aeronet * 1e6, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;
        p3 = plot(aerExt_1064_aeronet * 1e6, height, 'Color', [230, 0, 0]/255, 'LineWidth', 1, 'DisplayName', '1064 nm'); hold on;

        xlim(xLim_Profi_Ext);
        ylim(yLim_Profi_Ext);

        xlabel('Extinction Coefficient [Mm^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Ext(1):1000:yLim_Profi_Ext(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast', 'FontSize', 6);
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'AERONET'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% Lidar ratio raman
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_LR_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(LR355_raman, height, 'Color', [0, 0, 255]/255, 'LineWidth', 1, 'DisplayName', '355 nm'); hold on;
        p2 = plot(LR532_raman, height, 'Color', [0, 179, 0]/255, 'LineWidth', 1, 'DisplayName', '532 nm'); hold on;

        xlim(xLim_Profi_LR);
        ylim(yLim_Profi_LR);

        xlabel('Lidar Ratio [sr]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_LR(1):1000:yLim_Profi_LR(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% angstroem exponent klett
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_ANGEXP_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(ang_bsc_355_532_klett, height, 'Color', [255, 128, 0]/255, 'LineWidth', 1, 'DisplayName', 'BSC 355-532'); hold on;
        p2 = plot(ang_bsc_532_1064_klett, height, 'Color', [255, 0, 255]/255, 'LineWidth', 1, 'DisplayName', 'BSC 532-1064'); hold on;

        xlim([-1, 2]);
        ylim(yLim_Profi_Ext);

        xlabel('Angtroem Exponent', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Ext(1):500:yLim_Profi_Ext(2), 'xtick', -1:0.5:2);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% angstroem exponent raman
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_ANGEXP_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(ang_bsc_355_532_raman, height, 'Color', [255, 128, 0]/255, 'LineWidth', 1, 'DisplayName', 'BSC 355-532'); hold on;
        p2 = plot(ang_bsc_532_1064_raman, height, 'Color', [255, 0, 255]/255, 'LineWidth', 1, 'DisplayName', 'BSC 532-1064'); hold on;
        p3 = plot(ang_ext_355_532_raman, height, 'Color', [0, 0, 0]/255, 'LineWidth', 1, 'DisplayName', 'EXT 355-532'); hold on;

        xlim([-1, 2]);
        ylim(yLim_Profi_Ext);

        xlabel('Angtroem Exponent', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_Ext(1):500:yLim_Profi_Ext(2), 'xtick', -1:0.5:2);
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close();

        %% depol ratio klett
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_DepRatio_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(voldepol355_klett, height, 'Color', [36, 146, 255]/255, 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 355}'); hold on;
        p2 = plot(voldepol532_klett, height, 'Color', [128, 255, 0]/255, 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p3 = plot(pardepol355_klett, height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 355}'); hold on;
        p4 = plot(pardepol532_klett, height, 'Color', [0, 128, 64]/255, 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim(yLim_Profi_DR);

        xlabel('Depolarization Ratio', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_DR(1):2500:yLim_Profi_DR(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'klett'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% depol ratio Raman
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_DepRatio_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(voldepol355_raman, height, 'Color', [36, 146, 255]/255, 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 355}'); hold on;
        p2 = plot(voldepol532_raman, height, 'Color', [128, 255, 0]/255, 'LineStyle', '--', 'LineWidth', 1, 'DisplayName', '\delta_{vol, 532}'); hold on;
        p3 = plot(pardepol355_raman, height, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 355}'); hold on;
        p4 = plot(pardepol532_raman, height, 'Color', [0, 128, 64]/255, 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', '\delta_{par, 532}'); hold on;

        xlim([-0.01, 0.4]);
        ylim(yLim_Profi_DR);

        xlabel('Depolarization Ratio', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_DR(1):2500:yLim_Profi_DR(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Method: %s'], processInfo.programVersion, 'raman'), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% WVMR
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_WVMR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(wvmr, height, 'Color', [36, 146, 255]/255, 'LineStyle', '-', 'LineWidth', 1); hold on;

        xlim(xLim_Profi_WV_RH);
        ylim(yLim_Profi_WV_RH);

        xlabel('Water Vapor Mixing Ratio [g*kg^{-1}]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_WV_RH(1):1000:yLim_Profi_WV_RH(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Calibrated?: %s'], processInfo.programVersion, flagWVCalibration), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% RH (meteorological data and lidar)
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_RH.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(rh, height, 'Color', [36, 146, 255]/255, 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', taskInfo.pollyVersion); hold on;
        p2 = plot(rh_meteor, height, 'Color', [255, 0, 128]/255, 'LineStyle', '-', 'LineWidth', 1, 'DisplayName', meteorSource);

        xlim([0, 100]);
        ylim(yLim_Profi_WV_RH);

        xlabel('Relative Humidity [%]', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['%s at %s' char(10) '[Averaged] %s-%s'], taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold', 'FontSize', 6);
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_Profi_WV_RH(1):1000:yLim_Profi_WV_RH(2));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        l = legend([p1, p2], 'Location', 'NorthEast');
        set(l, 'interpreter', 'none');
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'Calibrated?: %s'], processInfo.programVersion, flagWVCalibration), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% meteorological paramters Temperature
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Meteor_T.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        temperature = data.temperature(iGroup, :);

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(temperature, height, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1); hold on;

        xlim([-100, 50]);
        ylim(yLim_FR_RCS);

        xlabel('Temperature (\circC)', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['Meteorological Parameters at %s' char(10) '%s-%s'], campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_FR_RCS(1):2500:yLim_FR_RCS(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'From: %s'], processInfo.programVersion, meteorSource), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close()

        %% meteorological paramters Pressure
        picFile = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'), sprintf('%s_%s_%s_Meteor_P.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM')));

        % visualization
        figure('Position', [0, 0, 500, 800], 'Units', 'Pixels', 'Visible', 'off');
        p1 = plot(pressure, height, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1); hold on;

        xlim([0, 1000]);
        ylim(yLim_FR_RCS);

        xlabel('Pressure (hPa)', 'FontSize', 6);
        ylabel('Height (m)', 'FontSize', 6);
        title(sprintf(['Meteorological Parameters at %s' char(10) '%s-%s'], campaignInfo.location, datestr(data.mTime(startIndx), 'yyyymmdd HH:MM'), datestr(data.mTime(endIndx), 'HH:MM')), 'Interpreter', 'none', 'fontweight', 'bold');
        set(gca, 'Box', 'on', 'TickDir', 'out', 'FontSize', 6);
        set(gca, 'ytick', yLim_FR_RCS(1):2500:yLim_FR_RCS(end));
        set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

        grid();
        
        text(-0.1, -0.07, sprintf(['Version: %s' char(10) 'From: %s'], processInfo.programVersion, meteorSource), 'interpreter', 'none', 'units', 'normal', 'fontsize', 5, 'fontweight', 'bold');

        set(findall(gcf, '-property', 'fontname'), 'fontname', processInfo.fontname);
        export_fig(gcf, picFile, '-transparent', sprintf('-r%d', processInfo.figDPI));
        close();
    
    elseif strcmpi(processInfo.visualizationMode, 'python')
        fprintf('Display the results with Python.\n');
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        
        %% display rcs 
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startIndx', 'endIndx', 'rcs355', 'rcs532', 'rcs1064', 'height', 'time', 'molRCS355', 'molRCS532', 'molRCS1064', 'refHIndx355', 'refHIndx532', 'refHIndx1064', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'aerBsc355_NR_klett', 'aerBsc532_NR_klett', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'aerBsc355_NR_raman', 'aerBsc532_NR_raman', 'aerBsc_355_aeronet', 'aerBsc_532_aeronet', 'aerBsc_1064_aeronet', 'aerExt_355_klett', 'aerExt_532_klett', 'aerExt_1064_klett', 'aerExt355_NR_klett', 'aerExt532_NR_klett', 'aerExt_355_raman', 'aerExt_532_raman', 'aerExt_1064_raman', 'aerExt355_NR_raman', 'aerExt532_NR_raman', 'aerExt_355_aeronet', 'aerExt_532_aeronet', 'aerExt_1064_aeronet', 'LR355_raman', 'LR532_raman', 'LR355_NR_raman', 'LR532_NR_raman', 'ang_bsc_355_532_klett', 'ang_bsc_532_1064_klett', 'ang_bsc_355_532_raman', 'ang_bsc_532_1064_raman', 'ang_ext_355_532_raman', 'ang_bsc_355_532_klett_NR', 'ang_bsc_355_532_raman_NR', 'ang_ext_355_532_raman_NR', 'voldepol355_klett', 'voldepol355_raman', 'voldepol532_klett', 'voldepol532_raman', 'pardepol355_klett', 'pardepol532_klett', 'pardepolStd355_klett', 'pardepolStd532_klett', 'pardepol355_raman', 'pardepol532_raman', 'pardepolStd355_raman', 'pardepolStd532_raman', 'wvmr', 'flagWVCalibration', 'flagWVCalibration', 'rh', 'rh_meteor', 'meteorSource', 'temperature', 'pressure', 'processInfo', 'campaignInfo', 'taskInfo', 'yLim_Profi_Ext', 'yLim_Profi_LR', 'yLim_Profi_DR', 'yLim_Profi_Bsc', 'yLim_Profi_WV_RH', 'yLim_FR_RCS', 'yLim_NR_RCS', 'xLim_Profi_Bsc', 'xLim_Profi_NR_Bsc', 'xLim_Profi_Ext', 'xLim_Profi_NR_Ext', 'xLim_Profi_WV_RH', 'xLim_Profi_RCS', 'xLim_Profi_LR', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_tau_display_retrieving.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyxt_tau_display_retrieving.py');
        end
        delete(tmpFile);
    else
        error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
    end

end