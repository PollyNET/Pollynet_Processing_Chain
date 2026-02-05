function [aerLR, aerLRStd, effRes] = pollyLR(aerExt, aerBsc, varargin)
% POLLYLR calculate aerosol lidar ratio.
%
% USAGE:
%    [aerLR, effRes, aerLRStd] = pollyLR(aerExt, aerBsc)
%
% INPUTS:
%    aerExt: numeric
%        aerosol extinction coefficient. (m^-1)
%    aerBsc: numeric
%        aerosol backscatter coefficient. (m^-1sr^-1)
%
% KEYWORDS:
%    hRes: numeric
%        vertical resolution of each height bin. (m)
%    aerExtStd: numeric
%        uncertainty of aerosol extinction coefficient. (m^-1)
%    aerBscStd: numeric
%        uncertainty of aerosol backscatter coefficient. (m^-1sr^-1)
%    smoothWinExt: numeric
%        applied smooth window length for calculating aerosol extinction coefficient.
%    smoothWinBsc: numeric
%        applied smooth window length for calculating aerosol backscatter coefficient.
%
% OUTPUTS:
%    aerLR: numeric
%        aerosol lidar ratio. (sr)
%    effRes: numeric
%        effective resolution of lidar ratio. (m)
%    aerLRStd: numeric
%        uncertainty of aerosol lidar ratio. (sr)
%
% REFERENCES:
%    Mattis, I., D'Amico, G., Baars, H., Amodeo, A., Madonna, F., and Iarlori, M.: EARLINET Single Calculus Chain–technical–Part 2: Calculation of optical products, Atmospheric Measurement Techniques, 9, 3009-3029, 2016.
%
% HISTORY:
%    2021-07-20: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'aerExt', @isnumeric);
addRequired(p, 'aerBsc', @isnumeric);
addParameter(p, 'hRes', 7.5, @isnumeric);
addParameter(p, 'aerExtStd', [], @isnumeric);
addParameter(p, 'aerBscStd', [], @isnumeric);
addParameter(p, 'smoothWinExt', 1, @isnumeric);
addParameter(p, 'smoothWinBsc', 1, @isnumeric);

parse(p, aerExt, aerBsc, varargin{:});

% smooth backscatter to assure the same effective vertical resolution with extinction
if p.Results.smoothWinExt >= p.Results.smoothWinBsc
    smoothWinBsc2 = round(0.625 * p.Results.smoothWinExt + 0.23);   % Eq (6) in Ref.1
    if smoothWinBsc2 <= 3
        smoothWinBsc2 = 3;
    end
else
    warning('Smoothing for backscatter is larger than the smoothing for extinction.');
    smoothWinBsc2 = 3;
end

aerBscSm = smooth(aerBsc, smoothWinBsc2, 'sgolay', 2);
aerBscSm = reshape(aerBscSm, size(aerBsc));

% lidar ratio
aerLR = aerExt ./ aerBscSm;
effRes = p.Results.hRes * p.Results.smoothWinExt;

% uncertainty
if isempty(p.Results.aerExtStd)
    aerExtStd = NaN(size(aerExt));
else
    aerExtStd = p.Results.aerExtStd;
end

if isempty(p.Results.aerBscStd)
    aerBscStd = NaN(size(aerBsc));
else
    aerBscStd = p.Results.aerBscStd;
end

aerLRStd = real(aerLR .* sqrt(aerExtStd.^2 ./ aerExt.^2 + aerBscStd.^2 ./ aerBsc.^2));

end