function [ pressure, altitude, temperature, relh, mTime ] = ceilo_bsc_WebSonde( URL )
%Reads pressure, altitude and temperature arrays from sounding file given
%in specified weblocation
%   This function reads pressure, altitude and temperature arrays from
%   sounding for the specified web location.
%
%   Input arguments:
%   
%   URL         - string containing URL where web content regarding an
%                 appropriate sounding file is stored
%
%   Output arguments:
%
%   pressure    - pressure [hPa]
%
%   altitude    - height [m]
%
%   temperature - temperature [�C]
%
%   relh        - relative humidity [%]
%
%   mTime       - launching time. [datenum]
%   
%   History:
%       read the radiosonde data in the given time period. (Raw version from Birgit Heese.)

% get data from internet (example url:
% 'http://weather.uwyo.edu/cgi-bin/sounding?region=europe&TYPE=TEXT%3ALIST&YEAR=2015&MONTH=03&FROM=2312&TO=2312&STNM=10393')

pressure = cell(0);
altitude = cell(0);
temperature = cell(0);
relh = cell(0);
mTime = [];

[radiosonde, status] = urlread (URL, 'Timeout', 10);

if status == 0
    fprintf ('Could not import radiosonde data from web.\n');
end

startPos = strfind(radiosonde, '-----------------------------------------------------------------------------');
endPos = strfind(radiosonde, '</PRE><H3>Station');
obTimePos = strfind(radiosonde, 'Observation time:');

if numel(startPos) == 0 || numel(endPos) == 0 || numel(obTimePos) == 0
    fprintf ('Problem with radiosonde from website:\n %s\n', URL);
    return;
end

for iSonde = 1:int32(numel(startPos)/2)
    iStartPos = startPos(iSonde*2) + 79;
    iEndPos = endPos(iSonde) - 1;

    currentRadiosonde = radiosonde(iStartPos:iEndPos);

    % radiosonde should now be a string, where each line has 11 values and for
    % each value there should be 7 digits. each line then has 7*11 characters
    % plus the newline information contained in character 78 at the end of the line

    % check if number of entries in radiosonde is insufficient
    lines = floor(length(currentRadiosonde)/78);
    %% 
    if lines < 10
        continue;
    end
        
    pres = NaN(lines,1);
    alt = NaN(lines,1);
    temp = NaN(lines,1);
    rh = NaN(lines, 1);
    obTime = datenum(radiosonde((obTimePos + 18):(obTimePos + 28)), 'yymmdd/HHMM');
    
    for k = 1:lines
        index = (k-1)*78 + 1;
        
        if numel(sscanf(currentRadiosonde(index:index+6), '%g')) == 0
            pres(k) = NaN;
        else
            pres(k) = sscanf(currentRadiosonde(index:index+6), '%g');
        end
        
        if numel(sscanf(currentRadiosonde(index+7:index+13), '%g')) == 0
            alt(k) = NaN;
        else
            alt(k) = sscanf(currentRadiosonde(index+7:index+13), '%g');
        end
        
        if numel(sscanf(currentRadiosonde(index+14:index+20), '%g')) == 0
            temp(k) = NaN;
        else
            temp(k) = sscanf(currentRadiosonde(index+14:index+20), '%g');
        end
        
        if numel(sscanf(currentRadiosonde(index+28:index+34), '%g')) == 0
            rh(k) = NaN;
        else
            rh(k) = sscanf(currentRadiosonde(index+28:index+34), '%g');
        end
        
    end

    temperature{end + 1} = temp;
    pressure{end + 1} = pres;
    altitude{end + 1} = alt;
    relh{end + 1} = rh;
    mTime(end + 1) = obTime;
end

end
