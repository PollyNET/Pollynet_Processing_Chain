function [rh] = wvmr_2_rh(wvmr, es, pressure)
% WVMR_2_RH convert water vapor mixing ratio to relative humidity.
% USAGE:
%    [rh] = wvmr_2_rh(wvmr, es, pressure)
% INPUTS:
%    wvmr: array or matrix
%        water vapor mixing ratio. [g*kg^{-1}] 
%    es: array or matrix
%        saturated vapor pressure. [hPa]
%    pressure: array or matrix
%        air pressure. [hPa]
% OUTPUTS:
%    rh: array or matrix
%        relative humidity. [%]
% EXAMPLE:
% HISTORY:
%    2021-06-01: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ isequal(size(wvmr), size(pressure)) 
    error('wvmr and pressure is not compatible.');
end

if ~ isequal(size(wvmr), size(es))
    error('wvmr and es is not compatible.');
end

rh = wvmr .* pressure ./ (622.0 .* es + wvmr .* es) .* 100;   % [%]

end