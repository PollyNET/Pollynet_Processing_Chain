function [wvconst, wvconstStd] = pollyxt_fmi_search_wvconst(currentTime, ...
                                file, deltaTime, defaults, flagUsePrevWVConst)
%pollyxt_fmi_search_wvconst Search the previous calibration constants with 
%a time lag less than deltaTime.
%   Example:
%       [wvconst, wvconstStd] = pollyxt_fmi_search_wvconst(currentTime, file,
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
%   Contact:
%       zhenping@tropos.de

if ~ exist('deltaTime', 'var')
    deltaTime = datenum(0, 1, 7);
end

if ~ exist('flagUsePrevWVConst', 'var')
    flagUsePrevWVConst = false;
end

[preWVlCaliTime, preWVconst, preWVconstStd] = pollyxt_lacros_read_wvconst(file);

flagValid = (preWVlCaliTime > (currentTime - deltaTime)) & ...
                     (preWVlCaliTime < (currentTime + deltaTime));
if (sum(flagValid) == 0) || (~ flagUsePrevWVConst)
    % if there is no previous calibration results with time lag less than 
    % required, or flagUsePrevWVConst was set to be true
    wvconst = defaults.wvconst;
    wvconstStd = defaults.wvconstStd;
else
    preWVlCaliTimeValid = preWVlCaliTime(flagValid);
    preWVconstValid = preWVconst(flagValid);
    preWVconstStdValid = preWVconstStd(flagValid);
    thisLag = abs(preWVlCaliTimeValid - currentTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1);
    wvconst = preWVconstValid(indx);
    wvconstStd = preWVconstStdValid(indx);
end
    
end