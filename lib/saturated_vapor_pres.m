function [es] = saturated_vapor_pres(temperature)
%saturated_vapor_pres calculate the saturated water vapor pressure.
%   Example:
%       [es] = saturated_vapor_pres(temperature)
%   Inputs:
%       temperature: array
%           air temperature. [°C] 
%   Outputs:
%       es: array
%           saturated water vapor pressure. [hPa]
%   References:
%       https://en.wikipedia.org/wiki/Arden_Buck_equation
%   History:
%       2018-12-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

es = NaN(size(temperature));

for iBin = 1:numel(temperature)
    if temperature(iBin) >= -40   % saturated vapor pressure over water
        es(iBin) = 6.1121 .* exp((18.678 - temperature(iBin)./234.5) .* (temperature(iBin) ./ (257.14 + temperature(iBin))));
    else   % saturated vapor pressure over ice
        es(iBin) = 6.1115 .* exp((23.036 - temperature(iBin)./333.7) .* (temperature(iBin) ./ (279.82 + temperature(iBin))));
    end
end

end