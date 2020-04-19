function [volDepol, volDepolStd] = polly_volDepol(sigTot, bgTot, sigCross, ...
    bgCross, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, smoothWindow, ...
    flagSmoothBefore)
%POLLY_VOLDEPOL calculate the volume depolarization ratio for pollyXT system.
%   Example:
%       [volDepol, volDepolStd] = polly_volDepol(sigTot, bgTot, sigCross, 
%       bgCross, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, smoothWindow)
%   Inputs:
%       sigTot: array
%           signal strength of the total channel. [photon count]
%       bgTot: array
%           background of the total channel. [photon count]
%       sigCross: array
%           signal strength of the cross channel. [photon count]
%       bgCross: array
%           background of the cross channel. [photon count]
%       Rt: scalar
%           transmission ratio in total channel
%       RtStd: scalar
%           uncertainty of the transmission ratio in total channel
%       Rc: scalar
%           transmission ratio in cross channel
%       RcStd: scalar
%           uncertainty of the transmission ratio in cross channel
%       depolConst: scalar
%           depolarzation calibration constant. (transmission ratio for the 
%           parallel component in cross channel and total channel)
%       depolConstStd: scalar
%           uncertainty of the depolarization calibration constant.
%       smoothWindow: scalar or m*3 matrix
%           the width of the sliding smoothing window for the signal.
%       flagSmoothBefore: logical
%           flag to control the vol-depol smoothing whether before or after the 
%           signal ratio.
%   Outputs:
%       volDepol: array
%           volume depolarization ratio.
%       volDepolStd: array
%           uncertainty of the volume depolarization ratio
%   Reference:
%       instrumentation info about PollyXT can be found in 
%       (R.Engelmann et al, AMT, 2016) and deduction about volume 
%       depolarization calculation can be found in (Freudenthaler et al,
%       Tellus B, 2009)
%   History:
%       2018-09-02. First edition by Zhenping
%       2018-09-04. Change the smoothing order. Smoothing the signal ratio 
%       instead of smoothing the signal.
%       2019-05-24. Add 'flagSmoothBefore' to control the smoothing order.
%   Contact:
%       zhenping@tropos.de
    
if ~ exist('smoothWindow', 'var')
    smoothWindow = 1;
end

if ~ exist('flagSmoothBefore', 'var')
    flagSmoothBefore = true;
end

if flagSmoothBefore
    sigRatio = transpose(smoothWin(sigCross, smoothWindow) ./ ...
                         smoothWin(sigTot, smoothWindow));
else
    sigRatio = transpose(smoothWin(sigCross ./ sigTot, smoothWindow));
end

sigCrossStd = signalStd(sigCross, bgCross, smoothWindow, 2);
sigTotStd = signalStd(sigTot, bgTot, smoothWindow, 2);

volDepol = (1 - sigRatio ./ depolConst) ./ (sigRatio * Rt / depolConst - Rc);
% TODO:
%   1. taking into account of the uncertainty of Rt, Rc
volDepolStd = (sigRatio .* (Rt - Rc) ./ ...
              (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
               depolConstStd.^2 + ...
               (depolConst .* (Rc - Rt) ./ ...
               (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
               (sigTotStd .* sigCross.^2 ./ sigTot.^4 + ...
               sigCrossStd ./ sigTot.^2);

end