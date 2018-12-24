function [depol_cal_fac, depol_cal_fac_std, depol_cal_time] = depol_cali(signal_t, bg_t, signal_x, bg_x, time, depol_cali_pAng_time, depol_cali_nAng_time, TR_t, TR_x, caliHIndxRange, SNRmin, sigMax, rel_std_dplus, rel_std_dminus, segmentLen, smoothWin, folder, wavelength)
    %DEPOL_CALI depolarization calibration for PollyXT lidar system.
    %	Example:
    %		[depol_cal_fac, depol_cal_fac_std, depol_cal_time] = depol_cali(signal_t, bg_t, signal_x, bg_x, time, depol_cali_pAng_time, depol_cali_nAng_time, TR_t, TR_x, caliHIndxRange, SNRmin, sigMax, rel_std_dplus, rel_std_dminus, segmentLen, smoothWin, flagShowResults, folder, wavelength)
    %	Inputs:
    %		signal_t: matrix
    %			background removed photon count signal at total channel. (nBins * nProfiles)
    %		bg_t: matrix
    %			background at total channel. (nBins * nProfiles)
    %		signal_x: matrix
    %			background removed photon count signal at cross channel. (nBins * nProfiles)
    %		bg_x: matrix
    %			background at cross channel. (nBins * nProfiles)
    %		time: array
    %			datenum array states the measurement time of each profile.
    %		depol_cali_pAng_time: array
    %			datenum array states the start time that the polarizer rotates to the positive angle.
    %		depol_cali_nAng_time: array
    %			datenum array states the end time that the polarizer rotates to the negative angle.
    %		TR_t: float
    %			tranmission at total channel.
    %		TR_x: float
    %			transmision at cross channel.
    %		caliHIndxRange: 2-element array
    %			range of height indexes which the signal can be used for depolarization calibration in.
    %		SNRmin: array
    %			minimum SNR that signal should have to assure the stability of the calibration results.
    %		sigMax: array
    %			maximum signal strength that could be used in the calibration in case of pulse pileup effects. (Photon Count)
    %		rel_std_dplus: float
    %			maximum relative std of dplus that is allowed.
    %		rel_std_dplus: float
    %			maximum relative std of dminus that is allowed.
    %		segmentLen: integer
    %			length of the segement to test the variability of the calibration results to filter the effects from cloud layers.
    %		smoothWin: integer
    %			width of the sliding smooth window for smoothing the signal.
    %		flagShowResults: boolean
    %			flag to control whether to save the intermediate results.
    %		folder: char
    %			folder for saving the intermediate results.
    %		wavelength: integer
    %			depolarization calibration wavelength. [nm]
    %	Outputs:
    %		depol_cal_fac: array
    %			depolarization calibration factor.
    %		depol_cal_fac_std
    %			std of depolarization calibration factor.
    %		depol_cal_time
    %			time for each successful calibration.
    %	History:
    %		2018-07-25. First edition by Zhenping.
    %	Contact:
    %		zhenping@tropos.de

    if ~ exist(folder, 'dir')
        fprintf('Create folder to save depolarization calibration results.\n%s\n', folder);
        mkdir(folder);
    end
    
    %% parameters initialization
    depol_cal_fac = [];
    depol_cal_fac_std = [];
    mean_dminus = [];
    mean_dplus = [];
    std_dminus = [];
    std_dplus = [];
    depol_cal_time = [];
    
    if isempty(signal_t) || isempty(signal_x) 
        warning('No data for depolarization calibration.');
        return;
    end
    
    days = unique(fix(time));   % datenum array which stands for different measurement day
    nDays = length(days);
    
    for iDay = 1:nDays
        for iDepolCal = 1:length(depol_cali_nAng_time)
            indx_45p = find(time >= days(iDay) & time < (days(iDay) + 1) & ...
                            rem(time, 1) >= depol_cali_pAng_time(iDepolCal) & ...
                            rem(time, 1) < (depol_cali_pAng_time(iDepolCal) + datenum(0, 0, 0, 0, 5, 0)));
            indx_45m = find(time >= days(iDay) & time < (days(iDay) + 1) & ...
                            rem(time, 1) >= depol_cali_nAng_time(iDepolCal) & ... 
                            rem(time, 1) < (depol_cali_nAng_time(iDepolCal) + datenum(0, 0, 0, 0, 5, 0)));
            if ~ (length(indx_45p) == 10) || ~ (length(indx_45m) == 10)
                continue;
            end
    
            thisCaliTime = time(floor(mean([indx_45m, indx_45p])));
    
            % neglect the first and last profile which could be unstable due to the rotation of the polarizer
            indx_45m = indx_45m(2:end-1);
            indx_45p = indx_45p(2:end-1);
    
            sig_t_p = nanmean(signal_t(:, indx_45p), 2);
            bg_t_p = nanmean(bg_t(:, indx_45p), 2);
            SNR_t_p = polly_SNR(sig_t_p, bg_t_p);
            sig_t_p(SNR_t_p <= SNRmin(1) | sig_t_p >= sigMax(1)) = NaN;
    
            sig_t_m = nanmean(signal_t(:, indx_45m), 2);
            bg_t_m = nanmean(bg_t(:, indx_45m), 2);
            SNR_t_m = polly_SNR(sig_t_m, bg_t_m);
            sig_t_m(SNR_t_m <= SNRmin(2) | sig_t_m >= sigMax(2)) = NaN;
    
            sig_x_p = nanmean(signal_x(:, indx_45p), 2);
            bg_x_p = nanmean(bg_x(:, indx_45p), 2);
            SNR_x_p = polly_SNR(sig_x_p, bg_x_p);
            sig_x_p(SNR_x_p <= SNRmin(3) | sig_x_p >= sigMax(3)) = NaN;
    
            sig_x_m = nanmean(signal_x(:, indx_45m), 2);
            bg_x_m = nanmean(bg_x(:, indx_45m), 2);
            SNR_x_m = polly_SNR(sig_x_m, bg_x_m);
            sig_x_m(SNR_x_m <= SNRmin(4) | sig_x_m >= sigMax(4)) = NaN;
    
            dplus = smooth(sig_x_p(caliHIndxRange(1):caliHIndxRange(2))./ sig_t_p(caliHIndxRange(1):caliHIndxRange(2)), 'moving', smoothWin);
            dminus = smooth(sig_x_m(caliHIndxRange(1):caliHIndxRange(2)) ./ sig_t_m(caliHIndxRange(1):caliHIndxRange(2)), 'moving', smoothWin);
            dplus(isinf(dplus)) = NaN;
            dminus(isinf(dminus)) = NaN;
    
            mean_dplus_tmp = [];
            std_dplus_tmp = [];
            mean_dminus_tmp = [];
            std_dminus_tmp = [];
            segIndx_tmp = [];
            % find the most stable region where the realtive std of the signal
            % is less than rel_std_dminus and rel_std_dplus
            for iReg = 1:(caliHIndxRange(2) - caliHIndxRange(1) - segmentLen)
    
                if length(find(~isnan(dplus(iReg:(iReg + segmentLen))))) <= segmentLen/4 || length(find(~isnan(dminus(iReg:(iReg + segmentLen))))) <= segmentLen/4
                    continue;
                end
                
                this_mean_dplus = nanmean(dplus(iReg:(iReg + segmentLen)));
                this_std_dplus = nanstd(dplus(iReg:(iReg + segmentLen)));
                this_mean_dminus = nanmean(dminus(iReg:(iReg + segmentLen)));
                this_std_dminus = nanstd(dminus(iReg:(iReg + segmentLen)));
    
                if abs(this_std_dminus / this_mean_dminus) <= rel_std_dminus && abs(this_std_dplus / this_mean_dplus) <= rel_std_dplus
                    segIndx_tmp = [segIndx_tmp, iReg];
                    mean_dplus_tmp = [mean_dplus_tmp, this_mean_dplus];
                    mean_dminus_tmp = [mean_dminus_tmp, this_mean_dminus];
                    std_dplus_tmp = [std_dplus_tmp, this_std_dplus];
                    std_dminus_tmp = [std_dminus_tmp, this_std_dminus];
                end	
            end
    
            % if there is no stable calibration segment, start the next 
            % calibration 
            if isempty(mean_dplus_tmp)
                continue;
            end
            
            % find the most stable calbiration region
            [~, segIndx] = min(sqrt((std_dplus_tmp./mean_dplus_tmp).^2 + (std_dminus_tmp./mean_dminus_tmp).^2));
            indx = segIndx_tmp(segIndx);
            depol_cal_time = [depol_cal_time, thisCaliTime];
            mean_dplus = [mean_dplus, mean_dplus_tmp(segIndx)];
            std_dplus = [std_dplus, std_dplus_tmp(segIndx)];
            mean_dminus = [mean_dminus, mean_dminus_tmp(segIndx)];
            std_dminus = [std_dminus, std_dminus_tmp(segIndx)];
    
            % visualize calibration process
            if flagShowResults
                figure('position', [0, 0, 600, 600], 'Units', 'Pixels', 'visible', 'off');
    
                subplot(121);
                p1 = semilogx(sig_t_p, 1:length(sig_t_p), '-b', 'LineWidth', 1, 'DisplayName', 'Sig_{el, +45\circ}'); hold on;
                p2 = semilogx(sig_t_m, 1:length(sig_t_m), '--b', 'LineWidth', 1, 'DisplayName', 'Sig_{el, -45\circ}');
                p3 = semilogx(sig_x_p, 1:length(sig_x_p), '-r', 'LineWidth', 1, 'DisplayName', 'Sig_{x, +45\circ}'); 
                p4 = semilogx(sig_x_m, 1:length(sig_x_m), '--r', 'LineWidth', 1, 'DisplayName', 'Sig_{x, -45\circ}');
                ylim(caliHIndxRange);
                ylabel('index');
                xlabel('Signal (.a.u)');
                title(sprintf('%s - %s', datestr(time(indx_45p(1) - 1), 'yyyymmdd HH:MM'), datestr(time(indx_45m(end) + 1), 'HH:MM')));
                grid();
                l1 = legend([p1, p2, p3, p4], 'Location', 'NorthEast');
    
                subplot(122);
                p1 = plot(dplus, caliHIndxRange(1):caliHIndxRange(2), '-b', 'LineWidth', 1, 'DisplayName', 'Ratio_{+45\circ}'); hold on;
                p2 = plot(dminus, caliHIndxRange(1):caliHIndxRange(2), '-r', 'LineWidth', 1, 'DisplayName', 'Ratio_{-45\circ}'); hold on;
                l1 = plot([0, 1e10], [indx + caliHIndxRange(1) - 1, indx + caliHIndxRange(1) - 1], '--k');
                l2 = plot([0, 1e10], [indx + segmentLen + caliHIndxRange(1) - 1, indx + segmentLen + caliHIndxRange(1) - 1], '--k');
                ylim(caliHIndxRange);
                xlim([0.1*min([dplus; dminus]), 3*max([dplus; dminus])]);
                xlabel('Ratio');
                text(0.2, 0.8, sprintf('mean_{dplus}=%6.2f, std_{dplus}=%5.2f\nmean_{dminus}=%6.2f, std_{dminus}=%5.2f\nK=%6.4f, delta_K=%8.6f', ...
                     mean_dplus_tmp(segIndx), std_dplus_tmp(segIndx), mean_dminus_tmp(segIndx), ...
                     std_dminus_tmp(segIndx), (1 + TR_t) ./ (1 + TR_x) .* sqrt(mean_dplus_tmp(segIndx) .* mean_dminus_tmp(segIndx)), ...
                     (1 + TR_t) ./ (1 + TR_x) ./ sqrt(mean_dplus_tmp(segIndx) .* mean_dminus_tmp(segIndx)) .* 0.5 .* (mean_dplus_tmp(segIndx) .* std_dminus_tmp(segIndx) + mean_dminus_tmp(segIndx) .* std_dplus_tmp(segIndx))), ...
                     'Units', 'Normalized', 'fontsize', 8);
                grid();
                l2 = legend([p1, p2], 'Location', 'NorthEast');
    
                saveas(gcf, fullfile(folder, sprintf('%s_%3d.png', datestr(thisCaliTime, 'yyyymmdd-HHMM'), wavelength)));
                close;

                %% saving calibration results
    
            end
        end
    end
    
    % calculate the depol-calibration factor and std
    depol_cal_fac = nanmean((1 + TR_t) ./ (1 + TR_x) .* sqrt(mean_dplus .* mean_dminus), 1);
    depol_cal_fac_std = nanmean(sqrt(((1 + TR_t) ./ (1 + TR_x) ./ sqrt(mean_dplus .* mean_dminus) .* 0.5 .* (mean_dplus .* std_dminus + mean_dminus .* std_dplus)).^2), 1);
    
end
    