function laserlogbookFullpath = convert_temp_2_laserlogbook(fileinfo_new, pollyList, pollyTempDirs)
% CONVERT_TEMP_2_LASERLOGBOOK convert the polly temps file to laserlogbook file.
% USAGE:
%   convert_temp_2_laserlogbook(fileinfo_new, pollyList, pollyTempDirs)
% INPUTS:
%   fileinfo_new: char
%       absolute path of the fileinfo_new
%   pollyList: cell
%       python list whose temps file needs to be converted.
%   pollyTempDirs: cell
%       the respective temps folder.
% OUTPUTS:
%   laserlogbookFullpath: char
%       absolute path of the laserlogbook file that was converted from the temps file.
% EXAMPLE:
% HISTORY:
%    2021-06-13: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if exist(fileinfo_new, 'file') ~= 2
    warning('%s file does not exist.', fileinfo_new);
    return;
end

if length(pollyList) ~= length(pollyTempDirs)
    error('pollyList and pollyTempDirs are not compatible.');
end

laserlogbookFullpath = '';

%% parsing the fileinfo_new
pollyDataInfo = read_fileinfo_new(fileinfo_new);

for iTask = 1:length(pollyDataInfo.zipFile)

    pollyType = pollyDataInfo.pollyType{iTask};
    pollyDataFile = pollyDataInfo.zipFile{iTask};
    pollyLaserlogbookFile = sprintf('%s.laserlogbook.txt', pollyDataInfo.dataFilename{iTask});

    if ~ any(ismember(lower(pollyList), lower(pollyType)))
        % if the current polly is not in the pollyList
        continue;
    end

    switch lower(pollyType)

    case {'pollyxt_tjk', 'pollyxt_cyp', 'pollyxt_lacros', 'pollyxt_tropos', 'pollyxt_noa', 'pollyxt_tau', 'arielle', 'pollyxt_fmi', 'pollyxt_uw'}

        pollyDataFileFormat = '(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc';
        pollyTempDir = pollyTempDirs{ismember(lower(pollyList), lower(pollyType))};

        %% find the polly temps file
        measTime = pollyParseFiletime(pollyDataFile, pollyDataFileFormat);
        pollyTempsFile = fullfile(pollyTempDir, sprintf('%s_temps.txt', datestr(measTime, 'yyyymmdd')));

        %% read the polly temps file
        laserlogData = pollyReadTemps(pollyTempsFile);

        %% create a fake laserlogbook file
        fprintf('Start to convert the %s to %s\n', basename(pollyTempsFile), basename(pollyLaserlogbookFile));
        laserlogbookFullpath = fullfile(pollyDataInfo.todoPath{iTask}, pollyDataInfo.dataPath{iTask}, pollyLaserlogbookFile);
        write_laserlogbook(laserlogbookFullpath, laserlogData, 'w');

    end
end

end
