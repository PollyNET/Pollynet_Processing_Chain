function [volDepol] = pollyVDR2GHK(sigTot, sigCross, GT, GR, HT, HR, eta)
% POLLYVDR2 calculate 2-dimensional volume depolarization ratio for PollyXT
% system, which is used for the high resolution and quasi PDR products. 
%
% USAGE:
%    [volDepol] = pollyVDR2(sigTot, sigCross, Rt, Rc, depolConst)
%
% INPUTS:
%    sigTot: array
%        signal strength of the total channel. [photon count]
%    sigCross: array
%        signal strength of the cross channel. [photon count]
%    Rt: scalar
%        transmission ratio in total channel
%    Rc: scalar
%        transmission ratio in cross channel
%    depolConst: scalar
%        depolarzation calibration constant. (transmission ratio for the 
%        parallel component in cross channel and total channel)
%
% OUTPUTS:
%    volDepol: array
%        volume depolarization ratio.
%
% REFERENCE:
%    Engelmann, R. et al. The automated multiwavelength Raman polarization and water-vapor lidar Polly XT: the neXT generation. Atmospheric Measurement Techniques 9, 1767-1784 (2016).
%    Freudenthaler, V. et al. Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006. Tellus B 61, 165-179 (2009).
%    Freudenthaler, V. About the effects of polarising optics on lidar signals and the Delta90 calibration. Atmos. Meas. Tech., 9, 4181–4255 (2016).
%
% HISTORY:
%    - 2021-06-04: first edition by Zhenping
%    - 2024-08-14: Changed to GHK by Moritz.
%
% .. Authors: - zhenping@tropos.de, haarig@tropos.de

sigRatio = sigCross./sigTot;
volDepol = (sigRatio ./ eta * (GT + HT) - (GR + HR)) ./ ((GR - HR) - sigRatio ./ eta * (GT - HT));


end