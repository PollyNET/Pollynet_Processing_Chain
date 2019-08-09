function [ pressure, altitude, temperature, relh ] = ceilo_bsc_ModelSonde( filename )
%Reads pressure, altitude and temperature arrays from gdas model sounding
%   
%   This function reads pressure, altitude and temperature arrays from gdas
%   model sounding for the specified filename.
%
%   Input arguments:
%   
%   filename    - string containing full filepath and filename
%               - can contain wildcard character instead of lon/lat
%                 information
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
%   History:
%       (Raw version from Birgit Heese.)
%       2018-12-15. Add ouput of relh

pressure    = NaN;
altitude    = NaN;
temperature = NaN;
relh        = NaN;

% in automated version filename is passed with wildcard character instead
% of lon/lat information. to get exact filename, list files first. filename
% should be unambiguous.
% filepath = filename(1:end-26);
[filepath,~,~] = fileparts(filename);
filenameList = dir(filename);
if numel(filenameList) == 0
    fprintf('gdas File (%s) does not exist.\n', filename);
    return;
end
% filename = [filepath filenameList(1).name];
filename = fullfile(filepath, filenameList(1).name);
fid = fopen(filename);

% if file does not exist or cannot be opened
if fid == -1
    fprintf('File (%s) does not exist or cannot be opened.\n', filename);
    return;
end

% headerlines, read and overwrite
for k = 1:9
    fgetl(fid);
end
% preallocate
pressure    = NaN(23,1);
altitude    = NaN(23,1);
temperature = NaN(23,1);
relh        = NaN(23,1);
% read relevant lines
for k = 1:23
    line = fgetl(fid);
    % check if next line has valid data
    if ~ischar(line)
        pressure    = NaN;
        altitude    = NaN;
        temperature = NaN;
        relh        = NaN;
        fprintf('gdas sonde is defective.\n');
        return;
    end
    pressure(k)    = str2double ( line (1:6) );
    altitude(k)    = str2double ( line (7:12) );
    temperature(k) = str2double ( line(13:18) );
    relh(k)        = str2double ( line(37:42) );
end
fclose(fid);

% if the sonde file has not been updated with actual data the entries are 0
% therefore the data needs a check
if sum(altitude) == 0
    fprintf('gdas sonde does not contain actual data.\n');
    pressure    = NaN;
    altitude    = NaN;
    temperature = NaN;
    relh        = NaN;
end

end

