function [aerBsc, bestLR, biasAOD, nIters] = polly_constrainedfernald(height, signal, SNR, refHeight, refBeta, molBsc, maxIterations, minLR, maxLR, AOD_AERONET, minAODDev, minHeight, minSNR, window_size)
%polly_constrainedfernald retrieve the aerosol backscatter coefficient with the constrain from the AOD from AERONET.
%	Usage:
%		[aerBsc, bestLR, biasAOD, nIters] = polly_constrainedfernald(height, signal, SNR, refHeight, refBeta, molBsc, maxIterations, minLR, maxLR, AOD_AERONET, minAODDev, minHeight, minSNR, window_size)
%	Inputs:
%		height: array
%			height. [m]
%		signal: array
%			measured signal.
%		SNR: array
%			signal-noise-ratio
%       refHeight: 2-element array
%           reference height. [m]
%       refBeta: float
%           reference value. [m^{-1}Sr^{-1}]
%		molBsc: array
%			molecular backscatter coefficient. [m^{-1}*Sr^{-1}]
%		maxIterations: integer
%			maximum number of the iterations.
%		minLR: float
%			minimum aerosol Lidar ratio. [Sr]
%		maxLR: float
%			maximum aerosol Lidar ratio. [Sr]
%		AOD_AERONET: float
%			AOD measured by AERONET.
%		minAODDev: float
%			minimum deviation of AOD between Lidar and AERONET that can be tolerable.
%		LR: float
%			aerosol lidar ratio. [Sr]
%		minHeight: float
%			minimum height for the full FOV. [m]
%		minSNR: float
%			minimum SNR
%		window_size: integer
%			smoothing window size.
%	Outputs:
%       aerBsc: array
%           aerosol backscatter coefficient. [m^{-1}Sr^{-1}] 
%       bestLR: float
%           the best lidar ratio with the AOD deviation less that required. 
%		biasAOD: float
%			deviation of AOD between lidar and AERONET.
%       nIters: integer
%           number of iterations to achieve the minimun AOD deviation.
%	History:
%		2018-02-03. First edition by Zhenping
%       2019-03-29. Fix the bug of returning NaN for lidar ratio.
%       2019-04-09. Screen out the negative backscatter coefficient during the calculation.
%	Copyright:
%		Ground-based remote sensing. (TROPOS)

% initialize
aerBsc = NaN(size(height));
bestLR = NaN;
biasAOD = NaN;
nIters = 0;
AODDev = Inf;

if isnan(AOD_AERONET)
    warning('Not a valid AERONET AOD.')
    return;
end

%% find the integral range to calculate the AOD
hBaseIndx = find(height >= minHeight + window_size/2 * (height(2) - height(1)), 1);
if isempty(hBaseIndx)
    warning('Failure in searching the index of minHeight. Set the default value to be 70');
    hBaseIndx = 70;
end
hTopIndx = find(SNR(hBaseIndx:end) <= minSNR, 1);
if isempty(hTopIndx)
    warning('Failure in searching the index of maxHeight. Set the default value to be the length of height.');
    hTopIndx = numel(height);
end
hTopIndx = hBaseIndx + hTopIndx - 1;

while AODDev > minAODDev
    midLR = (minLR + maxLR) / 2;

    bscMid = polly_fernald(height, signal, midLR, refHeight, refBeta, molBsc, window_size); 
    bscMax = polly_fernald(height, signal, maxLR, refHeight, refBeta, molBsc, window_size);
    bscMin = polly_fernald(height, signal, minLR, refHeight, refBeta, molBsc, window_size);

    bscMid(1:hBaseIndx) = bscMid(hBaseIndx);
    bscMax(1:hBaseIndx) = bscMax(hBaseIndx);
    bscMin(1:hBaseIndx) = bscMin(hBaseIndx);

    bscMid(bscMid < 0) = 0;
    bscMax(bscMax < 0) = 0;
    bscMin(bscMin < 0) = 0;

    biasAODMax = sum(bscMax .* [height(1), diff(height)] * maxLR) - AOD_AERONET;
    biasAODMin = sum(bscMin .* [height(1), diff(height)] * minLR) - AOD_AERONET;
    biasAODMid = sum(bscMid .* [height(1), diff(height)] * midLR) - AOD_AERONET;

    AODDev = abs(biasAODMid);

    aerBsc = bscMid;
    biasAOD = AODDev;

    nIters = nIters + 1;
    if (nIters >= maxIterations) && (AODDev <= minAODDev)
        aerBsc = bscMid;
        bestLR = midLR;
        biasAOD = AODDev;
        return;
    elseif (nIters >= maxIterations) && (AODDev > minAODDev)
        warning('Best fit aerosol backscatter coefficient profile can not be found!');
        return;
    end

    if sign(biasAODMin) == sign(biasAODMax)
        if min(abs([biasAODMin, biasAODMax])) > minAODDev
            warning('Best fit aerosol backscatter coefficient profile can not be found!');
            aerBsc = NaN(size(height));
            bestLR = NaN;
            biasAOD = NaN;
            return;
        elseif abs(biasAODMax) > abs(biasAODMin)
            aerBsc = bscMin;
            bestLR = minLR;
            biasAOD = abs(biasAODMin);
            return;
        else
            aerBsc = bscMax;
            bestLR = maxLR;
            biasAOD = abs(biasAODMax);
            return;
        end
    elseif sign(biasAODMin) == sign(biasAODMid)
        minLR = midLR;
    else
        maxLR = midLR;
    end
end

bestLR = midLR;

end