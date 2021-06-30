function [flag] = pollyIs387Off(sig387)
% POLLYIS387OFF determine whether channel 387nm is turned off.
% USAGE:
%    [flag] = pollyIs387Off(sig387)
% INPUTS:
%    sig387: array
%        photon count. [height * time]
% OUTPUTS:
%    flag: logical array
%        if flag is true, channel 387nm is turned off.
% EXAMPLE:
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if isempty(sig387)
    % empty signal has dimensions of 0 x height x time
    flag = false(1, size(sig387, 3));
    return;
end

flag = false(1, size(sig387, 2));

flag((mean(sig387, 1) <= 0.1) & (std(sig387, 0, 1) <= 0.1)) = true;

end