function [MDR, MDRStd, flagDeft] = pollyMDRGHK(sigT, bgT, sigC, bgC, flagT,flagC, eta, voldep_sys_uncertainty, minSNR, deftMDR, deftMDRStd, PollyConfig)
% POLLYMDR etimate the molecular depolarization ratio according to the measurements at reference height.
%
% USAGE:
%    [MDR, MDRStd, flagDeft] = pollyMDR(sigT, bgT, ...
%    sigC, bgC, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, ...
%    minSNR, deftMDR, deftMDRStd)
%
% INPUTS:
%    sigT: array
%        signal strength of the total channel at reference height. 
%        [photon count]
%    bgT: array
%        background of the total channel at reference height. [photon count]
%    sigCross: array
%        signal strength of the cross channel at reference height. 
%        [photon count]
%    bgCross: array
%        background of the cross channel at reference height. [photon count]
%    Rt: scalar
%        transmission ratio in total channel
%    RtStd: scalar
%        uncertainty of the transmission ratio in total channel
%    Rc: scalar
%        transmission ratio in cross channel
%    RcStd: scalar
%        uncertainty of the transmission ratio in cross channel
%    depolConst: scalar
%        depolarzation calibration constant. (transmission ratio for the 
%        parallel component in cross channel and total channel)
%    depolConstStd: scalar
%        uncertainty of the depolarization calibration constant.
%    minSNR: float
%        the SNR constrain for the the signal strength at reference height. 
%        Choose a strong constrain for ensuring a stable result, 
%        like 50 or 100.
%    deftMDR: float
%        default molecular depolarization ratio.
%    deftMDRStd: float
%        default std of molecular depolarization ratio.
%
% OUTPUTS:
%    MDR: float
%        retrieved molecular depolarization ratio. 
%    MDRStd: float
%        std of retrieved molecular depolarization ratio. 
%    flagDeft: logical
%        flag to show whether using the default values. If true, 
%        it means default MDR and MDRStd were used.
%
% HISTORY:
%    - 2021-05-31: first edition by Zhenping
%    - 2024-08-13: MH changed to GHK
%
% .. Authors: - zhenping@tropos.de, haarig@tropos.de

MDR = deftMDR;
MDRStd = deftMDRStd;
flagDeft = true;

snrTot = pollySNR(sum(sigT), sum(bgT));
snrCro = pollySNR(sum(sigC), sum(bgC));

flagValidPointTot = (snrTot >= minSNR);
flagValidPointCro = (snrCro >= minSNR);

if (~ flagValidPointCro) || (~ flagValidPointTot)
    fprintf(['Too noisy in the reference height to calculate ' ...
             'the molecular depol ratio.\n']);
    return;
end

[MDR, MDRStd] = pollyVDRGHK(sum(sigT), sum(sigC), ...
                            PollyConfig.G(flagT), PollyConfig.G(flagC), ...
                            PollyConfig.H(flagT), PollyConfig.H(flagC), ...
                            eta, voldep_sys_uncertainty, 1);
flagDeft = false;

end