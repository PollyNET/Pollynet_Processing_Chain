function [cRange] = auto_RCS_cRange(height, rcs, varargin)
% AUTO_RCS_CRANGE search the suitable color range for range corrected signal.
%
% USAGE:
%    % Usecase 1: find the color range of range corrected signal
%    cRange = auto_RCS_cRange(height, rcs)
%
%    % Usecase 2: find the color range based with signal at given spatial range
%    cRange = auto_RCS_cRange(height, rcs, 'hRange', [0, 7000])
%
%    % Usecase 3: specify the minimun color range
%    cRange = auto_RCS_cRange(height, rcs, 'minCRange', 0)
%
% INPUTS:
%    height: array
%        height over ground. [m]
%    rcs: matrix (height * time)
%        range corrected signal
%
% KEYWORDS:
%    hRange: 2-element array
%        vertical range for searching the best color range. [m]
%    minCRange: double
%        minimum color range.
%    maxCRange: double
%        maximum color range.
%
% OUTPUTS:
%    cRange: 2-element array
%        color range of the range corrected signal.
%
% HISTORY:
%    - 2020-05-16. First Edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'rcs', @isnumeric);
addParameter(p, 'hRange', [], @isnumeric);
addParameter(p, 'minCRange', NaN, @isnumeric);
addParameter(p, 'maxCRange', NaN, @isnumeric);

parse(p, height, rcs, varargin{:});

if isempty(p.Results.hRange)
    p.Results.hRange = [min(height), max(height)];
end

cRange = NaN(1, 2);

hIndx = (height >= p.Results.hRange(1)) & (height <= p.Results.hRange(end));

flagRCS_neg = (rcs <= 0);
rcs(flagRCS_neg) = NaN;
medianVal = nanmedian(nanmedian(rcs(hIndx, :)));

if isnan(p.Results.minCRange)
    cRange(1) = 0.1 * medianVal;
else
    cRange(1) = p.Results.minCRange;
end

if isnan(p.Results.maxCRange)
    cRange(2) = 3.0 * medianVal;
else
    cRange(2) = p.Results.maxCRange;
end

end