function [ beta_aer, LR ] = polly_raman_bsc_rr(height, sigElastic, sigVRN2, ext_aer, ext_mol, beta_mol, HRef, wavelength, betaRef, window_size, flagSmoothBefore)
%POLLY_RAMAN_BSC calculate the aerosol backscatter coefficient with rotational 
%Raman signal. 
%Usage:
%   [ beta_aer, LR ] = polly_raman_bsc_rr(height, sigElastic, sigVRN2, ...
%   ext_aer, ext_mol, beta_mol, HRef, wavelength, betaRef, window_size, ...
%   flagSmoothBefore)
%Inputs:
%   height: array
%       height. [m]
%   sigElastic: array
%       elastic photon count signal.
%   sigVRN2: array
%       N2 vibration rotational raman photon count signal.
%   ext_aer: array
%       aerosol extinction coefficient. [m^{-1}]
%   ext_mol: array
%       molecular extinction coefficient. [m^{-1}]
%   beta_mol: array
%       molecular backscatter coefficient. [m^{-1}Sr^{-1}]
%   HRef: 2 element array
%       reference region. [m]
%   wavelength: integer
%       wavelength of the corresponding elastic signal. [nm]
%   betaRef: float
%       aerosol backscatter coefficient at the reference region. 
%       [m^{-1}Sr^{-1}]
%   window_size: integer
%       number of the bins of the sliding window for the signal smooth. 
%       [default: 40]
%   flagSmoothBefore: logcial
%       flag bit to control the smoothing order, whether smoothing the 
%       signal before calculating the signal ratio or not.
%Outputs:
%   beta_aer: array
%       aerosol backscatter coefficient. [m^{-1}Sr^{-1}]
%   LR: array
%       aerosol lidar ratio.
%References:
%   Ansmann, A., et al. (1992). "Independent measurement of extinction and 
%   backscatter profiles in cirrus clouds by using a combined Raman elastic-
%   backscatter lidar." Applied optics 31(33): 7113-7131.
%
%   Veselovskii, I., P. Goloub, T. Podvin, V. Bovchaliuk, Y. Derimian, P. 
%   Augustin, M. Fourmentin, D. Tanre, M. Korenskiy, and D. Whiteman (2016),
%   Retrieval of optical and physical properties of African dust from 
%   multiwavelength Raman lidar measurements during the SHADOW campaign in 
%   Senegal, Atmospheric Chemistry and Physics, 16(11), 7013.
%History:
%   2018-01-02. First edition by Zhenping.
%   2018-07-24. Add the ext_mol_factor and ext_aer_factor for wavelength 
%   of 1064nm
%   2018-09-04. Change the smoothing order. Previous way is smoothing the 
%   signal. This will create large drift at the signal ridges.
%   2018-09-05. Keep the original smoothing order for 355, which makes the 
%   retrieving results at the far range bins quite stable.
%Contact:
%   zhenping@tropos.de

% check the inputs                        
if ~ (nargin >= 9)
    error('Not enough input arguments.');
end 

if ~ exist('window_size', 'var')
    window_size = 40;
end

if (HRef(1) >= height(end)) || (HRef(end) <= height(1))
    error('HRef is out of range.');
end

if ~ exist('flagSmoothBefore', 'var')
    flagSmoothBefore = true;
end

if wavelength == 355
    ext_aer_factor = 1;
    ext_mol_factor = 1;
elseif wavelength == 532
    ext_aer_factor = 1;
    ext_mol_factor = 1;
else
    error('Unsupported wavelength!');
end

dH = height(2) - height(1);   % height resolution. [m]

% find the index of the HRef region and the midpoint of HRef
HRefIndx = [fix((HRef(1) - height(1)) / dH) + 1, ...
            fix((HRef(end) - height(1)) / dH) + 1];
refIndx = fix((mean(HRef) - height(1)) / dH) + 1;

% calculate the extinction coefficient at inelastic wavelength.
ext_aer_raman = ext_aer .* ext_aer_factor;
ext_mol_raman = ext_mol .* ext_mol_factor;

