function [sigTCor, bgTCor] = transCorGHK(sigT, bgT, sigC, bgC, varargin)
% TRANSCOR corrects the effect of different polarization dependent transmission inside the total and depol channel.
%
% USAGE:
%    [sigTCor, bgTCor] = transCorGHK(sigEl, bgT, sigC, bgC)
%
% INPUTS:
%    sigT: array
%        signal in total channel.
%    bgT: array
%        background in total channel.
%    sigC: array
%        signal in cross channel.
%    bgC: array
%        background in total channel.
%
% KEYWORDS:
%    transGT: float
%        G parameter in total channel.
%    transGR: float
%        G parameter in cross channel.
%    transHT: float
%        H parameter in total channel.
%    transHR: float
%        H parameter in cross channel.
%    polCaliFactor: float
%        depolarization calibration constant (eta).
%    polCaliFacStd: float
%        uncertainty of the depolarization calibration constant.
%
% OUTPUTS:
%    sigTCor: array
%        transmission corrected elastic signal.
%    bgTCor: array
%        background of transmission corrected elastic signal.
%    sigTCorStd: array
%        uncertainty of transmission corrected elastic signal (has to be
%        implemented in the new code as well)
%
% REFERENCES:
%    Mattis, I., Tesche, M., Grein, M., Freudenthaler, V., and Müller, D.: Systematic error of lidar profiles caused by a polarization-dependent receiver transmission: Quantification and error correction scheme, Appl. Opt., 48, 2742-2751, 2009.
%    Freudenthaler, V. About the effects of polarising optics on lidar signals and the Delta90 calibration. Atmos. Meas. Tech., 9, 4181–4255 (2016).
%
% HISTORY:
%    - 2021-05-27: first edition by Zhenping.
%    - 2024-08-14: Change to GHK parameterization by Moritz.
%
% .. Authors: - zhenping@tropos.de, haarig@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'sigT', @isnumeric);
addRequired(p, 'bgT', @isnumeric);
addRequired(p, 'sigC', @isnumeric);
addRequired(p, 'bgC', @isnumeric);
addParameter(p, 'transGT', 1, @isnumeric);
addParameter(p, 'transGR', 1, @isnumeric);
addParameter(p, 'transHT', 0, @isnumeric);
addParameter(p, 'transHR', -1, @isnumeric);
addParameter(p, 'polCaliEta', 1, @isnumeric);
addParameter(p, 'polCaliEtaStd', 0, @isnumeric);

parse(p, sigT, bgT, sigC, bgC, varargin{:});

if ~ isequal(size(sigT), size(sigC))
    error('input signals have different size.')
end

GT = p.Results.transGT;
GR = p.Results.transGR;
HT = p.Results.transHT;
HR = p.Results.transHR;
eta = p.Results.polCaliEta;
etaStd = p.Results.polCaliEtaStd;

% from Freudenthaler AMT 2016: eq 65 with the denominator from eq 64 to
% avoid a negative signal
display(size(eta))
display(size(HR))
display(size(sigT))
display(size(HT))
display(size(sigC))
display(size(GT))
display(size(GR))
sigTCor = (eta * HR .* sigT - HT .* sigC) ./ (HR*GT - HT*GR);
bgTCor = (eta * HR .* bgT - HT .* bgC) ./ (HR*GT - HT*GR);
% Variance and std not yet included. 
%sigTCor = (Rc - 1)/(Rc - Rt) .* sigT + ...
%            (1 - Rt)/(Rc - Rt) ./ depolConst .* sigC;
%bgTCor = (Rc - 1)/(Rc - Rt) .* bgT + ...
%           (1 - Rt)/(Rc - Rt) ./ depolConst .* bgC;
%sigTCorVar = (sigC ./ depolConst.^2 * (1-Rt) / (Rc-Rt)).^2 .* ...
%                depolConstStd.^2 + ((Rc - 1) / (Rc - Rt)).^2 .* ...
%                (sigT + bgT) + ((1 - Rt) ./ ...
%                (depolConst * (Rc - Rt))).^2 .* (sigC + bgC);

%sigTCorVar(sigTCorVar < 0) = 0;   % convert non-negative
%sigTCorStd = sqrt(sigTCorVar);   % TODO
 
end