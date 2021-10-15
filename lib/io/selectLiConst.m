function [lcUsed, lcUsedStd, lcUsedTag, lcUsedWarning] = selectLiConst(liconst, liconstStd, caliStartTime, caliStopTime, queryTime, dbFile, pollyType, wavelength, telescope, varargin)
% SELECTLICONST select the most suitable lidar constant.
%
% USAGE:
%    [lcUsed, lcUsedStd, lcUsedTag, lcUsedWarning] = selectLiConst(liconst, liconstStd, caliStartTime, caliStopTime, queryTime, dbFile, pollyType, wavelength)
%
% INPUTS:
%    liconst: array
%        lidar calibration constants.
%    liconstStd: array
%        uncertainty of lidar constants.
%    caliStartTime: array
%        start time for each lidar calibration period. (datenum)
%    caliStopTime: array
%        stop time for each lidar calibration period. (datenum)
%    queryTime: datenum
%        query time for searching the lidar calibration constant.
%    dbFile: char
%        path of SQLite database, which contains lidar calibration
%        results.
%    pollyType: char
%        polly type name. (case-sensitive)
%    wavelength: char
%        wavelength ('355', '532', '1064', '387' or '607')
%    telescope: char
%        detection range. ('near_range', or 'far_range')
%
% KEYWORDS:
%    flagUsePrevLC: logical
%        flag to control whether to search for lidar calibration
%        constants from the database.
%    flagLCCalibration: logical
%        flag to control whether to use lidar calibration constants.
%    deltaTime: datenum
%        maximum time lapse between query time and calibration time of old
%        calibration results.
%    default_liconst: double
%        default lidar calibration constant, which will be used if no
%        suitable calibration results were found.
%    default_liconstStd: double
%        uncertainty of default lidar calibration constant.
%
% OUTPUTS:
%    lcUsed: double
%        lidar constant that will be used. (photon_count * m^3 * sr)
%    lcUsedStd: double
%        uncertainty of lidar constant. (photon_count * m^3 * sr)
%    lcUsedTag: integer
%        source of the applied lidar constant.
%        (1: klett; 2: raman; 3: defaults; 4: history) 
%    lcUsedWarning: logical
%        flag to show whether the calibration constant is unstable.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'liconst', @isnumeric);
addRequired(p, 'liconstStd', @isnumeric);
addRequired(p, 'caliStartTime', @isnumeric);
addRequired(p, 'caliStopTime', @isnumeric);
addRequired(p, 'queryTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addRequired(p, 'wavelength', @ischar);
addRequired(p, 'telescope', @ischar);
addParameter(p, 'flagLCCalibration', true, @islogical);
addParameter(p, 'flagUsePrevLC', true, @islogical);
addParameter(p, 'deltaTime', datenum(0, 1, 7), @isnumeric);
addParameter(p, 'default_liconst', NaN, @isnumeric);
addParameter(p, 'default_liconstStd', true, @isnumeric);

parse(p, liconst, liconstStd, caliStartTime, caliStopTime, queryTime, ...
      dbFile, pollyType, wavelength, telescope, varargin{:});

if (any(~ isnan(liconst))) && (p.Results.flagLCCalibration)

    % take the realtime calibration results
    [~, indx] = min(liconstStd ./ liconst);
    lcUsed = liconst(indx);
    lcUsedStd = liconstStd(indx);
    lcUsedTag = 2;

else

    % loading lidar calibration constants from the database.
    [preLc, preLcStd, ~, ~] = loadLiConst(queryTime, dbFile, pollyType, ...
        wavelength, 'Raman_Method', telescope, 'deltaTime', ...
        p.Results.deltaTime, 'flagClosest', true);

    if p.Results.flagUsePrevLC && p.Results.flagLCCalibration && ...
       (~ isempty(preLc))
        lcUsed = preLc;
        lcUsedStd = preLcStd;
        lcUsedTag = 4;
    else
        lcUsed = p.Results.default_liconst;
        lcUsedStd = p.Results.default_liconstStd;
        lcUsedTag = 3;
    end
end

if (lcUsedStd / lcUsed) >= 0.1
    lcUsedWarning = true;
else
    lcUsedWarning = false;
end

end