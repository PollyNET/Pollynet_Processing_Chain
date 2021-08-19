function [ dsig ] = dsigma_phi_rayleigh(theta, wavelength, pressure, temperature, C, rh)
%DSIGMA_PHI_RAYLEIGH Calculates the angular rayleigh scattering cross section per molecule.
%	Inputs:
%       theta: float
%           Scattering angle [rads]
%       wavelength: float
%           Wavelength [nm]
%       pressure: float
%           The atmospheric pressure [hPa]
%       temperature: float
%           The atmospheric temperature [K]   
%       C: float
%           CO2 concentration [ppmv].
%       rh: float
%           Relative humidity from 0 to 100 [%] 
%	Returns:
%       dsigma: float
%           rayleigh-scattering cross section [m2sr-1]

    phase = phase_function(theta, wavelength, pressure, temperature, C, rh);
    phase = phase ./ (4 * pi);
    sigma = sigma_rayleigh(wavelength, pressure, temperature, C, rh);
    dsig = sigma .* phase;
end