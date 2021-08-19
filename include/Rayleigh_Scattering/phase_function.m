function [ p ] = phase_function(theta, wavelength, pressure, temperature, C, rh)
%PHASE_FUNCTION Calculates the phase function at an angle theta for a specific wavelegth.
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
%       p: float
%           Scattering phase function
%        
%	Notes:
%       The formula is derived from Bucholtz (1995). A different formula is given in 
%       Miles (2001). 
% 
%       The use of this formula insetad of the wavelenght independent 3/4(1+cos(th)**2)
%       improves the results for back and forward scatterring by ~1.5%
% 
%       Anthony Bucholtz, "Rayleigh-scattering calculations for the terrestrial atmosphere", 
%       Applied Optics 34, no. 15 (May 20, 1995): 2765-2773.  
% 
%       R. B Miles, W. R Lempert, and J. N Forkey, "Laser Rayleigh scattering", 
%       Measurement Science and Technology 12 (2001): R33-R51
%     
    % TODO: Check use formula and values.
    p_e = rh_to_pressure(rh, temperature);

    r = rho_atmosphere(wavelength, C, p_e, pressure);
    gamma = r ./ (2 - r);

    % first part of the equation
    f1 = 3 ./ (4 * (1 + 2 * gamma));
    % second part of the equation
    f2 = (1 + 3 * gamma) + (1 - gamma) .* (cos(theta)) .^ 2;
    % results
    p = f1 .* f2;
end