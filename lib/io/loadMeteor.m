function [temp, pres, relh, wins, wind, meteorAttri] = loadMeteor(mTime, asl, varargin)
% LOADMETEOR read meteorological data.
% USAGE:
%    [temp, pres, relh, wins, wind, meteorAttri] = loadMeteor(mTime, asl, varargin)
% INPUTS:
%    mTime: array
%       query time.
%   asl: array
%       height above sea level. (m)
% KEYWORDS:
%    meteorDataSource: str
%        meteorological data type.
%        e.g., 'gdas1'(default), 'standard_atmosphere', 'websonde', 'radiosonde'
%    gdas1Site: str
%        the GDAS1 site for the current campaign.
%    gdas1_folder: str
%        the main folder of the GDAS1 profiles.
%    radiosondeSitenum: integer
%        site number, which can be found in 
%        doc/radiosonde-station-list.txt.
%    radiosondeFolder: str
%        the folder of the sonding files.
%    radiosondeType: integer
%        file type of the radiosonde file.
%        - 1: radiosonde file for MOSAiC (default)
%        - 2: radiosonde file for MUA
%   flagReadLess: logical
%       flag to determine whether access meteorological data by certain time
%       interval. (default: false)
%   method: char
%       Interpolation method. (default: 'nearest')
% OUTPUTS:
%   temp: matrix (time * height)
%       temperature for each range bin. [C]
%   pres: matrix (time * height)
%       pressure for each range bin. [hPa]
%   relh: matrix (time * height)
%       relative humidity for each range bin. [%]
%   wins: matrix (time * height)
%       wind speed. (m/s)
%   meteorAttri: struct
%       dataSource: cell
%           The data source used in the data processing for each cloud-free group.
%       URL: cell
%           The data file info for each cloud-free group.
%       datetime: array
%           datetime label for the meteorlogical data.
% EXAMPLE:
% HISTORY:
%    2021-05-22: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'mTime', @isnumeric);
addRequired(p, 'asl', @isnumeric);
addParameter(p, 'meteorDataSource', 'gdas1', @ischar);
addParameter(p, 'gdas1Site', 'leipzig', @ischar);
addParameter(p, 'gdas1_folder', '', @ischar);
addParameter(p, 'radiosondeSitenum', 0, @isnumeric);
addParameter(p, 'radiosondeFolder', '', @ischar);
addParameter(p, 'radiosondeType', 1, @isnumeric);
addParameter(p, 'flagTemporalInterp', false, @islogical);
addParameter(p, 'flagReadLess', false, @islogical);
addParameter(p, 'method', 'nearest', @ischar);

parse(p, mTime, asl, varargin{:});

meteorAttri.dataSource = cell(0);
meteorAttri.URL = cell(0);
meteorAttri.datetime = [];

if p.Results.flagReadLess
    % Reading meteorological data is very time consuming, which would decrease
    % data processing efficiency substantially if it was done for each measurement
    % time. However, this does not make sense as many measurement time correspond to
    % the same meteorological profile. Therefore, using the keyword 'flagReadLess'
    % can avoid it because it only allow the program to access meteorological at 
    % interval of 1 hour.
    mTimeQry = mTime(1):datenum(0, 1, 0, 3, 0, 0):mTime(end);
else
    mTimeQry = mTime;
end

tempQry = [];
presQry = [];
relhQry = [];
winsQry = [];
windQry = [];

%% read meteorological data
for iTime = 1:length(mTimeQry)

    [altRaw, tempRaw, presRaw, relhRaw, winsRaw, windRaw, attri] = readMeteor(mTimeQry(iTime), varargin{:});
    meteorAttri.dataSource{end + 1} = attri.dataSource;
    meteorAttri.URL{end + 1} = attri.URL;
    meteorAttri.datetime = cat(2, meteorAttri.datetime, attri.datetime);

    % interp the parameters
    tempI = interpMeteor(altRaw, tempRaw, asl);
    presI = interpMeteor(altRaw, presRaw, asl);
    relhI = interpMeteor(altRaw, relhRaw, asl);
    winsI = interpMeteor(altRaw, winsRaw, asl);
    windI = interpMeteor(altRaw, windRaw, asl);

    % concatenate the parameters
    tempQry = cat(1, tempQry, tempI);
    presQry = cat(1, presQry, presI);
    relhQry = cat(1, relhQry, relhI);
    winsQry = cat(1, winsQry, winsI);
    windQry = cat(1, windQry, windI);
end

%% interp meteorological data
[MTIMEQRY, ASLQRY] = meshgrid(asl, mTimeQry);
[MTIME, ASL] = meshgrid(asl, mTime);
if length(mTimeQry) == 1
    temp = repmat(tempQry, length(mTime), 1);
    pres = repmat(presQry, length(mTime), 1);
    relh = repmat(relhQry, length(mTime), 1);
    wins = repmat(winsQry, length(mTime), 1);
    wind = repmat(windQry, length(mTime), 1);
elseif length(mTimeQry) >= 2
    temp = interp2(MTIMEQRY, ASLQRY, tempQry, MTIME, ASL, p.Results.method);
    pres = interp2(MTIMEQRY, ASLQRY, presQry, MTIME, ASL, p.Results.method);
    relh = interp2(MTIMEQRY, ASLQRY, relhQry, MTIME, ASL, p.Results.method);
    wins = interp2(MTIMEQRY, ASLQRY, winsQry, MTIME, ASL, p.Results.method);
    wind = interp2(MTIMEQRY, ASLQRY, windQry, MTIME, ASL, p.Results.method);
else
    temp = [];
    pres = [];
    relh = [];
    wins = [];
    wind = [];
end

end