function [sigTotCor, bgTotCor, sigTotCorStd] = polly_trans_correct(sigTot, ...
    bgTot, sigCross, bgCross, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd)
%POLLY_TRANS_CORRECT correct the effect of different transmission inside the 
%Tot and depol channel.
%Example:
%   [sigTotCor, sigTotCorStd] = Polly_trans_correct(sigEl, sigCross, Rt, 
%   RtStd, Rc, RcStd, depolConst, depolConstStd)
%Inputs:
%   sigTot: array
%       signal in total channel.
%   bgTot: array
%       background in total channel.
%   sigCross: array
%       signal in cross channel.
%   bgCross: array
%       background in total channel.
%   Rt: float
%       transmission ratio of perpendicular and parallel component in 
%       total channel.
%   RtStd: float
%       uncertainty of the transmission ratio of perpendicular and 
%       parallel componnet in total channel.
%   Rc: float
%       transmission ratio of perpendicular and parallel component in 
%       cross channel.
%   RcStd: float
%       uncertainty of the transmission ratio of perpendicular and 
%       parallel componnet in total channel.
%   depolConst: float
%       depolarization calibration constant.
%   depolConstStd: float
%       uncertainty of the depolarization calibration constant.
%Outputs:
%   sigTotCor: array
%       transmission corrected elastic signal.
%   bgTotCor: array
%       background of transmission corrected elastic signal.
%   sigTotCorStd: array
%       uncertainty of transmission corrected elastic signal.
%References:
%   Mattis, I., Tesche, M., Grein, M., Freudenthaler, V., and Müller, D.:
%   Systematic error of lidar profiles caused by a polarization-dependent
%   receiver transmission: Quantification and error correction scheme,
%   Appl. Opt., 48, 2742-2751, 2009.
%History:
%   2018-08-23. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

if ~ isequal(size(sigTot), size(sigCross))
    error('input signals have different size.')
end

% uncertainty caused by RcStd and RtStd is neglected because usually it
% is very small. 
sigTotCor = (Rc - 1)/(Rc - Rt) .* sigTot + ...
            (1 - Rt)/(Rc - Rt) ./ depolConst .* sigCross;
bgTotCor = (Rc - 1)/(Rc - Rt) .* bgTot + ...
           (1 - Rt)/(Rc - Rt) ./ depolConst .* bgCross;
sigTotCorVar = (sigCross ./ depolConst.^2 * (1-Rt) / (Rc-Rt)).^2 .* ...
                depolConstStd.^2 + ((Rc - 1) / (Rc - Rt)).^2 .* ...
                (sigTot + bgTot) + ((1 - Rt) ./ ...
                (depolConst * (Rc - Rt))).^2 .* (sigCross + bgCross);

sigTotCorVar(sigTotCorVar < 0) = 0;   % convert non-negative
sigTotCorStd = sqrt(sigTotCorVar);   % TODO

end