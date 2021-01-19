function [data, depCalAttri] = pollyxt_ift_depolcali_UV(data, config, dbFile)
%POLLYXT_IFT_DEPOLCALI_UV calibrate the PollyXT depol channels at 355 nm
%with +- 45\deg method.
%Example:
%   [data, depCalAttri] = pollyxt_ift_depolcali_UV(data, config)
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
%   2021-01-19. First edition.
%Contact:
%   zhenping@tropos.de

global campaignInfo defaults

depCalAttri = struct();

if isempty(data.rawSignal)
    return;
end

%% depol calibration
time = data.mTime;

% 355 nm
flagTot355 = config.isFR & config.is355nm & config.isTot;
flagCro355 = config.isFR & config.is355nm & config.isCross;

signal_tot_355 = squeeze(data.signal(flagTot355, :, :));
bg_tot_355 = squeeze(data.bg(flagTot355, :, :));
signal_x_355 = squeeze(data.signal(flagCro355, :, :));
bg_x_355 = squeeze(data.bg(flagCro355, :, :));

[depol_cal_fac_355, depol_cal_fac_std_355, ...
 depol_cal_start_time_355, depol_cal_stop_time_355, ...
 depCalAttri.depCalAttri355] = depol_cali(...
    signal_tot_355, bg_tot_355, signal_x_355, bg_x_355, time, ...
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
depCalAttri.depol_cal_start_time_355 = depol_cal_start_time_355;
depCalAttri.depol_cal_stop_time_355 = depol_cal_stop_time_355;

[data.depol_cal_fac_355, data.depol_cal_fac_std_355, ...
 data.depol_cal_start_time_355, data.depol_cal_stop_time_355] = ...
    select_depolconst(depol_cal_fac_355, depol_cal_fac_std_355, ...
        depol_cal_start_time_355, depol_cal_stop_time_355, ...
        mean(time), dbFile, campaignInfo.name, '355', ...
        'flagUsePrevDepolConst', config.flagUsePreviousDepolCali, ...
        'flagDepolCali', config.flagDepolCali, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_depolconst', defaults.depolCaliConst355, ...
        'default_depolconstStd', defaults.depolCaliConstStd355);

end
