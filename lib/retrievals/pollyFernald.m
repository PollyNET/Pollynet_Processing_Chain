function [aerBsc, aerBscStd, aerBR, aerBRStd] = pollyFernald(alt, signal, bg, LR_aer, refAlt, refBeta, molBsc, window_size)
% POLLYFERNALD retrieve aerosol backscatter coefficient with Fernald method.
%
% USAGE:
%    [aerBsc, aerBscStd, aerBR, aerBRStd] = pollyFernald(alt, signal, bg, LR_aer, refAlt, refBeta, molBsc, window_size)
%
% INPUTS:
%    alt: array
%        height. [m]
%    signal: array
%        elastic signal without background. [Photon Count]
%    bg: array
%        background. [Photon count]
%    LR_aer: float or array
%        aerosol lidar ratio. [sr]
%    refAlt: float or 2-element array
%        reference altitude or region. [m]
%    refBeta: float
%        aerosol backscatter coefficient at the reference region. 
%        [m^{-1}sr^{-1}]       
%    molBsc: array
%        molecular backscattering coefficient. Unit: m^{-1}*sr^{-1}
%    window_size: int32
%        Bins of the smoothing window for the signal. [default, 40 bins]
%
% OUTPUTS:
%    aerBsc: array
%        aerosol backscatter coefficient. [m^{-1}*sr^{-1}]
%    aerBscStd: array
%        statistical uncertainty of aerosol backscatter. [m^{-1}*sr^{-1}]
%    aerBR: array
%        aerosol backscatter ratio.
%    aerBRStd: array
%        statistical uncertainty of aerosol backscatter ratio.
%
% REFERENCES:
%    Fernald, F. G.: Analysis of atmospheric lidar observations: some comments, Appl. Opt., 23, 652-653, 10.1364/AO.23.000652, 1984.
%
% HISTORY:
%    - 2021-05-30: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if nargin < 6
    error('Not enough inputs.');
end

if ~ exist('window_size', 'var')
    window_size = 40;
end

alt = alt/1e3 ;   % convert the unit to km.
refAlt = refAlt/1e3;   % convert the unit to km
molBsc = molBsc * 1e3;   % convert the unit to km^{-1}sr^{-1}
refBeta = refBeta * 1e3;   % convert the unit to km^{-1}*sr^{-1}

% signal noise
totSig = signal + bg;
totSig(totSig < 0) = 0;
noise = sqrt(totSig);

dAlt = alt(2) - alt(1);
nAlt = length(alt);

% atmospheric molecular radiative parameters
LR_mol = 8 * pi / 3;
LR_mol = ones(1, nAlt) * LR_mol;

% index of the reference altitude 
if length(refAlt) == 1
    if refAlt > alt(end) || refAlt < alt(1)
        error('refAlt is out of range.');
    end
    indRefAlt = find(alt >= refAlt, 1, 'first');
    indRefAlt = ones(1, 2) * indRefAlt;
elseif length(refAlt) == 2
    if (refAlt(1) - alt(end)) * (refAlt(1) - alt(1)) <=0 && ...
        (refAlt(2) - alt(end)) * (refAlt(2) - alt(1)) <=0
        indRefAlt = [floor((refAlt(1) - alt(1)) / dAlt), floor((refAlt(2) - alt(1)) / dAlt)];
    else
        error('refAlt is out of range.');
    end
end

if (length(LR_aer) == 1) 
    LR_aer = ones(1, nAlt) * LR_aer;
elseif ~ (length(LR_aer) == nAlt)
    error('Error in setting LR_aer.');
end

RCS = reshape(signal, 1, numel(signal)) .* reshape(alt, 1, numel(alt)).^2;

indRefMid = int32(mean(indRefAlt));
% smooth the signal at the reference height region
RCS = smooth(RCS, window_size, 'moving');
RCS(indRefMid) = mean(RCS(indRefAlt(1):indRefAlt(2)));

% intialize some parameters and set the value at the reference altitude.
aerBsc = NaN(1, nAlt);
aerBsc(indRefMid) = refBeta;
aerBR = NaN(1, nAlt);
aerBR(indRefMid) = refBeta / molBsc(indRefMid);

% backward retrieval
for iAlt = indRefMid-1:-1:1
    A = ((LR_aer(iAlt+1) - LR_mol(iAlt+1)) * molBsc(iAlt+1) + ...
        (LR_aer(iAlt) - LR_mol(iAlt)) * molBsc(iAlt)) * ...
        abs(alt(iAlt+1) - alt(iAlt));
    numerator = RCS(iAlt) * exp(A);
    denominator1 = RCS(iAlt+1) / (aerBsc(iAlt+1) + molBsc(iAlt+1));
    denominator2 = (LR_aer(iAlt+1) * RCS(iAlt+1) + LR_aer(iAlt) * ...
                   numerator) * abs(alt(iAlt+1) - alt(iAlt));
    aerBsc(iAlt) = numerator/(denominator1 + denominator2) - molBsc(iAlt);
    aerBR(iAlt) = aerBsc(iAlt) / molBsc(iAlt);

    m1 = noise(iAlt + 1) * alt(iAlt + 1).^2 / (aerBsc(iAlt + 1) + molBsc(iAlt + 1)) / numerator;
    m2 = (LR_aer(iAlt + 1) * noise(iAlt + 1) * alt(iAlt + 1).^2 + LR_aer(iAlt) * noise(iAlt) * alt(iAlt).^2 * exp(A)) * abs(alt(iAlt + 1) - alt(iAlt)) / numerator;
    m(iAlt) = m1 + m2;
end

% forward retrieval
for iAlt = indRefMid+1:1:nAlt
    A = ((LR_aer(iAlt-1) - LR_mol(iAlt-1)) * molBsc(iAlt-1) + ...
        (LR_aer(iAlt) - LR_mol(iAlt)) * molBsc(iAlt)) * ...
        abs(alt(iAlt)-alt(iAlt-1));
    numerator = RCS(iAlt) * exp(-A);
    denominator1 = RCS(iAlt-1) / (aerBsc(iAlt-1) + molBsc(iAlt-1));
    denominator2 = (LR_aer(iAlt-1) * RCS(iAlt-1) + LR_aer(iAlt) * ...
                   numerator) * abs(alt(iAlt) - alt(iAlt-1));
    aerBsc(iAlt) = numerator / (denominator1 - denominator2) - molBsc(iAlt);
    aerBR(iAlt) = aerBsc(iAlt) / molBsc(iAlt);

    m1 = noise(iAlt - 1) * alt(iAlt - 1).^2 / (aerBsc(iAlt - 1) + molBsc(iAlt - 1)) / numerator;
    m2 = (LR_aer(iAlt - 1) * noise(iAlt - 1) * alt(iAlt - 1).^2 + LR_aer(iAlt) * noise(iAlt) * alt(iAlt).^2 * exp(-A)) * abs(alt(iAlt) - alt(iAlt - 1)) / numerator;
    m(iAlt) = m1 - m2;
end

aerBsc = aerBsc / 1e3;   % convert the unit to m^{-1}*sr^{-1}
aerRelBRStd = abs((1 + noise ./ signal) ./ (1 + m .* (aerBsc + molBsc / 1e3)) - 1);
aerBRStd = aerRelBRStd .* aerBR;
aerBscStd = aerRelBRStd .* molBsc / 1e3 .* aerBR;

end