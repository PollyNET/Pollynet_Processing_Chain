function [alt, temp, pres, rh, globalAttri] = read_websonde(measTime, tRange, sitenum)
%read_websonde search the closest radionsde based on the ui in http://weather.uwyo.edu/upperair/sounding.html. And read the data.
%   Example:
%       [alt, temp, pres, rh, globalAttri] = read_websonde(measTime, tRange, sitenum)
%   Inputs:
%       measTime: float
%           polly measurement time. [datenum] 
%       tRange: 2-element array
%           search range for the online radiosonde. [current whole day]
%       sitenum: integer
%           site number, which can be found in doc/radiosonde-station-list.txt. You can update the list with using download_radiosonde_list.m
%   Outputs:
%       alt: array
%           altitute for each range bin. [m]
%       temp: array
%           temperature for each range bin. If no valid data, NaN will be filled. [C]
%       pres: array
%           pressure for each range bin. If no valid data, NaN will be filled. [hPa]
%       rh: array
%           relative humidity for each range bin. If no valid data, NaN will be filled. [%]
%       globalAttri: struct
%           URL: URL which can be used to retrieve the current returned values.
%           datetime: measurement time for current used sonde. [datenum]
%           sitenum: site number for current used sonde.
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

alt = [];
temp = [];
pres = [];
rh = [];

[thisYear, thisMonth, day1] = datevec(tRange(1)); 
[~, ~, day2] = datevec(tRange(2)); 
URL = sprintf('http://weather.uwyo.edu/cgi-bin/sounding?region=europe&TYPE=TEXT%3ALIST&YEAR=%04d&MONTH=%02d&FROM=%02d00&TO=%02d00&STNM=%5d', thisYear, thisMonth, day1, day2, sitenum);

[pressure, altitude, temperature, relh, mTime] = ceilo_bsc_WebSonde(URL);

if isempty(mTime)
    warning('No radiosonde data was found.\n%s\n', URL);
    return;
end

[datetime, iSonde] = min(abs(measTime - mTime));
globalAttri.URL = URL;
globalAttri.datetime = datetime;
globalAttri.sitenum = sitenum;

alt = altitude{iSonde};
temp = temperature{iSonde};
rh = relh{iSonde};
pres = pressure{iSonde};

end