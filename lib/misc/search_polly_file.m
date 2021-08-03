function [filePath] = search_polly_file(pollyFolder, thisTime, timeLapse, flagLatest, flagModifiedTime)
% SEARCH_POLLY_FILE Search the most recent polly measurement data.
% USAGE:
%    [filePath] = search_polly_file(pollyFolder, thisTime, timeLapse)
% INPUTS:
%    pollyFolder: char
%        the polly folder. 
%        e.g., 'C:\Users\zhenping\Documents\Data\PollyXT\arielle'. 
%        Don't include the 'data_zip'
%    thisTime: datenum
%        the base time you want to search.
%    timeLapse: float
%        the search range of the base time. [datenum]
%    flagLatest: logical
%        whether to take the latest file only. (Defaults: false)
%    flagModifiedTime: logical
%        whether to search file based on its modified time. (Defaults: true)
% OUTPUTS:
%    filePath: cell
%        the absolute path of the found polly data files.
% HISTORY:
%    2019-07-22: First Edition by Zhenping
%    2019-08-07: Enable the output of multiple filepaths.
%    2019-08-09: Add the variable to control the output of the latest polly 
%                data file.
%    2019-09-02: Add the flag to search the recent files based on the 
%                modiefied time.
% .. Authors: - zhenping@tropos.de

if ~ exist('timeLapse', 'var')
    timeLapse = datenum(0, 1, 0, 6, 0, 0);
end

if ~ exist('flagLatest', 'var')
    flagLatest = false;
end

if ~ exist('flagModifiedTime', 'var')
    flagModifiedTime = false;
end

% parameter initialization
filePath = cell(0);

if ~ exist(pollyFolder, 'dir')
    warning('The polly folder does not exist. Please check it!%s', pollyFolder);
    return;
end

[thisYear, thisMonth, thisDay, thisHour, thisMinute, thisSecond] = ...
    datevec(thisTime);

pollyMonthFolder = fullfile(pollyFolder, 'data_zip', ...
                            datestr(thisTime, 'yyyymm'));
if ~ exist(pollyMonthFolder, 'dir')
    warning('No current measurement, at least in the same month.');
    return;
end

files = dir(fullfile(pollyMonthFolder, ...
            sprintf('%04d_%02d_%02d*.nc.zip', thisYear, thisMonth, thisDay)));

if isempty(files)
    warning('Still no current measurement in the day.');
    return;
end

% convert the filename to the measurement time
fileTime = [];
if ~ flagModifiedTime

    startMeasTime = [];
    % search file based on the measurement start time
    % this will omit the files when the files was uploaded with several hours 
    % delay
    for iFile = 1:length(files)
        pollyFile = files(iFile).name;
        startMeasTime = [startMeasTime, ...
                        datenum([datestr(thisTime, 'yyyymmdd'), ...
                        pollyFile((end-14):(end-13)), ...
                        pollyFile((end-11):(end-10)), ...
                        pollyFile((end-8):(end-7))], 'yyyymmddHHMMSS')];
    end

    fileTime = startMeasTime;

elseif flagModifiedTime

    fileModifiedTime = NaN(size(files));

    % search file based on the modified time
    for iFile = 1:length(files)
        fileModifiedTime(iFile) = datenum(files(iFile).date, 'dd-mmm-yyyy HH:MM:SS');
    end

    fileTime = fileModifiedTime;
else
    error('flagModifiedTime can only be logical value.');
end

% search the closest filename.
flagWithinTimeLapse = abs(thisTime - fileTime) < timeLapse;
filesWithinTimeLapse = files(flagWithinTimeLapse);
if sum(flagWithinTimeLapse) == 0
    warning('No current measurement within %5.2f hour.', ...
    timeLapse / datenum(0, 1, 0, 1, 0, 0));
    return;
end

if flagLatest
    % return the latest polly data file
    [~, indx] = min(abs(thisTime - fileTime));
    filePath{end + 1} = fullfile(pollyFolder, 'data_zip', ...
        datestr(thisTime, 'yyyymm'), files(indx).name);
else
    % return all searched data files
    for iFile = 1:length(filesWithinTimeLapse)
        filePath{end + 1} = fullfile(pollyFolder, 'data_zip', ...
            datestr(thisTime, 'yyyymm'), filesWithinTimeLapse(iFile).name);
    end
end

end

