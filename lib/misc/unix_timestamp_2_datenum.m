function [matlab_datenum] = unix_timestamp_2_datenum(unix_timestamp)
%UNIX_TIMESTAMP_2_DATENUM convert the matlab datenum to unix timstamp.
%Example:
%   [matlab_datenum] = unix_timestamp_2_datenum(unix_timestamp)
%Inputs:
%   unix_timestamp: datenum
%Outputs:
%   matlab_datenum: float
%       unix timestamp coressponding to the input.
%History:
%   2019-05-10. First Edition by Zhenping
%Note:
%   unix timestamp is based on the seconds since 1 January 1970. And both of 
%   the convention didn't correct the leap seconds.
%Contact:
%   zhenping@tropos.de

matlab_datenum = (unix_timestamp) / 86400 + datenum(1970, 1, 1);

end