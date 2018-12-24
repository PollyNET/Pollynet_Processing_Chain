function [data] = pollyxt_dwd_depolcali(data, config, taskInfo, defaults, saveFolder)
    %pollyxt_dwd_depolcali calibrate the polly depol channels both for 355 and 532 nm with +- 45\deg method.
    %	Example:
    %		[data] = pollyxt_dwd_depolcali(data, config, taskInfo, defaults, saveFolder)
    %	Inputs:
    %		data: struct
    %           More detailed information can be found in doc/pollynet_processing_program.md
    %       config: struct
    %           More detailed information can be found in doc/pollynet_processing_program.md
    %       taskInfo: struct
    %           More detailed information can be found in doc/pollynet_processing_program.md
    %       defaults: struct
    %           More detailed information can be found in doc/polly_defaults.md
    %       saveFolder: char
    %           folder to save the calibration results
    %	Outputs:
    %		data: struct
    %           The depolarization calibration results will be inserted. And more information can be found in doc/pollynet_processing_program.md
    %	History:
    %		2018-12-17. First edition by Zhenping
    %	Contact:
    %		zhenping@tropos.de
    
    if isempty(data.rawSignal)
        return;
    end
    
    %% search cali periods
    caliTIndx = find((config.depol_cal_ang_p_time < data.mTime(end)) & (config.depol_cal_ang_p_time >= data.mTime(1)));
    
    %% depol calibration
    time = data.mTime;
    signal_tot_532 = squeeze(data.signal(config.isFR & config.is532nm & config.isTot, :, :));
    bg_tot_532 = squeeze(data.bg(config.isFR & config.is532nm & config.isTot, :, :));
    signal_x_532 = squeeze(data.signal(config.isFR & config.is532nm & config.isCross, :, :));
    bg_x_532 = squeeze(data.bg(config.isFR & config.is532nm & config.isCross, :, :));
    
    if (~ isempty(signal_tot_532)) && (~ isempty(signal_x_532))
        [depol_cal_fac_532, depol_cal_fac_std_532, depol_cal_time_532, depolcali_dplus, depolcali_dminus] = ...
            depol_cali(signal_tot_532, bg_tot_532, signal_x_532, bg_x_532, time, ...
            config.depol_cal_ang_p_time, config.depol_cal_ang_n_time, ...
            config.TR(config.isFR & config.is532nm & config.isTot), ...
            config.TR(config.isFR & config.is532nm & config.isCross), ...
            [config.depol_cal_minbin_532, config.depol_cal_maxbin_532], ...
            config.depol_cal_SNRmin_532, config.depol_cal_sigMax_532, ...
            config.rel_std_dplus_532, config.rel_std_dminus_532, ...
            config.depol_cal_segmentLen_532, config.depol_cal_smoothWin_532, ...
            fullfile(saveFolder, datestr(data.mTime(1), 'yyyymmdd')), 532);
    
        % saving calibration constants
        pollyxt_dwd_save_depolcaliconst(depol_cal_fac_532, depol_cal_fac_std_532, depol_cal_time_532, taskInfo.dataFilename, defaults, fullfile(saveFolder, config.depolCaliFile));
    end
    
    % if no successful calibration, set the calibration factor to be default
    % values or other values as you like    
    if sum(isnan(depol_cal_fac_532)) < 1
        data.depol_cal_fac_532 = defaults.depolCaliConst532;
        data.depol_cal_fac_std_532 = config.depolCaliConstStd532;
        data.depol_cal_time_532 = '-999';
    else
        data.depol_cal_fac_532 = depol_cal_fac_532;
        data.depol_cal_fac_std_532 = depol_cal_fac_std_532;
        data.depol_cal_time_532 = depol_cal_time_532;
    end
    
end