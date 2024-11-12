function [ ext_aer ] = pollyRamanExt_smart(height, sig, lambda_emit, ...
    lambda_Raman,alpha_molecular_elastic, alpha_molecular_Raman, number_density, angstrom, window_size, method, measure_error)
% POLLYRAMANEXT etrieve the aerosol extinction coefficient with Raman method
%
% USAGE:
%    [ ext_aer ] = pollyRamanExt(height, sig, lambda_emit, lambda_Raman, angstrom, pressure, temperature, window_size, C, rh, method, measure_error)
%
% INPUTS:
%    height: array
%        height[m]
%    sig: array
%        measured raman signal. Unit: Photon Count
%    lambda_emit: float
%        the wavelength of the emitted laser beam.[nm]
%    lambda_Raman: float
%        the wavelength of raman sigal.[nm]
%    angstrom: float
%        the angstrom exponent for aerosol extinction coefficient
%    window_size: integer
%        window_size for smoothing the signal with sgolay filter.
%    order: integer
%        order of the implemented sgolay filter.
%   method: char
%        specify the method to calculate the slope of the signal. You can 
%        choose from 'moving', 'smoothing' and 'chi2'.
%    measure_error: array
%        measurement error for each bin.
%    alpha_molecular_elastic: array
%        molecular scattering coefficient at emitted wavelength in m^-1 sr^-1
%     alpha_molecular_Raman: array
%        molecular scattering coefficient at Raman wavelength in m^-1 sr^-1
%     number_density: array
%        molecular number density
%
% OUTPUTS:
%    ext_aer: array
%        aerosol extinction coefficient [m^{-1}]
%
% REFERENCES:
%    https://bitbucket.org/iannis_b/lidar_processing
%
%    Ansmann, A. et al. Independent measurement of extinction and backscatter profiles in cirrus clouds by using a combined Raman elastic-backscatter lidar. Applied Optics Vol. 31, Issue 33, pp. 7113-7131 (1992)
%
% HISTORY:
%    - 2021-05-31: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

% default method is movingslope
if ~ exist('method', 'var')
    method = 'movingslope';
end

if ~ exist('measure_error', 'var')
    measure_error = zeros(size(sig));
end

temp = number_density ./ (sig .* height.^2);
temp(temp <= 0) = NaN;
ratio = log(temp);

if strcmpi(method, 'moving') || strcmpi(method, 'movingslope')
    deriv_ratio = movingslope_variedWin(ratio, window_size) ./ ...
    [height(2) - height(1), diff(height)];
elseif strcmpi(method, 'smoothing') || strcmpi(method, 'smooth')
    deriv_ratio = movingsmooth_variedWin(ratio, window_size) ./ [height(2) - ...
    height(1), diff(height)];
elseif strcmpi(method, 'chi2') 
    deriv_ratio = movingLinfit_variedWin(height, ratio, measure_error, ...
    window_size);
else
    error('Please set a valid method for calculate the extinction coefficient.');
end

ext_aer = (deriv_ratio - alpha_molecular_elastic - alpha_molecular_Raman) ./ ...
          (1 + (lambda_emit ./ lambda_Raman) .^ angstrom);

end