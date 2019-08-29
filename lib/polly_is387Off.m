function [flag] = polly_is387Off(sig387)
%POLLY_IS387OFF determine whether channel 387nm is turned off.
%   Example:
%       [flag] = polly_is387Off(sig387)
%   Inputs:
%       sig387: array
%           photon count. [height * time]
%   Outputs:
%       flag: logical array
%           if flag is true, channel 387nm is turned off.
%   History:
%       2019-08-27. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

flag = false(1, size(sig387, 2));

flag((mean(sig387, 1) <= 0.1) & (std(sig387, 0, 1) <= 0.1)) = true;

end