function [ alp ] = alpha_rayleigh(wavelength, pressure, temperature, C, rh)
%ALPHA_RAYLEIGH Cacluate the extinction coefficient for Rayleigh scattering. 
%	Inputs:
%       wavelength : float or array of floats
%           Wavelegnth [nm]
%       pressure : float or array of floats
%           Atmospheric pressure [hPa]
%       temperature : float
%           Atmospheric temperature [K]
%       C : float
%           CO2 concentration [ppmv].
%       rh : float
%           Relative humidity from 0 to 100 [%] 
%	Returns:
%       alpha: float
%           The molecular scattering coefficient [m-1]

ASSUME_AIR_IDEAL = true;

    sigma = sigma_rayleigh(wavelength, pressure, temperature, C, rh);
    N = number_density_at_pt(pressure, temperature, rh, ASSUME_AIR_IDEAL);

    alp = N .* sigma;
end