function [quasi_par_bsc, quasi_par_ext] = quasi_retrieving_V2(height, att_beta_el, att_beta_ra, wavelength, molExtEl, molBscEl, molExtRa, molBscRa, AE, LR, nIters)
%quasi_retrieving_V2 Retrieve the aerosol optical properties with quasi retrieving method (V2). This method was improved from the quasi-retrieving method, which also takes use of the Raman signal. Detailed information please refer to '../doc/quasi_retrieving_V2.pdf'
%   Example:
%       [quasi_par_bsc, quasi_par_ext] = quasi_retrieving_V2(height, att_beta_el, att_beta_ra, wavelength, molExtEl, molBscEl, molExtRa, molBscRa, AE, LR, nIters)
%   Inputs:
%       height: array
%           height. [m] 
%       att_beta_el: matrix
%           attenuated backscatter at elastic wavelength. [m^{-1}sr^{-1}] 
%       att_beta_ra: matrix
%           attenuated backscatter at corresponding Raman backscatter wavelength. [m^{-1}sr^{-1}]
%       wavelength: integer
%           the wavelength of the elastic backscatter to guide to choose the suitable Raman wavelength. [nm]
%       molExtEl: matrix
%           molecule extinction coefficient at the Elastic wavelength. [m^{-1}] 
%       molBscEl: matrix
%           molecule backscatter coefficient at the Elastic wavelength. [m^{-1}sr^{-1}]
%       molExtRa: matrix
%           molecule extinction coefficient at the Raman backscatter wavelength. [m^{-1}] 
%       molBscRa: matrix
%           molecule backscatter coefficient at the Raman backscatter wavelength. [m^{-1}sr^{-1}]
%       AE: float
%           Extinction related Angstroem exponent.
%       LR: float
%           aerosol lidar ratio. [sr]
%       nIters: integer
%           number of iterations to converge the retrieving results.
%   Outputs:
%       quasi_par_bsc: matrix
%           quasi particle backscatter coefficient. [m^{-1}sr^{-1}] 
%       quasi_par_ext: matrix
%           quasi particle extinction coefficient. [m^{-1}]
%   History:
%       2019-08-03. First Edition by Zhenping. Inspired by Holger Baars.
%   Contact:
%       zhenping@tropos.de

if ~ exist('nIters', 'var')
    nIters = 1;
end

diffHeight = repmat(transpose([height(1), diff(height)]), 1, size(att_beta_el, 2));
quasi_par_ext = zeros(size(molBscEl));

switch wavelength
case 355
    for iLoop = 1:nIters
        molBsc387 = molBscEl * (355/387)^4;
        OD_mol_355 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_387 = nancumsum(molExtRa .* diffHeight, 1);
        OD_par_355 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = att_beta_el ./ att_beta_ra .* exp((1 - (355/387)^AE) * OD_par_355 + (OD_mol_355 - OD_mol_387)) .* molBsc387 - molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
case 532
    for iLoop = 1:nIters
        molBsc607 = molBscEl * (532/607)^4;
        OD_mol_532 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_607 = nancumsum(molExtRa .* diffHeight, 1);
        OD_par_532 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = att_beta_el ./ att_beta_ra .* exp((1 - (532/607)^AE) * OD_par_532 + (OD_mol_532 - OD_mol_607)) .* molBsc607 - molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
case 1064
    for iLoop = 1:nIters
        molBsc532 = molBscEl * (1064/532)^4;
        molBsc607 = molBscEl * (1064/607)^4;
        OD_mol_1064 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_607 = nancumsum(molExtRa .* diffHeight, 1);
        OD_mol_532 = nancumsum(molExtRa .* (607/532)^4 .* diffHeight, 1);
        OD_par_1064 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = (att_beta_el ./ att_beta_ra .* exp((2 - (1064/607)^AE - (1064/532)^AE) * OD_par_1064 + (2*OD_mol_1064 - OD_mol_532 - OD_mol_607))) .* molBsc607 - molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
end

end