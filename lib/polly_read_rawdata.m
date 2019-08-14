function [ data ] = polly_read_rawdata(file, config, flagDelete)
%POLLY_READ_RAWDATA read polly raw data.
%   Usage:
%       data = polly_read_rawdata(file, config, flagDelete)
%   Inputs:
%       file: char
%           fullpath of polly data file.
%       config: struct
%           configuration. Detailed information can be found in 
%           doc/polly_config.md.
%       flagDelete: logical
%           flag to control whether to delete the data files after extracting 
%           the data.
%   Outputs:
%       data: struct
%           rawSignal: array
%               signal. [Photon Count]
%           mShots: array
%               number of the laser shots for each profile.
%           mTime: array
%               datetime array for the measurement time of each profile.
%           depCalAng: array
%               angle of the polarizer in the receiving channel. (>0 means 
%               calibration process starts)
%           zenithAng: array
%               zenith angle of the laer beam.
%           repRate: float
%               laser pulse repetition rate. [s^-1]
%           hRes: float
%               spatial resolution [m]
%           mSite: char
%               measurement site.
%           lat: float
%               latitude of measurement site. [degree]
%           lon: float
%               longitude of measurement site. [degree]
%           alt: float
%               altitude of measurement site. [degree]
%   History:
%       2018-12-16. First edition by Zhenping.
%       2019-07-08. Read the 'laser_rep_rate'.
%   Contact:
%       zhenping@tropos.de

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

if ~ exist(file, 'file')
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

if flagDelete
    delete(file);
end

% search the profiles with invalid mshots
flagFalseShots = false(1, size(mShots, 2));
for iChannel = 1:size(mShots, 1)
    tmp = (mShots(iChannel, :) > 1e6) | (mShots(iChannel, :) <= 0);
    flagFalseShots = flagFalseShots | tmp;
end

% filter non 30s profiles
if config.flagFilterFalseMShots

    if sum(~ flagFalseShots) == 0
        fprintf('No profile with mshots < 1e6 and mshots > 0 was found.\nPlease take a look inside %s\n', file);
        return;
    else
        rawSignal = rawSignal(:, :, ~ flagFalseShots);
        mShots = mShots(~ flagFalseShots);
        mTime = mTime(~ flagFalseShots);
        depCalAng = depCalAng(~ flagFalseShots);
    end

elseif config.flagCorrectFalseMShots
    mShots(:, flagFalseShots) = 600;
    mTimeStart = floor(polly_parsetime(file, config.dataFileFormat) / ...
                       datenum(0,1,0,0,0,30)) * datenum(0,1,0,0,0,30);
    [thisYear, thisMonth, thisDay, thisHour, thisMinute, thisSecond] = ...
                       datevec(mTimeStart);
    mTime(1, :) = thisYear * 1e4 + thisMonth * 1e2 + thisDay;
    mTime(2, :) = thisHour * 3600 + ...
                  thisMinute * 60 + ...
                  thisSecond + 30 .* (0:(size(mTime, 2) - 1));
end

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
data.lon = coordinates(1, 1);
data.lat = coordinates(2, 1);
data.alt0 = alt;

end