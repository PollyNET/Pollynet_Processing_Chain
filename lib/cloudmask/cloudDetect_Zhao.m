function [flagCloudFree, layerStatus] = cloudDetect_Zhao(time, height, signal, bg, varargin)
% CLOUDDETECT_ZHAO cloud layer detection based on Zhao's algorithm.
%
% USAGE:
%    % Usecase 1: get the cloud mask
%    flagCloudFree = cloudDetect_Zhao(time, height, signal, bg);
%
%    % Usecase 2: specify the detection range
%    [flagCloudFree, layerStatus] = cloudDetect_Zhao(time, height, signal, bg, 'detectRange', [0, 8000])
%
%    % Usecase 3: specify the minimum layer depth
%    [flagCloudFree, layerStatus] = cloudDetect_Zhao(time, height, signal, bg, 'minDepth', 500);
%
% INPUTS:
%    time: array
%        measurement time for each profile. (datenum)
%    height: array
%        height above ground. (m)
%    signal: matrix (height x time)
%        signal. (photon count)
%    bg: array
%        background. (photon count)
%
% KEYWORDS:
%    minDepth: double
%        minimum layer depth (default: 100). (m)
%    detectRange: 2-element array
%        bottom and top height for cloud detection (default: [0, 10000]). (m)
%    heightFullOverlap: double
%        minimum height with full overlap (default: 600). (m)
%    smoothWin: integer
%        smooth window (default: 8). (bins)
%    minSNR: double
%        minimum layer mean signal-noise-ratio (default: 1).
%
% OUTPUTS:
%    flagCloudFree: array
%        cloud free mask for each profile.
%    layerStatus: matrix (height x time)
%        layer status for each bin. (0: unknown; 1: cloud; 2: aerosol)
%
% REFERENCES:
%    1. Zhao, C., Y. Wang, Q. Wang, Z. Li, Z. Wang, and D. Liu (2014), A new cloud and aerosol layer detection method based on micropulse lidar measurements, Journal of Geophysical Research: Atmospheres, 119(11), 6788-6802.
%
% HISTORY:
%    - 2021-05-18: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'height', @isnumeric);
addRequired(p, 'signal', @isnumeric);
addRequired(p, 'bg', @isnumeric);
addParameter(p, 'minDepth', 100, @isnumeric);
addParameter(p, 'detectRange', [0, 10000], @isnumeric);
addParameter(p, 'heightFullOverlap', 600, @isnumeric);
addParameter(p, 'smoothWin', 8, @isnumeric);
addParameter(p, 'minSNR', 1, @isnumeric);

parse(p, time, height, signal, bg, varargin{:});

if (size(signal, 1) ~= length(height)) || ...
   (size(signal, 2) ~= length(time)) || ...
   (size(signal, 2) ~= length(bg))
    error('Dimensions are not matched!');
end

flagCloudFree = true(1, length(time));
layerStatus = zeros(size(signal));

flagDetectBins = (height >= p.Results.detectRange(1)) & ...
                 (height <= p.Results.detectRange(2));

for iTime = 1:length(time)

    % layer detection
    layerInfo = VDE_cld(signal(flagDetectBins, iTime), ...
                        height(flagDetectBins) / 1e3, bg(iTime), ...
                        p.Results.minDepth / 1e3, ...
                        p.Results.heightFullOverlap / 1e3, ...
                        p.Results.smoothWin, ...
                        p.Results.minSNR);

    for iLayer = 1:length(layerInfo)

        % gridding the layers
        layerIndex = (height >= layerInfo(iLayer).baseHeight * 1e3) & ...
                     (height <= layerInfo(iLayer).topHeight * 1e3);

        if layerInfo(iLayer).flagCloud

            % cloud layer
            flagCloudFree(iTime) = false;
            layerStatus(layerIndex, iTime) = 1;

        else

            % aerosol layer
            layerStatus(layerIndex, iTime) = 2;

        end
    end
end

end