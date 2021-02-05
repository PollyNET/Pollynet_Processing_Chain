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
depol_cal_fac_355 = [];
depol_cal_fac_std_355 = [];
depol_cal_start_time_355 = [];
depol_cal_stop_time_355 = [];

if isempty(data.rawSignal)
    return;
end

if config.flagMolDepolCali

    %% 355 nm depolarization calibration
    for iGroup = 1:size(data.cloudFreeGroups, 1)

        proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
        flagChannel355Tot = config.isFR & config.is355nm & config.isTot;
        flagChannel355Cro = config.isFR & config.is355nm & config.isCross;
        sig355Tot = squeeze(sum(data.signal(flagChannel355Tot, :, proIndx), 3));
        bg355Tot = squeeze(sum(data.bg(flagChannel355Tot, :, proIndx), 3));
        sig355Cro = squeeze(sum(data.signal(flagChannel355Cro, :, proIndx), 3));
        bg355Cro = squeeze(sum(data.bg(flagChannel355Cro, :, proIndx), 3));

        refHIndx355 = data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2);

        % molecular depolarization calibration
        fprintf('Start molecular depolarization calibration for the %d cloud free period at 355 nm.\n', iGroup);
        [this_depol_cal_fac_355, this_depol_cal_fac_std_355] = polly_molDepolCali(sig355Tot(refHIndx355), bg355Tot(refHIndx355), sig355Cro(refHIndx355), bg355Cro(refHIndx355), config.TR(flagChannel355Tot), 0, config.TR(flagChannel355Cro), 0, 10, defaults.molDepol355, defaults.molDepolStd355);

        depol_cal_fac_355 = cat(2, depol_cal_fac_355, this_depol_cal_fac_355);
        depol_cal_fac_std_355 = cat(2, depol_cal_fac_std_355, this_depol_cal_fac_std_355);
        depol_cal_start_time_355 = cat(2, depol_cal_start_time_355, data.mTime(proIndx(1)));
        depol_cal_stop_time_355 = cat(2, depol_cal_stop_time_355, data.mTime(proIndx(end)));

    end

    depCalAttri.depol_cal_fac_355 = depol_cal_fac_355;
    depCalAttri.depol_cal_fac_std_355 = depol_cal_fac_std_355;
    depCalAttri.depol_cal_start_time_355 = depol_cal_start_time_355;
    depCalAttri.depol_cal_stop_time_355 = depol_cal_stop_time_355;

end

% select depolarization calibration factor
[data.depol_cal_fac_355, data.depol_cal_fac_std_355, ...
 data.depol_cal_start_time_355, data.depol_cal_stop_time_355] = ...
   select_depolconst(depol_cal_fac_355, depol_cal_fac_std_355, ...
       depol_cal_start_time_355, depol_cal_stop_time_355, ...
       mean(data.mTime), dbFile, campaignInfo.name, '355', ...
       'flagUsePrevDepolConst', config.flagUsePreviousDepolCali, ...
       'flagDepolCali', config.flagDepolCali, ...
       'deltaTime', datenum(0, 1, 7), ...
       'default_depolconst', defaults.depolCaliConst355, ...
       'default_depolconstStd', defaults.depolCaliConstStd355);

end
