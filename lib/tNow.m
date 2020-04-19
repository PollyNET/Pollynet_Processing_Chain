function [tStr] = tNow()
%TNOW generate the string of the present time with a certain format
%Example:
%   [tStr] = tNow()
%Inputs:
%Outputs:
%   tStr: char
%       date string for now.
%History:
%   2018-12-16. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

tStr = datestr(now, 'yyyy-mm-dd HH:MM:SS');

end