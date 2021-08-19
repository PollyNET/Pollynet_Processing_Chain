function [quasi_par_bsc, quasi_par_ext] = quasiRetrieval2(height, ...
    att_beta_el, att_beta_ra, wavelength, molExtEl, molBscEl, molExtRa, ...
    AE, LR, varargin)
% QUASIRETRIEVAL2 Retrieve the aerosol optical properties with quasi 
% retrieving method (V2). This method was improved from the quasi-retrieving 
% method, which also takes use of the Raman signal.
%
% USAGE:
%    [quasi_par_bsc, quasi_par_ext] = quasiRetrieval2(height, ...
%    att_beta_el, att_beta_ra, wavelength, molExtEl, molBscEl, molExtRa, ...
%    AE, LR)
%
% INPUTS:
%    height: array
%        height. [m] 
%    att_beta_el: matrix
%        attenuated backscatter at elastic wavelength. [m^{-1}sr^{-1}] 
%    att_beta_ra: matrix
%        attenuated backscatter at corresponding Raman backscatter 
%        wavelength. [m^{-1}sr^{-1}]
%    wavelength: integer
%        the wavelength of the elastic backscatter to guide to choose the 
%        suitable Raman wavelength. [nm]
%    molExtEl: matrix
%        molecule extinction coefficient at the Elastic wavelength. [m^{-1}] 
%    molBscEl: matrix
%        molecule backscatter coefficient at the Elastic wavelength. 
%        [m^{-1}sr^{-1}]
%    molExtRa: matrix
%        molecule extinction coefficient at the Raman backscatter wavelength.
%        [m^{-1}] 
%    AE: float
%        Extinction related Angstroem exponent.
%    LR: float
%        aerosol lidar ratio. [sr]
%
% KEYWORDS:
%     nIters: numeric
%         iteration times.
%
% OUTPUTS:
%    quasi_par_bsc: matrix
%        quasi particle backscatter coefficient. [m^{-1}sr^{-1}] 
%    quasi_par_ext: matrix
%        quasi particle extinction coefficient. [m^{-1}]
%
% HISTORY:
%    - 2021-06-07: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'att_beta_el', @isnumeric);
addRequired(p, 'att_beta_ra', @isnumeric);
addRequired(p, 'wavelength', @isnumeric);
addRequired(p, 'molExtEl', @isnumeric);
addRequired(p, 'molBscEl', @isnumeric);
addRequired(p, 'molExtRa', @isnumeric);
addRequired(p, 'AE', @isnumeric);
addRequired(p, 'LR', @isnumeric);
addParameter(p, 'nIters', 1, @isnumeric);

parse(p, height, att_beta_el, att_beta_ra, wavelength, molExtEl, molBscEl, molExtRa, AE, LR, varargin{:});

diffHeight = repmat(transpose([height(1), diff(height)]), 1, ...
                    size(att_beta_el, 2));
quasi_par_ext = zeros(size(molBscEl));

switch wavelength
case 355
    for iLoop = 1:p.Results.nIters
        OD_mol_355 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_387 = nancumsum(molExtRa .* diffHeight, 1);
        OD_par_355 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = att_beta_el ./ ...
        att_beta_ra .* exp((1 - (355/387)^AE) * OD_par_355 + ...
        (OD_mol_355 - OD_mol_387)) .* molBscEl - molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
case 532
    for iLoop = 1:p.Results.nIters
        OD_mol_532 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_607 = nancumsum(molExtRa .* diffHeight, 1);
        OD_par_532 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = att_beta_el ./ att_beta_ra .* ...
            exp((1 - (532/607)^AE) * OD_par_532 + ...
            (OD_mol_532 - OD_mol_607)) .* molBscEl - molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
case 1064
    for iLoop = 1:p.Results.nIters
        molBsc532 = molBscEl * (1064/532)^4;
        OD_mol_1064 = nancumsum(molExtEl .* diffHeight, 1);
        OD_mol_607 = nancumsum(molExtRa .* diffHeight, 1);
        OD_mol_532 = nancumsum(molExtRa .* (607/532)^4 .* diffHeight, 1);
        OD_par_1064 = nancumsum(quasi_par_ext .* diffHeight, 1);

        quasi_par_bsc = (att_beta_el ./ att_beta_ra .* ...
            exp((2 - (1064/607)^AE - (1064/532)^AE) * OD_par_1064 + ...
            (2*OD_mol_1064 - OD_mol_532 - OD_mol_607))) .* molBsc532 - ...
            molBscEl;
        quasi_par_ext = quasi_par_bsc * LR;
    end
end

end