function [output] = write_to_filelist(instrument, year, month, day, writeMode)
%write_to_filelist description
%   Example:
%       [output] = write_to_filelist(instrument, year, month, day, writeMode)
%   Inputs:
%       instrument, year, month, day, writeMode
%   Outputs:
%       output
%   History:
%       2019-01-01. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

%% parameter initialization
saveFolder = '/pollyhome';    % folder which saving the zip files
todoFolder = '/pollyhome/Picasso/todo_filelist';
todoListFile = '/pollyhomePicasso/todo_filelist/fileinfo_new.txt';

%% search zip files
files = dir(fullfile(saveFolder, instrument, 'data_zip', sprintf('%04d%02d', year, month), sprintf('%04d_%02d_%02d*.nc.zip', year, month, day)));
logbookFiles = dir(fullfile(saveFolder, instrument, sprintf('%04d%02d', year, month), sprintf('%04d_%02d_%02d*.nc.laserlogbook.txt.zip', year, month, day)));

%% unzip laserlogbook files to todofolder
for iFile = 1:length(logbookFiles)
    zipFile = logbookFiles(iFile).name;
    file = unzip(fullfile(saveFolder, instrument, sprintf('%04d%02d', year, month), zipFile), ...
    fullfile(todoFolder, instrument, 'data_zip'));
end

%% write the file to fileinfo_new.txt
fid = fopen(todoListFile, writeMode);

for iFile = 1:length(files)
    zipFile = files(iFile).name;

    % extract the file 
    fprintf('--->Extracting %s.\n', zipFile);
    file = unzip(fullfile(saveFolder, instrument, sprintf('%04d%02d', year, month), zipFile), ...
                    fullfile(todoFolder, instrument, 'data_zip'));    % read the netCDF file
    file = file{1, 1};
    tmp = dir(file);
    thisSize = tmp.bytes;

    fprintf(fid, '%s, %s, %s, %s, %d, %s\n', todoFolder, fullfile(instrument, 'data_zip'), basename(file), fullfile(instrument, 'data_zip', sprintf('%04d%02d', year, month), sprintf('%s.zip', basename(file))), thisSize, upper(instrument));
    
end

fclose(fid);

end