function [] = write_single_to_filelist(pollyType, pollyZipFilepath, todolistFolder, writeMode)
%write_single_to_filelist Unzip the polly data to the todofile folder and setup the fileinfo_new.txt.
%   Example:
%       [output] = write_single_to_filelist(pollyType, pollyZipFilepath, todolistFolder, writeMode)
%   Inputs:
%       pollyType: char
%           polly instrument.
%       pollyZipFilepath: char
%           the absolute path the zipped polly data.
%       todolistFolder: char
%           the folder of the todolist
%       writeMode: char
%           If writeMode was 'a', the polly data info will be appended. If 'w', a new todofile will be created.
%   Outputs:
% 
%   History:
%       2019-01-01. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('writeMode', 'var')
    writeMode = 'w';
end

projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectDir, 'lib'));
addpath(fullfile(projectDir, 'include', 'jsonlab-1.5'))

% load pollynet_processing_chain config
configFile = fullfile(projectDir, 'config', 'pollynet_processing_chain_config.json');
if ~ exist(configFile, 'file')
	error('Error in pollynet_processing_main: Unrecognizable configuration file\n%s\n', configFile);
else
	config = loadjson(configFile);
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
