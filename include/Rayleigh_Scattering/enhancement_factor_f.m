function [ f ] = enhancement_factor_f(pressure, temperature)
%ENHANCEMENT_FACTOR_F Enhancement factor.
%	Inputs:
%       pressure: float
%           Atmospheric pressure [hPa]
%       temperature: float
%           Atmospehric temperature [K]    
    T = temperature;
    p = pressure * 100.;   % In Pa

    f = 1.00062 + 3.14e-8 * p + 5.6e-7 * (T - 273.15) .^ 2;
end