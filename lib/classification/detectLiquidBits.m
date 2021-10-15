function flagLiquid = detectLiquidBits(height, bsc1064, varargin)
% DETECTLIQUIDBITS detect liquid cloud bits.
%
% USAGE:
%    flagLiquid = detectLiquidBits(height, bsc1064, cloudThresBsc1064, minAttnBsc1064, p.Results.searchCloudAbove, p.Results.searchCloudBelow)
%
% INPUTS:
%    height: numeric
%        height. (m)
%    bsc1064: matrix (height x time)
%        particle backscatter at 1064 nm.
%
% KEYWORDS:
%    cloudThresBsc1064: numeric
%        threshold of cloud backscatter at 1064 nm.
%    minAttnBsc1064: numeric
%        minimum attanuation required to detect liquid cloud.
%    searchCloudAbove: numeric
%        cloud search window above current bit. (m)
%    searchCloudBelow
%        cloud search window below current bit. (m)
%
% OUTPUTS:
%    flagLiquid: logical (height x time)
%
% HISTORY:
%    - 2021-06-05: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'bsc1064', @isnumeric);
addParameter(p, 'cloudThresBsc1064', 2e-5, @isnumeric);
addParameter(p, 'minAttnRatioBsc1064', 10, @isnumeric);
addParameter(p, 'searchCloudAbove', 300, @isnumeric);
addParameter(p, 'searchCloudBelow', 100, @isnumeric);

parse(p, height, bsc1064, varargin{:});

bsc1064(~isfinite(bsc1064)) = 0;
flagLiquid = false(size(bsc1064));
hRes = height(2) - height(1);

jump_distance = 250;   % [m]
jump_hBins = ceil(jump_distance / hRes);

if p.Results.searchCloudAbove < jump_distance
    error('searchCloudAbove should be larger than jump_distance (%5d).', jump_distance);
end
search_bins_above = ceil(p.Results.searchCloudAbove / hRes);
search_bins_below = ceil(p.Results.searchCloudBelow / hRes);

diff_factor = 0.25;

for iTime = 1:size(bsc1064, 2)
    start_bin = 2;

    while start_bin <= (size(bsc1064, 1) - jump_hBins)
        hIndLargeBsc = find(bsc1064(start_bin:(size(bsc1064, 1) - search_bins_above), iTime) > p.Results.cloudThresBsc1064, 1) + start_bin - 1;

        if isempty(hIndLargeBsc)
            break;
        end

        if min(bsc1064(hIndLargeBsc:(hIndLargeBsc + jump_hBins), iTime) ./ bsc1064(hIndLargeBsc, iTime)) < 1/p.Results.minAttnRatioBsc1064

            search_start = max(1, hIndLargeBsc - search_bins_below);
            diff_bsc1064 = diff(bsc1064(search_start:hIndLargeBsc, iTime));
            max_diff = max(diff_bsc1064);

            base_cloud = find(diff_bsc1064 > max_diff*diff_factor, 1) + search_start;
            top_cloud = find(bsc1064((hIndLargeBsc + 1):(hIndLargeBsc + search_bins_above), iTime) ~= 0, 1, 'last') + hIndLargeBsc - 1;
            if isempty(top_cloud)
                diff_bsc1064 = diff(bsc1064(hIndLargeBsc:(hIndLargeBsc + search_bins_above), iTime));
                max_diff = max(-diff_bsc1064);
                top_cloud = find(-diff_bsc1064 > max_diff*diff_factor) + hIndLargeBsc - 1;
            end

            flagLiquid(base_cloud:top_cloud, iTime) = true;
            start_bin = top_cloud + 1;
        else
            start_bin = hIndLargeBsc + 1;
        end
    end
end