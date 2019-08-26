function [el532, bgEl532] = pollyxt_ift_transratioCor(data, config)
%pollyxt_ift_transratioCor correct the effects of non-ideal transmission ratio in total channel to retrieve the real elastic signal.
%   Example:
%       [el532, bgEl532] = pollyxt_ift_transratioCor(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       el532: matrix
%           elastic signal with transmission ratio correction.
%       bgEl532: matrix
%           background elastic signal with transmission ratio correction.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

el532 = NaN(size(data.signal, 2), size(data.signal, 3));
bgEl532 = NaN(size(data.signal, 2), size(data.signal, 3));

if isempty(data.rawSignal)
    return;
end

%% 532 nm
flagChannel532 = config.is532nm & config.isTot & config.isFR;
flagChannel532Cross = config.is532nm & config.isCross & config.isFR;
[el532, bgEl532, ~] = polly_trans_correct(squeeze(data.signal(flagChannel532, :, :)), squeeze(data.bg(flagChannel532, :, :)), squeeze(data.signal(flagChannel532Cross, :, :)), squeeze(data.bg(flagChannel532Cross, :, :)), config.TR(flagChannel532), 0, config.TR(flagChannel532Cross), 0, data.depol_cal_fac_532, data.depol_cal_fac_std_532);

end