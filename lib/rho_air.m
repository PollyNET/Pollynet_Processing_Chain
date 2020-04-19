function [rho] = rho_air(pressure, temperature)
%RHO_AIR calculate the air denstiry as a function of pressure and temperature
%Example:
%   [rho] = rho_air(pressure, temperature)
%Inputs:
%   pressure: array
%       pressure. [hPa] 
%   temperature: array
%       temperature. [K]
%Outputs:
%   rho: array
%       air density. [g*m^{-3}]
%Reference:
%   Dai, G., et al. (2018). "Calibration of Raman lidar water vapor profiles 
%   by means of AERONET photometer observations and GDAS meteorological 
%   data." Atmospheric Measurement Techniques 11(5): 2735-2748.
%History:
%   2018-12-26. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

rho = 348.328 .* (pressure ./ temperature) .* ...
                 (1 + pressure .* (57.9 * 1e-8 - ...
                 0.94581*1e-3 ./ temperature + 0.25844 ./ temperature.^2));

end