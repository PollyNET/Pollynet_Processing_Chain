function [SNR] = polly_SNR(signal, bg)
%POLLY_SNR calculate the SNR
%Example:
%   [SNR] = polly_SNR(signal, bg)
%Inputs:
%   signal: array
%       signal strength.
%   bg: array
%       background. (bg should have the same size as signal)
%Outputs:
%   SNR: array
%       signal-noise-ratio. For negative signal, the SNR was set to be 0.
%History:
%   2018-09-01. First edition by Zhenping.
%Contact:
%   zhenping@tropos.de


tot = signal + 2 * bg;
tot(tot <= 0) = NaN;

SNR = signal ./ sqrt(tot);
SNR(SNR <= 0) = 0;
SNR(isnan(SNR)) = 0;

end