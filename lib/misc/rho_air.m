function [rho] = rho_air(pressure, temperature)
% RHO_AIR calculate air denstiry as a function of pressure and temperature
% USAGE:
%    [rho] = rho_air(pressure, temperature)
% INPUTS:
%   pressure: array
%       pressure. [hPa] 
%   temperature: array
%       temperature. [K]
% OUTPUTS:
%   rho: array
%       air density. [g*m^{-3}]
% REFERENCES:
%   Dai, G., Althausen, D., Hofer, J., Engelmann, R., Seifert, P., Bühl, J., Mamouri, R.-E., Wu, S., and Ansmann, A.: Calibration of Raman lidar water vapor profiles by means of AERONET photometer observations and GDAS meteorological data, Atmospheric Measurement Techniques, 11, 2735-2748, 2018.
% EXAMPLE:
% HISTORY:
%    2021-06-01: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

rho = 348.328 .* (pressure ./ temperature) .* ...
                 (1 + pressure .* (57.9 * 1e-8 - ...
                 0.94581*1e-3 ./ temperature + 0.25844 ./ temperature.^2));

end