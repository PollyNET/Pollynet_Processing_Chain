function [volDepol, volDepolStd] = pollyVDR(sigTot, bgTot, sigCross, ...
    bgCross, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, smoothWindow, ...
    flagSmoothBefore)
% POLLYVDR calculate volume depolarization ratio.
%
% USAGE:
%    [volDepol, volDepolStd] = pollyVDR(sigTot, bgTot, sigCross, bgCross, Rt, RtStd, Rc, RcStd, depolConst, depolConstStd, smoothWindow)
%
% INPUTS:
%    sigTot: array
%        signal strength of the total channel. [photon count]
%    bgTot: array
%        background of the total channel. [photon count]
%    sigCross: array
%        signal strength of the cross channel. [photon count]
%    bgCross: array
%        background of the cross channel. [photon count]
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
%    smoothWindow: scalar or m*3 matrix
%        the width of the sliding smoothing window for the signal.
%    flagSmoothBefore: logical
%        flag to control the vol-depol smoothing whether before or after the 
%        signal ratio.
%
% OUTPUTS:
%    volDepol: array
%        volume depolarization ratio.
%    volDepolStd: array
%        uncertainty of the volume depolarization ratio
%
% REFERENCE:
%    Engelmann, R. et al. The automated multiwavelength Raman polarization and water-vapor lidar Polly XT: the neXT generation. Atmospheric Measurement Techniques 9, 1767-1784 (2016).
%    Freudenthaler, V. et al. Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006. Tellus B 61, 165-179 (2009).
%
% HISTORY:
%    - 2018-09-02: First edition by Zhenping
%    - 2018-09-04: Change the smoothing order. Smoothing the signal ratio instead of smoothing the signal.
%    - 2019-05-24: Add 'flagSmoothBefore' to control the smoothing order.
%
% .. Authors: - zhenping@tropos.de

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
%1. taking into account of the uncertainty of Rt, Rc
volDepolStd = (sigRatio .* (Rt - Rc) ./ ...
              (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
               depolConstStd.^2 + ...
               (depolConst .* (Rc - Rt) ./ ...
               (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
               (sigTotStd .* sigCross.^2 ./ sigTot.^4 + ...
               sigCrossStd ./ sigTot.^2);

end