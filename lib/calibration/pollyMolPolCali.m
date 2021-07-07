function [polCaliEta, polCaliEtaStd, polCaliFac, polCaliFacStd] = pollyMolPolCali(tSig, bgTSig, cSig, bgCSig, TR_t, TR_t_std, TR_c, TR_c_std, minSNR, mdr, mdrStd)
% POLLYMOLPOLCALI molecular polarization calibration.
% USAGE:
%    [polCaliEta, polCaliEtaStd, polCaliFac, polCaliFacStd] = pollyMolPolCali(tSig, bgTSig, cSig, bgCSig, TR_t, TR_t_std, TR_c, TR_c_std, minSNR, mdr, mdrStd)
% INPUTS:
%    tSig: numeric
%        total signal. (photon count)
%    bgTSig: numeric
%        background at total channel. (photon count) 
%    cSig: numeric
%        cross signal. (photon count)
%    bgCSig: numeric
%        background at cross channel. (photon count)
%    TR_t: scalar
%        transmission ratio at total channel
%    TR_t_std: scalar
%        uncertainty of the transmission ratio at total channel
%    TR_c: scalar
%        transmission ratio at cross channel
%    TR_c_std: scalar
%        uncertainty of the transmission ratio at cross channel.
%    minSNR: float
%        the SNR constrain for the the signal strength at reference height. 
%        Choose a strong constrain for ensuring a stable result, 
%        like 50 or 100.
%    mdr: float
%        default molecular depolarization ratio.
%    mdrStd: float
%        default std of molecular depolarization ratio.
% OUTPUTS:
%    polCaliEta: array
%        polarization calibration eta.
%    polCaliEtaStd: array
%        uncertainty of polarization calibration eta.
%    polCaliFac: array
%        polarization calibration factor.
%    polCaliFacStd: array
%        uncertainty of polarization calibration factor.
% REFERENCES:
%    Baars, H., Ansmann, A., Althausen, D., Engelmann, R., Heese, B., Muller, D., Artaxo, P., Paixao, M., Pauliquevis, T., and Souza, R.: Aerosol profiling with lidar in the Amazon Basin during the wet and dry season, J Geophys Res-Atmos, 117, 10.1029/2012jd018338, 2012.
% HISTORY:
%    2021-07-06: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

polCaliEta = [];
polCaliEtaStd = [];
polCaliFac = [];
polCaliFacStd = [];

SNR_TSig = pollySNR(sum(tSig), sum(bgTSig));
SNR_CSig = pollySNR(sum(cSig), sum(bgCSig));

flagValidTSig = (SNR_TSig >= minSNR);
flagValidCSig = (SNR_CSig >= minSNR);

if (~ flagValidTSig) || (~ flagValidCSig)
    fprintf('Too noisy at the reference height to enable molecular polarization calibration.\n');
    return;
end

sumTSig = sum(tSig);
sumTBG = sum(bgTSig);
sumCSig = sum(cSig);
sumCBG = sum(bgCSig);
stdTSig = sqrt(sumTSig + sumTBG);
stdCSig = sqrt(sumCSig + sumCBG);

polCaliFacFunc = @(x) (x ./ sumCSig) .* (1 + mdr .* TR_t) ./ (1 + mdr .* TR_c);
deriv_depolCali_tSig = (polCaliFacFunc(sumTSig * 1.01) - polCaliFacFunc(sumTSig)) ./ (0.01 .* sumTSig);

polCaliFacFunc = @(x) (sumTSig ./ x) .* (1 + mdr .* TR_t) ./ (1 + mdr .* TR_c);
deriv_depolCali_cSig = (polCaliFacFunc(sumCSig * 1.01) - polCaliFacFunc(sumCSig)) ./ (0.01 .* sumCSig);

polCaliFacFunc = @(x) (sumTSig ./ sumCSig) .* (1 + x .* TR_t) ./ (1 + x .* TR_c);
deriv_depolCali_mdr = (polCaliFacFunc(mdr + 0.0005) - polCaliFacFunc(mdr)) ./ 0.0005;

polCaliFac = (sumCSig ./ sumTSig) .* (1 + mdr .* TR_t) ./ (1 + mdr .* TR_c);
polCaliFacStd = sqrt(deriv_depolCali_tSig.^2 .* stdTSig.^2 + ...
                     deriv_depolCali_cSig.^2 .* stdCSig.^2 + ...
                     deriv_depolCali_mdr.^2 .* mdrStd.^2);
polCaliEta = polCaliFac .* (1 + TR_c) ./ (1 + TR_t);
polCaliEtaStd = polCaliFacStd .* (1 + TR_c) ./ (1 + TR_t);

end