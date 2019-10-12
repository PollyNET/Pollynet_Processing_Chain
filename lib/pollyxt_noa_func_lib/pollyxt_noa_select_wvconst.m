function [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = pollyxt_noa_select_wvconst(wvconst, wvconstStd, IWVAttri, currentTime, file, flagUsePreviousWVConst)
%pollyxt_noa_select_wvconst  select the most appropriate water vapor 
%calibration constant to calculate the WVMR and RH.
%   Example:
%       [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = 
%           pollyxt_noa_select_wvconst(wvconst, wvconstStd, WVCaliInfo, 
%                                       IWVAttri, currentTime, defaults, file)
%   Inputs:
%       wvconst: array
%           water vapor calibration constants. [g*kg^{-1}] 
%       wvconstStd: array
%           uncertainty of water vapor calibration constants. [g*kg^{-1}] 
%       IWVAttri: struct
%           datetime: array
%               water vapor calibration time. [datenum]
%           WVCaliInfo: cell
%               calibration information for each calibration period.
%           IntRange: matrix
%               index of integration range for calculate the raw IWV from lidar. 
%       currentTime: datenum
%           The creation time for the data netCDF file.
%       defaults: struct
%           defaults configuration. Detailed information can be found in 
%           doc/polly_defaults.md 
%       file: char
%           file for saving water vapor calibration results.
%       flagUsePreviousWVConst: logical
%           flag to control whether to search for the water vapor calibration
%           constants in the calibration file.
%   Outputs:
%       wvconstUsed: float
%           applied water vapor calibration constants.[g*kg^{-1}]  
%       wvconstUsedStd: float
%           uncertainty of applied water vapor calibration constants. 
%           [g*kg^{-1}]  
%       wvconstUsedInfo: struct
%           flagCalibrated: logical
%               flag to show whether the applied constant comes from a 
%               successful calibration. If not, the result comes from the 
%               defaults.
%           IWVInstrument: char
%               the instrument for external standard IWV measurement 
%           nIWVCali: integer
%               number of successful water vapor calibration.
%   History:
%       2018-12-19. First Edition by Zhenping
%       2019-08-16. Fix bug for taking defaults when there was no calibration 
%                   instead of taking the previous calibration results.
%   Contact:
%       zhenping@tropos.de

global defaults

%% initialization
wvconstUsedInfo = struct();
wvconstUsed = NaN;
wvconstUsedStd = NaN;

if isempty(wvconst)
    [wvconstUsed, wvconstUsedStd] = pollyxt_noa_search_wvconst(currentTime, ...
                file, datenum(0,1,7), defaults, flagUsePreviousWVConst);
    wvconstUsedInfo.flagCalibrated = false;
    wvconstUsedInfo.IWVInstrument = 'none';
    wvconstUsedInfo.nIWVCali = 0;
elseif sum(~ isnan(wvconst)) == 0
    [wvconstUsed, wvconstUsedStd] = pollyxt_noa_search_wvconst(currentTime, ...
                file, datenum(0,1,7), defaults, flagUsePreviousWVConst);
    wvconstUsedInfo.flagCalibrated = false;
    wvconstUsedInfo.IWVInstrument = IWVAttri.source;
    wvconstUsedInfo.nIWVCali = 0;
else
    flagCalibrated = ~ isnan(wvconst);
    wvconstUsed = nanmean(wvconst);
    wvconstUsedStd = sqrt(sum(wvconstStd(flagCalibrated).^2)) ./ ...
                          sum(flagCalibrated);
    wvconstUsedInfo.flagCalibrated = true;
    wvconstUsedInfo.IWVInstrument = IWVAttri.source;
    wvconstUsedInfo.nIWVCali = sum(flagCalibrated);
end

end