function [quasi_par_bsc, quasi_par_ext] = quasiRetrieval(height, att_beta, ...
                    molExt, molBsc, LRaer, varargin)
% QUASIRETRIEVAL Retrieve the aerosol optical properties with quasi retrieving 
% method
% USAGE:
%    [quasi_par_bsc, quasi_par_ext] = quasiRetrieval(height, att_beta, ...
%                                        molExt, molBsc, LRaer)
% INPUTS:
%    height: array
%        height. [m] 
%    att_beta: matrix
%        attenuated backscatter. [m^{-1}Sr^{-1}] 
%    molExt: matrix
%        molecule extinction coefficient. [m^{-1}] 
%    molBsc: matrix
%        molecule backscatter coefficient. [m^{-1}Sr^{-1}]
%    LRaer: float
%        aerosol lidar ratio. [Sr]
% KEYWORDS:
%    nIters: numeric
%        iteration times.
% OUTPUTS:
%    quasi_par_bsc: matrix
%        quasi particle backscatter coefficient. [m^{-1}Sr^{-1}] 
%    quasi_par_ext: matrix
%        quasi particle extinction coefficient. [m^{-1}]
% REFERENCES:
%    Baars, H., Seifert, P., Engelmann, R. & Wandinger, U. Target categorization of aerosol and clouds by continuous multiwavelength-polarization lidar measurements. Atmospheric Measurement Techniques 10, 3175-3201, doi:10.5194/amt-10-3175-2017 (2017).
% EXAMPLE:
% HISTORY:
%    2018-12-25: First Edition by Zhenping
%    2019-03-31: Add the keywork of 'nIters' to control the iteration times.
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'att_beta', @isnumeric);
addRequired(p, 'molExt', @isnumeric);
addRequired(p, 'molBsc', @isnumeric);
addRequired(p, 'LRaer', @isnumeric);
addParameter(p, 'nIters', 2, @isnumeric);

parse(p, height, att_beta, molExt, molBsc, LRaer, varargin{:});

diffHeight = repmat(transpose([height(1), diff(height)]), 1, size(att_beta, 2));
mol_att = exp(- cumsum(molExt .* diffHeight, 1));
quasi_par_ext = zeros(size(molBsc));

for iLoop = 1:p.Results.nIters
    quasi_par_att = exp(-nancumsum(quasi_par_ext .* diffHeight, 1));
    quasi_par_bsc = att_beta ./ (mol_att .* quasi_par_att).^2 - molBsc;
    quasi_par_bsc(quasi_par_bsc < 0) = 0;
    quasi_par_ext = quasi_par_bsc * LRaer;
end

end