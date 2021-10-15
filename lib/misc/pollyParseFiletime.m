function [time] = pollyParseFiletime(file, textFormat)
% POLLYPARSEFILETIME parse time from polly data file.
%
% USAGE:
%    [time] = pollyParseFiletime(file, textFormat)
%
% INPUTS:
%    file: char
%        filename of polly data.
%    textFormat: char
%        parsing format to analysis polly data filename.
%
% OUTPUTS:
%    time: datenum
%        time when the polly data file was created.
%
% HISTORY:
%    - 2018-12-17: First edition by Zhenping
%    - 2020-07-23: Add error message when filename cannot be parsed by the textFormat
%
% .. Authors: - zhenping@tropos.de

try
    data = regexp(file, textFormat, 'names');
    time = datenum(str2double(data.year), str2double(data.month), ...
                   str2double(data.day), str2double(data.hour), ...
                   str2double(data.minute), str2double(data.second));
catch
    error('PICASSO:InvaliFile', ...
          'Failure in parsing time from %s with parsing format %s.\n', ...
          file, textFormat);
end

end