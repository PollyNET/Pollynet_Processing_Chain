function [ aerBscStd ] = polly_raman_bsc_std(height, sigElastic, bgElastic, ...
                    sigVRN2, bgVRN2, ext_aer, sigma_ext_aer, angstroem, ...
                    sigma_angstroem, ext_mol, beta_mol, HRef, wavelength, ...
                    betaRef, smoothWindow, nSamples, method, flagSmoothBefore)
%POLLY_RAMAN_BSC_STD calculate the uncertainty of aerosol backscatter 
%coefficient with Raman method.
%   Example:
%       [ aerBscStd ] = polly_raman_bsc_std(height, sigElastic, bgElastic, ...
%                    sigVRN2, bgVRN2, ext_aer, sigma_ext_aer, angstroem, ...
%                    sigma_angstroem, ext_mol, beta_mol, HRef, wavelength, ...
%                    betaRef, smoothWindow, nSamples, method)
%   Inputs:
%       height: array
%           height. [m]
%       sigElastic: array
%           elastic photon count signal.
%		bgElastic: array
%			background of elastic signal.
%       sigVRN2: array
%           N2 vibration rotational raman photon count signal.
%       bgVRN2: array
%           background of N2 vibration rotational signal.
%       ext_aer: array
%           aerosol extinction coefficient. [m^{-1}]
%		sigma_ext_aer: array
%			uncertainty of aerosol extinction coefficient. [m^{-1}]
%       angstroem: array
%           aerosol angstroem exponent.
%       ext_mol: array
%           molecular extinction coefficient. [m^{-1}]
%       beta_mol: array
%           molecular backscatter coefficient. [m^{-1}Sr^{-1}]
%       HRef: 2 element array
%           reference region. [m]
%       wavelength: integer
%           wavelength of the corresponding elastic signal. [nm]
%       betaRef: float
%           aerosol backscatter coefficient at the reference region. 
%           [m^{-1}Sr^{-1}]
%       smoothWindow: integer or n*3 matrix
%           number of the bins of the sliding window for the signal smooth. 
%           [default: 40]
%       nSamples: scalar or matrix
%           samples for each error source.
%           [samples_angstroem, samples_aerExt, samples_signal,
%            samples_aerBscRef]
%       method: char
%           computational method. ['monte-carlo' or 'analytical']
%       flagSmoothBefore: logical
%           flag to control the smooth order.
%   Outputs:
%       aerBscStd: array
%           uncertainty of aerosol backscatter coefficient. [m^{-1}Sr^{-1}]
%   References:
%       netcdf-florian retrieving package
%       Ansmann, A., et al. (1992). "Independent measurement of extinction and 
%       backscatter profiles in cirrus clouds by using a combined Raman 
%       elastic-backscatter lidar." Applied optics 31(33): 7113-7131.
%   History:
%       2018-01-02. First edition by Zhenping.
%   Contact:
%       zhenping@tropos.de


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
    warning('MyLib:Polly_raman_bsc_std', ...
            'Too large sampling for monte-carlo simulation.');
    aerBscStd = NaN(size(sigElastic));
    return;
end

if strcmpi(method, 'monte-carlo')
    hRefIndx = (height >= HRef(1)) & (height < HRef(2));
    rel_std_betaRef = std(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) / ...
                      mean(sigElastic(hRefIndx)./sigVRN2(hRefIndx)) * 0.2;
    betaRefSample = transpose(sigGenWithNoise(betaRef, rel_std_betaRef * ...
                    mean(beta_mol(hRefIndx)), nSamples(4), 'norm'));

    angstroemSample = transpose(sigGenWithNoise(angstroem, sigma_angstroem, ...
                                nSamples(1), 'norm'));
    ext_aer_sample = transpose(sigGenWithNoise(ext_aer, sigma_ext_aer, ...
                               nSamples(2), 'norm'));
    sigElasticSample = transpose(sigGenWithNoise(sigElastic, ...
                                 sqrt(sigElastic + bgElastic), nSamples(3), ...
                                 'norm'));
    sigVRN2Sample = transpose(sigGenWithNoise(sigVRN2, ...
                               sqrt(sigVRN2 + bgVRN2), nSamples(3), 'norm'));

    aerBscSample = NaN(prod(nSamples), length(ext_aer));
    for iLoop_angstroem = 1:nSamples(1)
        for iLoop_ext_aer = 1:nSamples(2)
            for iLoop_signal = 1:nSamples(3)
                for iLoop_betaRef = 1:nSamples(4)
                    aerBscSample(iLoop_betaRef + nSamples(4)*(iLoop_signal - 1) + ...
                        nSamples(4)*nSamples(3)*(iLoop_ext_aer - 1) + ...
                        nSamples(4)*nSamples(3)*nSamples(2)*(iLoop_angstroem - 1), :) = ...
                        Polly_raman_bsc(height, sigElasticSample(iLoop_signal, :), sigVRN2Sample(iLoop_signal, :), ...
                        ext_aer_sample(iLoop_ext_aer, :), ...
                        angstroemSample(iLoop_angstroem, :), ext_mol, ...
                        beta_mol, HRef, wavelength, ...
                        betaRefSample(iLoop_betaRef), smoothWindow, ...
                        flagSmoothBefore);
                end
            end
        end
    end

    aerBscStd = std(aerBscSample, 0, 1);

elseif strcmpi(method, 'analytical')
%TODO: analytical error analysis for Raman Backscatter retrieval
else
    error(['Polly_raman_bsc_std', 'Unkown method to estimate the uncertainty.']);
end

end