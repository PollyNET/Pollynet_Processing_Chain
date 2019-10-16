function [] = write_daily_to_filelist(pollyType, saveFolder, ...
            pollynetConfigFile, year, month, day, writeMode)
        %WRITE_DAILY_TO_FILELIST Unzip the polly data and write the data info to the 
%todolist file for pollynet processing chain.
%   Example:
%       [] = write_daily_to_filelist(pollyType, saveFolder, pollynetConfigFile, 
%           year, month, day, writeMode)
%   Inputs:
%       pollyType: char
%           polly instrument. 
%           e.g., arielle
%       saveFolder: char
%           polly data folder. 
%           e.g., /oceanethome/pollyxt
%       pollynetConfigFile: char
%           the absolute path of the pollynet configuration file.
%           e.g., /home/picasso/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json
%       year: integer | char
%       month: integer | char
%       day: integer | char
%       writeMode: char
%           If writeMode was 'a', the polly data info will be appended. If 'w', 
%           a new todofile will be created.
%   Outputs:
%   History:
%       2019-07-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

projectDir = fileparts(fileparts(mfilename('fullpath')));

%% add library path
addpath(fullfile(projectDir, 'lib'));
addpath(fullfile(projectDir, 'include', 'jsonlab-1.5'))

if ~ exist('writeMode', 'var')
    writeMode = 'w';
end

if ischar(year)
    year = str2double(year);
end
if ischar(month)
    month = str2double(month);
end
if ischar(day)
    day = str2double(day);
end

% load pollynet_processing_chain config
if exist(pollynetConfigFile, 'file') ~= 2
    error(['Error in pollynet_processing_main: ' ...
           'Unrecognizable configuration file\n%s\n'], pollynetConfigFile);
else
    config = loadjson(pollynetConfigFile);
end

%% search zip files
files = dir(fullfile(saveFolder, 'data_zip', ...
                     sprintf('%04d%02d', year, month), ...
                     sprintf('%04d_%02d_%02d*.nc.zip', year, month, day)))

for iFile = 1:length(files)

    % if there are multiple files in a day, other entries will be appended. 
    if (iFile > 1) && (writeMode == 'w')
        writeMode = 'a';
    end

    write_single_to_filelist(pollyType, ...
    fullfile(saveFolder, 'data_zip', sprintf('%04d%02d', year, month), ...
    files(iFile).name), pollynetConfigFile, writeMode);
end

%% convert polly housekeeping temp file to laserlogbook file
% This part is only necessary to be configured when you run this code on the rsd server
pollyList = {'pollyxt_tjk'};   % polly list of which needs to be converted
pollyTempFolder = {'/pollyhome/pollyxt_tjk/log'};   % root directory of the temps file
convert_temp_2_laserlogbook(config.fileinfo_new, pollyList, pollyTempFolder);

end
