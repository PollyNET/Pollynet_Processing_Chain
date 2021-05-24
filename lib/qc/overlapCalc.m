function [overlap, overlapStd, sigRatio, normRange] = overlapCalc(...
    sigFR, bgFR, sigNR, bgNR, height, varargin)
% OVERLAPCALC calculate the overlap function.
% USAGE:
%    overlap = overlapCalc(sigFR, bgFR, sigNR, bgNR, height);
% INPUTS:
%    sigFR: array
%        far-range signal. (photon count)
%    bgFR: array
%        background of far-range signal. (photon count)
%    sigNR: array
%        near-range signal. (photon count)
%    bgNR: array
%        background of near-range signal. (photon count)
%    height: array
%        height above ground. (m)
% KEYWORDS:
%    hFullOverlap: numeric
%        minimum height with full overlap function for far-range signal
%        (default: 600). (m)
%    overlapCalMode: integer
%        overlap calculation mode.
%        1: signal ratio between near-range and far-range channel
%        2: Raman method
% OUTPUTS:
%    overlap: array
%        overlap function. If no overlap function was calculated, `overlap` will
%        be empty.
%    overlapStd: array
%        error of the overlap function. If no overlap function was calculated,
%        `overlapStd` will be empty.
%    sigRatio: numeric
%        signal ratio between near-range and far-range signal.
%    normRange: 2-element array
%        height index of the signal normalization range.
% EXAMPLE:
% HISTORY:
%    2021-05-18: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'sigFR', @isnumeric);
addRequired(p, 'bgFR', @isnumeric);
addRequired(p, 'sigNR', @isnumeric);
addRequired(p, 'bgNR', @isnumeric);
addRequired(p, 'height', @isnumeric);
addParameter(p, 'hFullOverlap', 600, @isnumeric);
addParameter(p, 'overlapCalMode', 1, @isnumeric);

parse(p, sigFR, bgFR, sigNR, bgNR, height, varargin{:});

%% initialization
overlap = [];
overlapStd = [];
sigRatio = [];
normRange = [];

switch p.Results.overlapCalMode

case 1   % ratio of near and far range signal

    if (~ isempty(sigNR)) && (~ isempty(sigFR))

        % find the height index with full overlap
        fullOverlapIndx = find(height >= p.Results.hFullOverlap, 1);
        if isempty(fullOverlapIndx)
            error('The index with full overlap can not be found.');
        end

        % calculate the channel ratio of near range and far range total signal
        [sigRatio, normRange, ~] = mean_stable(sigNR./sigFR, 40, ...
            fullOverlapIndx, length(sigNR), 0.1);

        % calculate the overlap of FR channel
        if ~ isempty(normRange)
            SNRnormRangeFR = polly_SNR(sum(sigFR(normRange)), sum(bgFR(normRange)));
            SNRnormRangeNR = polly_SNR(sum(sigNR(normRange)), sum(bgNR(normRange)));
            sigRatioStd = sigRatio * sqrt(1 / SNRnormRangeFR.^2 + 1 / SNRnormRangeNR.^2);
            overlap = sigFR ./ sigNR * sigRatio;
            overlapStd = overlap .* ...
                sqrt(sigRatioStd.^2 / sigRatio.^2 + 1 ./ sigFR.^2 + 1 ./ sigNR.^2);
        end
    end

case 2   % raman method
    % TODO
end

end
