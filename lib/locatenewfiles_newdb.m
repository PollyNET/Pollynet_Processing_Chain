function [flag] = locatenewfiles_newdb(pollyAppConfigFile, picassoConfigFile, ...
    pollyDataBaseDir, minDataSize, tSearchStart, tSearchRange, flagCheckGDAS1)
%locatenewfiles_newdb Search the updated polly data in the server with comparing 
%its file size with the file size saved in the database. And also checked the 
%GDAS1 status together if 'flagCheckGDAS1' was set true. The modified zipped 
%files will be extracted to the todopath and the fileinfo_new file will be 
%created to trigger the Picasso.
%   Example:
%       [flag] = locatenewfiles_newdb(pollyAppConfigFile, picassoConfigFile, ...
%    pollyDataBaseDir, minDataSize, tSearchStart, tSearchRange, flagCheckGDAS1)
%   Inputs:
%       pollyAppConfigFile: char
%           filename of the pollyAPP private configuration file. 
%           e.g., '~/pollyAPP/config/config.private'
%       picassoConfigFile: char
%           filename of the picasso global configuration file.
%           e.g., '~/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json'
%       pollyDataBaseDir: char
%           root directory for holding polly data
%           e.g., '/pollyhome'
%       minDataSize: integer
%           minumum size of the polly data to trigger the processing. [bytes]
%       tSearchStart: datenum
%           start time for searching the polly data file.
%       tSearchRange: datenum
%           search range for searching the polly data file before the tSearchStart.
%       flagCheckGDAS1: logical
%           flag to control whether to reprocess the data when GDAS1 files were ready.
%   Outputs:
%       flag: logical
%           status for the whole process.
%   History:
%       2019-09-02. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

flag = false;

if exist(pollyAppConfigFile, 'file') ~= 2
    warning('pollyAppConfigFile does not exist. Please check!\n%s', pollyAppConfigFile);
    return;
end

if exist(picassoConfigFile, 'file') ~= 2
    warning('picassoConfigFile does not exist. Please check!\n%s', picassoConfigFile);
    return;
end

if ~ exist('pollyDataBaseDir', 'var')
    pollyDataBaseDir = '/pollyhome';
end

if ~ exist('minDataSize', 'var')
    minDataSize = 50000;
end

if ~ exist('tSearchStart', 'var')
    tSearchStart = now;
end

if ~ exist('tSearchRange', 'var')
    tSearchRange = datenum(0, 1, 7);
end

if ~ exist('flagCheckGDAS1', 'var')
    flagCheckGDAS1 = false;
end

%% read pollyApp configuration file
% detailed information can be found in '/pollyhome/Picasso/pollyAPP/config'
fprintf('Loading pollyAPP configurations from %s\n', pollyAppConfigFile);
pollyAPPConfig = loadConfigPrivate(pollyAppConfigFile);

%% read picasso configuration file
% detailed information can be found in 'doc/pollynet_processing_chain_config.md'
fprintf('Loading picasso configurations from %s\n', picassoConfigFile);
picassoConfig = loadjson(picassoConfigFile);
todoPath = fileparts(picassoConfig.fileinfo_new);
picassoLinkFile = picassoConfig.pollynet_config_history_file;

