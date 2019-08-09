function [sigStd] = signalStd(signal, bg, smoothWindow, dimension)
%SIGNALSTD description
%   Example:
%       [sigStd] = signalStd(signal, bg, smoothWindow, dimension)
%   Inputs:
%       signal: array
%           signal strength
%       bg: array
%           background
%       smoothWindow: scalar or matrix
%           the width of the smoothing window. If smoothWindow is a scalar, 
%           the width is fixed. Otherwise, the width of smoothing window is 
%           dependent of the height.
%       dimension: integer
%           the dimension which the smoothing is along with.
%   Outputs:
%       sigStd: array
%           std of the signal
%   History:
%       2018-09-02. First edition by Zhenping
%   Contact:
%       zhenping@tropos.de



if ~ exist('smoothWindow', 'var')
    smoothWindow = 1;
end

if ~ exist('dimension', 'var')
    dimension = 1;
end

if isscalar(smoothWindow)
    sigStd = sqrt(signal.^2 + bg.^2)/sqrt(smoothWindow);
    return;
end

if ismatrix(smoothWindow)
    if size(smoothWindow, 2) ~= 3
        error('signalStd:incompatibleSize', 'smoothWindow should be a m*3 matrix if height dependent smoothing is set');
    end

    sizeSignal = ones(1, ndims(signal));
    sizeSignal(dimension) = size(signal, dimension);

    thisSmoothWindow = ones(sizeSignal);
    for iWin = 1:size(dimension, 2)
        thisSmoothWindow(smoothWindow(iWin, 1):smoothWindow(iWin, 2)) = smoothWindow(iWin, 3);
    end

    sigStd = sqrt(signal.^2 + bg.^2) ./ sqrt(thisSmoothWindow);

end

end