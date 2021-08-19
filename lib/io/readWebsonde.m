function [alt, temp, pres, rh, wins, wind, globalAttri] = readWebsonde(measTime, ...
                                                            tRange, sitenum)
% READWEBSONDE search the closest radionsde based on the ui in 
% http://weather.uwyo.edu/upperair/sounding.html. And read the data.
%
% USAGE:
%    [alt, temp, pres, rh, wins, wind, globalAttri] = readWebsonde(measTime, tRange, sitenum)
%
% INPUTS:
%    measTime: float
%        polly measurement time. [datenum] 
%    tRange: 2-element array
%        search range for the online radiosonde. [current whole day]
%    sitenum: integer
%        site number, which can be found in doc/radiosonde-station-list.txt. 
%        You can update the list with using download_radiosonde_list.m
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
%    wind: array
%        wind direction. [degree]
%    wins: array
%        wind speed [m/s]
%    globalAttri: struct
%        URL: URL which can be used to retrieve the current returned values.
%        datetime: measurement time for current used sonde. [datenum]
%        sitenum: site number for current used sonde.
%
% HISTORY:
%    - 2021-05-24: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

alt = [];
temp = [];
pres = [];
rh = [];
wins = [];
wind = [];
globalAttri = struct();
globalAttri.URL = '';
globalAttri.datetime = [];
globalAttri.sitenum = [];

[thisYear, thisMonth, day1] = datevec(tRange(1)); 
[~, ~, day2] = datevec(tRange(2)); 
URL = sprintf(['http://weather.uwyo.edu/cgi-bin/sounding?region=europe&' ...
    'TYPE=TEXT%%3ALIST&YEAR=%04d&MONTH=%02d&FROM=%02d00&TO=%02d00&STNM=%5d'], ...
    thisYear, thisMonth, day1, day2, sitenum);

[pressure, altitude, temperature, relh, thisWins, thisWind, mTime] = ceilo_bsc_WebSonde(URL);

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
wins = thisWins{iSonde};
wind = thisWind{iSonde};

end