function [yOut] = interpMeteor(x, y, xOut, method)
% INTERPMETOER interp the meteorological parameters with NaNs.
% USAGE:
%    [yOut] = interpMeteor(x, y, xOut, method)
% INPUTS:
%    x: array
%        sample points
%    y: array 
%        sample values
%    xOut: array
%        query points.
%    method: char
%        interpolation method. ('linear', 'cubic', 'nearest')
% OUTPUTS:
%    yOut: array
%        query values.
% EXAMPLE:
% HISTORY:
%    2021-05-24: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ exist('method', 'var')
    method = 'linear';
end

validIndx = (~ isnan(x)) & (~ isnan(y));
if sum(validIndx) <= 3
    warning('Number of valid parameter data points is less than 3.');
    yOut = NaN(size(xOut));
    return
end

yOut = interp1(x(validIndx), y(validIndx), xOut, method, 'extrap');

end