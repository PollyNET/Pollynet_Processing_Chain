function [polCaliFac, polCaliFacStd, polCaliStartTime, polCaliStopTime, globalAttri] = depolCali(signal_t, ...
        bg_t, signal_x, bg_x, time, polCaliPAngStartTime, ...
        polCaliPAngStopTime, polCaliNAngStartTime, ...
        polCaliNAngStopTime, TR_t, TR_x, caliHIndxRange, ...
        SNRmin, sigMax, rel_std_dplus, rel_std_dminus, segmentLen, smoothWin)
% depolCali depolarization calibration for PollyXT lidar system.
% USAGE:
%    [polCaliFac, polCaliFacStd, depol_cal_time] = depolCali(signal_t, 
%        bg_t, signal_x, bg_x, time, polCaliPAngStartTime, 
%        polCaliPAngStopTime, polCaliNAngStartTime, 
%        polCaliNAngStopTime, TR_t, TR_x, caliHIndxRange, 
%        SNRmin, sigMax, rel_std_dplus, rel_std_dminus, 
%        segmentLen, smoothWin, flagShowResults)
% INPUTS:
%    signal_t: matrix
%        background-removed photon count signal at total channel.
%        (nBins * nProfiles)
%    bg_t: matrix
%        background at total channel. (nBins * nProfiles)
%    signal_x: matrix
%        background-removed photon count signal at cross channel.
%        (nBins * nProfiles)
%    bg_x: matrix
%        background at cross channel. (nBins * nProfiles)
%    time: array
%        datenum array represents the measurement time of each profile.
%    polCaliPAngStartTime: array
%        datenum array represents the start time that the polarizer
%        rotates to the positive angle. 
%    polCaliPAngStopTime: array
%        datenum array represents the stop time that the polarizer
%        rotates to the positive angle.
%    polCaliNAngStartTime array
%        datenum array represents the start time that the polarizer
%        rotates to the negative angle.
%    polCaliNAngStopTime: array
%        datenum array represents the end time that the polarizer
%        rotates to the negative angle.
%    TR_t: float
%        tranmission at total channel.
%    TR_x: float
%        transmision at cross channel.
%    caliHIndxRange: 2-element array
%        range of height indexes at which the signal can be used for
%        depolarization calibration.
%    SNRmin: array
%        minimum SNR for calibration.
%    sigMax: array
%        maximum signal that could be used in the calibration to prevent
%        pulse pileup effects. (Photon Count)
%    rel_std_dplus: float
%        maximum relative std of dplus that is allowed.
%    rel_std_dplus: float
%        maximum relative std of dminus that is allowed.
%    segmentLen: integer
%        segement length for testing the variability of the calibration results
%        to prevent of cloud contamintaion.
%    smoothWin: integer
%        width of the sliding window for smoothing the signal.
%    flagShowResults: logical
%        flag to control whether to save the intermediate results.
% OUTPUTS:
%    polCaliFac: array
%        depolarization calibration factor.
%    polCaliFacStd: array
%        std of depolarization calibration factor.
%    polCaliStartTime: array
%        start time for each successful calibration.
%    polCaliStopTime: array
%        stop time for each successful calibration.
%    globalAttri: struct
%        all the information about the depol calibration.
% EXAMPLE:
% HISTORY:
%    2018-07-25: First edition by Zhenping.
%    2019-06-08: If no depol cali, return empty array.
%    2019-09-06: Remove the part to replace the bins of low SNR with NaN, 
%                because it will lead to bias when doing smoothing.
% .. Authors: - zhenping@tropos.de

%% parameters initialization
polCaliFac = [];
polCaliFacStd = [];
mean_dminus = [];
mean_dplus = [];
std_dminus = [];
std_dplus = [];
polCaliStartTime = [];
polCaliStopTime = [];
globalAttri = struct();
globalAttri.sig_t_p = cell(0);
globalAttri.sig_t_m = cell(0);
globalAttri.sig_x_p = cell(0);
globalAttri.sig_x_m = cell(0);
globalAttri.caliHIndxRange = cell(0);
globalAttri.indx_45m = cell(0);
globalAttri.indx_45p = cell(0);
globalAttri.dplus = cell(0);
globalAttri.dminus = cell(0);
globalAttri.segmentLen = cell(0);
globalAttri.indx = cell(0);
globalAttri.mean_dplus_tmp = cell(0);
globalAttri.std_dplus_tmp = cell(0);
globalAttri.mean_dminus_tmp = cell(0);
globalAttri.std_dminus_tmp = cell(0);
globalAttri.TR_t = cell(0);
globalAttri.TR_x = cell(0);
globalAttri.segIndx = cell(0);
globalAttri.caliTime = cell(0);

