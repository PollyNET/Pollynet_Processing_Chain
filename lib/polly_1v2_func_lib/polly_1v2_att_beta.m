function [att_beta_532] = polly_1v2_att_beta(data, config)
%polly_1v2_att_beta Calculate the attenuated backscatter.
%   Example:
%       [att_beta_532] = polly_1v2_att_beta(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       att_beta_532: matrix
%           attenuated backscatter at 532 nm. [m^{-1}Sr^{-1}] 
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

att_beta_532 = [];

if isempty(data.rawSignal)
    return;
end

flagChannel532 = config.isFR & config.is532nm & config.isTot;

RCS532 = squeeze(data.signal(flagChannel532, :, :)) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS532(:, data.depCalMask) = NaN;

att_beta_532 = RCS532 ./ repmat(data.LCUsed.LCUsed532, numel(data.height), numel(data.mTime));

end