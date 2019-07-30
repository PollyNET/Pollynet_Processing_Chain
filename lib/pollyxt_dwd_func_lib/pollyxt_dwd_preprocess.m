function [ data ] = pollyxt_dwd_preprocess(data, config)
%pollyxt_dwd_preprocess deadtime correction, background correction, 
%first-bin shift, mask for low-SNR and mask for depolarization-calibration process.
%   Usage:
%       [ data ] = pollyxt_dwd_preprocess(data, config)
%   Inputs:
%       data: struct
%           rawSignal: array
%               signal. [Photon Count]
%           mShots: array
%               number of the laser shots for each profile.
%           mTime: array
%               datetime array for the measurement time of each profile.
%           depCalAng: array
%               angle of the polarizer in the receiving channel. (>0 means 
%               calibration process starts)
%           zenithAng: array
%               zenith angle of the laer beam.
%           repRate: float
%               laser pulse repetition rate. [s^-1]
%           hRes: float
%               spatial resolution [m]
%           mSite: string
%               measurement site.
%       config: struct
%           configuration. Detailed information can be found in doc/polly_config.md.
%   Outputs:
%       data: struct
%           rawSignal: array
%               signal. [Photon Count]
%           mShots: array
%               number of the laser shots for each profile.
%           mTime: array
%               datetime array for the measurement time of each profile.
%           depCalAng: array
%               angle of the polarizer in the receiving channel. (>0 means 
%               calibration process starts)
%           zenithAng: array
%               zenith angle of the laer beam.
%           repRate: float
%               laser pulse repetition rate. [s^-1]
%           hRes: float
%               spatial resolution [m]
%           mSite: string
%               measurement site.
%           signal: array
%               Background removed signal
%           bg: array
%               background
%           height: array
%               height. [m]
%           lowSNRMask: array
%               If SNR less SNRmin, mask is set true. Otherwise, false
%           depCalMask: array
%               If polly was doing depolarization calibration, depCalMask is set
%               true. Otherwise, false.
%           fogMask: array
%               If it is foggy which means the signal will be very weak, 
%               fogMask will be set true. Otherwise, false
%   History:
%       2018-12-16. First edition by Zhenping.
%       2019-07-10. Add mask for laser shutter due to approaching airplanes.
%   Copyright:
%       Ground-based remote sensing (tropos)

global campaignInfo

if isempty(data.rawSignal)
    return;
end

if (max(config.max_height_bin + config.first_range_gate_indx - 1) > size(data.rawSignal, 2))
    tmpStr = sprintf('%d, ', config.first_range_gate_indx);
    warning('%s_config.max_height_bin or %s_config.first_range_gate_indx is out of range.\nTotal number of range bin is %d.\n%s_config.max_height_bin is %d\n%s_config.first_range_gate_indx is %s\n', config.pollyVersion, config.pollyVersion, size(data.rawSignal, 2), config.max_height_bin, config.first_range_gate_indx);
    fprintf('Set the %s_config.max_height_bin and %s_config.first_range_gate_indx to be default value.\n', config.pollyVersion, config.pollyVersion);
    config.max_height_bin = 251;
    config.first_range_gate_indx = ones(1, size(data.rawSignal, 1));
end

