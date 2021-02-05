function [molDepol, molDepolStd, flagDefault] = polly_molDepol(sigTot, bgTot, sigCro, bgCro, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, minSNR, defaultMolDepol, defaultMolDepolStd)
%POLLY_MOLDEPOL etimate the molecular depolarization ratio according to the 
%measurements at reference height.
%Example:
%   [molDepol, molDepolStd, flagDefault] = polly_molDepol(sigTot, bgTot, ...
%   sigCro, bgCro, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, ...
%   minSNR, defaultMolDepol, defaultMolDepolStd)
%Inputs:
%   sigTot: array
%       signal strength of the total channel at reference height. 
%       [photon count]
%   bgTot: array
%       background of the total channel at reference height. [photon count]
%   sigCross: array
%       signal strength of the cross channel at reference height. 
%       [photon count]
%   bgCross: array
%       background of the cross channel at reference height. [photon count]
%   Rt: scalar
%       transmission ratio in total channel
%   RtStd: scalar
%       uncertainty of the transmission ratio in total channel
%   Rc: scalar
%       transmission ratio in cross channel
%   RcStd: scalar
%       uncertainty of the transmission ratio in cross channel
%   depolConst: scalar
%       depolarzation calibration constant. (transmission ratio for the 
%       parallel component in cross channel and total channel)
%   depolConstStd: scalar
%       uncertainty of the depolarization calibration constant.
%   minSNR: float
%       the SNR constrain for the the signal strength at reference height. 
%       Choose a strong constrain for ensuring a stable result, 
%       like 50 or 100.
%   defaultMolDepol: float
%       default molecular depolarization ratio. Detailed information 
%       please go to doc/polly_defaults.md
%   defaultMolDepolStd: float
%       default std of molecular depolarization ratio. Detailed 
%       information please go to doc/polly_defaults.md
%Outputs:
%   molDepol: float
%       retrieved molecular depolarization ratio. 
%   molDepolStd: float
%       std of retrieved molecular depolarization ratio. 
%   flagDefault: logical
%       flag to show whether using the default values. If true, 
%       it means default molDepol and molDepolStd were used.
%History:
%   2018-12-24. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

molDepol = defaultMolDepol;
molDepolStd = defaultMolDepolStd;
flagDefault = true;

snrTot = polly_SNR(sum(sigTot), sum(bgTot));
snrCro = polly_SNR(sum(sigCro), sum(bgCro));

flagValidPointTot = snrTot >= minSNR;
flagValidPointCro = snrCro >= minSNR;

if (~ flagValidPointCro) || (~ flagValidPointTot)
    fprintf(['Too noisy in the reference height to calculate ' ...
             'the molecular depol ratio.\n']);
    return;
end

[molDepol, molDepolStd] = polly_volDepol(sum(sigTot), sum(bgTot), ...
                                         sum(sigCro), sum(bgCro), ...
                                         Rt, RtStd, Rc, RcStd, depolConst, ...
                                         depolConstStd, 1);
flagDefault = false;

end