if isempty(signal_t) || isempty(signal_x) 
    warning('No data for depolarization calibration.');
    return;
end

days = unique(fix(time));
nDays = length(days);

for iDay = 1:nDays
    for iDepolCal = 1:length(polCaliNAngStartTime)
        indx_45p = find(time >= days(iDay) & time < (days(iDay) + 1) & ...
                        time >= polCaliPAngStartTime(iDepolCal) & ...
                        time <= polCaliPAngStopTime(iDepolCal));
        indx_45m = find(time >= days(iDay) & time < (days(iDay) + 1) & ...
                        time >= polCaliNAngStartTime(iDepolCal) & ... 
                        time <= polCaliNAngStopTime(iDepolCal));

        if (length(indx_45p) < 4) || (length(indx_45m) < 4)
            % if not enough depol cali profiles were found, break the loop
            break;
        end

        thisCaliStartTime = min([polCaliPAngStartTime(iDepolCal), ...
                                 polCaliNAngStartTime(iDepolCal)]);
        thisCaliStopTime = max([polCaliPAngStopTime(iDepolCal), ...
                                polCaliNAngStopTime(iDepolCal)]);

        % neglect the first and last profile which could be unstable due to
        % the rotation of the polarizer
        indx_45m = indx_45m(2:end-1);
        indx_45p = indx_45p(2:end-1);

        sig_t_p = nanmean(signal_t(:, indx_45p), 2);
        bg_t_p = nanmean(bg_t(:, indx_45p), 2);
        SNR_t_p = pollySNR(sig_t_p, bg_t_p);
        indxBad_t_p = (SNR_t_p <= SNRmin(1)) | (sig_t_p >= sigMax(1));

        sig_t_m = nanmean(signal_t(:, indx_45m), 2);
        bg_t_m = nanmean(bg_t(:, indx_45m), 2);
        SNR_t_m = pollySNR(sig_t_m, bg_t_m);
        indxBad_t_m = (SNR_t_m <= SNRmin(2)) | (sig_t_m >= sigMax(2));

        sig_x_p = nanmean(signal_x(:, indx_45p), 2);
        bg_x_p = nanmean(bg_x(:, indx_45p), 2);
        SNR_x_p = pollySNR(sig_x_p, bg_x_p);
        indxBad_x_p = (SNR_x_p <= SNRmin(3)) | (sig_x_p >= sigMax(3));

        sig_x_m = nanmean(signal_x(:, indx_45m), 2);
        bg_x_m = nanmean(bg_x(:, indx_45m), 2);
        SNR_x_m = pollySNR(sig_x_m, bg_x_m);
        indxBad_x_m = (SNR_x_m <= SNRmin(4)) | (sig_x_m >= sigMax(4));

        dplus = smooth(sig_x_p, 'moving', smoothWin) ./ ...
                smooth(sig_t_p, 'moving', smoothWin);
        dminus = smooth(sig_x_m, 'moving', smoothWin) ./ ...
                 smooth(sig_t_m, 'moving', smoothWin);
        dplus(isinf(dplus)) = NaN;
        dminus(isinf(dminus)) = NaN;
        dplus(indxBad_t_p | indxBad_x_p) = NaN;
        dminus(indxBad_t_m | indxBad_x_m) = NaN;
        dplus = dplus(caliHIndxRange(1):caliHIndxRange(2));
        dminus = dminus(caliHIndxRange(1):caliHIndxRange(2));

        mean_dplus_tmp = [];
        std_dplus_tmp = [];
        mean_dminus_tmp = [];
        std_dminus_tmp = [];
        segIndx_tmp = [];
        % find the most stable region where the realtive std of the signal
        % is less than rel_std_dminus and rel_std_dplus
        for iReg = 1:(caliHIndxRange(2) - caliHIndxRange(1) - segmentLen)

            if sum(~ isnan(dplus(iReg:(iReg + segmentLen)))) ...
                <= segmentLen/4 || ...
               sum(~ isnan(dminus(iReg:(iReg + segmentLen)))) <= segmentLen/4
                continue;
            end

            this_mean_dplus = nanmean(dplus(iReg:(iReg + segmentLen)));
            this_std_dplus = nanstd(dplus(iReg:(iReg + segmentLen)));
            this_mean_dminus = nanmean(dminus(iReg:(iReg + segmentLen)));
            this_std_dminus = nanstd(dminus(iReg:(iReg + segmentLen)));

            if abs(this_std_dminus / this_mean_dminus) <= rel_std_dminus && ...
               abs(this_std_dplus / this_mean_dplus) <= rel_std_dplus
                segIndx_tmp = cat(2, segIndx_tmp, iReg);
                mean_dplus_tmp = cat(2, mean_dplus_tmp, this_mean_dplus);
                mean_dminus_tmp = cat(2, mean_dminus_tmp, this_mean_dminus);
                std_dplus_tmp = cat(2, std_dplus_tmp, this_std_dplus);
                std_dminus_tmp = cat(2, std_dminus_tmp, this_std_dminus);
            end 
        end

        % if there is no stable calibration segments, start the next 
        % calibration 
        if isempty(mean_dplus_tmp)
            continue;
        end

        % find the most stable calbiration region
        [~, segIndx] = min(sqrt((std_dplus_tmp./mean_dplus_tmp).^2 + ...
                                (std_dminus_tmp./mean_dminus_tmp).^2));
        indx = segIndx_tmp(segIndx);
        polCaliStartTime = cat(2, polCaliStartTime, thisCaliStartTime);
        polCaliStopTime = cat(2, polCaliStopTime, thisCaliStopTime);
        mean_dplus = cat(2, mean_dplus, mean_dplus_tmp(segIndx));
        std_dplus = cat(2, std_dplus, std_dplus_tmp(segIndx));
        mean_dminus = cat(2, mean_dminus, mean_dminus_tmp(segIndx));
        std_dminus = cat(2, std_dminus, std_dminus_tmp(segIndx));

        % save the intermediate results
        globalAttri.sig_t_p{end + 1} = sig_t_p;
        globalAttri.sig_t_m{end + 1} = sig_t_m;
        globalAttri.sig_x_p{end + 1} = sig_x_p;
        globalAttri.sig_x_m{end + 1} = sig_x_m;
        globalAttri.caliHIndxRange{end + 1} = caliHIndxRange;
        globalAttri.indx_45m{end + 1} = indx_45m;
        globalAttri.indx_45p{end + 1} = indx_45p;
        globalAttri.dplus{end + 1} = dplus;
        globalAttri.dminus{end + 1} = dminus;
        globalAttri.segmentLen{end + 1} = segmentLen;
        globalAttri.indx{end + 1} = indx;
        globalAttri.mean_dplus_tmp{end + 1} = mean_dplus_tmp;
        globalAttri.std_dplus_tmp{end + 1} = std_dplus_tmp;
        globalAttri.mean_dminus_tmp{end + 1} = mean_dminus_tmp;
        globalAttri.std_dminus_tmp{end + 1} = std_dminus_tmp;
        globalAttri.TR_t{end + 1} = TR_t;
        globalAttri.TR_x{end + 1} = TR_x;
        globalAttri.segIndx{end + 1} = segIndx;
        globalAttri.caliTime{end + 1} = mean([thisCaliStartTime, thisCaliStopTime]);

    end
end

if isempty(mean_dminus) || isempty(mean_dplus)
    return;
end

% calculate the depol-calibration factor and std
polCaliFac = nanmean((1 + TR_t) ./ (1 + TR_x) .* ...
                        sqrt(mean_dplus .* mean_dminus), 1);
polCaliFacStd = nanmean(sqrt(((1 + TR_t) ./ (1 + TR_x) ./ ...
                            sqrt(mean_dplus .* mean_dminus) .* ...
        0.5 .* (mean_dplus .* std_dminus + mean_dminus .* std_dplus)).^2), 1);

end