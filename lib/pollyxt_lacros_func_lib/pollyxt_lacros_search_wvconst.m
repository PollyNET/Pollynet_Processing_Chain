function [wvconst, wvconstStd] = pollyxt_lacros_search_wvconst(currentTime, file, deltaTime, defaults)
%pollyxt_lacros_search_wvconst Search the previous calibration constants with a time lag less than deltaTime.
%   Example:
%       [wvconst, wvconstStd] = pollyxt_lacros_search_wvconst(currentTime, file, deltaTime, defaults)
%   Inputs:
%       currentTime: datenum
%           current measurement time.
%       file: char
%           full path of the depol calibration file.
%       deltaTime: float
%           maximum time lag between the current time and the previous calibration time.
%       defaults: struct
%           defaults configuration. Detailed information can be found in doc/polly_defaults.md 
%   Outputs:
%       wvconst: double
%           water vapor calibration constants.
%       wvconstStd: double
%           standard deviation of water vapor calibration constants.
%   History:
%       2019-02-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('deltaTime', 'var')
    deltaTime = datenum(0, 1, 7);
end

[preWVlCaliTime, preWVconst, preWVconstStd] = pollyxt_lacros_read_wvconst(file);

index = find((preWVlCaliTime > (currentTime - deltaTime)) & (preWVlCaliTime < (currentTime + deltaTime)));
if isempty(index)
    % if there is no previous calibration results with time lag less than required
    wvconst = defaults.wvconst;
    wvconstStd = defaults.wvconstStd;
else
    [~, indx] = min(abs(preWVlCaliTime - currentTime));
    wvconst = preWVconst(indx);
    wvconstStd = preWVconstStd(indx);
end
    
end