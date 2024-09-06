function [MDR, MDRStd, flagDeft] = pollyMDRGHK(sigT, bgT, sigC, bgC, flagT,flagC, eta, voldepol_error, minSNR, deftMDR, deftMDRStd, PollyConfig)
% POLLYMDR etimate the molecular depolarization ratio according to the measurements at reference height.
%
% USAGE:
%    [MDR, MDRStd, flagDeft] = pollyMDRGHK(sigT, bgT, ...
%    sigC, bgC, flagT,flagC, eta, voldep_sys_uncertainty, ...
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
%    flagT: 
%        flag the total channel for the respective wavelength.
%    flagC: 
%        flag the cross channel for the respective wavelength.
%    eta: scalar
%        depolarzation calibration constant. 
%    voldep_sys_uncertainty: scalar
%        systematic uncertainty of the volume depolarization ratio (in
%        future it should be given in the config file)
%    minSNR: float
%        the SNR constrain for the the signal strength at reference height. 
%        Choose a strong constrain for ensuring a stable result, 
%        like 50 or 100.
%    deftMDR: float
%        default molecular depolarization ratio.
%    deftMDRStd: float
%        default std of molecular depolarization ratio.
%    Polly.Config:
%        contains the GHK parameters for further calcualtions. 
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
                            eta, voldepol_error(1), voldepol_error(2), voldepol_error(3), 1);
flagDeft = false;

end