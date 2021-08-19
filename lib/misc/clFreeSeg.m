function [clFreSegs] = clFreeSeg(prfFlag, nIntPrf, minNIntPrf)
% CLFREESEG split continous cloud free profiles into small sections.
%
% USAGE:
%    [clFreSegs] = clFreeSeg(prfFlag, nIntPrf, minNIntPrf)
%
% INPUTS:
%    prfFlag: logical
%        cloud-free flags for each profile.
%    nIntPrf: numeric
%        number of integral profiles.
%    minNIntPrf: numeric
%        minimum number of integral profiles.
%
% OUTPUTS:
%    clFreSegs: 2xn matrix
%        start and stop indexes for each cloud free section.
%        [[startI1, stopI1], [startI2, stopI2], ...]
%
% HISTORY:
%    - 2021-05-22: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'prfFlag', @islogical);
addRequired(p, 'nIntPrf', @isnumeric);
addRequired(p, 'minNIntPrf', @isnumeric);

parse(p, prfFlag, nIntPrf, minNIntPrf);

prfFlagD = double(prfFlag);
prfFlagD(prfFlagD == 0) = NaN;

% mark the contiguous cloud-free, fog-free, no depol calibration profile
[clFreGrpTag, nClFreGrps] = label(prfFlagD);   % label contiguous cloud-free profiles

clFreSegs = [];
nClFreSeg = 0;

if nClFreGrps == 0
    fprintf('No cloud-free segments were found.\n');
else
    for iClFreGrp = 1:nClFreGrps
        iClFreGrpInd = find(clFreGrpTag == iClFreGrp);

        % check number of contiguous profiles
        if (length(iClFreGrpInd) <= nIntPrf) && (length(iClFreGrpInd) >= minNIntPrf)
            nClFreSeg = nClFreSeg + 1;
            clFreSegs = cat(1, clFreSegs, [iClFreGrpInd(1), iClFreGrpInd(end)]);

        elseif length(iClFreGrpInd) > nIntPrf
            % keep segmentation if profile number is too large
            if rem(length(iClFreGrpInd), nIntPrf) >= minNIntPrf
                nClFreSeg = nClFreGrps + ceil(length(iClFreGrpInd) / nIntPrf);
                subClFreGrp = [(0:ceil(length(iClFreGrpInd) / nIntPrf) - 1) * nIntPrf + iClFreGrpInd(1); ...
                    [(1:ceil(length(iClFreGrpInd) / nIntPrf) - 1) * nIntPrf - 1 + iClFreGrpInd(1), ...
                     iClFreGrpInd(end)]];
                clFreSegs = cat(1, clFreSegs, transpose(subClFreGrp));
            else
                nClFreSeg = nClFreSeg + floor(length(iClFreGrpInd) / nIntPrf);
                subClFreGrp = [(0:floor(length(iClFreGrpInd) / nIntPrf) - 1) * nIntPrf + iClFreGrpInd(1); ...
                    [(1:floor(length(iClFreGrpInd) / nIntPrf) - 1) * nIntPrf - 1 + iClFreGrpInd(1), ...
                     iClFreGrpInd(end)]];
                clFreSegs = cat(1, clFreSegs, transpose(subClFreGrp));
            end
        end
    end
end

end