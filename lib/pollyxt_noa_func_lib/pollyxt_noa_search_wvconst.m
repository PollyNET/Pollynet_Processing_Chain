function [wvconst, wvconstStd] = pollyxt_noa_search_wvconst(currentTime, ...
                                file, deltaTime, defaults, flagUsePrevWVConst)
%pollyxt_noa_search_wvconst Search the previous calibration constants with 
%a time lag less than deltaTime.
%   Example:
%       [wvconst, wvconstStd] = pollyxt_noa_search_wvconst(currentTime, file,
%                                    deltaTime, defaults, flagUsePrevWVConst)
%   Inputs:
%       currentTime: datenum
%           current measurement time.
%       file: char
%           full path of the depol calibration file.
%       deltaTime: float
%           maximum time lag between the current time and the previous 
%           calibration time.
%       defaults: struct
%           defaults configuration. Detailed information can be found in 
%           doc/polly_defaults.md 
%       flagUsePrevWVConst: logical
%           flag to control whether to use previous calibration results.
%   Outputs:
%       wvconst: double
%           water vapor calibration constants.
%       wvconstStd: double
%           standard deviation of water vapor calibration constants.
%   History:
%       2019-02-26. First Edition by Zhenping
%       2019-08-16. Add 'flagUsePrevWVConst' to control whether to use previous
%                   calibration results.
%       2019-10-12. Enable using uncalibrated results if there is no calibrated
%                   results within the given time period.
%   Contact:
%       zhenping@tropos.de

if ~ exist('deltaTime', 'var')
    deltaTime = datenum(0, 1, 7);
end

if ~ exist('flagUsePrevWVConst', 'var')
    flagUsePrevWVConst = false;
end

[preWVlCaliTime, preWVCaliFlag, preWVconst, preWVconstStd] = pollyxt_noa_read_wvconst(file);

% previous water vapor constants
flagWVconst = (preWVlCaliTime > (currentTime - deltaTime)) & ...
              (preWVlCaliTime < (currentTime + deltaTime));
% previous water vapor constants that were calibrated successfully
flagWVconstValid = (preWVlCaliTime > (currentTime - deltaTime)) & ...
                   (preWVlCaliTime < (currentTime + deltaTime)) & ...
                   (preWVCaliFlag == 1);

if ((sum(flagWVconst) == 0) && sum(flagWVconstValid == 0)) || (~ flagUsePrevWVConst)
    % if there is no previous results with time lag less than 
    % required, or flagUsePrevWVConst was set to be false
    wvconst = defaults.wvconst;
    wvconstStd = defaults.wvconstStd;
elseif ((sum(flagWVconst) ~= 0) && sum(flagWVconstValid == 0)) || (flagUsePrevWVConst)
    % if there is no previous calibration results but has water vapor constant (within 7 days)
    % select the closest results (uncalibrated)
    preWVlCaliTimeValid = preWVlCaliTime(flagWVconst);
    preWVconstValid = preWVconst(flagWVconst);
    preWVconstStdValid = preWVconstStd(flagWVconst);
    thisLag = abs(preWVlCaliTimeValid - currentTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1);
    wvconst = preWVconstValid(indx);
    wvconstStd = preWVconstStdValid(indx);
else
    % select the closest calibration results
    preWVlCaliTimeValid = preWVlCaliTime(flagWVconstValid);
    preWVconstValid = preWVconst(flagWVconstValid);
    preWVconstStdValid = preWVconstStd(flagWVconstValid);
    thisLag = abs(preWVlCaliTimeValid - currentTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1);
    wvconst = preWVconstValid(indx);
    wvconstStd = preWVconstStdValid(indx);
end
    
end