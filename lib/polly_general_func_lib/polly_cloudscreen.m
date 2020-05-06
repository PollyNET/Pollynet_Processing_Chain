function flagCloudFree = polly_cloudScreen(time, height, signal, varargin)
%POLLY_CLOUDSCREEN cloud screen.
%Example:
%   % Usecase 1: get the cloud mask
%   flagCloudFree = polly_cloudScreen(time, height, signal);
%
%   % Usecase 2: cloudscreen with using signal gradient
%   flagCloudFree = polly_cloudScreen(time, height, signal, ...
%          'mode', 1, 'detectRange', [0, 8000], 'slope_thres', 1e7)
%
%   % Usecase 3: cloudscreen with using Zhao's algorithm
%   flagCloudFree = polly_cloudScreen(time, height, signal, ...
%           'mode', 2, 'minDepth', 500);
%
%Inputs:
%   time: array
%       measurement time for each profile. (datenum)
%   height: array
%       height above ground. (m)
%   signal: matrix (height x time)
%       signal. (photon count)
%Keywords:
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
%Outputs:
%   flagCloudFree: array
%       cloud free mask for each profile.
%References:
%   1. Zhao, C., Y. Wang, Q. Wang, Z. Li, Z. Wang, and D. Liu (2014), A new
%      cloud and aerosol layer detection method based on micropulse lidar 
%      measurements, Journal of Geophysical Research: Atmospheres, 119(11),
%      6788-6802.
%History:
%   2020-04-26. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

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
    flagCloudFree = cloudScreen_MSG(height, signal, p.Results.slope_thres, ...
                                    p.Results.detectRange);

case 2

    % Zhao's algorithm
    flagCloudFree = cloudDetect_Zhao(height, time, signal, ...
                                     p.Results.background, varargin);

otherwise
    error('Unknown cloud screening mode.');
end

end