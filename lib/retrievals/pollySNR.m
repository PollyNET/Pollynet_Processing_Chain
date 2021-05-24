function [SNR] = pollySNR(signal, bg)
% pollySNR calculate signal-noise ratio (SNR).
% USAGE:
%    [SNR] = pollySNR(signal, bg)
% INPUTS:
%    signal: array
%        signal strength.
%    bg: array
%        background. (bg should have the same size as signal)
% OUTPUTS:
%    SNR: array
%        signal-noise-ratio. For negative signal, the SNR was set to be 0.
% EXAMPLE:
% References:
% 1. Heese, B., Flentje, H., Althausen, D., Ansmann, A., and Frey, S.: Ceilometer lidar comparison: backscatter coefficient retrieval and signal-to-noise ratio determination, Atmospheric Measurement Techniques, 3, 1763-1770, 2010.
% HISTORY:
%    2021-04-21: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

tot = signal + 2 * bg;
tot(tot <= 0) = NaN;

SNR = signal ./ sqrt(tot);
SNR(SNR <= 0) = 0;
SNR(isnan(SNR)) = 0;

end