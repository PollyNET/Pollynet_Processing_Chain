function [data, depCalAttri] = pollyxt_ift_depolcali(data, config, dbFile)
%POLLYXT_IFT_DEPOLCALI calibrate the PollyXT depol channels at 532 nm
%with +- 45\deg method.
%Example:
%   [data, depCalAttri] = pollyxt_ift_depolcali(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   dbFile: char
%       absolute path of the database.
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
%   2020-04-18. Generalise the interface.
%Contact:
%   zhenping@tropos.de

global campaignInfo defaults

depCalAttri = struct();

if isempty(data.rawSignal)
    return;
end

%% depol calibration
time = data.mTime;

% 532 nm
flagTot532 = config.isFR & config.is532nm & config.isTot;
flagCro532 = config.isFR & config.is532nm & config.isCross;

signal_tot_532 = squeeze(data.signal(flagTot532, :, :));
bg_tot_532 = squeeze(data.bg(flagTot532, :, :));
signal_x_532 = squeeze(data.signal(flagCro532, :, :));
bg_x_532 = squeeze(data.bg(flagCro532, :, :));

[depol_cal_fac_532, depol_cal_fac_std_532, ...
 depol_cal_start_time_532, depol_cal_stop_time_532, ...
 depCalAttri.depCalAttri532] = depol_cali(...
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
depCalAttri.depol_cal_start_time_532 = depol_cal_start_time_532;
depCalAttri.depol_cal_stop_time_532 = depol_cal_stop_time_532;

[data.depol_cal_fac_532, data.depol_cal_fac_std_532, ...
 data.depol_cal_start_time_532, data.depol_cal_stop_time_532] = ...
    select_depolconst(depol_cal_fac_532, depol_cal_fac_std_532, ...
        depol_cal_start_time_532, depol_cal_stop_time_532, ...
        mean(time), dbFile, campaignInfo.name, '532', ...
        'flagUsePrevDepolConst', config.flagUsePreviousDepolCali, ...
        'flagDepolCali', config.flagDepolCali, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_depolconst', defaults.depolCaliConst532, ...
        'default_depolconstStd', defaults.depolCaliConstStd532);

end