%% connect to the polly database
% connect to database (server)
conn = database(pollyAPPConfig.DATABASE_NAME, pollyAPPConfig.DATABASE_USER, pollyAPPConfig.DATABASE_PASSWORD, 'Vendor', pollyAPPConfig.DATABASE_DRIVER, 'Server', pollyAPPConfig.DATABASE_HOST, 'PortNumber', pollyAPPConfig.DATABASE_PORT);
% conn = database('polly_14', 'webapp_user', 'ramadan1', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost:7802/');

%% Retrieve the list of supported system by Picasso
picassoLinkInfo = read_pollynet_processing_configs(picassoLinkFile);
% find the unique polly names
pollyNames = picassoLinkInfo.pollyVersion;
pollyNames = transpose(pollyNames);
pollyNamesTab = cell2table(pollyNames, 'VariableNames', {'polly'});
pollyUniqNameTable = unique(pollyNamesTab, 'rows');   % [table]

%% Search the saved polly data files for each supported lidar
taskTable = cell2table(cell(0, 6), 'variablenames', {'pollyName', 'filename', 'filePath', 'fileSize', 'GDAS1', 'date'});
for iPolly = 1:length(pollyUniqNameTable.polly)

    % retrieve the filesize and gdas status from the database
    fprintf('Start to fetch polly data filenames for %s from %s\n', pollyUniqNameTable.polly{iPolly}, pollyAPPConfig.DATABASE_NAME);

    % TODO:
    % Speed up the searching with add a criteria of datetime in the SQL command.
    % SQL command:
    % '''
    % SELECT 
    %     l.name,
    %     ld.nc_zip_file,
    %     ld.nc_zip_file_size,
    %     loc.name,
    %     ld.gdas,
    %     ld.starttime
    % FROM 
    %     lidar_data ld
    % INNER JOIN
    %     lidar l
    % INNER JOIN
    %     location loc
    % WHERE
    %     ld.lidar_fk=l.id AND
    %     ld.location_fk=loc.id AND
    %     l.name='Polly_1V2' AND
    %     (ld.starttime >= '20191007') AND (ld.stoptime <= '20191014')
    % '''
    % You are at your own responsibility to test this.
    sqlCmd = sprintf('SELECT l.name, ld.nc_zip_file, ld.nc_zip_file_size, loc.name, ld.gdas FROM lidar_data ld INNER JOIN lidar l, location loc WHERE ld.lidar_fk=l.id AND ld.location_fk=loc.id AND l.name=''%s'';', pollyUniqNameTable.polly{iPolly});
    res = exec(conn, sqlCmd);
    dbRet = fetch(res);

    if (length(dbRet.Data) == 1 ) && (strcmpi(dbRet.Data{1}, 'no data'))
        fprintf('No data was found.\n');
        pollyDBDataTable = cell2table(cell(0, 5), 'VariableNames', {'pollyName', 'fileName', 'fileSize', 'location', 'GDAS1'});
    else
        fprintf('%d polly data file logs were found.\n', size(dbRet.Data, 1));
        pollyDBDataTable = cell2table(dbRet.Data, 'VariableNames', {'pollyName', 'fileName', 'fileSize', 'location', 'GDAS1'});
    end

    % search all the polly files in the server in the given period (start - stop)
    pollySaveData = struct('pollyName', {}, 'GDAS1', {}, 'filePath', {}, 'fileName', {}, 'fileSize', {}, 'date', {});

    fprintf('Start to search data files for %s in the server.\n', pollyUniqNameTable.polly{iPolly});
    fileCount = 0;
    for thisDate = floor(tSearchStart - tSearchRange):floor(tSearchStart)
        [year, month, day] = datevec(thisDate);
        files = dir(fullfile(pollyDataBaseDir, pollyUniqNameTable.polly{iPolly}, 'data_zip', sprintf('%04d%02d', year, month), sprintf('%04d_%02d_%02d*.nc.zip', year, month, day)));

        for iFile = 1:length(files)
            fileCount = fileCount + 1;
            pollySaveData(fileCount).pollyName = pollyUniqNameTable.polly{iPolly};
            pollySaveData(fileCount).GDAS1 = false;
            pollySaveData(fileCount).filePath = fullfile(pollyDataBaseDir, pollyUniqNameTable.polly{iPolly}, 'data_zip', sprintf('%04d%02d', year, month));
            pollySaveData(fileCount).fileName = files(iFile).name;
            pollySaveData(fileCount).fileSize = files(iFile).bytes;
            pollySaveData(fileCount).date = datenum(year, month, day);
        end
    end

    % compare the file size between the saved data and the previous data
    for iFile = 1:length(pollySaveData)
        filename = pollySaveData(iFile).fileName;
        fileSizeNew = pollySaveData(iFile).fileSize;

        if fileSizeNew < minDataSize
            % if the data size is not large enough
            continue;
        end

        % search the file size in the database
        maskFile = ismember(pollyDBDataTable.fileName, ...
                 [datestr(pollySaveData(iFile).date,'yyyymm'), '/', filename]);
        fileSizeOld = pollyDBDataTable.fileSize(maskFile);
        processedWithGDAS1 = pollyDBDataTable.GDAS1(maskFile);
        if sum(maskFile) == 0
            % if the file is not in the database

            taskEntry.pollyName = {pollySaveData(iFile).pollyName};
            taskEntry.filename = {filename};
            taskEntry.filePath = {pollySaveData(iFile).filePath};
            taskEntry.fileSize = fileSizeNew;
            taskEntry.GDAS1 = pollySaveData(iFile).GDAS1;
            taskEntry.date = pollySaveData(iFile).date;

            taskTable = [taskTable; struct2table(taskEntry)];
            continue;
        end

        if sum(maskFile) > 1
            % if multiple files were found, choose the file with the largest
            % file size
            warning('Multiple entries were found for %s',  [datestr(pollySaveData(iFile).date,'yyyymm'), '/', filename]);

            [maxFileSizeOld, maxIndx] = max(fileSizeOld);
            fileSizeOld = maxFileSizeOld;
            processedWithGDAS1 = pollyDBDataTable.GDAS1(maxIndx);
            maskFile = false(size(maskFile));
            maskFile(maxIndx) = true;
        end

        if (fileSizeNew ~= fileSizeOld) || (flagCheckGDAS1 && (~ processedWithGDAS1))
            taskEntry.pollyName = {pollyDBDataTable.pollyName{maskFile}};
            taskEntry.filename = {basename(pollyDBDataTable.fileName{maskFile})};
            taskEntry.filePath = {pollySaveData(iFile).filePath};
            taskEntry.fileSize = fileSizeNew;
            taskEntry.GDAS1 = pollyDBDataTable.GDAS1(maskFile);
            taskEntry.date = pollySaveData(iFile).date;

            taskTable = [taskTable; struct2table(taskEntry)];
        end
    end
end

% close the database connection
close(conn);

%% unzipping the data
unzipStatus = false(length(taskTable.filename));
unzipFilename = cell(size(taskTable.filename));
for iTask = 1:length(taskTable.filename)
    % unzipping the data
    fprintf('Unzipping %s to the todo foler. \n%f%% finished.\n', taskTable.filename{iTask}, iTask/length(taskTable.filename)*100);
    try
        % unzip the data file
        pollyUnzipFile = unzip(fullfile(taskTable.filePath{iTask}, taskTable.filename{iTask}), fullfile(todoPath, taskTable.pollyName{iTask}, 'data_zip'));

        unzipStatus(iTask) = true;
        unzipFilename(iTask) = pollyUnzipFile;
    catch
        unzipStatus(iTask) = false;
        unzipFilename{iTask} = '';
        warning('Failure in unzipping %s', fullfile(taskTable.filePath{iTask}, taskTable.filename{iTask}));
    end
    
    try
        laserlogbookFile = fullfile(taskTable.filePath{iTask}, [taskTable.filename{iTask}(1:end-4), '.laserlogbook.txt.zip']);
        if exist(laserlogbookFile, 'file') == 2
            % unzip the laserlogbook file
            unzip(laserlogbookFile, fullfile(todoPath, taskTable.pollyName{iTask}, 'data_zip'));
        end
    catch
        warning('Failure in unzipping %s', laserlogbookFile);
    end
end

% write entry to the fileinfo_new
fid = fopen(picassoConfig.fileinfo_new, 'w');

for iTask = 1:length(taskTable.filename)
    if unzipStatus(iTask)
        fprintf(fid, '%s, %s, %s, %s, %d, %s\n', todoPath, fullfile(taskTable.pollyName{iTask}, 'data_zip'), basename(unzipFilename{iTask}), fullfile(datestr(taskTable.date(iTask), 'yyyymm'), taskTable.filename{iTask}), taskTable.fileSize(iTask), upper(taskTable.pollyName{iTask}));
    end
end

fclose(fid);

flag = true;

% convert polly housekeeping temp file to laserlogbook file
% This part is only necessary to be configured when you run this code on the rsd server
pollyList = {'pollyxt_tjk'};   % polly list of which needs to be converted
pollyTempFolder = {'/pollyhome/pollyxt_tjk/log'};   % root directory of the temps file
convert_temp_2_laserlogbook(picassoConfig.fileinfo_new, pollyList, pollyTempFolder);

end