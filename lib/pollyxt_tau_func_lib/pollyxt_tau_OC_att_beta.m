function [att_beta_355, att_beta_532, att_beta_1064, att_beta_387, att_beta_607] = pollyxt_tau_OC_att_beta(data, config)
%pollyxt_tau_OC_att_beta Calculate the overlap corrected attenuated backscatter.
%   Example:
%       [att_beta_355, att_beta_532, att_beta_1064, att_beta_387, att_beta_607] = pollyxt_tau_OC_att_beta(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       att_beta_355: matrix
%           attenuated backscatter at 355 nm. [m^{-1}Sr^{-1}] 
%       att_beta_532: matrix
%           attenuated backscatter at 532 nm. [m^{-1}Sr^{-1}] 
%       att_beta_1064: matrix
%           attenuated backscatter at 1064 nm. [m^{-1}Sr^{-1}] 
%       att_beta_387: matrix
%           attenuated backscatter at 387 nm. [m^{-1}Sr^{-1}] 
%           Note: the differential molecular Raman backscatter cross section was replaced with differential molecular Rayleigh cross section at the same wavelength.
%       att_beta_607: matrix
%           attenuated backscatter at 607 nm. [m^{-1}Sr^{-1}] 
%           Note: the differential molecular Raman backscatter cross section was replaced with differential molecular Rayleigh cross section at the same wavelength.
%   History:
%       2019-11-27. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

att_beta_355 = [];
att_beta_532 = [];
att_beta_1064 = [];
att_beta_387 = [];
att_beta_607 = [];

if isempty(data.rawSignal)
    return;
end

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel387 = config.isFR & config.is387nm;
flagChannel607 = config.isFR & config.is607nm;

RCS355 = data.signal355OverlapCor .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS355(:, data.depCalMask) = NaN;
RCS532 = data.signal532OverlapCor .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS532(:, data.depCalMask) = NaN;
RCS1064 = data.signal1064OverlapCor .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS1064(:, data.depCalMask) = NaN;
RCS387 = data.signal387OverlapCor .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS387(:, data.depCalMask) = NaN;
RCS607 = data.signal607OverlapCor .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS607(:, data.depCalMask) = NaN;

att_beta_355 = RCS355 ./ repmat(data.LCUsed.LCUsed355, numel(data.height), numel(data.mTime));
att_beta_532 = RCS532 ./ repmat(data.LCUsed.LCUsed532, numel(data.height), numel(data.mTime));
att_beta_1064 = RCS1064 ./ repmat(data.LCUsed.LCUsed1064, numel(data.height), numel(data.mTime));
att_beta_387 = RCS387 ./ repmat(data.LCUsed.LCUsed387, numel(data.height), numel(data.mTime));
att_beta_607 = RCS607 ./ repmat(data.LCUsed.LCUsed607, numel(data.height), numel(data.mTime));

end