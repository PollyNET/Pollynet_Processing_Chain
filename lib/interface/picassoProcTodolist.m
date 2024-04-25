function [report] = picassoProcTodolist(PicassoConfigFile, varargin)
% PICASSOPROCTODOLIST process polly data with entries listed in todolist.
%
% USAGE:
%    [report] = picassoProcTodolist(PicassoConfigFile)
%
% INPUTS:
%    PicassoConfigFile: char
%        absolute path of Picasso configuration file.
%
% KEYWORDS:
%    flagDonefileList: logical
%        flag for writing done_filelist.
%    defaultPicassoConfigFile: char
%        absolute path of default Picasso configuration file.
%
% OUTPUTS:
%    report: cell
%        processing report.
%
% HISTORY:
%    - 2021-06-27: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

PicassoDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'PicassoConfigFile', @ischar);
addParameter(p, 'flagDonefileList', true, @islogical);
addParameter(p, 'defaultPicassoConfigFile', fullfile(PicassoDir, 'lib', 'config', 'pollynet_processing_chain_config.json'), @iscell);

parse(p, PicassoConfigFile, varargin{:});

%% Load Picasso configuration
if exist(PicassoConfigFile, 'file') ~= 2
    error('Picasso config file does not exist: %s', PicassoConfigFile);
else
    PicassoConfig = loadConfig(PicassoConfigFile, p.Results.defaultPicassoConfigFile);
end

%% Read fileinfo_new file
pollyDataTasks = read_fileinfo_new(PicassoConfig.fileinfo_new);

if PicassoConfig.flagDeleteTodofile
    delete(PicassoConfig.fileinfo_new);
end

%% Start data processing
report = cell(1, length(pollyDataTasks.dataFilename));

for iTask = 1:length(pollyDataTasks.dataFilename)
    fprintf('Processing task No.%d. There are still %d remained.\n', iTask, length(pollyDataTasks.dataFilename) - iTask);
    pollyDataFile = fullfile(pollyDataTasks.todoPath{iTask}, ...
                             pollyDataTasks.dataPath{iTask}, ...
                             pollyDataTasks.dataFilename{iTask});
    laserlogbook = fullfile(pollyDataTasks.todoPath{iTask}, ...
        pollyDataTasks.dataPath{iTask}, ...
        sprintf('%s.laserlogbook.txt', pollyDataTasks.dataFilename{iTask}));
    reportTmp = picassoProcV3(pollyDataFile, pollyDataTasks.pollyType{iTask}, ...
        PicassoConfigFile, ...
        'pollyZipFile', pollyDataTasks.zipFile{iTask}, ...
        'pollyZipFileSize', pollyDataTasks.dataSize(iTask), ...
        'pollyLaserlogbook', laserlogbook, ...
        'flagDonefileList', p.Results.flagDonefileList);
    report{end + 1} = reportTmp;
end

fclose('all');

[USER, HOME, OS] = getsysinfo();
%% Clean
if strcmpi(OS, 'linux')
   clear all;
   quit;
else
    % Do nothing
end


end
