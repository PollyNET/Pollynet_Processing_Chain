function [ n_air ] = air_refractive_index(wavelength, pressure, temperature, C, relative_humidity)
%AIR_FRACTIVE_INDEX Calculate the refractive index of air. 
%	Inputs:
%       wavelength : float
%           Light wavelegnth [nm]
%   	pressure : float
%           Atmospheric pressure [hPa]
%       temperature : float
%           Atmospehric temperature [K]
%       C : float
%           Concentration of CO2 [ppmv]
%       relative_humidity : float
%           Relative humidity from 0 to 100 [%]
%	Returns:
%       n_air : float
%           Refractive index of air.
%   References:
%       https://bitbucket.org/iannis_b/lidar_molecular
%   Copyright:
%       Group of Ground-based Remote Sensing (Leibniz-Institut für Troposphärenforschung)

    Xw = molar_fraction_water_vapour(pressure, temperature, relative_humidity);

    [rho_axs] = moist_air_density(1013.25, 288.15, C, 0);
    [rho_ws] = moist_air_density(13.33, 293.15, 0, 1);   % C not relevant

    [~ , rho_a, rho_w] = moist_air_density(pressure, temperature, C, Xw);

    n_axs = n_standard_air_with_CO2(wavelength, C);
    n_ws = n_water_vapor(wavelength);

    n_air = 1 + (rho_a ./ rho_axs) .* (n_axs - 1) + (rho_w ./ rho_ws) .* (n_ws - 1);

end


function [ rho, rho_air, rho_wv] = moist_air_density(pressure, temperature, C, Xw)
%MOIST_AIR_DENSITY Calculate the moist air density using the BIPM (Bureau International des
%	Poids et Mesures) 1981/91 equation. See Tomasi et al. (2005), eq. 12.
%	Inputs:
%       pressure: float
%           Total pressure [hPa]
%       temperature: float
%           Atmospehric temperature [K]
%       C: float
%           CO2 concentration [ppmv]
%       Xw: float
%           Molar fraction of water vapor
    const = physical_constants();
    
    Ma = molar_mass_dry_air(C);  % in kg/mol--  Molar mass  dry air.
    Mw = 0.018015;   % in kg/mol -- Molar mass of water vapour. 

    Z = compressibility_of_moist_air(pressure, temperature, Xw);

    P = pressure * 100.;   % In Pa
    T = temperature;

    rho = P .* Ma ./ (Z * const.R .* T) .* (1 - Xw .* (1 - Mw ./ Ma));

    rho_air = (1 - Xw) .* P .* Ma ./ (Z .* const.R .* T);
    rho_wv = Xw .* P .* Mw ./ (Z .* const.R .* T);
end


function [ Ma ] = molar_mass_dry_air(C)
%MOLAR_MASS_DRY_AIR Molar mass of dry air, as a function of CO2 concentration.
%	Inputs:
%       C: float
%           CO2 concentration [ppmv]
%   Returns:
%       Ma: float
%       Molar mass of dry air [km/mol]
    C1 = 400.;

    Ma = 10 ^ -3 * (28.9635 + 12.011e-6 * (C - C1));
end


function [ Z ] = compressibility_of_moist_air(pressure, temperature, molar_fraction)
%COMPRESSIBILITY_OF_MOIST_AIR Compressibility of moist air.
%	Inputs:
%       pressure: float
%           Atmospheric pressure [hPa]
%       temperature: float
%           Atmospehric temperature [K]   
%       molar_fraction: float
%           Molar fraction.
%	Note:
%       Eg. 16 of Tomasi et al. is missing a bracket. The formula of Ciddor 1996
%       was used instead.
    a0 = 1.58123e-6;  % K Pa-1
    a1 = -2.9331e-8;  % Pa-1
    a2 = 1.1043e-10;  % K Pa-1
    b0 = 5.707e-6;  % K Pa-1
    b1 = -2.051e-8;  % Pa-1
    c0 = 1.9898e-4;  % Pa-1
    c1 = -2.376e-6;  % Pa-1
    d0 = 1.83e-11;  % K2 Pa-2
    d1 = -7.65e-9;  % K2 Pa-2

    p = pressure * 100.;  % in Pa
    T = temperature;
    Tc = temperature - 273.15;  % in C

    Xw = molar_fraction;

    Z = 1 - (p ./ T) .* (a0 + a1 * Tc + a2 * Tc .^ 2 + (b0 + b1 .* Tc) .* Xw + ...
        (c0 + c1 .* Tc) .* Xw .^ 2) + (p ./ T) .^ 2 .* (d0 + d1 * Xw .^ 2);
end


function [ ns ] = n_standard_air(wavelength)
%N_STANDARD_AIR The refractive index of air at a specific wavelength with CO2 concentration 450 ppmv. 
%	Calculated for standard air at T = 15C, P=1013.25hPa, e = 0, C=450ppmv. 
%	(see Tomasi, 2005, eg. 17).
%	Inputs:
%       wavelength : float
%           Wavelength [nm]
%	Returns:
%       ns : float
%           Refractivity of standard air with C = 450ppmv

    wl_micrometers = wavelength / 1000.0;  % Convert nm to um

    s = 1 / wl_micrometers;  % the reciprocal of wavelength
    c1 = 5792105.;
    c2 = 238.0185;
    c3 = 167917.;
    c4 = 57.362;
    ns = 1 + (c1 ./ (c2 - s .^ 2) + c3 ./ (c4 - s .^ 2)) * 1e-8;
end


function [ n_axs ] = n_standard_air_with_CO2(wavelength, C)
%N_STANDARD_AIR_WITH_CO2 The refractive index of air at a specific wavelength including random CO2. 
%	Calculated for standard air at T = 15C, P=1013.25hPa, e = 0. 
%	(see Tomasi, 2005, eq. 18) 
%	Inputs:
%       wavelength : float
%           Wavelength [nm]
%       C : float
%           CO2 concentration [ppmv]
%	Returns:
%       n_axs : float
%           Refractive index of air for the specified CO2 concentration.
    C2 = 450.;  % ppmv

    n_as = n_standard_air(wavelength);

    n_axs = 1 + (n_as - 1) * (1 + 0.534e-6 * (C - C2));
end


function [ n_ws ] = n_water_vapor(wavelength)
%N_WATER_VAPOR Refractive index of water vapour. 
%	Calculated for T = 20C, e=1333Pa  (see Tomasi, 2005, eq. 19)
%	Inputs:
%       wavelength: float
%           Wavelength [nm]
%	Returns:
%       n_wv : float
%           Refractive index of water vapour.
    wl_micrometers = wavelength / 1000.0;  % Convert nm to um

    s = 1 / wl_micrometers;  % the reciprocal of wavelength

    c1 = 1.022;
    c2 = 295.235;
    c3 = 2.6422;
    c4 = 0.032380;  % Defined positive
    c5 = 0.004028;

    n_ws = 1 + c1 * (c2 + c3 * s .^ 2 - c4 * s .^ 4 + c5 * s .^ 6) * 1e-8;

end
