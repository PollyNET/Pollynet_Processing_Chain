    function [ rho ] = rho_atmosphere(wavelength, C, p_e, p_t)
    %RHO_ATMOSPHERE Calculate the depolarization factor of the atmosphere. 
    %	Inputs:
    %       wavelength : float or array of floats
    %           Wavelength in nm
    %       C : float
    %           CO2 concentration in ppmv
    %       p_e : float
    %           water-vapor pressure [hPa]
    %       p_t : float
    %           total air pressure [hPa]
    %	Returns:
    %       rho: float or array of floats
    %       Depolarization factor
    
    F_k = kings_factor_atmosphere(wavelength, C, p_e, p_t);
    rho = (6 * F_k - 6) ./ (7 * F_k + 3);
    end