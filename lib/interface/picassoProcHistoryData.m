function picassoProcHistoryData(startTime, endTime, saveFolder, varargin)
% PICASSOPROCHISTORYDATA process archived polly data.
% USAGE:
%    [output] = picassoProcHistoryData(startTime, endTime, saveFolder)
% INPUTS:
%    startDate: numeric
%        start date of polly data to be decompressed. i.e, datenum(2015, 1, 1) stands for Jan 1st, 2015.
%    endDate: numeric
%        stop date of polly data to be decompressed.
%    saveFolder: char
%        polly data folder. 
%        e.g., /oceanethome/pollyxt
% KEYWORDS:
%    pollyType: char
%        polly instrument. 
%        e.g., arielle
%    PicassoConfigFile: char
%        absolute path of Picasso configuration file.
% EXAMPLE:
% HISTORY:
%    2021-06-27: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'startTime', @isnumeric);
addRequired(p, 'endTime', @isnumeric);
addRequired(p, 'saveFolder', @ischar);
addParameter(p, 'pollyType', '', @ischar);
addParameter(p, 'PicassoConfigFile', '', @ischar);

parse(p, startTime, endTime, saveFolder, varargin{:});

libFolder = fileparts(fileparts(mfilename('fullpath')));
if isempty(p.Results.PicassoConfigFile)
    PicassoConfigFile = fullfile(libFolder, 'config', 'pollynet_processing_chain_config.json');
else
    PicassoConfigFile = p.Results.PicassoConfigFile;
end

%% Parse input date
if length(startTime) == 8
    startTime = datenum([startTime, '-000000'], 'yyyymmdd-HHMMSS');
else
    startTime = datenum(startTime, 'yyyymmdd-HHMMSS');
end
if length(endTime) == 8
    endTime = datenum([endTime, '-235959'], 'yyyymmdd-HHMMSS');
else
    endTime = datenum(endTime, 'yyyymmdd-HHMMSS');
end

if endTime < startTime
    error('end time must be larger than start time.');
end

%% Decompress polly data
decompressPollyData(startTime, endTime, saveFolder, PicassoConfigFile, varargin{:});

%% Process polly data
picassoProcTodolist(PicassoConfigFile);

end