function [a, b, sigmaA, sigmaB, chi2, Q] = chi2fit(x, y, measure_error)
% CHI2FIT Chi-2 fitting. All the code are translated from the exemplified code in Numerical 
% Recipies in C (2nd Edition). Great help comes from Birgit Heese.
%
% USAGE:
%    [a, b, sigmaA, sigmaB, r_ab, Q] = linfit(x, y, meansure_error)
%
% INPUTS:
%    x: array 
%        The length of x should be larger than 1.
%    y: array
%        The measured signal.
%
% OUTPUTS:
%    a: float
%        intersect of the linear regression.
%    b: float
%        slope of the linear regression
%    sigmaA:
%        Uncertainty of intersect 
%    sigmaB:
%        Uncertainty of slope
%    chi2:
%        chi2 value
%    Q: 
%        goodness of fit.
%
% HISTORY:
%    2018-08-03. First edition by Zhenping.
%
% .. Authors: - zhenping@tropos.de

if length(x) ~= length(y)
    error('Array length must agree');
end

if length(y) ~= length(measure_error)
    error('Array length must agree');
end

if sum(measure_error) > 0
    indx = (~ isnan(y)) & (~ isnan(x)) & ((measure_error ~= 0));
else
    measure_error = ones(size(measure_error));
    indx = (~ isnan(y)) & (~ isnan(x));
end

xN = x(indx);
yN = y(indx);
measure_errorN = measure_error(indx);

%% initialize the outputs
a = NaN;
b = NaN;
sigmaA = NaN;
sigmaB = NaN;
Q = NaN;

if isempty(xN) || length(xN) <= 1
    % warning('Not enough data for chi2 regression or too much NaN values inside.');
    return;
end

S = sum(1 ./ measure_errorN.^2);
Sx = sum(xN ./ measure_errorN.^2);
Sy = sum(yN ./ measure_errorN.^2);
Sxx = sum(xN.^2 ./ measure_errorN.^2);
Sxy = sum(xN.*yN ./ measure_errorN.^2);

Delta = S .* Sxx - Sx .^ 2;
a = (Sxx .* Sy - Sx .* Sxy) ./ Delta;
b = (S .* Sxy - Sx .* Sy) ./ Delta;
sigmaA = sqrt(Sxx ./ Delta);
sigmaB = sqrt(S ./ Delta);
chi2 = sum(((yN - a - b.*xN) ./ measure_errorN) .^ 2);
Q = gammainc(chi2/2, (length(xN) - 2)/2);

end
