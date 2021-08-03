function [flag] = pollyIs607Off(sig607)
% pollyIs607Off Determine whether channel 607nm is turned off.
% USAGE:
%    [flag] = pollyIs607Off(sig607)
% INPUTS:
%    sig607: array
%        photon count. [height * time]
% OUTPUTS:
%    flag: logical array
%        if flag is true, channel 607nm is turned off.
% EXAMPLE:
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if isempty(sig607)
    % empty signal has dimensions of 0 x height x time
    flag = false(1, size(sig607, 3));
    return;
end

flag = false(1, size(sig607, 2));

flag((mean(sig607, 1) <= 0.1) & (std(sig607, 0, 1) <= 0.1)) = true;

end