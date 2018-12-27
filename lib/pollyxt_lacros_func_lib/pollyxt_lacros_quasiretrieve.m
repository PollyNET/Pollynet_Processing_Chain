function [quasi_bsc_532, quasi_bsc_1064, quasi_parDepol_532, volDepol_532, quasi_angstrexp_532_1064, quality_mask_355, quality_mask_532, quality_mask_1064, quality_mask_volDepol_532] = pollyxt_dwd_quasiretrieve(data, config)
%pollyxt_dwd_quasiretrieve Retrieving the intensive aerosol optical properties with Quasi-retrieving method. Detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [quasi_bsc_532, quasi_bsc_1064, quasi_parDepol_532, volDepol_532, quasi_angstrexp_532_1064, quality_mask_355, quality_mask_532, quality_mask_1064, quality_mask_volDepol_532] = pollyxt_dwd_quasiretrieve(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       quasi_bsc_532: matrix
%           quasi particle backscatter coefficient at 532 nm. [m^{-1}Sr^{-1}]
%       quasi_bsc_1064: matrix
%           quasi particle backscatter coefficient at 1064 nm. [m^{-1}Sr^{-1}]
%       quasi_parDepol_532: matrix
%           quasi particle depolarization ratio at 532 nm.
%       volDepol_532: matrix
%           volume depolarization ratio at 532 nm.
%       quasi_angstrexp_532_1064: matrix
%           quasi backscatter related Ångström exponent at 532-1064.
%       quality_mask_355: matrix
%           quality mask for attenuated backscatter at 355 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_532: matrix
%           quality mask for attenuated backscatter at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_1064: matrix
%           quality mask for attenuated backscatter at 1064 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_volDepol_532: matrix
%           quality mask for volume depolarization ratio at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo, defaults

quasi_bsc_532 = [];
quasi_bsc_1064 = [];
quasi_parDepol_532 = [];
volDepol_532 = [];
quasi_angstrexp_532_1064 = [];
quality_mask_355 = [];
quality_mask_532 = [];
quality_mask_1064 = [];
quality_mask_volDepol_532 = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
flagChannel532Cro = config.isFR & config.is532nm & config.isCross;
flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

%% calculate volDepol 532
volDepol_532 = polly_volDepol2(squeeze(data.signal(flagChannel532Tot, :, :)), squeeze(data.signal(flagChannel532Cro, :, :)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro));
volDepol_532(:, config.depCalMask) = NaN;

%% calculate the quality mask to filter the points with high SNR
quality_mask_355 = zeros(size(data.att_beta_355));
quality_mask_532 = zeros(size(data.att_beta_355));
quality_mask_1064 = zeros(size(data.att_beta_355));
quality_mask_volDepol_532 = zeros(size(data.att_beta_355));

SNR = polly_SNR(data.signal, data.bg);

% 0 in quality_mask means good data
% 1 in quality_mask means low-SNR data
% 2 in quality_mask means depolarization calibration periods
quality_mask_355(nanrunmedian(squeeze(SNR(flagChannel355, :, :)), config.quasi_smooth_h(flagChannel355), config.quasi_smooth_t(flagChannel355)) < config.mask_SNRmin(flagChannel355)) = 1;
quality_mask_532(nanrunmedian(squeeze(SNR(flagChannel532Tot, :, :)), config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot)) < config.mask_SNRmin(flagChannel532Tot)) = 1;
quality_mask_1064(nanrunmedian(squeeze(SNR(flagChannel1064, :, :)), config.quasi_smooth_h(flagChannel1064), config.quasi_smooth_t(flagChannel1064)) < config.mask_SNRmin(flagChannel1064)) = 1;
quality_mask_voldepol((nanrunmedian(squeeze(SNR(flagChannel532Cro, :, :)), config.quasi_smooth_h(flagChannel532Cro), config.quasi_smooth_t(flagChannel532Cro)) < config.mask_SNRmin(flagChannel532Cro)) | (nanrunmedian(squeeze(SNR(flagChannel532Tot, :, :)), config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot)) < config.mask_SNRmin(flagChannel532Tot))) = 1;
quality_mask_355(:, data.depCalMask) = 2;
quality_mask_355(:, data.depCalMask) = 2;
quality_mask_532(:, data.depCalMask) = 2;
quality_mask_1064(:, data.depCalMask) = 2;
quality_mask_voldepol(:, data.depCalMask) = 2;

% smooth the data
att_beta_355 = smooth2(data.att_beta_355, config.quasi_smooth_h(flagChannel355), config.quasi_smooth_t(flagChannel355));
att_beta_532 = smooth2(data.att_beta_532, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));
att_beta_1064 = smooth2(data.att_beta_1064, config.quasi_smooth_h(flagChannel1064), config.quasi_smooth_t(flagChannel1064));
volDepol_532_smooth = smooth2(volDepol_532, config.quasi_smooth_h(flagChannel532Cro), config.quasi_smooth_t(flagChannel532Cro));

% set low-SNR data or calibration data to NaN
att_beta_355(quality_mask_355 > 0) = NaN;
att_beta_532(quality_mask_532 > 0) = NaN;
att_beta_1064(quality_mask_1064 > 0) = NaN;
volDepol_532_smooth(quality_mask_voldepol > 0) = NaN;

%% quasi retrieving
% redistribute the meteorological data to 30-s intervals.
[molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri] = repmat_molscatter(data.mTime, data.alt, config.gdas1site, processInfo.gdas1_folder);

% molecule attenuation
mol_att_355 = exp(- cumsum(molExt355 .* repmat(transpose([data.height, diff(data.height)]), numel(data.height), numel(data.mTime))));
mol_att_532 = exp(- cumsum(molExt532 .* repmat(transpose([data.height, diff(data.height)]), numel(data.height), numel(data.mTime))));
mol_att_1064 = exp(- cumsum(molExt1064 .* repmat(transpose([data.height, diff(data.height)]), numel(data.height), numel(data.mTime))));

% correct calibration backscatter
corr_beta_355 = data.att_beta_355 ./ mol_att_355.^2;
corr_beta_532 = data.att_beta_532 ./ mol_att_532.^2;
corr_beta_1064 = data.att_beta_1064 ./ mol_att_1064.^2;

% quasi particle backscatter and extinction coefficents
[quasi_par_bsc_355, quasi_par_ext_355] = quasi_retrieving(data.height, data.att_beta_355, molExt355, molBsc355, config.LR355);
[quasi_par_bsc_532, quasi_par_ext_532] = quasi_retrieving(data.height, data.att_beta_532, molExt532, molBsc532, config.LR532);
[quasi_par_bsc_1064, quasi_par_ext_1064] = quasi_retrieving(data.height, data.att_beta_1064, molExt1064, molBsc1064, config.LR1064);

% quasi particle depolarization ratio and Ångström exponents
quasi_par_depol_532 = (volDepol_532 + 1) ./ (molBsc532 .* (defaults.molDepol532 - volDepol_532) ./ (quasi_par_bsc_532 .* (1 + defaults.molDepol532)) + 1) - 1;
quasi_ang_355_532 = log(quasi_par_bsc_532 ./ quasi_par_bsc_355) ./ log(355/532);
quasi_ang_532_1064 = log(quasi_par_bsc_1064 ./ quasi_par_bsc_532) ./ log(532/1064);
quasi_ang_355_1064 = log(quasi_par_bsc_1064 ./ quasi_par_bsc_355) ./ log(355/1064);

end