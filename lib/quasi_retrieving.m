function [quasi_par_bsc, quasi_par_ext] = quasi_retrieving(height, att_beta, molExt, molBsc, LRaer, nIters)
%quasi_retrieving Retrieve the aerosol optical properties with quasi retrieving method
%   Example:
%       [quasi_par_bsc, quasi_par_ext] = quasi_retrieving(height, att_beta, molExt, molBsc, LRaer)
%   Inputs:
%       height: array
%           height. [m] 
%       att_beta: matrix
%           attenuated backscatter. [m^{-1}Sr^{-1}] 
%       molExt: matrix
%           molecule extinction coefficient. [m^{-1}] 
%       molBsc: matrix
%           molecule backscatter coefficient. [m^{-1}Sr^{-1}]
%        LRaer: float
%           aerosol lidar ratio. [Sr]
%   Outputs:
%       quasi_par_bsc: matrix
%           quasi particle backscatter coefficient. [m^{-1}Sr^{-1}] 
%       quasi_par_ext: matrix
%           quasi particle extinction coefficient. [m^{-1}]
%   History:
%       2018-12-25. First Edition by Zhenping
%       2019-03-31. Add the keywork of 'nIters' to control the iteration times.
%   Contact:
%       zhenping@tropos.de

if ~ exist('nIters', 'var')
    nIters = 2;
end

diffHeight = repmat(transpose([height(1), diff(height)]), 1, size(att_beta, 2));
mol_att = exp(- cumsum(molExt .* diffHeight, 1));
quasi_par_ext = zeros(size(molBsc));

for iLoop = 1:nIters
    quasi_par_att = exp(-nancumsum(quasi_par_ext .* diffHeight, 1));
    quasi_par_bsc = att_beta ./ (mol_att .* quasi_par_att).^2 - molBsc;
    quasi_par_bsc(quasi_par_bsc < 0) = 0;
    quasi_par_ext = quasi_par_bsc * LRaer;
end

end