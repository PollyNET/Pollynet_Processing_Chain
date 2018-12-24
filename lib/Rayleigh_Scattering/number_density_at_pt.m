function [ n ] = number_density_at_pt(pressure, temperature, relative_humidity, ideal)
%NUMBER_DENSITY_AT_PT Calculate the number density for a given temperature and pressure,
%taking into account the compressibility of air.
%	Inputs:
%       pressure: float or array
%           Pressure in hPa
%       temperature: float or array
%           Temperature in K
%       relative_humidity: float or array (?)
%           ? The relative humidity of air (Check)
%       ideal: boolean
%           If False, the compressibility of air is considered. If True, the 
%           compressibility is set to 1.
%	Returns:
%       n: array or array
%           Number density of the atmosphere [m^{-3}]   
    Xw = molar_fraction_water_vapour(pressure, temperature, relative_humidity);
        
    if ideal
        Z = 1;
    else   
        Z = compressibility_of_moist_air(pressure, temperature, Xw);
    end

    p_pa = pressure * 100.;  % Pressure in pascal
    const = physical_constants();
    n = p_pa ./ (Z * temperature * const.k_b);
end
    
    
