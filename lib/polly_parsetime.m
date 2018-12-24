function [time] = polly_parsetime(file, textFormat)
%POLLY_PARSETIME parse time from polly data file.
%	Example:
%		[time] = polly_parsetime(file, textFormat)
%	Inputs:
%		file: char
%			filename of polly data.
% 	textFormat: char
%			parsing format to analysis polly data filename.
%	Outputs:
%		time: datenum
%			time when the polly data file was created.
%	History:
%		2018-12-17. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

time = [];
try
	data = textscan(file, textFormat, 'tokens');
	time = datenum(data{1}{1}, data{1}{2}, data{1}{3}, data{1}{4}, data{1}{5}, data{1}{6});
catch
	warning('Failure in parsing time from %s with parsing format %s.\n', file, textFormat);
	return;
end

end