%% deadtime correction
rawSignal = data.rawSignal;
if config.flagDTCor
    PCR = data.rawSignal ./ repmat(reshape(data.mShots, size(data.mShots, 1), 1, size(data.mShots, 2)), ...
        [1, size(data.rawSignal, 2), 1]) * 150.0 ./ data.hRes;   % [MHz]
    % polynomial correction with parameters saved in netcdf file
    if config.dtCorMode == 1
        for iChannel = 1:size(data.rawSignal, 1)
            PCR_Cor = polyval(data.deadtime(iChannel, end:-1:1), PCR(iChannel, :, :));
            rawSignal(iChannel, :, :) = PCR_Cor / (150.0 / data.hRes) .* ...
                repmat(reshape(data.mShots(iChannel, :), 1, 1, size(data.mShots, 2)), ...
                [1, size(data.rawSignal, 2), 1]);   % [count]
        end
    % nonparalyzable correction
    elseif config.dtCorMode == 2
        for iChannel = 1:size(data.rawSignal, 1)
            PCR_Cor = PCR(iChannel, :, :) ./ (1.0 - config.dt(iChannel) * 1e-3 * PCR(iChannel, :, :));
            rawSignal(iChannel, :, :) = PCR_Cor / (150.0 / data.hRes) .* ...
                repmat(reshape(data.mShots(iChannel, :), 1, 1, size(data.mShots, 2)), ...
                [1, size(data.rawSignal, 2), 1]);   % [count]
        end
    % user defined deadtime. Regarding the format of dt, please go to /doc/polly_config.md
    elseif config.dtCorMode == 3
        if isfield(config, 'dt')   % determine whether the deadtime parameters were defined.
            for iChannel = 1:size(data.rawSignal, 1)
                PCR_Cor = polyval(config.dt(iChannel, end:-1:1), PCR(iChannel, :, :));
                rawSignal(iChannel, :, :) = PCR_Cor / (150.0 / data.hRes) .* ...
                    repmat(reshape(data.mShots(iChannel, :), 1, 1, size(data.mShots, 2)), ...
                    [1, size(data.rawSignal, 2), 1]);   % [count]
            end
        else
            warning('User defined deadtime parameters were not found. Please go back to check the configuration file for the %s at %s.', campaignInfo.name, campaignInfo.location);
            warning('In order to continue the current processing, deadtime correction will not be implemented. Be careful!!!!!!!!!');
        end
    % No deadtime correction
    elseif config.dtCorMode == 4
        fprintf('Deadtime correction was turned off. Be careful to check the signal strength.\n');
    else
        error('Unknow deadtime correction setting! Please go back to check the configuration file for %s at %s. For dtCorMode, only 1-4 is allowed.', campaignInfo.name, campaignInfo.location);
    end
end

%% Background Substraction
bg = repmat(mean(rawSignal(:, config.bgCorRangeIndx(1):config.bgCorRangeIndx(2), :), 2), [1, config.max_height_bin, 1]);
data.signal = NaN(size(rawSignal, 1), config.max_height_bin, size(rawSignal, 3));
for iChannel = 1:size(rawSignal, 1)
    data.signal(iChannel, :, :) = rawSignal(iChannel, config.first_range_gate_indx(iChannel):config.max_height_bin + config.first_range_gate_indx(iChannel) - 1, :) - bg(iChannel, :, :);
end
data.bg = bg;

%% height (first bin height correction)
data.height = double((0:(size(data.signal, 2)-1)) * data.hRes * cos(data.zenithAng/180*pi) + config.first_range_gate_height);   % [m]
data.alt = double(data.height + campaignInfo.asl);   % geopotential height
data.distance0 = double(data.height ./ cos(data.zenithAng/180*pi));   % the distance between range bin and system.

%% mask for low SNR region
SNR = polly_SNR(data.signal, data.bg);
data.lowSNRMask = false(size(data.signal));
for iChannel = 1: size(data.signal, 1)
    data.lowSNRMask(iChannel, SNR(iChannel, :, :) < config.mask_SNRmin(iChannel)) = true;
end

%% depol cal time and mask
maskDepCalAng = {'none', 'none', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'none', 'none', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'none'};   % the mask for postive and negative calibration angle. 'none' means invalid profiles with different depol_cal_angle
[depol_cal_ang_p_time_start, depol_cal_ang_p_time_end, depol_cal_ang_n_time_start, depol_cal_ang_n_time_end, depCalMask] = polly_depolCal_time(data.depCalAng, data.mTime, config.init_depAng, maskDepCalAng);
data.depol_cal_ang_p_time_start = depol_cal_ang_p_time_start;
data.depol_cal_ang_p_time_end = depol_cal_ang_p_time_end;
data.depol_cal_ang_n_time_start = depol_cal_ang_n_time_start;
data.depol_cal_ang_n_time_end = depol_cal_ang_n_time_end;
data.depCalMask = transpose(depCalMask);

%% mask for laser shutter
data.shutterOnMask = polly_isLaserShutterOn(squeeze(data.signal(5, :, :)));

%% mask for fog profiles
data.fogMask = false(1, size(data.signal, 3));
is_channel_532_FR_Tot = config.isFR & config.is532nm & config.isTot;
% signal strength is weak and not caused by laser shutter on.
data.fogMask(transpose(squeeze(sum(data.signal(is_channel_532_FR_Tot, 40:120, :), 2)) <= config.minPC_fog) & (~ data.shutterOnMask)) = true;

end
