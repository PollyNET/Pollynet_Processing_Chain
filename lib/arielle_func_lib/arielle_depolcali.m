function [data, depCalAttri] = arielle_depolcali(data, config)
%arielle_depolcali calibrate the polly depol channels both for 355 and 532 nm
%with +- 45\deg method.
%Example:
%   [data] = arielle_depolcali(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%Outputs:
%   data.struct
%       The depolarization calibration results will be inserted.
%       More information can be found in doc/pollynet_processing_program.md
%   depCalAttri: struct
%       depolarization calibration information for each calibration period.
%History:
%   2018-12-17. First edition by Zhenping
%   2019-08-28. Add flag to control whether to do depolarization
%               calibration.
%Contact:
%   zhenping@tropos.de

global processInfo campaignInfo defaults

depCalAttri = struct();

if isempty(data.rawSignal)
    return;
end

%% depol calibration
time = data.mTime;

flagTot532 = config.isFR & config.is532nm & config.isTot;
flagCro532 = config.isFR & config.is532nm & config.isCross;

% 532 nm
signal_tot_532 = squeeze(data.signal(flagTot532, :, :));
bg_tot_532 = squeeze(data.bg(flagTot532, :, :));
signal_x_532 = squeeze(data.signal(flagCro532, :, :));
bg_x_532 = squeeze(data.bg(flagCro532, :, :));

[depol_cal_fac_532, depol_cal_fac_std_532, ...
 depol_cal_time_532, depCalAttri.depCalAttri532] = depol_cali(...
    signal_tot_532, bg_tot_532, signal_x_532, bg_x_532, time, ...
    data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
    data.depol_cal_ang_n_time_start,data.depol_cal_ang_n_time_end, ...
    config.TR(flagTot532), ...
    config.TR(flagCro532), ...
    [config.depol_cal_minbin_532, config.depol_cal_maxbin_532], ...
    config.depol_cal_SNRmin_532, config.depol_cal_sigMax_532, ...
    config.rel_std_dplus_532, config.rel_std_dminus_532, ...
    config.depol_cal_segmentLen_532, config.depol_cal_smoothWin_532);
depCalAttri.depol_cal_fac_532 = depol_cal_fac_532;
depCalAttri.depol_cal_fac_std_532 = depol_cal_fac_std_532;
depCalAttri.depol_cal_time_532 = depol_cal_time_532;

% if no successful calibration, set the calibration constant to default
% values or other predefined values
if sum(~ isnan(depol_cal_fac_532)) < 1 && ...
   config.flagUsePreviousDepolCali && config.flagDepolCali
    % Apply historical calibration results
    [depol_cal_fac_532, depol_cal_fac_std_532, ...
     depol_cal_time_532] = arielle_search_history_depolconst(mean(time), ...
        fullfile(processInfo.results_folder, ...
                 campaignInfo.name, config.depolCaliFile532), ...
        datenum(0,1,7,0,0,0), defaults, 532);
    data.depol_cal_fac_532 = depol_cal_fac_532;
    data.depol_cal_fac_std_532 = depol_cal_fac_std_532;
    data.depol_cal_time_532 = depol_cal_time_532;
elseif config.flagDepolCali && (sum(~ isnan(depol_cal_fac_532)) >= 1)
    % Apply current calibration results
    [~, indx] = min(depol_cal_fac_std_532);
    data.depol_cal_fac_532 = depol_cal_fac_532(indx);
    data.depol_cal_fac_std_532 = depol_cal_fac_std_532(indx);
    data.depol_cal_time_532 = depol_cal_time_532(indx);
else
    % Apply default settings
    data.depol_cal_fac_532 = defaults.depolCaliConst532;
    data.depol_cal_fac_std_532 = defaults.depolCaliConstStd532;
    data.depol_cal_time_532 = 0;
end

% 355 nm
flagTot355 = config.isFR & config.is355nm & config.isTot;
flagCro355 = config.isFR & config.is355nm & config.isCross;

signal_tot_355 = squeeze(data.signal(flagTot355, :, :));
bg_tot_355 = squeeze(data.bg(flagTot355, :, :));
signal_x_355 = squeeze(data.signal(flagCro355, :, :));
bg_x_355 = squeeze(data.bg(flagCro355, :, :));

[depol_cal_fac_355, depol_cal_fac_std_355, ...
 depol_cal_time_355, depCalAttri.depCalAttri355] = ...
    depol_cali(signal_tot_355, bg_tot_355, signal_x_355, bg_x_355, time, ...
    data.depol_cal_ang_p_time_start, data.depol_cal_ang_p_time_end, ...
    data.depol_cal_ang_n_time_start,data.depol_cal_ang_n_time_end, ...
    config.TR(flagTot355), ...
    config.TR(flagCro355), ...
    [config.depol_cal_minbin_355, config.depol_cal_maxbin_355], ...
    config.depol_cal_SNRmin_355, config.depol_cal_sigMax_355, ...
    config.rel_std_dplus_355, config.rel_std_dminus_355, ...
    config.depol_cal_segmentLen_355, config.depol_cal_smoothWin_355);
depCalAttri.depol_cal_fac_355 = depol_cal_fac_355;
depCalAttri.depol_cal_fac_std_355 = depol_cal_fac_std_355;
depCalAttri.depol_cal_time_355 = depol_cal_time_355;

% if no successful calibration, set the calibration factor to default
% values or other predefined values
if sum(~ isnan(depol_cal_fac_355)) < 1 && ...
   config.flagUsePreviousDepolCali && config.flagDepolCali
    % Apply historical calibration results
    [depol_cal_fac_355, depol_cal_fac_std_355, ...
     depol_cal_time_355] = arielle_search_history_depolconst(mean(time), ...
        fullfile(processInfo.results_folder, ...
                 campaignInfo.name, ...
                 config.depolCaliFile355), datenum(0,1,7,0,0,0), defaults, 355);
    data.depol_cal_fac_355 = depol_cal_fac_355;
    data.depol_cal_fac_std_355 = depol_cal_fac_std_355;
    data.depol_cal_time_355 = depol_cal_time_355;
elseif config.flagDepolCali && (sum(~ isnan(depol_cal_fac_355)) >= 1)
    % Apply current calibration results
    [~, indx] = min(depol_cal_fac_std_355);
    data.depol_cal_fac_355 = depol_cal_fac_355(indx);
    data.depol_cal_fac_std_355 = depol_cal_fac_std_355(indx);
    data.depol_cal_time_355 = depol_cal_time_355(indx);
else
    % Apply default settings
    data.depol_cal_fac_355 = defaults.depolCaliConst355;
    data.depol_cal_fac_std_355 = defaults.depolCaliConstStd355;
    data.depol_cal_time_355 = 0;
end
    
end