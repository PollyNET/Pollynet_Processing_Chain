function [flag] = polly_isRROff(sigRR)
%POLLY_ISRROFF determine whether rotational Raman channel is turned off.
%   Example:
%       [flag] = polly_isRROff(sigRR)
%   Inputs:
%       sigRR: array
%           photon count. [height * time]
%   Outputs:
%       flag: logical array
%           if flag is true, the rotational Raman channel is turned off.
%   History:
%       2018-09-06. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

flag = false(1, size(sigRR, 2));

flag((mean(sigRR, 1) <= 0.1) & (std(sigRR, 0, 1) <= 0.1)) = true;

end