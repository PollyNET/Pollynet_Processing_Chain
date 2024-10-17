function [volDepol, volDepolStd] = pollyVDRGHK(sigTot, sigCross, ...
    GT, GR,HT,HR, eta, voldepol_error_a0,voldepol_error_a1,voldepol_error_a2, smoothWindow, ...
    flagSmoothBefore)
% POLLYVDR calculate volume depolarization ratio using GHK parameters.
%
% USAGE:
%    [volDepol, volDepolStd] = pollyVDRGHK(sigTot, bgTot, sigCross, bgCross, GT, GR,HT,HR, eta, voldep_sys_uncertainty, smoothWindow)
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
%    GT: scalar
%        G parameter in total channel
%    GR: scalar
%        G parameter in cross channel
%    HT: scalar
%        H parameter in total channel
%    HR: scalar
%        H parameter in cross channel
%    voldep_sys_uncertainty: scalar
%        systematic uncertainty of the volume depolarization ratio (in
%        future it should be given in the config file)
%    eta: scalar
%        depolarzation calibration constant. 
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
%    Freudenthaler, V. About the effects of polarising optics on lidar signals and the Delta90 calibration. Atmos. Meas. Tech., 9, 4181–4255 (2016).
%
% HISTORY:
%    - 2018-09-02: First edition by Zhenping
%    - 2018-09-04: Change the smoothing order. Smoothing the signal ratio instead of smoothing the signal.
%    - 2019-05-24: Add 'flagSmoothBefore' to control the smoothing order.
%    - 2024-08-13: MH: Change calculation to GHK parameters and eta as depolarization constant. 
%
% .. Authors: - zhenping@tropos.de, haarig@tropos.de

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

%sigCrossStd = signalStd(sigCross, bgCross, smoothWindow, 2);
%sigTotStd = signalStd(sigTot, bgTot, smoothWindow, 2);

%volDepol = (1 - sigRatio ./ depolConst) ./ (sigRatio * Rt / depolConst - Rc);
volDepol = (sigRatio ./ eta * (GT + HT) - (GR + HR)) ./ ((GR - HR) - sigRatio ./eta * (GT - HT));
% Systematic uncertainty of the volume depolarization, coefficients given in config file,
% coefficients according to Volker's GHK script (positive branch)
volDepolStd = voldepol_error_a0 + voldepol_error_a1 .* volDepol + voldepol_error_a2 .* volDepol.^2;
% volDepolStd = (sigRatio .* (Rt - Rc) ./ ...
%               (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
%                depolConstStd.^2 + ...
%                (depolConst .* (Rc - Rt) ./ ...
%                (sigRatio .* Rt - depolConst .* Rc).^2).^2 .* ...
%                (sigTotStd .* sigCross.^2 ./ sigTot.^4 + ...
%                sigCrossStd ./ sigTot.^2);

end