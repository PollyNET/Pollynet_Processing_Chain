function [ k ] = kings_factor_atmosphere(wavelength, C, p_e, p_t)
%KING_FACTOR_ATMOSPHERE calculate the king factor.
%   Usage:
%       k = king_factor_atmosphere(wavelength, C, p_e, p_t)
%   Inputs:
%       wavelength: float
%           Unit: nm
%       C: float
%           CO2 concentration in ppmv
%       p_e: float
%           water vapor pressure in hPa
%       p_t: float
%           total air pressure in hPa
%   Returns:
%       k: float
%           total atmospheric King's factor
%   References:
%       https://bitbucket.org/iannis_b/lidar_molecular
%   Copyright:
%       Group of Ground-based Remote Sensing (Leibniz-Institut f�r Troposph�renforschung)

    if ~ ((wavelength < 4000) && (wavelength > 200))   % if wavelength is not in the range of 0.2um~4um
        error('King''s factor formula is only valid from 0.2 to 4um.');
    end

    % Calculate wavenumber
    lamda_cm = wavelength * 10 ^ -7;
    wavenumber = 1 ./ lamda_cm;

    % Individual kings factors
    F_N2 = kings_factor_N2(wavenumber);
    F_O2 = kings_factor_O2(wavenumber);
    F_ar = kings_factor_Ar();
    F_CO2 = kings_factor_CO2();
    F_H2O = kings_factor_H2O();

    % Individual concentrations
    c_n2 = 0.78084;
    c_o2 = 0.20946;
    c_ar = 0.00934;
    c_co2 = 1e-6 .* C;
    c_h2o = p_e ./ p_t;

    % Total concentration
    c_tot = c_n2 + c_o2 + c_ar + c_co2 + c_h2o;

    k = (c_n2 .* F_N2 + c_o2 .* F_O2 + c_ar .* F_ar + c_co2 .* F_CO2 + c_h2o .* F_H2O) ./ c_tot;
end

    function [ k ] =  kings_factor_N2(wavenumber)
    %KINGS_FACTOR_N2 approximates the King's correction factor for a specific wavenumber.
    %	According to Bates, the agreement with experimental values is
    %	"rather better than 1 per cent."
    %	Inputs:
    %       wavenumber : float
    %       Wavenumber (defined as 1/lamda) in cm-1
    %	Returns:
    %       Fk : float
    %       Kings factor for N2
    %	Notes:
    %       The King's factor is estimated as:
    %       .. math::
    %       F_{N_2} = 1.034 + 3.17 \cdot 10^{-4} \cdot \lambda^{-2}
    %       where :math:`\lambda` is the wavelength in micrometers.
    %	References:
    %       Tomasi, C., Vitale, V., Petkov, B., Lupi, A. & Cacciari, A. Improved
    %       algorithm for calculations of Rayleigh-scattering optical depth in standard
    %       atmospheres. Applied Optics 44, 3320 (2005).
    % 
    %       Bates, D. R.: Rayleigh scattering by air, Planetary and Space Science, 32(6),
    %       785-790, doi:10.1016/0032-0633(84)90102-8, 1984.

    lamda_cm = 1 / wavenumber;
    lamda_um = lamda_cm * 10 ^ 4;  % Convert to micrometers, as in the paper

    k = 1.034 + 3.17e-4 * lamda_um ^ -2;
    end


    function [ k ] = kings_factor_O2(wavenumber)
    lamda_cm = 1 / wavenumber;
    lamda_um = lamda_cm * 10 ^ 4;  % Convert to micrometers, as in the paper

    k = 1.096 + 1.385e-3 * lamda_um ^ -2 + 1.448e-4 * lamda_um ^ -4;
    end


    function [ k ] = kings_factor_Ar()
    k = 1.0;
    end


    function [ k ] = kings_factor_CO2()
    k = 1.15;
    end


    function [ k ] = kings_factor_H2O()
    k = 1.001;
    end

