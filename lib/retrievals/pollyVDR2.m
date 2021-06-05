function [volDepol] = pollyVDR2(sigTot, sigCross, Rt, Rc, depolConst)
% pollyVDR2 calculate the 2-dimensional volume depolarization ratio for 
% pollyXT system.
% USAGE:
%    [volDepol] = pollyVDR2(sigTot, sigCross, Rt, Rc, depolConst)
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
% OUTPUTS:
%    volDepol: array
%        volume depolarization ratio.
% REFERENCE:
%    1. Engelmann, R. et al. The automated multiwavelength Raman polarization and water-vapor lidar Polly XT: the neXT generation. Atmospheric Measurement Techniques 9, 1767-1784 (2016).
%    2. Freudenthaler, V. et al. Depolarization ratio profiling at several wavelengths in pure Saharan dust during SAMUM 2006. Tellus B 61, 165-179 (2009).
% EXAMPLE:
% HISTORY:
%    2021-06-04: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

sigRatio = sigCross./sigTot;
volDepol = (1 - sigRatio ./ depolConst) ./ (sigRatio * Rt / depolConst - Rc);

end