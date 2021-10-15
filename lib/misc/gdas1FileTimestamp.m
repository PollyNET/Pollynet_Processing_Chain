function [datetime, location] = gdas1FileTimestamp(gdas1File)
% GDAS1FILETIMESTAMP extract timestamp from the gdas1File name.
%
% USAGE:
%    [datetime] = gdas1FileTimestamp(gdas1File)
%
% INPUTS:
%    gdas1File: char
%        gdas1 data file.
%
% OUTPUTS:
%    datetime: float
%        datenum.
%
% HISTORY:
%    - 2021-08-03: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

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