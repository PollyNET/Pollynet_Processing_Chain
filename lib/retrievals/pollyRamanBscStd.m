function [ aerBscStd ] = pollyRamanBscStd(height, sigElastic, bgElastic, ...
                    sigVRN2, bgVRN2, ext_aer, sigma_ext_aer, angstroem, ...
                    sigma_angstroem, ext_mol, beta_mol, HRef, wavelength, ...
                    betaRef, smoothWindow, nSamples, method, flagSmoothBefore)
% POLLYRAMANBSCSTD calculate uncertainty of aerosol backscatter coefficient with Monte-Carlo simulation.
% USAGE:
%    [ aerBscStd ] = pollyRamanBscStd(height, sigElastic, bgElastic, ...
%                       sigVRN2, bgVRN2, ext_aer, sigma_ext_aer, angstroem, ...
%                       sigma_angstroem, ext_mol, beta_mol, HRef, wavelength, ...
%                       betaRef, smoothWindow, nSamples, method, flagSmoothBefore)
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
%        aerosol backscatter coefficient at the reference region. 
%        [m^{-1}Sr^{-1}]
%    smoothWindow: integer or n*3 matrix
%        number of the bins of the sliding window for the signal smooth. 
%        [default: 40]
%    nSamples: scalar or matrix
%        samples for each error source.
%        [samples_angstroem, samples_aerExt, samples_signal,
%         samples_aerBscRef]
%    method: char
%        computational method. ['monte-carlo' or 'analytical']
%    flagSmoothBefore: logical
%        flag to control the smooth order.
% OUTPUTS:
%    aerBscStd: array
%        uncertainty of aerosol backscatter coefficient. [m^{-1}Sr^{-1}]
% EXAMPLE:
% HISTORY:
%    2021-07-16: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ exist('method', 'var')
    method = 'monte-carlo';
end

if ~ exist('flagSmoothBefore', 'var')
    flagSmoothBefore = true;
end

if ~ exist('nSamples', 'var')
    nSamples = 3;
end

if isscalar(nSamples)
    nSamples = ones(1, 4) * nSamples;
end

if prod(nSamples) > 1e5
    warning('Too large sampling for monte-carlo simulation.');
    aerBscStd = NaN(size(sigElastic));
    return;
end

if strcmpi(method, 'monte-carlo')
    hRefIndx = (height >= HRef(1)) & (height < HRef(2));
%     rel_std_betaRef = std(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) / mean(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) * 0;
    rel_std_betaRef = 0.1;
    betaRefSample = transpose(sigGenWithNoise(betaRef, rel_std_betaRef*mean(beta_mol(hRefIndx)), nSamples(4), 'norm'));
    angstroemSample = transpose(sigGenWithNoise(angstroem, sigma_angstroem, nSamples(1), 'norm'));
    ext_aer_sample = transpose(sigGenWithNoise(ext_aer, sigma_ext_aer, nSamples(2), 'norm'));
    sigElasticSample = transpose(sigGenWithNoise(sigElastic, sqrt(sigElastic + bgElastic), nSamples(3), 'norm'));
    sigVRN2Sample = transpose(sigGenWithNoise(sigVRN2, sqrt(sigVRN2 + bgVRN2), nSamples(3), 'norm'));

    aerBscSample = NaN(prod(nSamples), length(ext_aer));
    for iX = 1:nSamples(1)
        for iY = 1:nSamples(2)
            for iZ = 1:nSamples(3)
                for iM = 1:nSamples(4)
                    aerBscSample(iM + nSamples(4)*(iZ - 1) + nSamples(4)*nSamples(3)*(iY - 1) + nSamples(4)*nSamples(3)*nSamples(2)*(iX - 1), :) = ...
                        pollyRamanBsc(height, sigElasticSample(iZ, :), ...
                        sigVRN2Sample(iZ, :), ext_aer_sample(iY, :), ...
                        angstroemSample(iX, :), ext_mol, beta_mol, HRef, wavelength, ...
                        betaRefSample(iM), smoothWindow, flagSmoothBefore);
                end
            end
        end
    end

    aerBscStd = nanstd(aerBscSample, 1, 0);

elseif strcmpi(method, 'analytical')
    %TODO: analytical error analysis for Raman Backscatter retrieval
else
    error('Unkown method to estimate the uncertainty.');
end

end