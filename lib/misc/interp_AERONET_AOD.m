function [AODOut] = interp_AERONET_AOD(wl1, AOD1, wl2, AOD2, wlOut)
% INTERP_AERONET_AOD interpolate AERONET AOD with the angstroem law.
%
% USAGE:
%    [AODOut] = interp_AERONET_AOD(wl1, AOD1, wl2, AOD2, wlOut)
%
% INPUTS:
%    wl1: float
%        wavelength 1. [nm] 
%    AOD1: float
%        AOD at wavelength 1. 
%    wl2: float
%        wavelength 2. [nm] 
%    AOD2: float
%        AOD at wavelength 2. 
%    wlOut: float
%        query wavelength. [nm]
%
% OUTPUTS:
%    AODOut: float
%        the interpolated AOD at hte input wavelength 'wvOut'
%
% HISTORY:
%    - 2021-05-30: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if (AOD1 <= 0) || (AOD2 <= 0)
    error('Negative AERONET AOD value.');
end

angstrexp = (log(AOD2) - log(AOD1)) / (log(wl1) - log(wl2));
AODOut = (wl1 / wlOut) .^ angstrexp .* AOD1;

end