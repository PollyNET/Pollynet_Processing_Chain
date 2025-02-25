function [beta_aer, aerBscStd, LR] = pollyRamanBsc_smart_MC(height, sigElastic, sigVRN2,  ext_aer, angstroem,  ext_mol, beta_mol, ext_mol_raman, beta_mol_inela, HRef, betaRef, window_size, flagSmoothBefore, el_lambda, inel_lambda,  bgElastic, bgVRN2,sigma_ext_aer, sigma_angstroem, MC_count, method) 
                
% POLLYRAMANBSCSTD calculate uncertainty of aerosol backscatter coefficient with Monte-Carlo simulation.
%
% USAGE:
%    [ aerBscStd ] = pollyRamanBscStd(height, sigElastic, bgElastic, ...
%                       sigVRN2, bgVRN2, ext_aer, sigma_ext_aer, angstroem, ...
%                       sigma_angstroem, ext_mol, beta_mol, HRef, wavelength, ...
%                       betaRef, smoothWindow, MC_count, method, flagSmoothBefore)
%
% INPUTS:
%    height: array
%        height. [m]
%    sigElastic: array
%        elastic photon count signal.
%    bgElastic: array
%        background of elastic signal.
%    sigVRN2: array
%        N2 vibration rotational raman photon count signal.
%    bgVRN2: array
%        background of N2 vibration rotational signal.
%    ext_aer: array
%        aerosol extinction coefficient. [m^{-1}]
%    sigma_ext_aer: array
%        uncertainty of aerosol extinction coefficient. [m^{-1}]
%    angstroem: array
%        aerosol angstroem exponent.
%    ext_mol: array
%        molecular extinction coefficient. [m^{-1}]
%    beta_mol: array
%        molecular backscatter coefficient. [m^{-1}Sr^{-1}]
%    HRef: 2 element array
%        reference region. [m]
%    wavelength: integer
%        wavelength of the corresponding elastic signal. [nm]
%    betaRef: float
%        aerosol backscatter coefficient at the reference region. [m^{-1}Sr^{-1}]
%    smoothWindow: integer or n*3 matrix
%        number of the bins of the sliding window for the signal smooth. [default: 40]
%    MC_count: scalar or matrix
%        samples for each error source. [samples_angstroem, samples_aerExt, samples_signal, samples_aerBscRef]
%    method: char
%        computational method. ['monte-carlo' or 'analytical']
%    flagSmoothBefore: logical
%        flag to control the smooth order.
%
% OUTPUTS:
%    aerBscStd: array
%        uncertainty of aerosol backscatter coefficient. [m^{-1}Sr^{-1}]
%
% HISTORY:
%    - 2021-07-16: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ~ exist('method', 'var')
    method = 'monte-carlo';
end

if ~ exist('flagSmoothBefore', 'var')
    flagSmoothBefore = true;
end

if ~ exist('MC_count', 'var')
    MC_count = 3;
end

if isscalar(MC_count)
    MC_count = ones(1, 4) * MC_count;
end

if prod(MC_count) > 1e5
    warning('Too large sampling for monte-carlo simulation.');
    aerBscStd = NaN(size(sigElastic));
    return;
end

[ beta_aer, LR ] = pollyRamanBsc_smart(height, sigElastic, sigVRN2, ext_aer, angstroem, ext_mol, beta_mol,ext_mol_raman, beta_mol_inela, HRef, el_lambda, betaRef, window_size, flagSmoothBefore, el_lambda, inel_lambda);

if strcmpi(method, 'monte-carlo')
    hRefIndx = (height >= HRef(1)) & (height < HRef(2));
%     rel_std_betaRef = std(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) / mean(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) * 0;
    rel_std_betaRef = 0.1;
    betaRefSample = transpose(sigGenWithNoise(betaRef, rel_std_betaRef*mean(beta_mol(hRefIndx)), MC_count(4), 'norm'));
    angstroemSample = transpose(sigGenWithNoise(angstroem, sigma_angstroem, MC_count(1), 'norm'));
    ext_aer_sample = transpose(sigGenWithNoise(ext_aer, sigma_ext_aer, MC_count(2), 'norm'));
    sigElasticSample = transpose(sigGenWithNoise(sigElastic, sqrt(sigElastic + bgElastic), MC_count(3), 'norm'));
    sigVRN2Sample = transpose(sigGenWithNoise(sigVRN2, sqrt(sigVRN2 + bgVRN2), MC_count(3), 'norm'));

    aerBscSample = NaN(prod(MC_count), length(ext_aer));
    for iX = 1:MC_count(1)
        for iY = 1:MC_count(2)
            for iZ = 1:MC_count(3)
                for iM = 1:MC_count(4)
                    aerBscSample(iM + MC_count(4)*(iZ - 1) + MC_count(4)*MC_count(3)*(iY - 1) + MC_count(4)*MC_count(3)*MC_count(2)*(iX - 1), :) = ...
                    pollyRamanBsc_smart(height, sigElasticSample(iZ, :), sigVRN2Sample(iZ, :), ext_aer_sample(iY, :), angstroemSample(iX, :), ext_mol, beta_mol,ext_mol_raman, beta_mol_inela, HRef, el_lambda, betaRefSample(iM), window_size, flagSmoothBefore, el_lambda, inel_lambda);
                 end
            end
        end
    end

    aerBscStd = nanstd(aerBscSample, 1, 0);

elseif strcmpi(method, 'analytical')
    aerBscStd=NaN(length(beta_aer));
    %TODO: analytical error analysis for Raman Backscatter retrieval
else
    aerBscStd=NaN(length(beta_aer));
    error('Unkown method to estimate the uncertainty.');
end

end