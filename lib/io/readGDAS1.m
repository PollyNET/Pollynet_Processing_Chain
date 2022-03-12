function [alt, temp, pres, relh, wins, wind, gdas1file] = readGDAS1(tRange, gdas1site, folder, varargin)
% READGDAS1 read gdas1 file
%
% EXAMPLE:
%    [alt, temp, pres, relh] = readGDAS1(tRange, gdas1site, folder)
%
% INPUTS:
%    tRange: 2-element array
%        search range. 
%    gdas1site: char
%        the location for gdas1. Our server will automatically produce the 
%        gdas1 products for all our pollynet location. You can find it in 
%        /lacroshome/cloudnet/data/model/gdas1
%
% KEYWORDS:
%    isUseLatestGDAS: logical
%        whether to search the latest available GDAS profile (default: false).
%
% OUTPUTS:
%    alt: array
%        altitute for each range bin. [m]
%    temp: array
%        temperature for each range bin. If no valid data, NaN will be 
%        filled. [C]
%    pres: array
%        pressure for each range bin. If no valid data, NaN will be filled. 
%        [hPa]
%    rh: array
%        relative humidity for each range bin. If no valid data, NaN will be 
%        filled. [%]
%    wins: array
%        wind speed [m/s]
%    wind: array
%        wind direction. [degree]
%    gdas1file: char
%        filename of gdas1 file. 
%
% HISTORY:
%    - 2018-12-22.:First Edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'tRange', @isnumeric);
addRequired(p, 'gdas1site', @ischar);
addRequired(p, 'folder', @ischar);
addParameter(p, 'isUseLatestGDAS', false, @islogical);

parse(p, tRange, gdas1site, folder, varargin{:});

midTime = mean(tRange);

if p.Results.isUseLatestGDAS
    [startYear, startMonth, ~] = datevec(midTime - datenum(0, 3, 1));
    [stopYear, stopMonth, ~] = datevec(midTime + 1);

    dateList = dateArr(datenum(startYear, startMonth, 1), ...
                       datenum(stopYear, stopMonth, 1), 'Interval', 'month');
    gdas1Files = cell(0);
    gdas1Times = [];
    for iDate = 1:length(dateList)
        gdasSubDir = fullfile(folder, gdas1site, ...
            datestr(dateList(iDate), 'yyyy'), ...
            datestr(dateList(iDate), 'mm'));
        %disp(gdasSubDir)
        if exist(gdasSubDir, 'dir')
            thisFiles = listfile(gdasSubDir, '.*.gdas1');
            %disp(thisFiles)
        else
            thisFiles = {};
        end

        for iFile = 1:length(thisFiles)
            gdas1Files = cat(2, gdas1Files, thisFiles{iFile});
            gdas1Times = cat(2, gdas1Times, gdas1FileTimestamp(basename(thisFiles{iFile})));
        end
    end

    % find the latest GDAS profile
    [~, latestInd] = min(abs(gdas1Times - midTime));
    if ~ isempty(latestInd)
        gdas1file = gdas1Files{latestInd};
    else
        gdas1file = '';
    end
else
    [thisyear, thismonth, thisday, thishour, ~, ~] = ...
                datevec(round(midTime / datenum(0, 1, 0, 3, 0, 0)) * ...
                datenum(0, 1, 0, 3, 0, 0));
    gdas1file = fullfile(folder, gdas1site, sprintf('%04d', thisyear), ...
                sprintf('%02d', thismonth), ...
                sprintf('*_%04d%02d%02d_%02d*.gdas1', ...
                thisyear, thismonth, thisday, thishour));
end

[pres, alt, temp, relh, wind, wins] = ceilo_bsc_ModelSonde(gdas1file);

end