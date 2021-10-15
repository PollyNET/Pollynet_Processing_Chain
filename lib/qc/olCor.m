function [sigCor] = olCor(sigFR, overlap, height, normRange)
% OLCOR overlap correction.
%
% USAGE:
%    sigCor = olCor(sigFR, overlap, height, normRange)
%
% INPUTS:
%    sigFR: matrix (height * time)
%        far-range signal
%    overlap: array
%        overlap function.
%    height: array
%        height above ground. (m)
%    normRange: array
%        signal normalization range. (m)
%
% OUTPUTS:
%    sigCor: matrix (height * time)
%        glued signal.
%
% HISTORY:
%    - 2021-05-22: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

sigCor = NaN(size(sigFR));

sigNR = sigFR ./ repmat(transpose(overlap), 1, size(sigFR, 2));

if (~ isempty(normRange))
    bottomIndx = find(height >= normRange(1), 1);
    topIndx = find(height >= normRange(end), 1);

    % step-like gluing
    sigCor(1:bottomIndx, :) = sigNR(1:bottomIndx, :);

    m = repmat((transpose(bottomIndx:topIndx) - bottomIndx) ./ (topIndx - bottomIndx), ...
            1, size(sigFR, 2));
    sigCor(bottomIndx:topIndx, :) = sigNR(bottomIndx:topIndx, :) .* (1 - m) + ...
                                    sigFR(bottomIndx:topIndx, :) .* m;

    sigCor(topIndx:end, :) = sigFR(topIndx:end, :);
end

end