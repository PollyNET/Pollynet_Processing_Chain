function [xStable, xIndx, xRelStd] = mean_stable(x, win, minBin, maxBin, minRelStd)
% MEAN_STABLE calculate the mean value of x based on the least fluctuated 
% segment of x. The searching is based on the std inside each window of x.
% USAGE:
%    [xStable, xIndx, xRelStd] = mean_stable(x, win)
% INPUTS:
%    x: array
%        signal
%    win: scalar
%        window width for calculate the relative std
%    minBin: integer
%        the start bin for the mean calculation
%    maxBin: integer
%        the end bin for the mean calculation
% OUTPUTS:
%    xStable: float
%        stable mean value.
%    xIndx: array
%        index of the elements to be used to calculate the mean value. 
%    xRelStd: float
%        relative uncertainty of the sequences to calculate the mean values.
% EXAMPLE:
% HISTORY:
%    2021-05-30: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if ~ exist('minBin', 'var')
    minBin = 1;
end

if ~ exist('maxBin', 'var')
    maxBin = length(x);
end

flagNaN = isnan(x);
x = smooth(x, win, 'moving');
x(flagNaN) = NaN;

if (maxBin - minBin + 1) <= win
    xIndx = minBin:maxBin;
    xStable = nanmean(x(minBin:maxBin));
    xRelStd = nanstd(x(minBin:maxBin)) / xStable;
    return;
end

relStd = [];
for iX = minBin:(maxBin - win)
    thisStd = nanstd(x(iX:(iX + win)));
    thisMean = nanmean(x(iX:(iX + win)));

    if (sum(isnan(x(iX:(iX + win)))) / (win + 1) <= 0.2)
        relStd = cat(2, relStd, thisStd / abs(thisMean));
    else
        relStd = cat(2, relStd, NaN);
    end
end

if ~ exist('minRelStd', 'var')
    [~, indxTmp] = nanmin(relStd);
    indx = indxTmp + minBin - 1;
else
    [thisRelStd, indxTmp] = nanmin(relStd);
    if thisRelStd > minRelStd
        xStable = [];
        xIndx = [];
        xRelStd = [];
        return;
    else 
        indx = indxTmp + minBin - 1;
    end
end

xStable = nanmean(x(indx:(indx + win)));
xIndx = indx:(indx + win);
xRelStd = relStd(indxTmp);

end