function [ sig ] = sigma_rayleigh(wavelength, pressure, temperature, C, rh)
%SIGMA_RAYLEIGH Calculates the Rayleigh-scattering cross section per molecule.
%	Inputs:
%   	wavelength: float
%           Wavelegnth [nm]
%       pressure: float
%           The atmospheric pressure [hPa]
%       temperature: float
%           The atmospheric temperature [K]   
%       C: float
%           CO2 concentration [ppmv].
%       rh: float
%           Relative humidity from 0 to 100 [%] 
%	Returns
%       sigma: float
%           Rayleigh-scattering cross section [m2]

global ASSUME_AIR_IDEAL
ASSUME_AIR_IDEAL = true;

    p_e = rh_to_pressure(rh, temperature);

    % Calculate properties of standard air
    n = air_refractive_index(wavelength, pressure, temperature, C, rh);
    N = number_density_at_pt(pressure, temperature, rh, ASSUME_AIR_IDEAL);

    % Wavelength of radiation
    wl_m = wavelength;   % nm

    % King's correction factor
    f_k = kings_factor_atmosphere(wavelength, C, p_e, pressure);  % no units

    % first part of the equation
    f1 = (24. * pi .^ 3) ./ (wl_m .^ 4 .* (N*1e-18) .^ 2);
    % second part of the equation
    f2 = (n .^ 2 - 1.) .^ 2 ./ (n .^ 2 + 2.) .^ 2;

    % result
    sig = f1 .* f2 .* f_k;
end