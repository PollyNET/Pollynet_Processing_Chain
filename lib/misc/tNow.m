function [tStr] = tNow()
% TNOW generate the string of the present time with a certain format
%
% USAGE:
%    [tStr] = tNow()
%
% OUTPUTS:
%    tStr: char
%        date string for now.
%
% HISTORY:
%    - 2021-06-08: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

tStr = datestr(now, 'yyyy-mm-dd HH:MM:SS');

end