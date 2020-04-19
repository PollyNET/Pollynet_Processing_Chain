function [angexp, angexpStd] = polly_angexp(param1, param1_std, param2, param2_std, wavelength1, wavelength2, smoothWindow)
%POLLY_ANGEXP calculate the angstroem exponent and its uncertainty.
%   Example:
%       [angexp, angexpStd] = polly_angexp(param1, param1_std, param2, 
%       param2_std, wavelength1, wavelength2)
%   Inputs:
%       param1: array
%           extinction or backscatter coefficient at wavelength1. 
%       param1_std: array
%           uncertainty of param1.
%       param2: array
%           extinction or backscatter coefficient at wavelength2.
%       param2_std: array
%           uncertainty of param2. 
%       wavelength1: float
%           the wavelength for the input parameter 1. [nm] 
%       wavelength2: float
%           the wavelength for the input parameter 2. [nm]
%   Outputs:
%       angexp: array
%           angstroem exponent based on param1 and param2 
%       angexpStd: array
%           uncertainty of angstroem exponent.
%   History:
%       2018-11-20. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de

if ~ exist('smoothWindow', 'var')
    smoothWindow = 17;
end

param1(param1 <= 0) = NaN;
param2(param2 <= 0) = NaN;

ratio = transpose(smoothWin(param1, smoothWindow) ./ ...
                  smoothWin(param2, smoothWindow));

angexp = log(ratio) ./ log(wavelength2 ./ wavelength1);

k = 1 ./ log(wavelength2 ./ wavelength1);
angexpStd = sqrt((k./param1).^2 .* param1_std.^2 ./ ...
            sqrt(smoothWindow) + (k./param2).^2 .* param2_std.^2 ./ ...
            sqrt(smoothWindow));

end