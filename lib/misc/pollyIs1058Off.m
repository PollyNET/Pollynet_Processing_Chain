function [flag] = pollyIs1058Off(sig1058)
% POLLYIS1058OFF determine whether channel 1058nm is turned off.
%
% USAGE:
%    [flag] = pollyIs1058Off(sig1058)
%
% INPUTS:
%    sig1058: array
%        photon count. [height * time]
%
% OUTPUTS:
%    flag: logical array
%        if flag is true, channel 1058nm is turned off.
%
% HISTORY:
%    - 2021-10-11: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if isempty(sig1058)
    % empty signal has dimensions of 0 x height x time
    flag = false(1, size(sig1058, 3));
    return;
end

flag = false(1, size(sig1058, 2));

flag((mean(sig1058, 1) <= 0.1) & (std(sig1058, 0, 1) <= 0.1)) = true;

end