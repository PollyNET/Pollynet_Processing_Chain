function [signalGen] = sigGenWithNoise(signal, noise, nProfile, method)
%SIGGENWITHNOISE generate the noise containing signal with certain noise adding 
%algorithm.
%Example:
%   [signalGen] = sigGenWithNoise(signal, noise, nProfile, method)
%Inputs:
%   signal: array
%       signal strength.
%    noise: array
%       noise. Unit should be keep the same with signal. 
%    nProfile: array
%       number of signal profiles should be generated.
%   method: char
%       'norm': normal distributed noise -> 
%       signalGen = signal + norm * noise
%       'poisson': poisson distributed noise -> 
%       signal = poisson(signal, nProfile)
%Outputs:
%   signalGen: matrix length(signal) * nProfile
%       noise containing signal.
%History:
%   2018-08-17. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

if ~ exist('nProfile', 'var')
    nProfile = 1; 
    method = 'norm';
end

if ~ exist('noise', 'var')
    noise = sqrt(signal);
end

signal = reshape(signal, 1, length(signal));
noise = reshape(noise, 1, length(noise));

signalGen = NaN(length(signal), nProfile);

switch method
    case 'norm'
        for iBin = 1:length(signal)
            signalGen(iBin, :) = signal(iBin) + randn(1, nProfile) * noise(iBin);
        end
    case 'poisson'
        for iBin = 1:length(signal)
            signalGen(iBin, :) = poissrnd(signal(iBin), 1, nProfile);
        end
    otherwise
        error('A required method should be provided');
end

end