function [att_beta_NR_355, att_beta_NR_532, ...
          att_beta_NR_387, att_beta_NR_607] = pollyxt_att_beta_NF(data, config)
%POLLYXT_ATT_BETA Calculate the attenuated backscatter.
%Example:
%   [att_beta_355, att_beta_532, att_beta_1064, att_beta_387,
%    att_beta_607] = pollyxt_att_beta(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%Outputs:
%   att_beta_355: matrix
%       attenuated backscatter at 355 nm. [m^{-1}Sr^{-1}] 
%   att_beta_532: matrix
%       attenuated backscatter at 532 nm. [m^{-1}Sr^{-1}] 
%   att_beta_1064: matrix
%       attenuated backscatter at 1064 nm. [m^{-1}Sr^{-1}] 
%   att_beta_387: matrix
%       attenuated backscatter at 387 nm. [m^{-1}Sr^{-1}] 
%       Note: the differential molecular Raman backscatter cross section was
%             replaced with differential molecular Rayleigh cross section at
%             the same wavelength.
%   att_beta_607: matrix
%       attenuated backscatter at 607 nm. [m^{-1}Sr^{-1}] 
%       Note: the differential molecular Raman backscatter cross section was
%             replaced with differential molecular Rayleigh cross section at
%             the same wavelength.
%History:
%   2018-12-24. First Edition by Zhenping
%   2019-08-03. Add 'att_beta_387' and 'att_beta_607'
%Contact:
%   zhenping@tropos.de

att_beta_NR_355 = [];
att_beta_NR_532 = [];
att_beta_NR_387 = [];
att_beta_NR_607 = [];

if isempty(data.rawSignal)
    return;
end

flagChannel355_NR = config.isNR & config.is355nm & config.isTot;
flagChannel532_NR = config.isNR & config.is532nm & config.isTot;
flagChannel387_NR = config.isNR & config.is387nm;
flagChannel607_NR = config.isNR & config.is607nm;

RCS355_NR = squeeze(data.signal(flagChannel355_NR, :, :)) .* ...
         repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS355_NR(:, data.depCalMask) = NaN;
RCS532_NR = squeeze(data.signal(flagChannel532_NR, :, :)) .* ...
         repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS532_NR(:, data.depCalMask) = NaN;
RCS387_NR = squeeze(data.signal(flagChannel387_NR, :, :)) .* ...
         repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS387_NR(:, data.depCalMask) = NaN;
RCS607_NR = squeeze(data.signal(flagChannel607_NR, :, :)) .* ...
         repmat(transpose(data.height), 1, numel(data.mTime)).^2;
RCS607_NR(:, data.depCalMask) = NaN;

att_beta_NR_355 = RCS355_NR ./ ...
    repmat(data.LCUsed.LCUsed355, numel(data.height), numel(data.mTime));
att_beta_NR_532 = RCS532_NR ./ ...
    repmat(data.LCUsed.LCUsed532, numel(data.height), numel(data.mTime));
att_beta_NR_387 = RCS387_NR ./ ...
    repmat(data.LCUsed.LCUsed387, numel(data.height), numel(data.mTime));
att_beta_NR_607 = RCS607_NR ./ ...
    repmat(data.LCUsed.LCUsed607, numel(data.height), numel(data.mTime));

end