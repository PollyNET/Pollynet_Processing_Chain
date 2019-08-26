function [quasi_par_bsc_355_V2, quasi_par_bsc_532_V2, quasi_par_bsc_1064_V2, quasi_par_depol_532_V2, volDepol_355, volDepol_532, quasi_ang_532_1064_V2, quality_mask_355_V2, quality_mask_532_V2, quality_mask_1064_V2, quality_mask_volDepol_355_V2, quality_mask_volDepol_532_V2, quasiAttri_V2] = arielle_quasiretrieve_V2(data, config)
%arielle_quasiretrieve_V2 Retrieving the intensive aerosol optical properties with Quasi-retrieving method. Detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [quasi_par_bsc_355_V2, quasi_par_bsc_532_V2, quasi_par_bsc_1064_V2, quasi_par_depol_532_V2, volDepol_355, volDepol_532, quasi_ang_532_1064, quality_mask_355_V2, quality_mask_532_V2, quality_mask_1064_V2, quality_mask_volDepol_355_V2, quality_mask_volDepol_532_V2] = arielle_quasiretrieve_V2(data, config)
%   Input:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       quasi_par_bsc_355_V2: matrix
%           quasi particle backscatter coefficient at 355 nm. [m^{-1}Sr^{-1}]
%       quasi_par_bsc_532_V2: matrix
%           quasi particle backscatter coefficient at 532 nm. [m^{-1}Sr^{-1}]
%       quasi_par_bsc_1064_V2: matrix
%           quasi particle_V2 backscatter coefficient at 1064 nm. [m^{-1}Sr^{-1}]
%       quasi_par_depol_532_V2: matrix
%           quasi particle depolarization ratio at 532 nm.
%       volDepol_355: matrix_V2
%           volume depolarization_V2 ratio at 355 nm.
%       volDepol_532: matrix
%           volume depolarization ratio at 532 nm.
%       quasi_angstrexp_532_1064: matrix
%           quasi backscatter related Ångström exponent at 532-1064.
%       quality_mask_355_V2: matrix
%           quality mask for attenuated backscatter at 355 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_532_V2: matrix
%           quality mask for attenuated backscatter at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_1064_V2: matrix
%           quality mask for attenuated backscatter at 1064 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_volDepol_355_V2: matrix
%           quality mask for volume depolarization ratio at 355 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_volDepol_532_V2: matrix
%           quality mask for volume depolarization ratio at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%   History:
%       2019-08-04. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults

quasi_par_bsc_355_V2 = [];
quasi_par_bsc_1064_V2 = [];
quasi_par_depol_532_V2 = [];
volDepol_532 = [];
volDepol_355 = [];
quasi_ang_532_1064_V2 = [];
quality_mask_355_V2 = [];
quality_mask_532_V2 = [];
quality_mask_1064_V2 = [];
quality_mask_387 = [];
quality_mask_607 = [];
quality_mask_volDepol_532_V2 = [];
quality_mask_volDepol_355_V2 = [];
quasiAttri_V2 = struct();
quasiAttri_V2.flagGDAS1 = false;
quasiAttri_V2.timestamp = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
flagChannel532Cro = config.isFR & config.is532nm & config.isCross;
flagChannel355Tot = config.isFR & config.is355nm & config.isTot;
flagChannel355Cro = config.isFR & config.is355nm & config.isCross;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel387 = config.isFR & config.is387nm;
flagChannel607 = config.isFR & config.is607nm;

