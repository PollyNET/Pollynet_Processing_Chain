function [flag] = pollyIs407Off(sig407)
% POLLYIS407OFF determine whether channel 407nm is turned off.
% USAGE:
%    [flag] = pollyIs407Off(sig407)
% INPUTS:
%    sig407: array
%        photon count. [height * time]
% OUTPUTS:
%    flag: logical array
%        if flag is true, channel 407nm is turned off.
% EXAMPLE:
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if isempty(sig407)
    % empty signal has dimensions of 0 x height x time
    flag = false(1, size(sig407, 3));
    return;
end

flag = false(1, size(sig407, 2));

flag((mean(sig407, 1) <= 0.1) & (std(sig407, 0, 1) <= 0.1)) = true;

end