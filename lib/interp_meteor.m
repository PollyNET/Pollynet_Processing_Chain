function [yOut] = interp_meteor(x, y, xOut, method)
%INTERP_METEOR interp the meteorological parameters which could contain a lot 
%of NaNs.
%Example:
%   [yOut] = interp_meteor(x, y, xOut)
%Inputs:
%   x: array
%       sample points
%   y: array 
%       sample values
%   xOut: array
%       query points.
%   method: char
%       interpolation method. ('linear', 'cubic', 'nearest')
%Outputs:
%   yOut: array
%       query values.
%History:
%   2018-12-23. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

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