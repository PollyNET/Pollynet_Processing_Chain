function [oDate] = dateArr(startDate, endDate, varargin)
% DATEARR create an array between startDate and endDate with a specified interval.
% USAGE:
%    [oDate] = dateArr(startDate, endDate, 'Interval', 'year')
% INPUTS:
%    startDate: datenum
%        start date.
%    endDate: datenum
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
addRequired(p, 'endDate', @isnumeric);
addParameter(p, 'Interval', defaultInterval);
addParameter(p, 'int_num', 1, @isnumeric);

parse(p, startDate, endDate, varargin{:});

[startY, startM, startD, startH, startMin, startS] = datevec(startDate);

switch lower(p.Results.Interval)
case 'year'
    nYears = floor(yearfrac(startDate, endDate, 1));

    oDate = datenum(startY + (0:p.Results.int_num:nYears), startM, startD, startH, startMin, startS);
case 'month'
    nMonths = floor(months(startDate, endDate));

    oDate = datenum(startY, startM + (0:p.Results.int_num:nMonths), startD, startH, startMin, startS);
end

end