function [alt, temp, pres, relh] = read_gdas1(tRange, gdas1site, folder)
%read_gdas1 read the gdas1 file for 
%   Example:
%       [alt, temp, pres, relh] = read_gdas1(tRange, gdas1site, folder)
%   Inputs:
%       tRange: 2-element array
%           search range. 
%       gdas1site: char
%           the location for gdas1. Our server will automatically produce the gdas1 products for all our pollynet location. You can find it in /lacroshome/cloudnet/data/model/gdas1
%   Outputs:
%       alt: array
%           altitute for each range bin. [m]
%       temp: array
%           temperature for each range bin. If no valid data, NaN will be filled. [C]
%       pres: array
%           pressure for each range bin. If no valid data, NaN will be filled. [hPa]
%       rh: array
%           relative humidity for each range bin. If no valid data, NaN will be filled. [%]
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

midTime = mean(tRange);
[thisyear, thismonth, thisday, thishour, thisminute, ~] =  datevec(midTime);
gdas1file = fullfile(folder, gdas1site, sprintf('%04d', thisyear), sprintf('%02d', thismonth), sprintf('%s_%04d%02d%02d_%02d_*.gdas1', gdas1site, thisyear, thismonth, thisday, round((thishour + thisminute/60)/3)*3));

[pres, alt, temp, relh] = ceilo_bsc_ModelSonde(gdas1file);

end