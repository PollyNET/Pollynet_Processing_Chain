function [slope, slopestd] = movingLinfit_variedWin(height, signal, ...
                                                    measure_error, win)
% MOVINGLINFIT_VARIEDWIN estimate the slope with chi-2 fitting model. 
% The width of the window can be either fixed or height dependent.
%
% USAGE:
%    [slope] = movingLinfit_variedWin(height, signal, measure_error, win)
%
% INPUTS:
%    height: array
%        the height array for each bin.
%    signal: array
%        signal for each bin.
%    measure_error: array
%        measurement error for each bin.
%    win: integer or matrix
%        If win is a integer, the width of the smoothing window will be
%        fixed. Or you can set it to be [[bottom1, top1, width1], 
%        [bottom2, top2, width2], ...], the widths then can be specified 
%        for each segement.
%
% OUTPUTS:
%    slope: array
%        slope at each given point.
%    slopestd: array
%        standard deviation of the slope at each given point.
%
% HISTORY:
%    - 2019-08-09. Finish the documentation.
%
% .. Authors: - zhenping@tropos.de

if (length(height) ~= length(signal)) || ...
    (length(height) ~= length(measure_error))
    error('input length is not compatible');
end

nPoint = length(height);
slope = NaN(size(height));
slopestd = NaN(size(height));

if isscalar(win)
    for iPoint = ceil(win/2):(nPoint- ceil(win/2))
        indx = (iPoint - ceil(win/2) + 1):(iPoint + win - ceil(win/2));
        [~, b, ~, bStd] = chi2fit(height(indx), signal(indx), ...
                                  measure_error(indx));
        slope(iPoint) = b;
        slopestd(iPoint) = bStd;
    end
    return;
end

if ismatrix(win)
    if ~ size(win, 2) == 3
        error(['the setting for the height dependent window ' ...
               'should be [[bottom1, top1, win1], ' ...
               '[bottom2, top2, win2], ...]']);
    end

    for iWin = 1:size(win, 1)
        for iPoint = win(iWin, 1):win(iWin, 2)
            startIndx = max(1, (iPoint - fix((win(iWin, 3) - 1)/2)));
            endIndx = min(length(signal), (iPoint + fix(win(iWin, 3)/2)));

            [~, k, ~, kStd] = chi2fit(height(startIndx:endIndx), ...
               signal(startIndx:endIndx), measure_error(startIndx:endIndx));
            slope(iPoint) = k;
            slopestd(iPoint) = kStd;
        end
    end
end

end