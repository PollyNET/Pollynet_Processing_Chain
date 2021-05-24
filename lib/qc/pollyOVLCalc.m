function [olFunc, olStd, olAttri] = pollyOVLCalc(height, sigFR, sigNR, bgFR, bgNR, varargin)
% pollyOVLCalc calculate overlap function from polly measurements.
% USAGE:
%    [output] = pollyOVLCalc(params)
% INPUTS:
%    [olFunc, olStd, olAttri] = pollyOVLCalc(sigFR, sigNR, bgFR, bgNR)
% KEYWORDS:
%    hFullOverlap: numeric
%        minimum height with complete overlap (default: 600). (m)
%    overlapCalMode: numeric
%        overlap calculation mode. (default: 1)
%        0: no overlap correction
%        1:overlap correction with using the default overlap function
%        2: overlap correction with using the calculated overlap function
%        3: overlap correction with gluing near-range and far-range signal
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
% EXAMPLE:
% HISTORY:
%    2021-05-20: first edition by Zhenping
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

parse(p, param1, varargin{:});

olAttri = struct();
[olFunc, olStd, sigRatio, normRange] = overlapCalc(height, ...
    sigFR, bgFR, sigNR, bgNR, ...
    'hFullOverlap', p.Results.heightFullOverlap(flagFR), ...
    'overlapCalMode', p.Results.overlapCalMode);

% PC2PCR = data.hRes * sum(data.mShots(data.flagCloudFree_NR)) / 150;
if (~ isempty(sigFR)) && (~ isempty(sigNR))
    % if both near- and far-field channels exist
    olAttri.sigFR = sigFR * PC2PCR;
    olAttri.sigNR = sigNR * PC2PCR;
    olAttri.sigRatio = sigRatio;
    olAttri.normRange = normRange;
end

end