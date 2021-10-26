function [oDate] = dateArr(startDate, stopDate, varargin)
% DATEARR create an array between startDate and stopDate with a specified interval.
% USAGE:
%    [oDate] = dateArr(startDate, stopDate, 'Interval', 'year')
% INPUTS:
%    startDate: datenum
%        start date.
%    stopDate: datenum
%        stop date.
% KEYWORDS:
%    Interval: char
%        interval of the returned array.
%        'year' (default) or 'month'
%    int_num: numeric
%        number of date units for each interval (default: 1).
% OUTPUTS:
%    oDate: datenum
%        returned datenum array.
% HISTORY:
%    2021-10-17: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;

defaultInterval = 'year';

addRequired(p, 'startDate', @isnumeric);
addRequired(p, 'stopDate', @isnumeric);
addParameter(p, 'Interval', defaultInterval);
addParameter(p, 'int_num', 1, @isnumeric);

parse(p, startDate, stopDate, varargin{:});

[startY, startM, startD, startH, startMin, startS] = datevec(startDate);
[stopY, stopM, stopD, ~, ~, ~] = datevec(stopDate);

switch lower(p.Results.Interval)

case 'year'

    nYears = ceil(stopY - startY);

    oDate = datenum(startY + (0:p.Results.int_num:nYears), startM, startD, startH, startMin, startS);
    isOverflow = (oDate > stopDate) | (oDate < startDate);

    oDate = oDate(~ isOverflow);

case 'month'

    nMonths = ((stopY - startY) * 12 + stopM - startM + 2);

    oDate = datenum(startY, startM + (0:p.Results.int_num:nMonths), startD, startH, startMin, startS);
    isOverflow = (oDate > stopDate) | (oDate < startDate);

    oDate = oDate(~ isOverflow);

end

end