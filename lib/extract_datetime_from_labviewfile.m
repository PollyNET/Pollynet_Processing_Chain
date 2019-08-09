function [startTime, endTime, smoothWin] = extract_datetime_from_labviewfile(file)
%extract_datetime_from_labviewfile Get the start time, end time and smoothing window from the *info file, output by the LabView program.
%   Example:
%       [startTime, endTime, smoothWin] = extract_datetime_from_labviewfile(file)
%   Inputs:
%       file: char
%           absolute path of the labview *info file.
%   Outputs:
%       startTime: datenum
%           the start for the retrieving.
%       endTime: datenum 
%           the end time for the retrieving.
%       smoothWin: integer
%   History:
%       2019-01-28. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

fid = fopen(file, 'r');

line1 = fgetl(fid);
fmt = 'Messung von (UTC):%s';
data = textscan(line1, fmt, 'delimiter', ';');
startTime = datenum(data{1}{1}, 'yymmdd HHMM');

line2 = fgetl(fid);
fmt = 'bis (UTC):%s';
data = textscan(line2, fmt, 'delimiter', ';');
endTime = datenum(data{1}{1}, 'yymmdd HHMM');

% extract smooth window
smoothWin = NaN;
while ~ feof(fid)
    line3 = fgetl(fid);
    if ~ isempty(regexpi(line3, 'smootingbeta355: \w*'))
        tmp = textscan(line3, 'smootingbeta355: %d');
        smoothWin = tmp{1};
    end
end

fclose(fid);

end