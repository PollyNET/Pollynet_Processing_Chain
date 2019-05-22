function [xOut] = fillmissing(xIn, varargin)
%fillmissing fill the missing values in input array.
%   Example:
%       [xOut] = fillmissing(xIn, varargin)
%   Inputs:
%       xIn: array or matrix
%           input array which could contain some values that you want to replace.
%       varargin: cell
%           leave it blank for updating.
%   Outputs:
%       xOut: array or matrix
%           after the missing values were filled.
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

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