function [flag] = pollySaturationDetect(data, varargin)
% POLLYSATURATIONDETECT detect the bins which is fully saturated by the clouds.
%
% USAGE:
%    [flag] = pollySaturationDetect(data)
%
% INPUTS:
%    data: struct
%        More detailed information can be found in doc\pollynet_processing_program.md
%
% KEYWORDS:
%    hFullOverlap: double
%        minimum height with full overlap (m). (default: 500)
%    sigSaturateThresh: double
%        threshold of saturated signal (photon count). (default: 500)
%
% OUTPUTS:
%    flag: logical matrix
%        if it is true, it means the current range bin should be saturated
%        by clouds. Vice versa.
%
% HISTORY:
%    - 2018-12-21: First Edition by Zhenping
%    - 2019-07-08: Fix the bug of converting signal to PCR.
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'data', @isstruct);
addParameter(p, 'hFullOverlap', 500, @isnumeric);
addParameter(p, 'sigSaturateThresh', 500, @isnumeric);

parse(p, data, varargin{:});

nChannels = size(data.signal, 1);
nProfiles = size(data.signal, 3);

flag = false(size(data.signal));

if isempty(data.rawSignal)
    return;
end

%% Convert signal from photon count to photon count rate.
signalPCR = squeeze(data.signal + data.bg) ./ ...
            repmat(reshape(data.mShots, ...
                        size(data.mShots, 1), 1, size(data.mShots, 2)), ...
                    [1, size(data.signal, 2), 1]) * 150.0 ./ data.hRes;

for iChannel = 1:nChannels
    for iProfile = 1:nProfiles
        flagSaturation = saturationDetect(...
                            signalPCR(iChannel, :, iProfile), ...
                            data.height, ...
                            p.Results.hFullOverlap(iChannel), ...
                            10000, p.Results.sigSaturateThresh, 500);
        flag(iChannel, :, iProfile) = flagSaturation;
    end
end

end



function [flag] = saturationDetect(signal, height, hBase, hTop, ...
                    sigThresh, cloudMaxGThickness)
% SATURATIONDETECT saturation bin detection. More detailed information can 
% be found in doc/pollynet_processing_program.md
% USAGE:
%    [flag] = saturationDetect(signal, height, hRange, sigThresh, 
%                                    cloudMaxGThickness)
% INPUTS:
%    signal: array
%        photon count rate. [MHz] 
%    height: array
%        height of each range bin. [m] 
%    hRange: 2-element array
%        range constrain for the detection.
%    sigThresh: float
%        the maximum signal to be trusted without strong signal satureation. 
%        [MHz] 
%    cloudMaxGThickness: float
%        the maximun penetration depth for strong attenuation clouds. [m]
% OUTPUTS:
%    flag: logical
%        saturation flag for each range bin.
% EXAMPLE:
% HISTORY:
%    2018-12-21: First Edition by Zhenping
%    2019-07-08: Add the criteria for the absolute values
% .. Authors: - zhenping@tropos.de

flag = false(size(signal));
if isempty(signal) || (numel(signal) < 2)
    warning('The length of signal is less than 2.');
    return;
end

hBaseIndx = find(height >= hBase, 1);
hTopIndx = find(height <= hTop, 1);
cloudMaxGThicknessIndx = int32(cloudMaxGThickness / (height(2) - height(1)));
if isempty(hBaseIndx) || isempty(hTopIndx)
    error(['Error in polly_saturationdetect: hBase or hTop is out of ' ...
           'range.\nCurrent hBase is %d and hTop is %d\n'], hBase, hTop);
end

% determine whether the signal is over the saturation threshold
flag(signal > sigThresh) = true;

indxSaturate = find((signal(hBaseIndx:(hTopIndx - 1)) - sigThresh) .* ...
                    (signal((hBaseIndx + 1):hTopIndx) - sigThresh) <= 0);
if isempty(indxSaturate) || (numel(indxSaturate) == 1)
    return;
else
    indxSaturate = indxSaturate + hBaseIndx - 1;
end

indx = 1;
while indx < length(indxSaturate)
    saturateBaseIndx = indxSaturate(indx);
    saturateTopIndx = indxSaturate(indx + 1);
    if (saturateTopIndx - saturateBaseIndx) >= cloudMaxGThicknessIndx
        indx = indx + 2;
        flag(saturateBaseIndx:saturateTopIndx) = true;
    else
        indx = indx + 1;
        flag(saturateBaseIndx:saturateTopIndx) = true;
    end        
end

end