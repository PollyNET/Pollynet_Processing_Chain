function [ext_std] = pollyRamanExtStd(height, signal, bg, lambda_emit, ...
    lambda_rec, angstrom, pressure, temperature, window_size, C, rh, nProfiles, method, measure_error)
% POLLYRAMANEXTSTD calcualte uncertainty of aerosol extinction coefficient with Monte-Carlo simulation.
% USAGE:
%    [ext_std] = pollyRamanExtStd(height, signal, bg, lambda_emit, ...
%       lambda_rec, angstrom, pressure, temperature, window_size, ...
%       C, rh, nProfiles, method, measure_error)
% INPUTS:
%    height: array
%        height[m]
%    signal: array
%        measured raman signal. [Photon Count]
%    bg: array
%        background. [Photon Count]
%    lambda_emit: float
%        the wavelength of the emitted laser beam.[nm]
%    lambda_rec: float
%        the wavelength of raman sigal.[nm]
%    angstrom: float
%        the angstrom exponent for aerosol extinction coefficient
%    pressure: array
%        pressure of the atmosphere. [hPa]
%    temperature: array
%        temperature of the atmosphere. [K]
%    window_size: integer
%        window_size for smoothing the signal.
%    C: array
%        CO2 concentration.[ppmv]
%    rh: array
%        relative humidity.
%    nProfiles: integer
%        number of the generated profiles to calculate the uncertainty.
% OUTPUTS:
%    ext_std: array
%        uncertainty of aerosol extinction coefficient [m^{-1}]
% EXAMPLE:
% HISTORY:
%    2021-07-16: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ exist('method', 'var')
    method = 'moving';
end

if ~ exist('measure_error', 'var')
    measure_error = zeros(size(signal));
end

ext_aer = NaN(nProfiles, length(signal));

signalGen = sigGenWithNoise(signal, sqrt(signal + bg), nProfiles, 'norm');

for iProfile = 1:nProfiles
    sig = signalGen(:, iProfile)';
    ext_aer(iProfile, :) = pollyRamanExt(height, sig, lambda_emit, lambda_rec, angstrom, pressure, temperature, window_size, C, rh, method, measure_error);
end

ext_std = nanstd(ext_aer, 1, 0);

end