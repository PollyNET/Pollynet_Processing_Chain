function [ Xw ] = molar_fraction_water_vapour(pressure, temperature, relative_humidity)
%MOLAR_FRACTION_WATER_VAPOUR Molar fraction of water vapor. 
%	Inputs:
%       pressure: float
%           Total pressure [hPa]
%       temperature: float
%           Atmospehric temperature [K] 
%       relative_humidity:
%           Relative humidity from 0 to 100 [%]

    % Convert units
    p = pressure;   % In hPa
    h = relative_humidity / 100.;   % From 0 to 1

    % Calculate water vapor pressure
    f = enhancement_factor_f(pressure, temperature);
    svp = saturation_vapor_pressure(temperature);

    p_wv = h .* f .* svp;   % Water vapor pressure

    Xw = p_wv ./ p;
end