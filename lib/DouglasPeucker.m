function [ sigIndx ] = DouglasPeucker(signal, height, epsilon, heightBase, heightTop, maxHThick, window_size)
%DOUGLASPEUCKER simplify the signal according to Douglas-Peucker algorithm.
%   Inputs: 
%       signal: array
%           Molecule corrected signal. [MHz]
%       height: array
%           height. [m]
%       epsilon: float
%           maximum distance.
%       heightBase: float
%           minimun height for the algorithm. [m]
%       heightTop: float
%           maximum height for the algorithm. [m]
%       maxHThick:
%           maximum spatial thickness of each segment. [m]
%       window_size: integer
%           size of the average smooth window.
%   Returns:
%       sigIndx: array
%           index of the signal that stands for different segments of the
%           signal.
%   References:
%       https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
%   History:
%       2017-12-29. First edition by Zhenping.
%       2018-07-29. Add the height range for the searching instead of SNR restriction.
%       2018-07-31. Add the maxHThick argument to control the maximum thickness
%       of each output segment.x
%   Copywrite:
%       Ground-based remote sensing (TROPOS)

% input check
if ~ nargin == 6
    error('6 inputs is needed.');
end
if ~ length(signal) == length(height)
    error('signal and height must have the same length.');
end
if ~ exist('window_size', 'var')
    window_size = 1;
end

% find the boundary for implementing Douglas-Peucker method
hBaseIndx = find( (height(1:end-1) - heightBase) .* (height(2:end) - heightBase) <= 0, 1) + 1;
hTopIndx = find((height(1:(end-1)) - heightTop) .* (height(2:end) - heightTop) <= 0, 1) + 1;
if isempty(hBaseIndx)
    warning('The base region can not be found. Set default value (%dm)', height(1));
    hBaseIndx = 1;
end
if isempty(hTopIndx)
    warning('The top region can not be found. Set default value (%dm)', height(end));
    hTopIndx = length(height);
end

if hTopIndx <= hBaseIndx
    warning('Error settings for the search range.');
    sigIndx = [];
    return;
end

% create cell array for storing the point
signalTemp = smooth(signal(hBaseIndx:hTopIndx), window_size, 'moving');
heightTemp = height(hBaseIndx:hTopIndx);
posIndx = find(signalTemp > 0);
signalTemp = signalTemp(posIndx);
heightTemp = heightTemp(posIndx);
pointList = cell(1, length(signalTemp));

if length(signalTemp) < 2
    sigIndx = [1; hTopIndx - hBaseIndx + 1];
    return;
end

for index = 1: length(signalTemp)
    pointList{index} = [heightTemp(index), log(signalTemp(index))];
end

sigIndx = DP_aglorithm(pointList, epsilon, maxHThick);

sigIndx = posIndx(sigIndx) + hBaseIndx - 1;


end


function [ sigIndx ] = DP_aglorithm(pointList, epsilon, maxHThick)
% find the point with the maximum distance 
dMax = 0;
index = 1;
thickness = 0;
if length(pointList) > 2
    thickness = pointList{end}(1) - pointList{1}(1);
    for indx = 2:length(pointList) - 1
        d = my_dist(pointList{indx}, pointList{1}, pointList{end});
        if (d > dMax)
            index = indx;
            dMax = d;
        end
    end
elseif length(pointList) == 1
    sigIndx = [1];
    return;
elseif length(pointList) == 2
    sigIndx = [1, 2];
    return;
end

if dMax > epsilon
    recResult1 = DP_aglorithm(pointList(1:index), epsilon, maxHThick);
    recResult2 = DP_aglorithm(pointList(index:end), epsilon, maxHThick) + index - 1;
    sigIndx = [recResult1(1:end-1), recResult2];
elseif thickness > maxHThick
    for indx1 = 2:(length(pointList) - 1)
        if pointList{indx1}(1) - pointList{1}(1) >= maxHThick
            break;
        end
    end
    recResult1 = DP_aglorithm(pointList(1:indx1), epsilon, maxHThick);
    recResult2 = DP_aglorithm(pointList(indx1:end), epsilon, maxHThick) + indx1 - 1;
    sigIndx = [recResult1(1:end-1), recResult2];
else
    sigIndx = [1, length(pointList)];
end

end

function [ d ] = my_dist(pointM, pointS, pointE)
    d = abs(pointM(2) - pointS(2) + (pointS(2) - pointE(2))/(pointS(1) - pointE(1))*(pointS(1) - pointM(1)));
end