function [flag] = pollyIsLaserShutterOn(sig)
% POLLYISLASERSHUTTERON determine whether the laser shutter is on due to the 
% flying object.
% USAGE:
%    [flag] = pollyIsLaserShutterOn(sig)
% INPUTS:
%    sig: array
%        photon count. [height * time]
% OUTPUTS:
%    flag: logical array
%        if flag is true, laser shutter is turned on.
% EXAMPLE:
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

flag = false(1, size(sig, 2));

flag((mean(sig, 1) <= 0.01) & (std(sig, 0, 1) <= 0.001)) = true;

end