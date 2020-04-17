function [quasi_par_bsc_532_V2, quasi_par_depol_532_V2, volDepol_532, quality_mask_532_V2, quality_mask_volDepol_532_V2, quasiAttri_V2] = polly_1v2_quasiretrieve_V2(data, config)
%polly_1v2_quasiretrieve_V2 Retrieving the intensive aerosol optical properties with Quasi-retrieving method. Detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [quasi_par_bsc_532_V2, quasi_par_depol_532_V2, volDepol_532, quality_mask_532_V2, quality_mask_volDepol_532_V2] = polly_1v2_quasiretrieve_V2(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       quasi_par_depol_532_V2: matrix
%           quasi particle depolarization ratio at 532 nm.
%       volDepol_532: matrix
%           volume depolarization ratio at 532 nm.
%       quality_mask_532_V2: matrix
%           quality mask for attenuated backscatter at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_volDepol_532_V2: matrix
%           quality mask for volume depolarization ratio at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%   History:
%       2019-08-04. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults processInfo

quasi_par_depol_532_V2 = [];
volDepol_532 = [];
quality_mask_532_V2 = [];
quality_mask_607 = [];
quality_mask_volDepol_532_V2 = [];
quasiAttri_V2 = struct();
quasiAttri_V2.flagGDAS1 = false;
quasiAttri_V2.timestamp = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
flagChannel532Cro = config.isFR & config.is532nm & config.isCross;
flagChannel607 = config.isFR & config.is607nm;

%% calculate volDepol 532
volDepol_532 = polly_volDepol2(squeeze(data.signal(flagChannel532Tot, :, :)), squeeze(data.signal(flagChannel532Cro, :, :)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);
volDepol_532(:, data.depCalMask) = NaN;

%% calculate the quality mask to filter the points with high SNR
quality_mask_532 = zeros(size(data.att_beta_532));
quality_mask_532_V2 = zeros(size(data.att_beta_532));
quality_mask_607 = zeros(size(data.att_beta_532));
quality_mask_volDepol_532 = zeros(size(data.att_beta_532));
quality_mask_volDepol_532_V2 = zeros(size(data.att_beta_532));

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
quality_mask_532(squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot)) = 1;
quality_mask_607(squeeze(SNR(flagChannel607, :, :)) < config.mask_SNRmin(flagChannel607)) = 1;
quality_mask_volDepol_532((squeeze(SNR(flagChannel532Cro, :, :)) < config.mask_SNRmin(flagChannel532Cro)) | (squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot))) = 1;
quality_mask_532(:, data.depCalMask) = 2;
quality_mask_607(:, data.depCalMask) = 2;
quality_mask_volDepol_532(:, data.depCalMask) = 2;
quality_mask_532(:, data.shutterOnMask) = 3;
quality_mask_607(:, data.shutterOnMask) = 3;
quality_mask_volDepol_532(:, data.shutterOnMask) = 3;
quality_mask_532(:, data.fogMask) = 4;
quality_mask_607(:, data.fogMask) = 4;
quality_mask_volDepol_532(:, data.fogMask) = 4;
% quality mask for V2 results (taking into the SNR of both Elastic and Raman signal)
quality_mask_532_V2 = quality_mask_532;
quality_mask_532_V2((quality_mask_532_V2 == 0) & (quality_mask_607 == 1)) = 1;
quality_mask_volDepol_532_V2 = quality_mask_volDepol_532;
quality_mask_volDepol_532_V2((quality_mask_volDepol_532_V2 == 0) & (quality_mask_607 == 1)) = 1;

% set data with the influence from (depol calibration, noise, fog and laser shutter on) to NaN
att_beta_532 = data.att_beta_532;
att_beta_607 = data.att_beta_607;
att_beta_532(quality_mask_532 ~= 0) = NaN;
att_beta_607(quality_mask_607 ~= 0) = NaN;

% smooth the data
att_beta_532 = smooth2(att_beta_532, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));
att_beta_607 = smooth2(att_beta_607, config.quasi_smooth_h(flagChannel607), config.quasi_smooth_t(flagChannel607));

% mask the data (depol calibration; shutter; fog)
sig532Tot = squeeze(data.signal(flagChannel532Tot, :, :));
sig532Tot(:, data.depCalMask) = NaN;
sig532Cro = squeeze(data.signal(flagChannel532Cro, :, :));
sig532Cro(:, data.depCalMask) = NaN;
volDepol_532_smooth = polly_volDepol2(smooth2(sig532Tot, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot)), smooth2(sig532Cro, config.quasi_smooth_h(flagChannel532Cro), config.quasi_smooth_t(flagChannel532Cro)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);

%% quasi retrieving
% redistribute the meteorological data to 30-s intervals.
meteorInfo.meteorDataSource = config.meteorDataSource;
meteorInfo.gdas1Site = config.gdas1Site;
meteorInfo.gdas1_folder = processInfo.gdas1_folder;
meteorInfo.radiosondeSitenum = config.radiosondeSitenum;
meteorInfo.radiosondeFolder = config.radiosondeFolder;
meteorInfo.radiosondeType = config.radiosondeType;
[molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri, molBsc387, molExt387, molBsc607, molExt607] = repmat_molscatter(data.mTime, data.alt, meteorInfo);
quasiAttri_V2.flagGDAS1 = strcmpi(globalAttri.source, 'gdas1');
quasiAttri_V2.meteorSource = globalAttri.source;
quasiAttri_V2.timestamp = globalAttri.datetime;

% quasi particle backscatter and extinction coefficents
[quasi_par_bsc_532_V2, quasi_par_ext_532_V2] = quasi_retrieving_V2(data.height, att_beta_532, att_beta_607, 532, molExt532, molBsc532, molExt607, 0.5, 50, 3);
quasi_par_bsc_532_V2 = smooth2(quasi_par_bsc_532_V2, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));

%% quasi particle depolarization ratio and Ångström exponents
quasi_par_depol_532_V2 = (volDepol_532_smooth + 1) ./ (molBsc532 .* (defaults.molDepol532 - volDepol_532_smooth) ./ (quasi_par_bsc_532_V2 .* (1 + defaults.molDepol532)) + 1) - 1;
quasi_par_depol_532_V2(quality_mask_volDepol_532_V2 ~= 0) = NaN;

end