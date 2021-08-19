function [unix_timestamp] = datenum_2_unix_timestamp(matlab_datenum)
% DATENUM_2_UNIX_TIMESTAMP convert the matlab datenum to unix timstamp.
%
% USAGE:
%    [unix_timestamp] = datenum_2_unix_timestamp(matlab_datenum)
%
% INPUTS:
%    matlab_datenum: datenum
%
% OUTPUTS:
%    unix_timestamp: float
%        unix timestamp coressponding to the input. Unix timestamp is based on the seconds since 1 January 1970. And both of the convention 
%        didn't correct the leap seconds.
%
% HISTORY:
%    - 2021-08-03: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

unix_timestamp = 86400 * (matlab_datenum - datenum(1970, 1, 1));

end