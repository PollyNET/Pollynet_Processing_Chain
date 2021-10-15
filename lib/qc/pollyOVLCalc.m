function [olFunc, olStd, olAttri] = pollyOVLCalc(height, sigFR, sigNR, bgFR, bgNR, varargin)
% POLLYOVLCALC calculate overlap function from polly measurements.
%
% USAGE:
%    [olFunc, olStd, olAttri] = pollyOVLCalc(height, sigFR, sigNR, bgFR, bgNR)
%
% INPUTS:
%    height: array
%        height above ground. (m)
%    sigFR: array
%        far-field signal.
%    sigNR: array
%        near-field signal.
%    bgFR: array
%        far-field background.
%    bgNR: array
%        near-field background.
%
% KEYWORDS:
%    hFullOverlap: numeric
%        minimum height with complete overlap (default: 600). (m)
%    overlapCalMode: numeric
%        overlap calculation mode. (default: 1)
%        0: no overlap correction
%        1:overlap correction with using the default overlap function
%        2: overlap correction with using the calculated overlap function
%        3: overlap correction with gluing near-range and far-range signal
%    PC2PCR: numeric
%        conversion factor from photon count to photon count rate (default: 1).
%
% OUTPUTS:
%    olFunc: numeric
%        overlap function.
%    olStd: numeric
%        standard deviation of overlap function.
%    olAttri: struct
%        sigFR: numeric
%            far-field signal.
%        sigNR: numeric
%            near-field signal.
%        sigRatio: numeric
%            signal ratio of near-field and far-field signal.
%        normRange: 2-element array
%            normalization range.
%
% HISTORY:
%    - 2021-05-20: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'sigFR', @isnumeric);
addRequired(p, 'sigNR', @isnumeric);
addRequired(p, 'bgFR', @isnumeric);
addRequired(p, 'bgNR', @isnumeric);
addParameter(p, 'hFullOverlap', 600, @isnumeric);
addParameter(p, 'overlapCalMode', 1, @isnumeric);
addParameter(p, 'PC2PCR', 1, @isnumeric);

parse(p, height, sigFR, sigNR, bgFR, bgNR, varargin{:});

olAttri = struct();
[olFunc, olStd, sigRatio, normRange] = overlapCalc(height, sigFR, bgFR, sigNR, bgNR, varargin{:});

if (~ isempty(sigFR)) && (~ isempty(sigNR))
    % if both near- and far-field channels exist
    olAttri.sigFR = sigFR * p.Results.PC2PCR;
    olAttri.sigNR = sigNR * p.Results.PC2PCR;
    olAttri.sigRatio = sigRatio;
    olAttri.normRange = normRange;
end

end