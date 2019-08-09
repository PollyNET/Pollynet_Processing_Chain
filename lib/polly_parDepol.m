function [parDepol, parDepolStd] = polly_parDepol(volDepol, volDepolStd, aerBsc, aerBscStd, molBsc, molDepol, molDepolStd)
%POLLY_PARDEPOL calculate the particle depolarization ratio and estimate the 
%standard deviation of particle depolarization ratio.
%   Example:
%       [parDepol, parDepolStd] = polly_parDepol(volDepol, volDepolStd, aerBsc, aerBscStd, molBsc, molDepol, molDepolStd)
%   Inputs:
%       volDepol: array
%           volume depolarization ratio.
%       volDepolStd: array
%           standard deviation of volume depolarization ratio.
%       aerBsc: array
%           aerosol backscatter coefficient. [m^{-1}Sr^{-1}]
%       aerBscStd: array
%           standard deviation of aerosol backscatter coefficient. 
%           [m^{-1}Sr^{-1}] 
%       molBsc: array
%           molecule backscatter coefficient. [m^{-1}Sr^{-1}]
%       molDepol: scalar
%           molecule depolarization ratio. This value is highly dependent on 
%           the central wavelength and FWHM of the narrow IF in the depol 
%           channel.
%       molDepolStd: scalar
%           standard deviation of molecule depolarization ratio.
%   Outputs:
%       parDepol: array
%           particle depolarization ratio. 
%       parDepolStd: array
%           standard deviation of particle depolarization ratio.
%   Reference:
%       H.Baars et. al, Aerosol Typing by lidar, Eq.10, AMT, 2017
%   History:
%       2018-09-05. First edition by Zhenping
%   Contact:
%       zhenping@tropos.de


parDepol = (volDepol + 1) ./ (molBsc .* (molDepol - volDepol) ./ ...
            aerBsc ./ (1 + molDepol) + 1) - 1;

% partial derivative
parDepol_volDepol_func = @(x) (x + 1) ./ (molBsc .* (molDepol - x) ./ aerBsc ./ (1 + molDepol) + 1) - 1;
deriv_parDepol_volDepol = (parDepol_volDepol_func(volDepol + 0.005) - parDepol_volDepol_func(volDepol)) ./ 0.005;

parDepol_molDepol_func = @(x) (volDepol + 1) ./ (molBsc .* (x - volDepol) ./ aerBsc ./ (1 + x) + 1) - 1;
deriv_parDepol_molDepol = (parDepol_molDepol_func(molDepol + 0.0005) - (parDepol_molDepol_func(molDepol))) ./ 0.0005;

parDepol_aerBsc_func = @(x) (volDepol + 1) ./ (molBsc .* (molDepol - volDepol) ./ x ./ (1 + molDepol) + 1) - 1;
deriv_parDepol_aerBsc = (parDepol_aerBsc_func(aerBsc + 5e-8) - parDepol_aerBsc_func(aerBsc)) ./ 5e-8;

% standard deviation
parDepolStd = sqrt(deriv_parDepol_volDepol.^2 .* volDepolStd.^2 + deriv_parDepol_molDepol.^2 .* molDepolStd.^2 + deriv_parDepol_aerBsc.^2 .* aerBscStd.^2);

end