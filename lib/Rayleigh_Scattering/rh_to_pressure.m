function [ p_wv ] = rh_to_pressure(rh, temperature)
%RH_TO_PRESSURE Convert relative humidity to water vapour partial pressure.   
%	Inputs:
%       rh: float
%           Relative humidity from 0 to 100 [%]
%       temperature: float
%           Temperature [K]
%	Returns:
%       p_wv: float
%           Water vapour pressure [hPa].
    svp = saturation_vapor_pressure(temperature);
    h = rh ./ 100.;
    
    p_wv = h .* svp;
end  % Previously / 100. This seems to be a bug (SVP already in hPA)/

