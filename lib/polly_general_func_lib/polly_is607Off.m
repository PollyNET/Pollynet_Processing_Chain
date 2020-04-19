function [flag] = polly_is607Off(sig607)
%POLLY_IS607OFF determine whether channel 607nm is turned off.
%   Example:
%       [flag] = polly_is607Off(sig607)
%   Inputs:
%       sig607: array
%           photon count. [height * time]
%   Outputs:
%       flag: logical array
%           if flag is true, channel 607nm is turned off.
%   History:
%       2019-08-27. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

flag = false(1, size(sig607, 2));

flag((mean(sig607, 1) <= 0.1) & (std(sig607, 0, 1) <= 0.1)) = true;

end