%% calculate volDepol 532 and 355 nm
volDepol_532 = polly_volDepol2(squeeze(data.signal(flagChannel532Tot, :, :)), squeeze(data.signal(flagChannel532Cro, :, :)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);
volDepol_532(:, data.depCalMask) = NaN;
volDepol_355 = polly_volDepol2(squeeze(data.signal(flagChannel355Tot, :, :)), squeeze(data.signal(flagChannel355Cro, :, :)), config.TR(flagChannel355Tot), config.TR(flagChannel355Cro), data.depol_cal_fac_355);
volDepol_355(:, data.depCalMask) = NaN;

%% calculate the quality mask to filter the points with high SNR
quality_mask_355 = zeros(size(data.att_beta_355));
quality_mask_532 = zeros(size(data.att_beta_355));
quality_mask_1064 = zeros(size(data.att_beta_355));
quality_mask_387 = zeros(size(data.att_beta_355));
quality_mask_607 = zeros(size(data.att_beta_355));
quality_mask_355_V2 = zeros(size(data.att_beta_355));
quality_mask_532_V2 = zeros(size(data.att_beta_532));
quality_mask_1064_V2 = zeros(size(data.att_beta_1064));
quality_mask_volDepol_532_V2 = zeros(size(data.att_beta_355));
quality_mask_volDepol_355_V2 = zeros(size(data.att_beta_355));

% SNR after temporal and vertical accumulation
SNR = NaN(size(data.signal));
for iChannel = 1:size(data.signal, 1)
    signal_sm = smooth2(squeeze(data.signal(iChannel, :, :)), config.quasi_smooth_h(iChannel), config.quasi_smooth_t(iChannel));
    signal_int = signal_sm * (config.quasi_smooth_h(iChannel) * config.quasi_smooth_t(iChannel));
    bg_sm = smooth2(squeeze(data.bg(iChannel, :, :)), config.quasi_smooth_h(iChannel), config.quasi_smooth_t(iChannel));
    bg_int = bg_sm * (config.quasi_smooth_h(iChannel) * config.quasi_smooth_t(iChannel));
    SNR(iChannel, :, :) = polly_SNR(signal_int, bg_int);
end

% 0 in quality_mask means good data
% 1 in quality_mask means low-SNR data
% 2 in quality_mask means depolarization calibration periods
% 3 in quality_mask means shutter on
% 4 in quality_mask means fog
quality_mask_355(squeeze(SNR(flagChannel355Tot, :, :)) < config.mask_SNRmin(flagChannel355Tot)) = 1;
quality_mask_532(squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot)) = 1;
quality_mask_1064(squeeze(SNR(flagChannel1064, :, :)) < config.mask_SNRmin(flagChannel1064)) = 1;
quality_mask_387(squeeze(SNR(flagChannel387, :, :)) < config.mask_SNRmin(flagChannel387)) = 1;
quality_mask_607(squeeze(SNR(flagChannel607, :, :)) < config.mask_SNRmin(flagChannel607)) = 1;
quality_mask_volDepol_532_V2((squeeze(SNR(flagChannel532Cro, :, :)) < config.mask_SNRmin(flagChannel532Cro)) | (squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot))) = 1;
quality_mask_volDepol_355_V2((squeeze(SNR(flagChannel355Cro, :, :)) < config.mask_SNRmin(flagChannel355Cro)) | (squeeze(SNR(flagChannel355Tot, :, :)) < config.mask_SNRmin(flagChannel355Tot))) = 1;
quality_mask_355(:, data.depCalMask) = 2;
quality_mask_532(:, data.depCalMask) = 2;
quality_mask_1064(:, data.depCalMask) = 2;
quality_mask_387(:, data.depCalMask) = 2;
quality_mask_607(:, data.depCalMask) = 2;
quality_mask_volDepol_532_V2(:, data.depCalMask) = 2;
quality_mask_volDepol_355_V2(:, data.depCalMask) = 2;
quality_mask_355(:, data.shutterOnMask) = 3;
quality_mask_532(:, data.shutterOnMask) = 3;
quality_mask_1064(:, data.shutterOnMask) = 3;
quality_mask_387(:, data.shutterOnMask) = 3;
quality_mask_607(:, data.shutterOnMask) = 3;
quality_mask_volDepol_532_V2(:, data.shutterOnMask) = 3;
quality_mask_volDepol_355_V2(:, data.shutterOnMask) = 3;
quality_mask_355(:, data.fogMask) = 4;
quality_mask_532(:, data.fogMask) = 4;
quality_mask_1064(:, data.fogMask) = 4;
quality_mask_387(:, data.fogMask) = 4;
quality_mask_607(:, data.fogMask) = 4;
quality_mask_volDepol_532_V2(:, data.fogMask) = 4;
quality_mask_volDepol_355_V2(:, data.fogMask) = 4;
% quality mask for V2 results
quality_mask_355_V2 = quality_mask_355;
quality_mask_355_V2((quality_mask_355_V2 == 0) & (quality_mask_387 == 1)) = 1;
quality_mask_532_V2 = quality_mask_532;
quality_mask_532_V2((quality_mask_532_V2 == 0) & (quality_mask_607 == 1)) = 1;
quality_mask_1064_V2 = quality_mask_1064;
quality_mask_1064_V2((quality_mask_1064_V2 == 0) & ((quality_mask_607 == 1) | (quality_mask_532 == 1))) = 1;

% set data with the influence from (depol calibration, noise, fog and laser shutter on) to NaN
att_beta_355 = data.att_beta_355;
att_beta_532 = data.att_beta_532;
att_beta_1064 = data.att_beta_1064;
att_beta_607 = data.att_beta_607;
att_beta_387 = data.att_beta_387;
att_beta_355(quality_mask_355 ~= 0) = NaN;
att_beta_532(quality_mask_532 ~= 0) = NaN;
att_beta_1064(quality_mask_1064 ~= 0) = NaN;
att_beta_607(quality_mask_607 ~= 0) = NaN;
att_beta_387(quality_mask_387 ~= 0) = NaN;

