function [slope] = movingsmooth_variedWin(signal, winWidth)
% MOVINGSMOOTH_VARIEDWIN calculate derivative with sliding smooth function.
%
% USAGE:
%    [slope] = movingsmooth_variedWin(signal, winWidth)
%
% INPUTS:
%    signal: array
%        signal for each bin.
%    winWidth: integer or matrix
%        if winWidth is a integer, the width of the window will be fixed. 
%        But if winWidth is set to be a k*3 matrix, the width of the window 
%        will be height dependent, like [[1, 20, 3], [18, 30, 5], 
%        [25, 40, 7]], which means the width of the window will be 3 between 
%        10 and 20, 5 between 18 and 30 and 7 between 25 and 40.
%
% OUTPUTS:
%    slope: array
%        slope for each bin.
%
% HISTORY:
%    - 2018-08-07. First edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if nargin < 2
    error('Not enought inputs.');
end

slope = NaN(size(signal));
if isscalar(winWidth)
    slope = diff(smooth([signal(end), signal], winWidth, 'sgolay', 1));
    return
end

if ismatrix(winWidth)
    signal = [signal(end), signal];
    if size(winWidth, 2) == 3
        for iWin = 1:size(winWidth, 1)
            startIndx = max(1, winWidth(iWin, 1) - ...
                               fix((winWidth(iWin, 3) - 1)/2));
            endIndx = min(length(signal), winWidth(iWin, 2) + ...
                          fix(winWidth(iWin, 3)/2));
            tmp = diff(smooth(signal(startIndx:endIndx), ...
                              winWidth(iWin, 3), 'moving'));
            slope(winWidth(iWin, 1):winWidth(iWin, 2)) = ...
              tmp((winWidth(iWin, 1) - startIndx + 1):(winWidth(iWin, 2) - startIndx + 1));
        end
    end
end

end