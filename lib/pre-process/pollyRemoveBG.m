function [sigO, bg] = pollyRemoveBG(sigI, varargin)
% pollyRemoveBG remove signal background.
% USAGE:
%    [sigO, bg] = pollyRemoveBG(sigI, varargin)
% INPUTS:
%    sigI: matrix (channel x height x time)
%       lidar signal.
% KEYWORDS:
%    maxHeightBin: numeric
%        number of range bins to read out from data file. (default: 3000)
%    firstBinIndex: numeric
%        index of first bin to read out. (default: 1)
%    bgCorrectionIndex: 2-element array
%        base and top index of bins for background estimation.
%        (defaults: [1, 2])
% OUTPUTS:
%    sigO: matrix (channel x height x time)
%        background-substracted signal.
%    bg: matrix (channel x height x time)
%        background.
% EXAMPLE:
% HISTORY:
%    2021-05-16: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'sigI', @isnumeric);
addParameter(p, 'bgCorrectionIndex', [1, 249], @isnumeric);
addParameter(p, 'maxHeightBin', 2500, @isnumeric);
addParameter(p, 'firstBinIndex', 261, @isnumeric);

parse(p, sigI, varargin{:});

bg = repmat(...
    mean(sigI(:, p.Results.bgCorrectionIndex(1):p.Results.bgCorrectionIndex(2), :), 2), ...
    [1, p.Results.maxHeightBin, 1]);

sigO = NaN(size(sigI, 1), p.Results.maxHeightBin, size(sigI, 3));
for iCh = 1:size(sigI, 1)
    sigO(iCh, :, :) = sigO(iCh, p.Results.firstBinIndex(iCh):(p.Results.maxHeightBin + p.Results.firstBinIndex(iCh) - 1), :) - bg(iCh, :, :);
end

end