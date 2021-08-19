function [fileinfo_new] = read_fileinfo_new(file)
% READ_FILEINFO_NEW read new file info.
%
% USAGE:
%    [fileinfo_new] = read_fileinfo_new(file)
%
% INPUTS:
%    file: char
%        filename of the fileinfo_new which locates in todo_filelist
%
% OUTPUTS:
%    fileinfo_new: struct
%        todoPath: cell
%            path of the todo_filelist
%        dataPath: cell
%            directory to the respective polly lidar data
%        dataFilename: cell
%            filename of the polly data
%        zipFile: cell
%            filename of the zipped polly data
%        dataSize: array
%            file size of the zipped polly data
%        pollyType: cell
%            polly lidar label. e.g., 'POLLYXT_TROPOS'
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

fileinfo_new = struct();
fileinfo_new.todoPath = {};
fileinfo_new.dataPath = {};
fileinfo_new.dataFilename = {};
fileinfo_new.zipFile = {};
fileinfo_new.dataSize = [];
fileinfo_new.pollyType = {};

if exist(file, 'file') ~= 2
    warning('fileinfo_new does not exist. \n%s\n', file);
    return;
end

try 
    fid = fopen(file, 'r');
    testSpec = '%s %s %s %s %s %s';
    data = textscan(fid, testSpec, 'Delimiter', ',', 'Headerlines', 0);
    fileinfo_new.todoPath = transpose(data{1});
    fileinfo_new.dataPath = transpose(data{2});
    fileinfo_new.dataFilename = transpose(data{3});
    fileinfo_new.zipFile = transpose(data{4});
    fileinfo_new.pollyType = transpose(data{6});

    for iTask = 1:length(data{5})
        fileinfo_new.dataSize = [fileinfo_new.dataSize, ...
                                 int32(str2double(data{5}{iTask}))];
    end

catch
    warning('Failure in reading fileinfo_new.\n%s\n', file);
    return;
end

if isempty(fileinfo_new.zipFile)
    fprintf('No processed data.\n');
    return;
end

end