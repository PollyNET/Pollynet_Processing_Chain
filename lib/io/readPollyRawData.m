function [ data ] = readPollyRawData(file, varargin)
% READPOLLYRAWDATA Read polly raw data.
% USAGE:
%    data = readPollyRawData(file)
% INPUTS:
%    file: char
%        absolute path of the polly data.
% KEYWORDS:
%    flagFilterFalseMShots: logical
%        whether to filter out profiles with false shots number.
%    flagCorrectFalseMShots: logical
%        whether to correct false shots number.
%    flagDeleteData: logical
%        flag to control whether to delete the data files after extracting 
%        the data.
%    dataFileFormat: char
%        parsing rules for polly data filename.
% OUTPUTS:
%    data: struct
%        rawSignal: array
%            signal. [Photon Count]
%        mShots: array
%            number of the laser shots for each profile.
%        mTime: array
%            datetime array for the measurement time of each profile.
%        depCalAng: array
%            angle of the polarizer in the receiving channel. (>0 means 
%            calibration process starts). [degree]
%        zenithAng: numeric
%            zenith angle of the laser beam. [degree]
%        repRate: float
%            laser pulse repetition rate. [s^-1]
%        hRes: float
%            spatial resolution [m]
%        mSite: char
%            measurement site.
%        deadtime: matrix (channel x polynomial_orders)
%            deadtime correction parameters.
%        lat: float
%            latitude of measurement site. [degree]
%        lon: float
%            longitude of measurement site. [degree]
%        alt: float
%            altitude of measurement site. [degree]
%        filenameStartTime: datenum
%            start time extracted from filename.
% EXAMPLE:
% HISTORY:
%    2018-12-16: First edition by Zhenping.
%    2019-07-08: Read the 'laser_rep_rate'.
%    2020-04-16: Unify the argument interface.
%    2021-02-03: Extract start time from polly data filename.
% .. Authors: - zhenping@tropos.de

%% parse arguments
p = inputParser;

addRequired(p, 'file', @ischar);
addParameter(p, 'flagFilterFalseMShots', false, @islogical);
addParameter(p, 'flagCorrectFalseMShots', false, @islogical);
addParameter(p, 'flagDeleteData', false, @islogical);
addParameter(p, 'dataFileFormat', '', @ischar);

parse(p, file, varargin{:});

%% variables initialization
data = struct();
data.rawSignal = [];
data.mShots = [];
data.mTime = [];
data.depCalAng = [];
data.hRes = [];
data.zenithAng = [];
data.repRate = [];
data.mSite = [];
data.deadtime = [];
data.lat = [];
data.lon = [];
data.alt0 = [];

if exist(file, 'file') ~= 2
    warning('polly data file does not exist.\n%s\n', file);
    return;
end

%% read data
try
    rawSignal = double(ncread(file, 'raw_signal'));
    if is_nc_variable(file, 'deadtime_polynomial')
        deadtime = ncread(file, 'deadtime_polynomial');
    else
        deadtime = [];
    end
    mShots = ncread(file, 'measurement_shots');
    mTime = ncread(file, 'measurement_time');
    if is_nc_variable(file, 'depol_cal_angle')
        depCalAng = ncread(file, 'depol_cal_angle');
    else
        depCalAng = [];
    end
    hRes = ncread(file, 'measurement_height_resolution') * 0.15; % Unit: m
    zenithAng = ncread(file, 'zenithangle'); % Unit: deg
    repRate = ncread(file, 'laser_rep_rate');
    coordinates = ncread(file, 'location_coordinates');
    alt = ncread(file, 'location_height');
    fileInfo = ncinfo(file);
    mSite = fileInfo.Attributes(1, 1).Value;
catch
    warning('Failure in read polly data file.\n%s\n', file);
    return;
end

if p.Results.flagDeleteData
    delete(file);
end

% search the profiles with invalid mshots
flagFalseShots = false(1, size(mShots, 2));
for iChannel = 1:size(mShots, 1)
    tmp = (mShots(iChannel, :) > 620) | (mShots(iChannel, :) <= 0);
    flagFalseShots = flagFalseShots | tmp;
end

% filter non 30s profiles
if p.Results.flagFilterFalseMShots

    if sum(~ flagFalseShots) == 0
        fprintf(['No profile with mshots < 1e6 and mshots > 0 was found.\n', ...
                 'Please take a look inside %s\n'], file);
        return;
    else
        rawSignal = rawSignal(:, :, ~ flagFalseShots);
        mShots = mShots(:, ~ flagFalseShots);
        mTime = mTime(:, ~ flagFalseShots);
        if ~ isempty(depCalAng)
            depCalAng = depCalAng(~ flagFalseShots);
        end
    end

elseif p.Results.flagCorrectFalseMShots
    mShots(:, flagFalseShots) = 600;
    mTimeStart = floor(pollyParseFiletime(file, p.Results.dataFileFormat) / ...
                       datenum(0,1,0,0,0,30)) * datenum(0,1,0,0,0,30);
    [thisYear, thisMonth, thisDay, thisHour, thisMinute, thisSecond] = ...
                       datevec(mTimeStart);
    mTime(1, :) = thisYear * 1e4 + thisMonth * 1e2 + thisDay;
    mTime(2, :) = thisHour * 3600 + ...
                 thisMinute * 60 + ...
                 thisSecond + 30 .* (0:(size(mTime, 2) - 1));
end

data.filenameStartTime = pollyParseFiletime(file, p.Results.dataFileFormat);
data.zenithAng = zenithAng;
data.hRes = hRes;
data.mSite = mSite;
data.mTime = datenum(num2str(mTime(1, :)), 'yyyymmdd') + ...
             datenum(0, 1, 0, 0, 0, double(mTime(2, :)));
data.mShots = double(mShots);
data.depCalAng = depCalAng;
data.rawSignal = rawSignal;
data.deadtime = deadtime;
data.repRate = repRate;
if isempty(coordinates)
    data.lon = NaN;
    data.lat = NaN;
else
    data.lon = coordinates(2, 1);
    data.lat = coordinates(1, 1);
end
data.alt0 = alt;

end