function [dcUsed, dcUsedStd, dcUsedStartTime, dcUsedStopTime] = selectDepolConst(depolconst, depolconstStd, depolCaliStartTime, depolCaliStopTime, queryTime, dbFile, pollyType, wavelength, varargin)
% SELECTDEPOLCONST select most suitable depol calibration constant.
% USAGE:
%    [dcUsed, dcUsedStd, dcUsedStartTime, dcUsedStopTime] =
%        selectDepolConst(depolconst, depolconstStd, depolCaliTime,
%            queryTime, dbFile, pollyType, wavelength)
% INPUTS:
%    depolconst: array
%        depolarization calibration constant.
%    depolconstStd: array
%        uncertainty of depolarization calibration constant.
%    depolCaliStartTime: array
%        start time for each depolarization calibration period. (datenum)
%    depolCaliStopTime: array
%        stop time for each depolarization calibration period. (datenum)
%    queryTime: datenum
%        query time for searching the depolarization calibration constant.
%    dbFile: char
%        full path of the depol calibration file.
%    pollyType: char
%        polly type. (case-sensitive)
%    wavelength: char
%        wavelength ('355' or '532')
% KEYWORDS:
%    flagUsePrevDepolConst: logical
%        flag to control whether to search for depolarization calibration
%        constants from the database.
%    flagDepolCali: logical
%        flag to control whether to use depolarization calibration constants.
%    deltaTime: datenum
%        maximum time lapse between query time and calibration time of old
%        calibration results.
%    default_depolconst: double
%        default depolarization calibration constant, which will be used if no
%        suitable calibration results were found.
%    default_depolconstStd: double
%        uncertainty of default depolarization calibration constant.
% OUTPUTS:
%    dcUsed: double
%        depolarization calibration constants.
%    dcUsedStd: double
%        uncertainty of depolarization calibration constants.
%    dcUsedStartTime: double
%        depolarization calibration start time.
%        (0 was set if there was no successful depolarization calibration.)
%    dcUsedStopTime: double
%        depolarization calibration stop time.
%        (0 was set if there was no successful depolarization calibration.)
% EXAMPLE:
% HISTORY:
%    2021-06-08: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'depolconst', @isnumeric);
addRequired(p, 'depolconstStd', @isnumeric);
addRequired(p, 'depolCaliStartTime', @isnumeric);
addRequired(p, 'depolCaliStopTime', @isnumeric);
addRequired(p, 'queryTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'wavelength', @ischar);
addRequired(p, 'pollyType', @ischar);
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'flagUsePrevDepolConst', true, @islogical);
addParameter(p, 'flagDepolCali', true, @islogical);
addParameter(p, 'default_depolconst', NaN, @isnumeric);
addParameter(p, 'default_depolconstStd', NaN, @isnumeric);

parse(p, depolconst, depolconstStd, depolCaliStartTime, depolCaliStopTime, ...
      queryTime, dbFile, wavelength, pollyType, varargin{:});

if (any(~ isnan(depolconst))) && (p.Results.flagUsePrevDepolConst)

    % take the realtime calibration results.
    [~, indx] = min(depolconstStd ./ depolconst);
    dcUsed = depolconst(indx);
    dcUsedStd = depolconstStd(indx);
    dcUsedStartTime = depolCaliStartTime(indx);
    dcUsedStopTime = depolCaliStopTime(indx);

else

    % loading depolarization calibration constants from the database.
    [preDepolconst, preDepolconstStd, caliStartTime, caliStopTime] = ...
        loadDepolConst(queryTime, ...
            dbFile, pollyType, wavelength, ...
            'deltaTime', p.Results.deltaTime, 'flagClosest', true);

    if (~ p.Results.flagUsePrevDepolConst) || isempty(preDepolconst) || ...
       (~ p.Results.flagDepolCali)
        % there were no previous calibration results
        dcUsedStartTime = 0;
        dcUsedStopTime = 0;
        dcUsed = p.Results.default_depolconst;
        dcUsedStd = p.Results.default_depolconstStd;
    else
        dcUsedStartTime = caliStartTime;
        dcUsedStopTime = caliStopTime;
        dcUsed = preDepolconst;
        dcUsedStd = preDepolconstStd;
    end

end

end