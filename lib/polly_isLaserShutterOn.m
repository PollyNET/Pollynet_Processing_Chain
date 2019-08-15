function [flag] = polly_isLaserShutterOn(sig)
%POLLY_ISLASERSHUTTERON determine whether the laser shutter is on due to the 
%flying object..
%   Example:
%       [flag] = polly_isLaserShutterOn(sig)
%   Inputs:
%       sig: array
%           photon count. [height * time]
%   Outputs:
%       flag: logical array
%           if flag is true, laser shutter is turned on.
%   History:
%       2019-07-10. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

flag = false(1, size(sig, 2));

flag((mean(sig, 1) <= 0.01) & (std(sig, 0, 1) <= 0.001)) = true;

end