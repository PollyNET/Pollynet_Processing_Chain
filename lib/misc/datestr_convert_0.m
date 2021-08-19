function [thisStr] = datestr_convert_0(thisDatenum, thisFormat)
% DATESTR_CONVERT_0 Convert datenum to datestr with keeping 0 to empty string, instead of '00000100'
%
% USAGE:
%    [thisStr] = datestr_convert_0(thisDatenum)
%
% INPUTS:
%    thisDatenum: float
%        matlab datenum.
%
% OUTPUTS:
%    thisStr: char array
%        date string corresponding to the input matlab datenum.
%    thisFormat: char array
%        date string format with being compatible with datestr format.
%
% HISTORY:
%    - 2021-06-21: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ~ exist('thisFormat', 'var')
    thisFormat = 'yyyymmdd HH:MM:SS';
end

if abs(thisDatenum) <= 1e-16
    thisStr = '';
else
    thisStr = datestr(thisDatenum, thisFormat);
end

end