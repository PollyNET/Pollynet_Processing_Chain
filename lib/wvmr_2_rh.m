function [rh] = wvmr_2_rh(wvmr, es, pressure)
%wvmr_2_rh convert the water vapor mixing ratio to relative humidity.
%   Example:
%       [rh] = wvmr_2_rh(wvmr, es, pressure)
%   Inputs:
%       wvmr: array or matrix
%           water vapor mixing ratio. [g*kg^{-1}] 
%       es: array or matrix
%           saturated vapor pressure. [hPa]
%       pressure: array or matrix
%           air pressure. [hPa]
%   Outputs:
%       rh: array or matrix
%           relative humidity. [%]
%   History:
%       2018-12-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ isequal(size(wvmr), size(pressure)) 
    error('wvmr and pressure is not compatible.');
end

if ~ isequal(size(wvmr), size(es))
    error('wvmr and es is not compatible.');
end

rh = wvmr .* pressure ./ (622.0 .* es + wvmr .* es) .* 100;   % [%]

end