% smooth the data
att_beta_355 = smooth2(att_beta_355, config.quasi_smooth_h(flagChannel355Tot), config.quasi_smooth_t(flagChannel355Tot));
att_beta_532 = smooth2(att_beta_532, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));
att_beta_1064 = smooth2(att_beta_1064, config.quasi_smooth_h(flagChannel1064), config.quasi_smooth_t(flagChannel1064));
att_beta_387 = smooth2(att_beta_387, config.quasi_smooth_h(flagChannel387), config.quasi_smooth_t(flagChannel387));
att_beta_607 = smooth2(att_beta_607, config.quasi_smooth_h(flagChannel607), config.quasi_smooth_t(flagChannel607));

% mask the data (depol calibration; shutter; fog)
sig532Tot = squeeze(data.signal(flagChannel532Tot, :, :));
sig532Tot(:, data.depCalMask) = NaN;
sig532Cro = squeeze(data.signal(flagChannel532Cro, :, :));
sig532Cro(:, data.depCalMask) = NaN;
volDepol_532_smooth = polly_volDepol2(smooth2(sig532Tot, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot)), smooth2(sig532Cro, config.quasi_smooth_h(flagChannel532Cro), config.quasi_smooth_t(flagChannel532Cro)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);
sig355Tot = squeeze(data.signal(flagChannel355Tot, :, :));
sig355Tot(:, data.depCalMask) = NaN;
sig355Cro = squeeze(data.signal(flagChannel355Cro, :, :));
sig355Cro(:, data.depCalMask) = NaN;
volDepol_355_smooth = polly_volDepol2(smooth2(sig355Tot, config.quasi_smooth_h(flagChannel355Tot), config.quasi_smooth_t(flagChannel355Tot)), smooth2(sig355Cro, config.quasi_smooth_h(flagChannel355Cro), config.quasi_smooth_t(flagChannel355Cro)), config.TR(flagChannel355Tot), config.TR(flagChannel355Cro), data.depol_cal_fac_355);

%% quasi retrieving
% redistribute the meteorological data to 30-s intervals.
[molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri, molBsc387, molExt387, molBsc607, molExt607] = repmat_molscatter(data.mTime, data.alt, config);
quasiAttri_V2.flagGDAS1 = strcmpi(globalAttri.source, 'gdas1');
quasiAttri_V2.meteorSource = globalAttri.source;
quasiAttri_V2.timestamp = globalAttri.datetime;

% quasi particle backscatter and extinction coefficents
[quasi_par_bsc_355_V2, quasi_par_ext_355_V2] = quasi_retrieving_V2(data.height, att_beta_355, att_beta_387, 355, molExt355, molBsc355, molExt387, 0.5, 50, 3);
quasi_par_bsc_355_V2 = smooth2(quasi_par_bsc_355_V2, config.quasi_smooth_h(flagChannel355Tot), config.quasi_smooth_t(flagChannel355Tot));
[quasi_par_bsc_532_V2, quasi_par_ext_532_V2] = quasi_retrieving_V2(data.height, att_beta_532, att_beta_607, 532, molExt532, molBsc532, molExt607, 0.5, 50, 3);
quasi_par_bsc_532_V2 = smooth2(quasi_par_bsc_532_V2, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));
[quasi_par_bsc_1064_V2, quasi_par_ext_1064_V2] = quasi_retrieving_V2(data.height, att_beta_1064, att_beta_607, 1064, molExt1064, molBsc1064, molExt607, 0.5, 50, 3);
quasi_par_bsc_1064_V2 = smooth2(quasi_par_bsc_1064_V2, config.quasi_smooth_h(flagChannel1064), config.quasi_smooth_t(flagChannel1064));

%% quasi particle depolarization ratio and Ångström exponents
quasi_par_depol_532_V2 = (volDepol_532_smooth + 1) ./ (molBsc532 .* (defaults.molDepol532 - volDepol_532_smooth) ./ (quasi_par_bsc_532_V2 .* (1 + defaults.molDepol532)) + 1) - 1;
quasi_par_depol_532_V2((quality_mask_volDepol_532_V2 ~= 0) | (quality_mask_532 ~= 0)) = NaN;

ratio_par_bsc_355_532 = quasi_par_bsc_532_V2 ./ quasi_par_bsc_355_V2;
ratio_par_bsc_1064_532 = quasi_par_bsc_1064_V2 ./ quasi_par_bsc_532_V2;
ratio_par_bsc_355_1064 = quasi_par_bsc_1064_V2 ./ quasi_par_bsc_355_V2;
% remove the negative ratio
ratio_par_bsc_355_532(ratio_par_bsc_355_532 <= 0) = NaN;
ratio_par_bsc_1064_532(ratio_par_bsc_1064_532 <= 0) = NaN;
ratio_par_bsc_355_1064(ratio_par_bsc_355_1064 <= 0) = NaN;

quasi_ang_355_532_V2 = log(ratio_par_bsc_355_532) ./ log(355/532);
quasi_ang_532_1064_V2 = log(ratio_par_bsc_1064_532) ./ log(532/1064);
quasi_ang_355_1064_V2 = log(ratio_par_bsc_355_1064) ./ log(355/1064);

end