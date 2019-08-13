function [flag] = write_single_to_filelist(pollyType, pollyZipFilepath, pollynetConfigFile, writeMode)
%write_single_to_filelist Unzip the polly data to the todofile folder and setup the fileinfo_new.txt.
%   Example:
%       [flag] = write_single_to_filelist(pollyType, pollyZipFilepath, pollynetConfigFile, writeMode)
%   Inputs:
%       pollyType: char
%           polly instrument.
%       pollyZipFilepath: char
%           the absolute path the zipped polly data.
%       pollynetConfigFile: char
%           the absolute path of the pollynet configuration file.
%       writeMode: char
%           If writeMode was 'a', the polly data info will be appended. If 'w', a new todofile will be created.
%   Outputs:
%       flag: logical
%           if true, the file was extracted and inserted into the task list successfully. Vice versa.
%   History:
%       2019-01-01. First Edition by Zhenping
%       2019-08-13. Add new input of 'pollynetConfigFile' to enable read the todofile list from the configuration file. 
%                   Add the output of 'flag' to represent the status.
%   Contact:
%       zhenping@tropos.de

projectDir = fileparts(fileparts(mfilename('fullpath')));

%% add library path
addpath(fullfile(projectDir, 'lib'));
addpath(fullfile(projectDir, 'include', 'jsonlab-1.5'))

%% defaults for input
if ~ exist('writeMode', 'var')
    writeMode = 'w';
end

if ~ exist('pollynetConfigFile', 'var')
    pollynetConfigFile = fullfile(projectDir, 'config', 'pollynet_processing_chain_config.json');
end

%% initialization
flag = true;

% load pollynet_processing_chain config
if ~ exist(pollynetConfigFile, 'file')
	error('Error in pollynet_processing_main: Unrecognizable configuration file\n%s\n', pollynetConfigFile);
else
	config = loadjson(pollynetConfigFile);
end

if isempty(pollyZipFilepath) && strcmp(writeMode, 'w')
	fid = fopen(config.fileinfo_new, 'w');
	fclose(fid);
	return;
end

%% filenames for data and laserlogbook
pollyZipFolder = fileparts(pollyZipFilepath);
pollyZipFile = basename(pollyZipFilepath);
logbookZipFilepath = fullfile(pollyZipFolder, [pollyZipFile(1:(strfind(pollyZipFile, '.zip') - 1)), '.laserlogbook.txt.zip']);

%% unzip laserlogbook files to todofolder
if ~ exist(logbookZipFilepath, 'file')
    warning('laserlogbook file does not exist.\n%s', logbookZipFilepath);
else
    try
        logbookUnzipFile = unzip(logbookZipFilepath, fullfile(todolistFolder, pollyType, 'data_zip'));
    catch
        warning('Failure in unzipping the file %s', logbookZipFilepath);
    end
end
    
%% unzip polly data to todofolder
try
    % extract the file 
    fprintf('--->Extracting %s.\n', pollyZipFile);
    pollyUnzipFile = unzip(pollyZipFilepath, fullfile(todolistFolder, pollyType, 'data_zip'));
catch
    flag = false;
    warning('Failure in unzipping the file %s', pollyZipFile);
	return;
end

%% write the file to fileinfo_new.txt
fid = fopen(config.fileinfo_new, writeMode);

tmp = dir(pollyUnzipFile{1});
thisSize = tmp.bytes;

fprintf(fid, '%s, %s, %s, %s, %d, %s\n', todolistFolder, fullfile(pollyType, 'data_zip'), basename(pollyUnzipFile{1}), fullfile(pollyType, 'data_zip', [pollyZipFile(1:4), pollyZipFile(6:7)], pollyZipFile), thisSize, upper(pollyType));

fclose(fid);

end
