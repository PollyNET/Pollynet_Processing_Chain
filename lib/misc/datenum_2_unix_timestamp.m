function [unix_timestamp] = datenum_2_unix_timestamp(matlab_datenum)
%DATENUM_2_UNIX_TIMESTAMP convert the matlab datenum to unix timstamp.
%Example:
%   [unix_timestamp] = datenum_2_unix_timestamp(matlab_datenum)
%Inputs:
%   matlab_datenum: datenum
%Outputs:
%   unix_timestamp: float
%       unix timestamp coressponding to the input.
%History:
%   2019-05-10. First Edition by Zhenping
%Note:
%   unix timestamp is based on the seconds since 1 January 1970. And both of the convention 
%   didn't correct the leap seconds.
%Contact:
%   zhenping@tropos.de

unix_timestamp = 86400 * (matlab_datenum - datenum(1970, 1, 1));

end