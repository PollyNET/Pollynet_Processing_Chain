function [campaignHistory] = read_pollynet_history(file)
%READ_POLLYNET_HISTORY read the pollynet history file for activating the 
%target classification processing
%Example:
%   [campaignHistory] = read_pollynet_history(file)
%Inputs:
%   file: char
%       filename of pollynet history of places, which was located in 
%       the todo_filelist. The `lat` and `lon` were reversed in the file.
%       Take care.
%Outputs:
%   campaignHistory: struct
%       name: cell
%           polly type.
%       location: cell
%           location of the campaign.
%       startTime: array (datenum)
%           start time of the campaign.
%       endTime: array (datenum)
%           stop time of the campaign.
%       lon: array (double)
%           longitude of the campaign (degree).
%       lat: array (double)
%           latitude of the campaign (degree).
%       asl: array (double)
%           height of the campaign (above sea level) (m).
%       depolConst: array (double)
%           predefined depolarization calibration constant.
%       molDepol: array (double)
%           predefined molecular depolarization ratio.
%       caption: cell
%           caption for the campaign.
%History:
%   2018-12-15. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

campaignHistory = struct();
campaignHistory.name = {};
campaignHistory.location = {};
campaignHistory.startTime = [];
campaignHistory.endTime = [];
campaignHistory.lon = [];
campaignHistory.lat = [];
campaignHistory.asl = [];
campaignHistory.depolConst = [];
campaignHistory.molDepol = [];
campaignHistory.caption = {};

if exist(file, 'file') ~= 2
    warning('pollynet history of places does not exist. \n%s\n', file);
    return;
end

try 
    fid = fopen(file, 'r');
    testSpec = '%s %s %s %s %s %s %s %s %s %s %s %s';
    data = textscan(fid, testSpec, 'Delimiter', '\t', 'Headerlines', 1);
    campaignHistory.name = transpose(data{1});
    campaignHistory.location = transpose(data{2});
    campaignHistory.caption = transpose(data{12});

    for iRow = 1:length(data{1})
        campaignHistory.startTime = [campaignHistory.startTime, ...
            datenum([data{3}{iRow}, sprintf('%04d', str2num(data{4}{iRow}))], 'yyyymmddHHMM')];
        campaignHistory.endTime = [campaignHistory.endTime, ...
            datenum([data{5}{iRow}, sprintf('%04d', str2num(data{6}{iRow}))], 'yyyymmddHHMM')];
        campaignHistory.lat = [campaignHistory.lat, ...
            str2num(data{7}{iRow})];   % the lat and lon were 
                                       % reversed in the file.
        campaignHistory.lon = [campaignHistory.lon, str2num(data{8}{iRow})];
        campaignHistory.asl = [campaignHistory.asl, str2num(data{9}{iRow})];
        campaignHistory.depolConst = [campaignHistory.depolConst, ...
                                      str2num(data{10}{iRow})];
        campaignHistory.molDepol = [campaignHistory.molDepol, ...
                                    str2num(data{11}{iRow})];
    end

catch
    warning('Failure in reading pollynet history of places.\n%s\n', file);
    return;
end

if isempty(campaignHistory.startTime)
    fprintf('No history campaign.\n');
    return;
end

end