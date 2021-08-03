function [flagCloudFree, layerStatus] = cloudScreen(time, height, signal, varargin)
% cloudScreen cloud screen.
% USAGE:
%   % Usecase 1: get the cloud mask
%   flagCloudFree = cloudScreen(time, height, signal);
%
%   % Usecase 2: cloudscreen with using signal gradient
%   flagCloudFree = cloudScreen(time, height, signal, ...
%          'mode', 1, 'detectRange', [0, 8000], 'slope_thres', 1e7)
%
%   % Usecase 3: cloudscreen with using Zhao's algorithm
%   [flagCloudFree, layerStatus] = cloudScreen(time, height, signal, ...
%           'mode', 2, 'minDepth', 500);
%
% INPUTS:
%   time: array
%       measurement time for each profile. (datenum)
%   height: array
%       height above ground. (m)
%   signal: matrix (height x time)
%       signal. (photon count)
% KEYWORDS:
%   mode: integer
%       1: with using signal gradient (default)
%       2: with using Zhao's algorithm
%   minDepth: double
%       minimum layer depth (default: 100). (m)
%   detectRange: 2-element array
%       bottom and top height for cloud detection (default: [0, 10000]). (m)
%   heightFullOverlap: double
%       minimum height with full overlap (default: 600). (m)
%   smoothWin: integer
%       smooth window (default: 8). (bins)
%   minSNR: double
%       minimum layer mean signal-noise-ratio (default: 1).
%   background: array
%       background (default: 0 for each profile). (photon count)
%   slope_thres: double
%       threshold of the slope to determine whether there is 
%       strong backscatter signal (default: 0). [MHz*m]
% OUTPUTS:
%   flagCloudFree: array
%       cloud free mask for each profile.
%   layerStatus: matrix (height x time)
%       layer status for each bin. (0: unknown; 1: cloud; 2: aerosol)
% EXAMPLE:
% REFERENCES:
%   1. Zhao, C., Y. Wang, Q. Wang, Z. Li, Z. Wang, and D. Liu (2014), A new
%      cloud and aerosol layer detection method based on micropulse lidar 
%      measurements, Journal of Geophysical Research: Atmospheres, 119(11),
%      6788-6802.
% HISTORY:
%    2021-05-18: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'height', @isnumeric);
addRequired(p, 'signal', @isnumeric);
addParameter(p, 'mode', 1, @isnumeric);
addParameter(p, 'minDepth', 100, @isnumeric);
addParameter(p, 'detectRange', [0, 10000], @isnumeric);
addParameter(p, 'heightFullOverlap', 600, @isnumeric);
addParameter(p, 'smoothWin', 8, @isnumeric);
addParameter(p, 'minSNR', 1, @isnumeric);
addParameter(p, 'background', zeros(size(time)), @isnumeric);
addParameter(p, 'slope_thres', 0, @isnumeric);

parse(p, time, height, signal, varargin{:});

if isempty(signal)
    warning('input signal is empty');
    flagCloudFree = false(size(time));
    return;
end

switch p.Results.mode
case 1

    % signal gradient method
    [flagCloudFree, layerStatus] = cloudScreen_MSG(time, height, signal, ...
        p.Results.slope_thres, p.Results.detectRange);

case 2

    % Zhao's algorithm
    [flagCloudFree, layerStatus] = cloudDetect_Zhao(time, height, signal, ...
        p.Results.background, varargin{:});

otherwise
    error('Unknown cloud screening mode.');
end

end