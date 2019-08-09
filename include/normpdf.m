function y = normpdf(x,mu,sigma)

if nargin<1
    error('Not enough inputs');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    y = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
catch
    error('mismatch input array size');
end
