function [clBaseH, clTopH, clPh, clPhProb] = cloud_layering(time, height, tc, varargin)
%cloud_layering extracting cloud information from target classification product.
%Example:
%   Usage 1:
%   [clBaseH, clTopH, clPh, clPhProb] = cloud_layering(time, height, tc)
%
%   Usage 2:
%   % threshold for the minimum cloud layer depth
%   clBaseH = cloud_layering(time, height, tc, 'minCloudDepth', 100)
%Inputs:
%   time: array
%       time for each profile. (datenum)
%   height: array
%       height above ground. (m)
%   tc: matrix (height x time)
%       target classification.
%Keywords:
%   minCloudDepth: double
%       minimum cloud layer depth (default: 0). (m)
%   liquidCloudBit: integer
%       target classification bit for liquid cloud (default: 1).
%   iceCloudBit: integer
%       target classification bit for ice cloud (default: 2).
%   cloudBits: array
%       target classification bits for clouds (default: [1, 2]).
%Outputs:
%   clBaseH: maxtrix (MAXCLOUDLAYERS x time)
%       cloud based height. (m)
%   clTopH: matrix (MAXCLOUDLAYERS x time)
%       cloud top height. (m)
%   clPh: maxtrix (MAXCLOUDLAYERS x time)
%       cloud phase. (0: unknown; 1: ice; 2: liquid; 3: mixed-phase)
%   clPhProb: maxtrix (MAXCLOUDLAYERS x time)
%       probability of cloud phase. (Range: 0-1)
%History:
%   2020-04-21. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'height', @isnumeric);
addRequired(p, 'tc', @isnumeric);
addParameter(p, 'minCloudDepth', 0, @isnumeric);
addParameter(p, 'cloudBits', [1, 2], @isnumeric);
addParameter(p, 'liquidCloudBit', 1, @isnumeric);
addParameter(p, 'iceCloudBit', 2, @isnumeric);

parse(p, time, height, tc, varargin{:});

MAXCLOUDLAYERS = 10;

clBaseH = NaN(MAXCLOUDLAYERS, size(tc, 2));
clTopH = NaN(MAXCLOUDLAYERS, size(tc, 2));
clPh = zeros(MAXCLOUDLAYERS, size(tc, 2));
clPhProb = zeros(MAXCLOUDLAYERS, size(tc, 2));

flagCloud = false(size(tc));
for iClBit = 1:length(p.Results.cloudBits)
    flagCloud = (flagCloud | (tc == p.Results.cloudBits(iClBit)));
end

%% binarization the tc matrix
tcBi = NaN(size(tc));
tcBi(flagCloud) = 1;

for iT = 1:size(tc, 2)
    validLayer = 1;
    [L, nLayer] = label(tcBi(:, iT));

    for iLayer = 1:nLayer
        baseIndx = find(L == iLayer, 1);
        topIndx = find(L == iLayer, 1, 'last');

        layerDepth = height(topIndx) - height(baseIndx);
        layerIndx = (L == iLayer);

        if (layerDepth >= p.Results.minCloudDepth) && (validLayer <= MAXCLOUDLAYERS)

            flagIce = any(tc(layerIndx, iT) == p.Results.iceCloudBit);
            flagLiquid = any(tc(layerIndx, iT) == p.Results.liquidCloudBit);

            clBaseH(validLayer, iT) = height(baseIndx);
            clTopH(validLayer, iT) = height(topIndx);
            clPh(validLayer, iT) = 1 * flagIce + 2 * flagLiquid;
            clPhProb(validLayer, iT) = 1;
            validLayer = validLayer + 1;

        end
    end
end

end