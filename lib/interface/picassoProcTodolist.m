function [report] = picassoProcTodolist(PicassoConfigFile, varargin)
% PICASSOPROCTODOLIST process polly data with entries listed in todolist.
% USAGE:
%    [report] = picassoProcTodolist(PicassoConfigFile)
% INPUTS:
%    PicassoConfigFile: char
%        absolute path of Picasso configuration file.
% KEYWORDS:
%    flagDonefileList: logical
%        flag for writing done_filelist.
% OUTPUTS:
%    report: cell
%        processing report.
% EXAMPLE:
% HISTORY:
%    2021-06-27: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'PicassoConfigFile', @ischar);
addParameter(p, 'flagDonefileList', true, @islogical);

parse(p, PicassoConfigFile, varargin{:});

%% Load Picasso configuration
if exist(PicassoConfigFile, 'file') ~= 2
    error('Picasso config file does not exist: %s', PicassoConfigFile);
else
    PicassoConfig = loadjson(PicassoConfigFile);
end

%% Read fileinfo_new file
pollyDataTasks = read_fileinfo_new(PicassoConfig.fileinfo_new);

%% Start data processing
report = cell(1, length(pollyDataTasks.dataFilename));

for iTask = 1:length(pollyDataTasks.dataFilename)
    fprintf('Processing task No.%d. There are still %d remained.\n', iTask, length(pollyDataTasks) - iTask);
    pollyDataFile = fullfile(pollyDataTasks.todoPath{iTask}, pollyDataTasks.dataPath{iTask}, pollyDataTasks.dataFilename{iTask});
    laserlogbook = fullfile(pollyDataTasks.todoPath{iTask}, pollyDataTasks.dataPath{iTask}, sprintf('%s.laserlogbook.txt', pollyDataTasks.dataFilename{iTask}));
    reportTmp = picassoProcV3(pollyDataFile, pollyDataTasks.pollyType{iTask}, PicassoConfigFile, ...
        'pollyZipFile', pollyDataTasks.zipFile{iTask}, 'pollyZipFileSize', pollyDataTasks.dataSize(iTask), 'pollyLaserlogbook', laserlogbook, 'pollyType', pollyDataTasks.pollyType{iTask});
    report{end + 1} = reportTmp;
end

end