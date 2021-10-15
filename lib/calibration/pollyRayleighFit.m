function [refHInd, DPInd] = pollyRayleighFit(height, sig, sigPCR, bg, mSig, varargin)
% POLLYRAYLEIGHFIT search reference height with Rayleigh fit algorithm.
%
% USAGE:
%    [refHInd, DPInd] = pollyRayleighFit(height, sig, sigPCR, bg, mSig)
%
% INPUTS:
%    height: array
%        height. (m)
%    sig: array
%        lidar signal. (photon count)
%    sigPCR: array
%        lidar signal. (photon count rate)
%    bg: array
%        background. (photon count)
%    mSig: array
%        molecular signal.
%
% KEYWORDS:
%    minDecomLogDist: float
%        maximum distance for Douglas-Peucker algorithm (default: 0.2).
%    maxDecomHeight: numeric
%        maximum height for signal decomposition (default: 10000). (m)
%    maxDecomThickness: numeric
%        maximum spatial thickness for each segment (default: 1500). [m]
%    decomSmWin: numeric
%        smoothing window for signal as input for Douglas-Peucker algorithm (default: 40).
%    minRefThickness: numeric
%        minimum spatial thickness for each segment
%    minRefDeltaExt: numeric
%        constrain for the uncertainty of the regressed extinction 
%        coefficient in the reference height. 
%        (see test 3 in Baars et al, ACP, 2016)
%    minRefSNR: numeric
%        minimum SNR for the signal at the reference height (default: 5).
%    heightFullOverlap: numeric
%        minimum height with full overlap (default: 600). (m)
%    flagSameRef: logical
%        flag to determine whether use default reference height and decomposition
%        points (default: false).
%    defaultRefH: 2-element array
%        default reference height (default: [NaN, NaN]). (m)
%    defaultDPInd: array
%        default decomposition points by Douglas-Peucker algorithm (default: []).
%    printLevel: numeric
%        print level.
%        0, 1, 2: print details while running.
%        3, 4, 5: hide prompts while running.
%
% OUTPUTS:
%    refHInd: 2-element array
%        [base, top] index of the reference height.
%    DPInd: array
%        index of the signal that stands for different segments of the
%        signal.
%
% HISTORY:
%    - 2021-05-25: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'sig', @isnumeric);
addRequired(p, 'sigPCR', @isnumeric);
addRequired(p, 'bg', @isnumeric);
addRequired(p, 'mSig', @isnumeric);
addParameter(p, 'minDecomLogDist', 0.2, @isnumeric);
addParameter(p, 'maxDecomHeight', 10000, @isnumeric);
addParameter(p, 'maxDecomThickness', 1500, @isnumeric);
addParameter(p, 'decomSmWin', 40, @isnumeric);
addParameter(p, 'minRefThickness', 700, @isnumeric);
addParameter(p, 'minRefDeltaExt', 1, @isnumeric);
addParameter(p, 'minRefSNR', 5, @isnumeric);
addParameter(p, 'heightFullOverlap', 600, @isnumeric);
addParameter(p, 'flagSameRef', false, @islogical);
addParameter(p, 'defaultRefH', [NaN, NaN], @isnumeric);
addParameter(p, 'defaultDPInd', [], @isnumeric);
addParameter(p, 'printLevel', 0, @isnumeric);

parse(p, height, sig, sigPCR, bg, mSig, varargin{:});

if (p.Results.printLevel == 0) || (p.Results.printLevel == 1) || (p.Results.printLevel == 2)
    flagShowDetail = true;
elseif (p.Results.printLevel == 3) || (p.Results.printLevel == 4) || (p.Results.printLevel == 5)
    flagShowDetail = false;
else
    error('Wrong printLevel %d', p.Results.printLevel);
end

%% signal decomposition with Douglas-Peucker algorithm
scaRatio = sigPCR .* height.^2 ./ mSig;
DPInd = DouglasPeucker(scaRatio, height, p.Results.minDecomLogDist, ...
    p.Results.heightFullOverlap, p.Results.maxDecomHeight, ...
    p.Results.maxDecomThickness, p.Results.decomSmWin);

%% Rayleigh fitting
if p.Results.flagSameRef
    % take default values of reference height and DPInd
    refHInd = p.Results.defaultRefH;
    DPInd = p.Results.defaultDPInd;

    if isempty(p.Results.defaultRefH)
        error('''defaultRefH'' cannot be an empty array.');
    end

    if isnan(p.Results.defaultRefH(1))
        return;
    end

    % determin SNR at reference height
    SNRRef = pollySNR(sum(sig(refHInd(1):refHInd(end))), sum(bg(refHInd(1):refHInd(end))));
    if SNRRef < p.Results.minRefSNR
        fprintf('Signal at reference height (%f-%f m) was too noisy.\n', height(refHInd(1)), height(refHInd(end)));
        refHInd = [NaN, NaN];
        return;
    end
else
    RCS = sigPCR .* height.^2;

    [hBInd, hTInd] = rayleighfit(height, RCS, sig, bg, mSig, DPInd, ...
        p.Results.minRefThickness, p.Results.minRefDeltaExt, p.Results.minRefSNR, flagShowDetail);

    refHInd = [hBInd, hTInd];
end

end