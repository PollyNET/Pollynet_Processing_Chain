function [alt, temp, pres, relh, wins, wind, gdas1file] = readGDAS1(tRange, gdas1site, folder)
% READGDAS1 read the gdas1 file
% EXAMPLE:
%    [alt, temp, pres, relh] = readGDAS1(tRange, gdas1site, folder)
% INPUTS:
%    tRange: 2-element array
%        search range. 
%    gdas1site: char
%        the location for gdas1. Our server will automatically produce the 
%        gdas1 products for all our pollynet location. You can find it in 
%        /lacroshome/cloudnet/data/model/gdas1
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
% HISTORY:
%    2018-12-22.:First Edition by Zhenping
% .. Authors: - zhenping@tropos.de

midTime = mean(tRange);
[thisyear, thismonth, thisday, thishour, ~, ~] = ...
            datevec(round(midTime / datenum(0, 1, 0, 3, 0, 0)) * ...
            datenum(0, 1, 0, 3, 0, 0));
gdas1file = fullfile(folder, gdas1site, sprintf('%04d', thisyear), ...
            sprintf('%02d', thismonth), ...
            sprintf('*_%04d%02d%02d_%02d*.gdas1', ...
            thisyear, thismonth, thisday, thishour));

[pres, alt, temp, relh, wind, wins] = ceilo_bsc_ModelSonde(gdas1file);

end