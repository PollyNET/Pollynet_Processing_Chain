function [flag] = polly_is407Off(sig407)
%POLLY_IS407OFF determine whether channel 407nm is turned off.
%Example:
%   [flag] = polly_is407Off(sig407)
%Inputs:
%   sig407: array
%       photon count. [height * time]
%Outputs:
%   flag: logical array
%       if flag is true, channel 407nm is turned off.
%History:
%   2018-09-06. First edition by Zhenping.
%Contact:
%   zhenping@tropos.de

flag = false(1, size(sig407, 2));

flag((mean(sig407, 1) <= 0.1) & (std(sig407, 0, 1) <= 0.1)) = true;

end