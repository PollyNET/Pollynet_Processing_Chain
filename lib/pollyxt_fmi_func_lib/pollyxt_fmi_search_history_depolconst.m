function [depolconst, depolconstStd, depolCaliTime] = pollyxt_fmi_search_history_depolconst(currentTime, file, deltaTime, defaults, wavelength)
%pollyxt_fmi_search_history_depolconst Search the previous calibration constants with a time lag less than deltaTime.
%   Example:
%       [depolconst, depolconstStd, depolCaliTime] = pollyxt_fmi_search_history_depolconst(file, deltaTime, defaults)
%   Inputs:
%       file: char
%           full path of the depol calibration file.
%       deltaTime: float
%           maximum time lag between the current time and the previous calibration time.
%       defaults: struct
%           defaults configuration. Detailed information can be found in doc/polly_defaults.md 
%       wavelength: float
%           calibration wavelength
%   Outputs:
%       depolconst: double
%           depol calibration constants. 
%       depolconstStd: double
%           standard deviation of depol calibration constants. 
%       depolCaliTime: double
%           depol calibration time. (it was set 0 if there is no real depol calibration.)
%   History:
%       2019-02-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('deltaTime', 'var')
    deltaTime = datenum(0, 1, 7);
end

[preDepolCaliTime, preDepolconst, preDepolconstStd] = pollyxt_fmi_read_depolconst(file);

index = find((preDepolCaliTime > (currentTime - deltaTime)) & (preDepolCaliTime < (currentTime + deltaTime)));
if isempty(index)
    % if there is no previous calibration results with time lag less than required
    depolCaliTime = 0;
    if wavelength == 532
        depolconst = defaults.depolCaliConst532;
        depolconstStd = defaults.depolCaliConstStd532;
    elseif wavelength == 355
        depolconst = defaults.depolCaliConst355;
        depolconstStd = defaults.depolCaliConstStd355;
    else
        error('Unknown wavelength for depolarization calibration.');
    end
else
    [~, indx] = min(abs(preDepolCaliTime - currentTime));
    depolconst = preDepolconst(indx);
    depolconstStd = preDepolconstStd(indx);
    depolCaliTime = 0;
end
    
end