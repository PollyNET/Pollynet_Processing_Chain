function [depolCaliFactor, depolCaliFactorStd] = polly_molDepolCali(tSig, bgTSig, cSig, bgCSig, TR_t, TR_t_std, TR_c, TR_c_std, minSNR, molDepol, molDepolStd)
%POLLY_MOLDEPOLCALI molecular depolarization calibration.
%Example:
%   [depolCaliFactor, depolCaliFactorStd] = polly_molDepolCali(tSig, bgTSig, 
%       cSig, bgCSig, TR_t, TR_t_std, TR_c, TR_c_std, minSNR, molDepol, 
%       molDepolStd)
%Inputs:
%   tSig: numeric
%       total signal. (photon count)
%   bgTSig: numeric
%       background at total channel. (photon count) 
%   cSig: numeric
%       cross signal. (photon count)
%   bgCSig: numeric
%       background at cross channel. (photon count)
%   TR_t: scalar
%       transmission ratio at total channel
%   TR_t_std: scalar
%       uncertainty of the transmission ratio at total channel
%   TR_c: scalar
%       transmission ratio at cross channel
%   TR_c_std: scalar
%       uncertainty of the transmission ratio at cross channel.
%   minSNR: float
%       the SNR constrain for the the signal strength at reference height. 
%       Choose a strong constrain for ensuring a stable result, 
%       like 50 or 100.
%   molDepol: float
%       default molecular depolarization ratio. Detailed information 
%       please go to doc/polly_defaults.md
%   molDepolStd: float
%       default std of molecular depolarization ratio. Detailed 
%       information please go to doc/polly_defaults.md
%Outputs:
%   depolCaliFactor: depolCaliFactorStd
%Reference:
%   H. Baars, PhD thesis, 2012.
%History:
%   2021-02-03. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

depolCaliFactor = [];
depolCaliFactorStd = [];

SNR_TSig = polly_SNR(sum(tSig), sum(bgTSig));
SNR_CSig = polly_SNR(sum(cSig), sum(bgCSig));

flagValidTSig = (SNR_TSig >= minSNR);
flagValidCSig = (SNR_CSig >= minSNR);

if (~ flagValidTSig) || (~ flagValidCSig)
    fprintf('Too noisy at the reference height to enable molecular depolarization calibration.\n');
    return;
end

sumTSig = sum(tSig);
sumTBG = sum(bgTSig);
sumCSig = sum(cSig);
sumCBG = sum(bgCSig);
stdTSig = sqrt(sumTSig + sumTBG);
stdCSig = sqrt(sumCSig + sumCBG);

depolCaliFactor = (sumCSig ./ sumTSig) .* (1 + molDepol .* TR_t) ./ (1 + molDepol .* TR_c);

depolCaliFactorFunc = @(x) (x ./ sumCSig) .* (1 + molDepol .* TR_t) ./ (1 + molDepol .* TR_c);
deriv_depolCali_tSig = (depolCaliFactorFunc(sumTSig * 1.01) - depolCaliFactorFunc(sumTSig)) ./ (0.01 .* sumTSig);

depolCaliFactorFunc = @(x) (sumTSig ./ x) .* (1 + molDepol .* TR_t) ./ (1 + molDepol .* TR_c);
deriv_depolCali_cSig = (depolCaliFactorFunc(sumCSig * 1.01) - depolCaliFactorFunc(sumCSig)) ./ (0.01 .* sumCSig);

depolCaliFactorFunc = @(x) (sumTSig ./ sumCSig) .* (1 + x .* TR_t) ./ (1 + x .* TR_c);
deriv_depolCali_molDepol = (depolCaliFactorFunc(molDepol + 0.0005) - depolCaliFactorFunc(molDepol)) ./ 0.0005;

depolCaliFactorStd = sqrt(deriv_depolCali_tSig.^2 .* stdTSig.^2 + ...
                          deriv_depolCali_cSig.^2 .* stdCSig.^2 + ...
                          deriv_depolCali_molDepol.^2 .* molDepolStd.^2);

end