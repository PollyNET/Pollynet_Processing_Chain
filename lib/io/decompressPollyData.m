function decompressPollyData(startDate, endDate, saveFolder, PicassoConfigFile, varargin)
% DECOMPRESSPOLLYDATA Unzip the polly data and write data info to the todolist file for pollynet processing chain.
% USAGE:
%    decompressPollyData(startDate, endDate, saveFolder, PicassoConfigFile)
% INPUTS:
%    startDate: numeric
%        start date of polly data to be decompressed. i.e, datenum(2015, 1, 1) stands for Jan 1st, 2015.
%    endDate: numeric
%        stop date of polly data to be decompressed.
%    saveFolder: char
%        polly data folder. 
%        e.g., /oceanethome/pollyxt
%    PicassoConfigFile: char
%        the absolute path of the pollynet configuration file.
%        e.g., /home/picasso/Pollynet_Processing_Chain/config/pollynet_processing_chain_config.json
% KEYWORDS:
%    pollyType: char
%        polly instrument. 
%        e.g., arielle
%    mode: char
%        If mode was 'a', the polly data info will be appended. If 'w', 
%        a new todofile will be created.
% HISTORY:
%    2019-07-21: First Edition by Zhenping
%    2019-10-16: Add warnings when no polly data files were found.
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'startDate', @isnumeric);
addRequired(p, 'endDate', @isnumeric);
addRequired(p, 'saveFolder', @ischar);
addRequired(p, 'PicassoConfigFile', @ischar);
addParameter(p, 'pollyType', '', @ischar);
addParameter(p, 'mode', 'a', @ischar);

parse(p, startDate, endDate, saveFolder, PicassoConfigFile, varargin{:});

if isempty(p.Results.pollyType)
    pollyType = basename(p.Results.saveFolder);
else
    pollyType = p.Results.pollyType;
end

writeMode = p.Results.mode;

% load pollynet_processing_chain config
if exist(PicassoConfigFile, 'file') ~= 2
    error(['Error in pollynet_processing_main: ' ...
           'Unrecognizable configuration file\n%s\n'], PicassoConfigFile);
else
    config = loadjson(PicassoConfigFile);
end

fileCounter = 0;
for iDate = startDate:ceil(endDate)

    [thisYear, thisMonth, thisDay] = datevec(iDate);

    %% search zip files
    files = listfile(fullfile(saveFolder, 'data_zip', sprintf('%04d%02d', thisYear, thisMonth)), ...
            sprintf('%04d_%02d_%02d.*\\w{2}_\\w{2}_\\w{2}.nc.zip', thisYear, thisMonth, thisDay));

    if isempty(files)
        fprintf('No polly data for %s at %s\n', pollyType, datestr(iDate, 'yyyy-mm-dd'));
    end

    fileCounter = fileCounter + length(files);

    for iFile = 1:length(files)

        fileTime = pollyParseFiletime(files{iFile}, '(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc.zip');

        if (fileTime > endDate) || (fileTime < startDate)
            continue;
        end

        % if there are multiple files in a day, all files will be appended. 
        if (iFile > 1) && (writeMode == 'w')
            writeMode = 'a';
        end

        pollyZipFolder = fileparts(files{iFile});
        pollyZipFile = basename(files{iFile});
        logbookZipFilepath = fullfile(pollyZipFolder, ...
                [pollyZipFile(1:(strfind(pollyZipFile, '.zip') - 1)), ...
                '.laserlogbook.txt.zip']);
        todolistFolder = fileparts(config.fileinfo_new);

        %% unzip laserlogbook files to todofolder
        if exist(logbookZipFilepath, 'file') ~= 2
            warning('Zipped laserlogbook file does not exist.\n%s', logbookZipFilepath);
        else
            try
                unzip(logbookZipFilepath, fullfile(todolistFolder, pollyType, 'data_zip'));
            catch
                warning('Failure in unzipping the file %s', logbookZipFilepath);
            end
        end

        %% unzip polly data to todofolder
        try
            % extract the file 
            fprintf('---> Extracting %s.\n', pollyZipFile);
            pollyUnzipFile = unzip(files{iFile}, ...
                fullfile(todolistFolder, pollyType, 'data_zip'));
        catch
            warning('Failure in unzipping the file %s', pollyZipFile);
            continue;
        end

        %% write the file to fileinfo_new.txt
        fid = fopen(config.fileinfo_new, writeMode);
        
        fileInfo = dir(pollyUnzipFile{1});

        fprintf(fid, '%s, %s, %s, %s, %d, %s\n', todolistFolder, ...
                fullfile(pollyType, 'data_zip'), basename(pollyUnzipFile{1}), ...
                fullfile([pollyZipFile(1:4), pollyZipFile(6:7)], pollyZipFile), ...
                fileInfo.bytes, upper(pollyType));

        fclose(fid);
    end
end

if fileCounter == 0
    warning('No polly data file was found.');
else
    fprintf('%d polly data files was found.\n', fileCounter);
end

%% convert polly housekeeping temp file to laserlogbook file
% This part is only necessary to be configured when you run this code on the rsd server
pollyList = {'pollyxt_tjk', 'pollyxt_cyp'};   % polly list of which needs to be converted
pollyTempFolder = {'/data/level0/polly/pollyxt_tjk/log', ...
                   '/data/level0/polly/pollyxt_cyp/temps'};   % root directory of the temps file
convert_temp_2_laserlogbook(config.fileinfo_new, pollyList, pollyTempFolder);

end