if wavelength == 532
    % calculate the optical depth from any point to refIndx 
    mol_el_OD = nansum(ext_mol(1:refIndx)) * dH - nancumsum(ext_mol) * dH;
    mol_vr_OD = nansum(ext_mol_raman(1:refIndx)) * dH - ...
                nancumsum(ext_mol_raman) * dH;
    aer_el_OD = nansum(ext_aer(1:refIndx)) * dH - nancumsum(ext_aer) * dH;
    aer_vr_OD = nansum(ext_aer_raman(1:refIndx)) * dH - ...
                nancumsum(ext_aer_raman) * dH;

    hIndx = false(1, length(height));
    hIndx(HRefIndx(1):HRefIndx(end)) = (sigElastic(HRefIndx(1):HRefIndx(end))...
                     >= 0) & (sigVRN2(HRefIndx(1):HRefIndx(end)) >= 0);

    % calculate the signal ratio at the reference height
    elMean = sigElastic(hIndx) .* height(hIndx).^2 ./ ...
            (beta_mol(hIndx) + betaRef);
    vrMean = sigVRN2(hIndx) .* height(hIndx).^2 ./ (beta_mol(hIndx));

    % calculate the aerosol backscatter coefficient.
    if ~ flagSmoothBefore
    beta_aer = transpose(smoothWin(((sigElastic ./ sigVRN2) ...
    .* (nanmean(vrMean) ./ nanmean(elMean)) .* ...
    exp(mol_vr_OD - mol_el_OD + aer_vr_OD - aer_el_OD) - 1) .* ...
    beta_mol, window_size, 'moving'));
    else
    beta_aer = ((transpose(smoothWin(sigElastic, window_size, 'moving')) ./ ...
                 transpose(smoothWin(sigVRN2, window_size, 'moving'))) .* ...
                 (nanmean(vrMean) ./ nanmean(elMean)) .* ...
                exp(mol_vr_OD - mol_el_OD + aer_vr_OD - aer_el_OD) - 1) .* ...
                beta_mol;
    end
    LR = ext_aer ./ beta_aer;

elseif wavelength == 355
    % calculate the optical depth from any point to refIndx 
    mol_el_OD = nansum(ext_mol(1:refIndx)) * dH - nancumsum(ext_mol) * dH;
    mol_vr_OD = nansum(ext_mol_raman(1:refIndx)) * dH - ...
                nancumsum(ext_mol_raman) * dH;
    aer_el_OD = nansum(ext_aer(1:refIndx)) * dH - nancumsum(ext_aer) * dH;
    aer_vr_OD = nansum(ext_aer_raman(1:refIndx)) * dH - ...
                nancumsum(ext_aer_raman) * dH;

    hIndx = false(1, length(height));
    hIndx(HRefIndx(1):HRefIndx(end)) = ...
    (sigElastic(HRefIndx(1):HRefIndx(end)) >= 0) & ...
    (sigVRN2(HRefIndx(1):HRefIndx(end)) >= 0);

    % calculate the signal ratio at the reference height
    elMean = sigElastic(hIndx) .* height(hIndx).^2 ./ ...
            (beta_mol(hIndx) + betaRef);
    vrMean = sigVRN2(hIndx) .* height(hIndx).^2 ./ (beta_mol(hIndx));

    % calculate the aerosol backscatter coefficient.
    if ~ flagSmoothBefore
    beta_aer = transpose(smoothWin(((sigElastic ./ sigVRN2) .* ...
               (nanmean(vrMean) ./ nanmean(elMean)) .* ...
                exp(mol_vr_OD - mol_el_OD + aer_vr_OD - aer_el_OD) - 1) .* ...
                beta_mol, window_size, 'moving'));
    else
    beta_aer = ((transpose(smoothWin(sigElastic, window_size, 'moving')) ./ ...
                 transpose(smoothWin(sigVRN2, window_size, 'moving'))) .* ...
                 (nanmean(vrMean) ./ nanmean(elMean)) .* ...
                exp(mol_vr_OD - mol_el_OD + aer_vr_OD - aer_el_OD) - 1) .* ...
                beta_mol;
    end
    LR = ext_aer ./ beta_aer;

end

end