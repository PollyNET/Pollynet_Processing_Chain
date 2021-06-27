function [xOut] = fillmissing(xIn, varargin)
% FILLMISSING fill the missing values in input array.
% USAGE:
%    [xOut] = fillmissing(xIn, varargin)
% INPUTS:
%    xIn: array or matrix
%        input array which could contain some values that you want to 
%        replace.
%    varargin: cell
%        leave it blank for updating.
% OUTPUTS:
%    xOut: array or matrix
%        after the missing values were filled.
% HISTORY:
%    2021-06-26: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if nargin == 0
    help fillmissing
    return;
end

if nargin == 1
    method = 'const';
    missingValue = -999;
end

if nargin == 2
    method = 'const';
    missingValue = varargin{1};
end

switch lower(method)
case 'const'
    xOut = xIn;
    xOut(isnan(xOut)) = missingValue;
otherwise
    error('Unknow filling method');
end

end