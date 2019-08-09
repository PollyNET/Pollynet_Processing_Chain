function [AODOut] = interp_AERONET_AOD(wl1, AOD1, wl2, AOD2, wlOut)
%interp_AERONET_AOD interp the AERONET AOD with the angstroem law.
%   Example:
%       [AODOut] = interp_AERONET_AOD(wl1, AOD1, wl2, AOD2, wlOut)
%   Inputs:
%       wl1: float
%           wavelength 1. [nm] 
%       AOD1: float
%           AOD at wavelength 1. 
%       wl2: float
%           wavelength 2. [nm] 
%       AOD2: float
%           AOD at wavelength 2. 
%       wlOut: float
%           query wavelength. [nm]
%   Outputs:
%       AODOut: float
%           the interpolated AOD at hte input wavelength 'wvOut'
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if (AOD1 <= 0) || (AOD2 <= 0)
    error('Negative AERONET AOD value.');
end

angstrexp = (log(AOD2) - log(AOD1)) / (log(wl1) - log(wl2));
AODOut = (wl1 / wlOut) .^ angstrexp .* AOD1;

end