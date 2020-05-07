function [att_beta_NR_355, att_beta_NR_532] = pollyxt_NR_att_beta(data, config)
%POLLYXT_NR_ATT_BETA Calculate the attenuated backscatter.
%Example:
%   [att_beta_NR_355, att_beta_NR_532] = pollyxt_NR_att_beta(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%Outputs:
%   att_beta_NR_355: matrix
%       attenuated backscatter at 355 nm. [m^{-1}Sr^{-1}]
%   att_beta_NR_532: matrix
%       attenuated backscatter at 532 nm. [m^{-1}Sr^{-1}]
%History:
%   2002-05-07. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

att_beta_NR_355 = [];
att_beta_NR_532 = [];

if isempty(data.rawSignal)
return;
end

flagChannel355 = config.isNR & config.is355nm & config.isTot;
flagChannel532 = config.isNR & config.is532nm & config.isTot;

if any(flagChannel355)
    RCS355 = squeeze(data.signal(flagChannel355, :, :)) .* ...
        repmat(transpose(data.height), 1, numel(data.mTime)).^2;
        RCS355(:, data.depCalMask) = NaN;
    att_beta_NR_355 = RCS355 ./ ...
        repmat(data.LCUsed.LCUsed355, numel(data.height), numel(data.mTime));
else
    att_beta_NR_355 = NaN(numel(data.height), numel(data.mTime));
end

if any(flagChannel532)
    RCS532 = squeeze(data.signal(flagChannel532, :, :)) .* ...
        repmat(transpose(data.height), 1, numel(data.mTime)).^2;
        RCS532(:, data.depCalMask) = NaN;
    att_beta_NR_532 = RCS532 ./ ...
        repmat(data.LCUsed.LCUsed532, numel(data.height), numel(data.mTime));
else
    att_beta_NR_532 = NaN(numel(data.height), numel(data.mTime));
end

end