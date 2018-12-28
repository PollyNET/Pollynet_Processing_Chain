function [flag] = polly_saturationdetect(signal, height, hBase, hTop, sigThresh, cloudMaxGThickness)
%polly_saturationdetect saturation bin detection. More detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [flag] = polly_saturationdetect(signal, height, hRange, sigThresh, cloudMaxGThickness)
%   Inputs:
%       signal: array
%           photon count rate. [MHz] 
%       height: array
%           height of each range bin. [m] 
%       hRange: 2-element array
%           range constrain for the detection.
%       sigThresh: float
%           the maximum signal to be trusted without strong signal satureation. [MHz] 
%       cloudMaxGThickness: float
%           the maximun penetration depth for strong attenuation clouds. [m]
%   Outputs:
%       flag: logical
%           saturation flag for each range bin.
%   History:
%       2018-12-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

flag = false(size(signal));
if isempty(signal) || (numel(signal) < 2)
    warning('The length of signal is less than 2.');
    return;
end

hBaseIndx = find(height >= hBase, 1);
hTopIndx = find(height <= hTop, 1);
cloudMaxGThicknessIndx = int32(cloudMaxGThickness / (height(2) - height(1)));
if isempty(hBaseIndx) || isempty(hTopIndx)
    error('Error in polly_saturationdetect: hBase or hTop is out of range.\nCurrent hBase is %d and hTop is %d\n', hBase, hTop);
end

indxSaturate = find((signal(hBaseIndx:(hTopIndx - 1)) - sigThresh) .* (signal((hBaseIndx + 1):hTopIndx) - sigThresh) <= 0);
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