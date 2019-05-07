function [ ext_std ] = polly_raman_ext_std(height, signal, bg, lambda_emit, ...
    lambda_rec, angstrom, pressure, temperature, window_size, C, rh, nProfiles, method, measure_error)
%POLLY_RAMAN_EXT_STD calculate the uncertainty of aerosol
%extinction coefficient with Raman method.
%   Inputs:
%       height: array
%           height[m]
%       signal: array
%           measured raman signal. [Photon Count]
%		bg: array
%			background. [Photon Count]
%       lambda_emit: float
%           the wavelength of the emitted laser beam.[nm]
%       lambda_rec: float
%           the wavelength of raman sigal.[nm]
%       angstrom: float
%           the angstrom exponent for aerosol extinction coefficient
%       pressure: array
%           pressure of the atmosphere. [hPa]
%       temperature: array
%           temperature of the atmosphere. [K]
%       window_size: integer
%           window_size for smoothing the signal.
%       C: array
%           CO2 concentration.[ppmv]
%       rh: array
%           relative humidity.
%       nProfiles: integer
%           number of the generated profiles to calculate the uncertainty.
%       method: str
%           method for calculating the signal slope. 
%				'moving'|'movingslope': using Savitzky-Golay filter.
%				'smoothing'|'smooth': using finite difference algorithm with smoothed signal.
%				'chi2': using chi2 linear fit.
%       measure_error: array
%           systematic error of signal. (not random error, normally treated as 0);
%   Returns:
%       uncertainty of aerosol extinction coefficient [m^{-1}]
%   History:
%       2017-12-18. First edition by Zhenping

if ~ exist('method', 'var')
    method = 'moving';
end

if ~ exist('measure_error', 'var')
    measure_error = zeros(size(signal));
end

ext_aer = NaN(nProfiles, length(signal));
signal_gen = NaN(nProfiles, length(signal));
bg_gen = NaN(nProfiles, length(signal));

signalGen = sigGenWithNoise(signal, sqrt(signal + bg), nProfiles, 'norm');

for iProfile = 1:nProfiles
    sig = signalGen(:, iProfile)';
    ext_aer(iProfile, :) = polly_raman_ext(height, sig, lambda_emit, ...
    lambda_rec, angstrom, pressure, temperature, window_size, C, rh, method, measure_error);
end

ext_std = nanstd(ext_aer);
end