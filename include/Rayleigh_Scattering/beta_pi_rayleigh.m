function [ beta_pi ] = beta_pi_rayleigh(wavelength, pressure, temperature, C, rh)
%BETA_PI_RAYLEIGH Calculates the total Rayleigh backscatter coefficient.
%	Inputs:
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
%	Returns
%       beta_pi: array
%           molecule backscatter coefficient. [m^{-1}Sr^{-1}]

    ASSUME_AIR_IDEAL = true;

    dsigma_pi = dsigma_phi_rayleigh(pi, wavelength, pressure, temperature, C, rh);
    N = number_density_at_pt(pressure, temperature, rh, ASSUME_AIR_IDEAL);

    beta_pi = dsigma_pi .* N;
end
