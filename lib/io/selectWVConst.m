function [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = selectWVConst(wvconst, wvconstStd, IWVAttri, queryTime, dbFile, pollyType, varargin)
% SELECTWVCONST  select the most appropriate water vapor calibration constant.
% USAGE:
%    [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = selectWVConst(wvconst, wvconstStd, IWVAttri, queryTime, dbFile, pollyType)
% INPUTS:
%    wvconst: array
%        water vapor calibration constants. [g*kg^{-1}] 
%    wvconstStd: array
%        uncertainty of water vapor calibration constants. [g*kg^{-1}] 
%    IWVAttri: struct
%        datetime: array
%            water vapor calibration time. [datenum]
%        WVCaliInfo: cell
%            calibration information for each calibration period.
%        IntRange: matrix
%            index of integration range for calculate the raw IWV from lidar.
%    queryTime: datenum
%        query time for searching the water vapor calibration constant.
%    dbFile: char
%        path of SQLite database, which contains water vapor calibration
%        results.
%    pollyType: char
%        polly type name. (case-sensitive)
% KEYWORDS:
%    flagUsePrevWVConst: logical
%        flag to control whether to search for the water vapor calibration
%        constants from the database.
%    flagWVCalibration: logical
%        flag to control whether to use water vapor calibration constants.
%    deltaTime: datenum
%        maximum time lapse between query time and calibration time of old
%        calibration results.
%    default_wvconst: double
%        default water vapor calibration constant, which will be used if no
%        suitable calibration results were found.
%    default_wvconstStd: double
%        uncertainty of default water vapor calibration constant.
% OUTPUTS:
%    wvconstUsed: float
%        applied water vapor calibration constants.[g*kg^{-1}]  
%    wvconstUsedStd: float
%        uncertainty of applied water vapor calibration constants. 
%        [g*kg^{-1}]  
%    wvconstUsedInfo: struct
%        flagCalibrated: logical
%            flag to show whether the applied constant comes from a 
%            successful calibration. If not, the result comes from the 
%            defaults.
%        IWVInstrument: char
%            the instrument for external standard IWV measurement 
%        nIWVCali: integer
%            number of successful water vapor calibration.
% HISTORY:
%    2018-12-19: First Edition by Zhenping
%    2019-08-16: Fix bug for taking defaults when there was no calibration 
%                instead of taking the previous calibration results.
%    2020-04-18: Update the interface.
% .. Authors: - zhenping@tropos.de


p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'wvconst', @isnumeric);
addRequired(p, 'wvconstStd', @isnumeric);
addRequired(p, 'IWVAttri', @isstruct);
addRequired(p, 'queryTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addParameter(p, 'flagUsePrevWVConst', true, @islogical);
addParameter(p, 'flagWVCalibration', true, @islogical);
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'default_wvconst', NaN, @isnumeric);
addParameter(p, 'default_wvconstStd', NaN, @isnumeric);

parse(p, wvconst, wvconstStd, IWVAttri, queryTime, dbFile, pollyType, ...
      varargin{:});

%% initialization
wvconstUsedInfo = struct();

if (any(~ isnan(wvconst))) && p.Results.flagUsePrevWVConst

    % take realtime calibration results
    flagCalibrated = ~ isnan(wvconst);
    wvconstUsed = nanmean(wvconst);
    wvconstUsedStd = sqrt(sum(wvconstStd(flagCalibrated).^2)) ./ ...
                          sum(flagCalibrated);
    wvconstUsedInfo.flagCalibrated = true;
    wvconstUsedInfo.IWVInstrument = IWVAttri.source;
    wvconstUsedInfo.nIWVCali = sum(flagCalibrated);

else

    % no suitable calibration periods
    [preWVCaliConst, preWVCaliConstStd, ~, ~, caliInstrument] = ...
        loadWVConst(queryTime, dbFile, pollyType, 'deltaTime', ...
            p.Results.deltaTime, 'flagClosest', true);

    if (~ p.Results.flagUsePrevWVConst) || (isempty(preWVCaliConst)) || ...
       (~ p.Results.flagWVCalibration)
        wvconstUsed = p.Results.default_wvconst;
        wvconstUsedStd = p.Results.default_wvconstStd;
        wvconstUsedInfo.flagCalibrated = false;
        wvconstUsedInfo.IWVInstrument = 'none';
        wvconstUsedInfo.nIWVCali = 0;
    else
        wvconstUsed = preWVCaliConst;
        wvconstUsedStd = preWVCaliConstStd;
        wvconstUsedInfo.flagCalibrated = true;
        wvconstUsedInfo.IWVInstrument = caliInstrument{1};
        wvconstUsedInfo.nIWVCali = 0;
    end

end

end