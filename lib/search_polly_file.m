function [filePath] = search_polly_file(pollyFolder, thisTime, timeLapse)
%search_current_polly_file Search the most recent polly measurement data.
%   Example:
%       [filePath] = search_current_polly_file(pollyFolder, thisTime, timeLapse)
%   Inputs:
%       pollyFolder: char
%           the polly folder. 
%           e.g., 'C:\Users\zhenping\Documents\Data\PollyXT\arielle'. Don't include the 'data_zip'
%       thisTime: datenum
%           the base time you want to search.
%       timeLapse: float
%           the search range of the base time. [datenum]
%   Outputs:
%       filePath: char
%           the absolute path of the found polly data.
%   History:
%       2019-07-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('timeLapse', 'var')
    timeLapse = datenum(0, 1, 0, 6, 0, 0);
end

% parameter initialization
filePath = '';

if ~ exist(pollyFolder, 'dir')
    warning('The polly folder does not exist. Please check it!%s', pollyFolder);
    return;
end

[thisYear, thisMonth, thisDay, thisHour, thisMinute, thisSecond] = datevec(thisTime);

pollyMonthFolder = fullfile(pollyFolder, 'data_zip', datestr(thisTime, 'yyyymm'));
if ~ exist(pollyMonthFolder, 'dir')
    warning('No current measurement, at least in the same month.');
    return;
end

files = dir(fullfile(pollyMonthFolder, sprintf('%04d_%02d_%02d*.nc.zip', thisYear, thisMonth, thisDay)));

if isempty(files)
    warning('No current measurement, at least in the same day.');
    return;
end

% convert the filename to the measurement time
startMeasTime = [];
for iFile = 1:length(files)
    pollyFile = files(iFile).name;
    startMeasTime = [startMeasTime, datenum([datestr(thisTime, 'yyyymmdd'), pollyFile((end-14):(end-13)), pollyFile((end-11):(end-10)), pollyFile((end-8):(end-7))], 'yyyymmddHHMMSS')];
end

% search the closest filename.
flagWithinTimeLapse = abs(thisTime - startMeasTime) < timeLapse;
filesWithinTimeLapse = files(flagWithinTimeLapse);
if sum(flagWithinTimeLapse) == 0
    warning('No current measurement within %5.2f hour.', timeLapse / datenum(0, 1, 0, 1, 0, 0));
    return;
end
[~, closestIndx] = min(abs(thisTime - startMeasTime(flagWithinTimeLapse)));
pollyFile = filesWithinTimeLapse(closestIndx).name;

filePath = fullfile(pollyFolder, 'data_zip', datestr(thisTime, 'yyyymm'), pollyFile);

end

