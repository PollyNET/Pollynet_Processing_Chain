function [quasi_par_bsc_532, quasi_par_depol_532, volDepol_532, quality_mask_532, quality_mask_volDepol_532, quasiAttri] = polly_1v2_quasiretrieve(data, config)
%polly_1v2_quasiretrieve Retrieving the intensive aerosol optical properties with Quasi-retrieving method. Detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [quasi_par_bsc_532, quasi_par_bsc_1064, quasi_par_depol_532, volDepol_355, volDepol_532, quasi_ang_532_1064, quality_mask_355, quality_mask_532, quality_mask_1064, quality_mask_volDepol_355, quality_mask_volDepol_532] = polly_1v2_quasiretrieve(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       quasi_par_depol_532: matrix
%           quasi particle depolarization ratio at 532 nm.
%       volDepol_532: matrix
%           volume depolarization ratio at 532 nm.
%       quality_mask_532: matrix
%           quality mask for attenuated backscatter at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%       quality_mask_volDepol_532: matrix
%           quality mask for volume depolarization ratio at 532 nm. In which, 0 means good data, 1 means low-SNR data and 2 means depolarization calibration periods.
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo defaults

quasi_par_depol_532 = [];
volDepol_532 = [];
quality_mask_532 = [];
quality_mask_volDepol_532 = [];
quasiAttri = struct();
quasiAttri.flagGDAS1 = false;
quasiAttri.timestamp = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
flagChannel532Cro = config.isFR & config.is532nm & config.isCross;

%% calculate volDepol 532 and 355 nm
volDepol_532 = polly_volDepol2(squeeze(data.signal(flagChannel532Tot, :, :)), squeeze(data.signal(flagChannel532Cro, :, :)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);
volDepol_532(:, data.depCalMask) = NaN;

%% calculate the quality mask to filter the points with high SNR
quality_mask_532 = zeros(size(data.att_beta_532));
quality_mask_volDepol_532 = zeros(size(data.att_beta_532));

SNR = polly_SNR(data.signal, data.bg);

% 0 in quality_mask means good data
% 1 in quality_mask means low-SNR data
% 2 in quality_mask means depolarization calibration periods
quality_mask_532(squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot)) = 1;
quality_mask_voldepol_532((squeeze(SNR(flagChannel532Cro, :, :)) < config.mask_SNRmin(flagChannel532Cro)) | (squeeze(SNR(flagChannel532Tot, :, :)) < config.mask_SNRmin(flagChannel532Tot))) = 1;
quality_mask_532(:, data.depCalMask) = 2;
quality_mask_voldepol_532(:, data.depCalMask) = 2;

% smooth the data
att_beta_532 = smooth2(data.att_beta_532, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot));
sig532Tot = squeeze(data.signal(flagChannel532Tot, :, :));
sig532Tot(:, data.depCalMask) = NaN;
sig532Cro = squeeze(data.signal(flagChannel532Cro, :, :));
sig532Cro(:, data.depCalMask) = NaN;
volDepol_532_smooth = polly_volDepol2(smooth2(sig532Tot, config.quasi_smooth_h(flagChannel532Tot), config.quasi_smooth_t(flagChannel532Tot)), smooth2(sig532Cro, config.quasi_smooth_h(flagChannel532Cro), config.quasi_smooth_t(flagChannel532Cro)), config.TR(flagChannel532Tot), config.TR(flagChannel532Cro), data.depol_cal_fac_532);

% set low-SNR data or calibration data to NaN
att_beta_532(quality_mask_532 > 0) = NaN;
volDepol_532_smooth(quality_mask_voldepol_532 > 0) = NaN;

%% quasi retrieving
% redistribute the meteorological data to 30-s intervals.
[molBsc355, molExt355, molBsc532, molExt532, molBsc1064, molExt1064, globalAttri] = repmat_molscatter(data.mTime, data.alt, config);
quasiAttri.flagGDAS1 = strcmpi(globalAttri.source, 'gdas1');
quasiAttri.timestamp = globalAttri.datetime;

% molecule attenuation
mol_att_532 = exp(- cumsum(molExt532 .* repmat(transpose([data.height(1), diff(data.height)]), 1, numel(data.mTime))));

% set the attenuated signal below the full overlap to be constant.
fullOvlpIndx532 = find(data.height >= config.heightFullOverlap(flagChannel532Tot), 1);
if ~ isempty(fullOvlpIndx532)
    att_beta_532(1:fullOvlpIndx532, :) = repmat(att_beta_532(fullOvlpIndx532, :), fullOvlpIndx532, 1);
else
    warning('The full overlap height is too high. Please check the configuration file.');
end

% quasi particle backscatter and extinction coefficents
[quasi_par_bsc_532, quasi_par_ext_532] = quasi_retrieving(data.height, att_beta_532, molExt532, molBsc532, config.LR532, 6);

% quasi particle depolarization ratio and Ångström exponents
quasi_par_depol_532 = (volDepol_532_smooth + 1) ./ (molBsc532 .* (defaults.molDepol532 - volDepol_532_smooth) ./ (quasi_par_bsc_532 .* (1 + defaults.molDepol532)) + 1) - 1;

end