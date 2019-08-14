function [thisStr] = datestr_convert_0(thisDatenum, thisFormat)
%DATESTR_CONVERT_0 Convert datenum to datestr with keeping 0 to empty string, instead of '00000100'
%   Example:
%       [thisStr] = datestr_convert_0(thisDatenum)
%   Inputs:
%       thisDatenum: float
%           matlab datenum.
%   Outputs:
%       thisStr: char array
%           date string corresponding to the input matlab datenum.
%       thisFormat: char array
%           date string format with being compatible with datestr format.
%   History:
%       2019-05-15. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('thisFormat', 'var')
    thisFormat = 'yyyymmdd HH:MM:SS';
end

if abs(thisDatenum) <= 1e-16
    thisStr = '';
else
    thisStr = datestr(thisDatenum, thisFormat);
end

end