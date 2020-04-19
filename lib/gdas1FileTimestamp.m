function [datetime, location] = gdas1FileTimestamp(gdas1File)
%GDAS1FILETIMESTAMP extract the timestamp from the gdas1File name.
%Example:
%   [datetime] = gdas1FileTimestamp(gdas1File)
%Inputs:
%   gdas1File: char
%       gdas1 data file.
%Outputs:
%   datetime: float
%       datenum.
%History:
%   2019-01-04. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

data = regexp(gdas1File, ...
             '(?<location>.*)_(?<date>\d{8})_(?<hour>\d{2})\w*', 'names');

if isempty(data)
    warning('Failure in converting gdas1 filename to timestamp.\n%s\n', gdas1File);
    datetime = datenum(0,1,0,0,0,0);
    location = '';
else
    datetime = datenum([data.date, data.hour], 'yyyymmddHH');
    location = data.location;
end

end