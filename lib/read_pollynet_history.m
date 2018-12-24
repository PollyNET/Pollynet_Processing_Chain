function [pollynetHistory] = read_pollynet_history(file)
%READ_POLLYNET_HISTORY read the pollynet history file for activating the 
%target classification processing
%	Example:
%		[pollynetHistory] = read_pollynet_history(file)
%	Inputs:
%		file: char
%			filename of the pollynetHistory which locates in todo_filelist
%	Outputs:
%		pollynetHistory: struct
%			name: cell
%			location: cell
%			startTime: array (datenum)
%			endTime: array (datenum)
%			lon: array (double)
%			lat: array (double)
%			asl: array (double)
%			depolConst: array (double)
%			molDepol: array (double)
%			caption: cell
%	History:
%		2018-12-15. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

pollynetHistory = struct();
pollynetHistory.name = {};
pollynetHistory.location = {};
pollynetHistory.startTime = [];
pollynetHistory.endTime = [];
pollynetHistory.lon = [];
pollynetHistory.lat = [];
pollynetHistory.asl = [];
pollynetHistory.depolConst = [];
pollynetHistory.molDepol = [];
pollynetHistory.caption = {};

if ~ exist(file, 'file')
	warning('pollynetHistory does not exist. \n%s\n', file);
	return;
end

try 
	fid = fopen(file, 'r');
	testSpec = '%s %s %s %s %s %s %s %s %s %s %s %s';
	data = textscan(fid, testSpec, 'Delimiter', '\t', 'Headerlines', 1);
	pollynetHistory.name = transpose(data{1});
	pollynetHistory.location = transpose(data{2});
	pollynetHistory.caption = transpose(data{12});

	for iRow = 1:length(data{1})
		pollynetHistory.startTime = [pollynetHistory.startTime, datenum([data{3}{iRow}, data{4}{iRow}], 'yyyymmddHHMM')];
		pollynetHistory.endTime = [pollynetHistory.endTime, datenum([data{5}{iRow}, data{6}{iRow}], 'yyyymmddHHMM')];
		pollynetHistory.lon = [pollynetHistory.lon, str2num(data{7}{iRow})];
		pollynetHistory.lat = [pollynetHistory.lat, str2num(data{8}{iRow})];
		pollynetHistory.asl = [pollynetHistory.asl, str2num(data{9}{iRow})];
		pollynetHistory.depolConst = [pollynetHistory.depolConst, str2num(data{10}{iRow})];
		pollynetHistory.molDepol = [pollynetHistory.molDepol, str2num(data{11}{iRow})];
	end

catch
	warning('Failure in reading pollynetHistory.\n%s\n', file);
	return;
end

if isempty(pollynetHistory.startTime)
	fprintf('No history data.\n');
	return;
end

end