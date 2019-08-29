function [att_beta_532, att_beta_607] = polly_1v2_att_beta(data, config)
%polly_1v2_att_beta Calculate the attenuated backscatter.
%   Example:
%       [att_beta_532, att_beta_607] = polly_1v2_att_beta(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       att_beta_532: matrix
%           attenuated backscatter at 532 nm. [m^{-1}Sr^{-1}] 
%       att_beta_607: matrix
%           attenuated backscatter at 607 nm. [m^{-1}Sr^{-1}] 
%           Note: the differential molecular Raman backscatter cross section was replaced with differential molecular Rayleigh cross section at the same wavelength.
%   History:
%       2018-12-24. First Edition by Zhenping
%       2019-08-04. Add 'att_beta_387' and 'att_beta_607'
%   Contact:
%       zhenping@tropos.de

att_beta_532 = [];
att_beta_607 = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel607 = config.isFR & config.is607nm;

RCS532 = squeeze(data.signal(flagChannel532, :, :)) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS532(:, data.depCalMask) = NaN;
RCS607 = squeeze(data.signal(flagChannel607, :, :)) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS607(:, data.depCalMask) = NaN;

att_beta_532 = RCS532 ./ repmat(data.LCUsed.LCUsed532, numel(data.height), numel(data.mTime));
att_beta_607 = RCS607 ./ repmat(data.LCUsed.LCUsed607, numel(data.height), numel(data.mTime));

end