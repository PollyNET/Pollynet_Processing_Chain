function [time] = polly_parsetime(file, textFormat)
%POLLY_PARSETIME parse time from polly data file.
%Example:
%   [time] = polly_parsetime(file, textFormat)
%Inputs:
%   file: char
%       filename of polly data.
%textFormat: char
%       parsing format to analysis polly data filename.
%Outputs:
%   time: datenum
%       time when the polly data file was created.
%History:
%   2018-12-17. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

time = [];
try
    data = regexp(file, textFormat, 'names');
    time = datenum(str2num(data.year), str2num(data.month), ...
                   str2num(data.day), str2num(data.hour), ...
                   str2num(data.minute), str2num(data.second));
catch
    warning('Failure in parsing time from %s with parsing format %s.\n', ...
            file, textFormat);
    return;
end

end