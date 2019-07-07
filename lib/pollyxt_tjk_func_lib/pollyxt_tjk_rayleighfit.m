function [refH355, refH532, refH1064, dpIndx355, dpIndx532, dpIndx1064] = pollyxt_tjk_rayleighfit(data, config)
%pollyxt_tjk_rayleighfit Find the reference height with rayleigh fitting algorithm.
%   Example:
%       [refH355, refH532, refH1064] = pollyxt_tjk_rayleighfit(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       refH355: matrix
%           [[refHBaseIndx355_1, refHTopIndx355_1], [refHBaseIndx355_2, refHTopIndx355_2], ...]. The number of layers reference height is compatible with the number of cloudfreegroups. If no reference height was found, the corresponding layer will be filled with NaN. 
%       refH532: matrix
%           as above. 
%       refH1064: matrix
%           as above.
%       dpIndx355: cell
%           Douglas-Peucker decomposition points for each cloud-free group.
%       dpIndx532: cell
%           as above;
%       dpIndx1064: cell
%           as above.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

refH355 = [];
refH532 = [];
refH1064 = [];
dpIndx355 = {};
dpIndx532 = {};
dpIndx1064 = {};

if isempty(data.rawSignal)
    return;
end

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

%% search reference height 
for iGroup = 1:size(data.cloudFreeGroups, 1)
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    temperature = data.temperature(iGroup, :);
    pressure = data.pressure(iGroup, :);

    % rayleigh fitting for 355 nm
    sig355PC = squeeze(sum(data.signal(config.isFR & config.isTot & config.is355nm, :, proIndx), 3));   % photon count
    nShots355 = nansum(data.mShots(flagChannel355, proIndx), 2);
    sig355PCR = sig355PC / nShots355 * (150 / data.hRes);
    bg355PC = squeeze(sum(data.bg(config.isFR & config.isTot & config.is355nm, :, proIndx), 3));   % photon count
    [molBsc355, molExt355] = rayleigh_scattering(355, pressure, temperature + 273.17, 380, 70);
    molSig355 = molBsc355 .* exp(-2 * cumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]));

    fprintf('\nStart to search reference height for 355 nm, period from %s to %s.\n', datestr(data.mTime(proIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(proIndx(end)), 'HH:MM'))
    [thisRefH355, thisDpIndx355] = polly_rayleighfit(data.distance0, sig355PC, sig355PCR, bg355PC, molSig355, config.minDecomLogDist355, config.heightFullOverlap(config.isFR & config.isTot & config.is355nm), config.maxDecomHeight355, config.maxDecomThickness355, config.decomSmoothWin355, config.minRefThickness355, config.minRefDeltaExt355, config.minRefSNR355);
    
    % rayleigh fitting for 532 nm
    sig532PC = squeeze(sum(data.signal(config.isFR & config.isTot & config.is532nm, :, proIndx), 3));   % photon count
    nShots532 = nansum(data.mShots(flagChannel532, proIndx), 2);
    sig532PCR = sig532PC / nShots532 * (150 / data.hRes);
    bg532PC = squeeze(sum(data.bg(config.isFR & config.isTot & config.is532nm, :, proIndx), 3));   % photon count
    [molBsc532, molExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    molSig532 = molBsc532 .* exp(-2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));

    fprintf('\nStart to search reference height for 532 nm, period from %s to %s.\n', datestr(data.mTime(proIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(proIndx(end)), 'HH:MM'))
    [thisRefH532, thisDpIndx532] = polly_rayleighfit(data.distance0, sig532PC, sig532PCR, bg532PC, molSig532, config.minDecomLogDist532, config.heightFullOverlap(config.isFR & config.isTot & config.is532nm), config.maxDecomHeight532, config.maxDecomThickness532, config.decomSmoothWin532, config.minRefThickness532, config.minRefDeltaExt532, config.minRefSNR532);
    
    % rayleigh fitting for 1064 nm
    sig1064PC = squeeze(sum(data.signal(config.isFR & config.isTot & config.is1064nm, :, proIndx), 3));   % photon count
    nShots1064 = nansum(data.mShots(flagChannel1064, proIndx), 2);
    sig1064PCR = sig1064PC / nShots1064 * (150 / data.hRes);
    bg1064PC = squeeze(sum(data.bg(config.isFR & config.isTot & config.is1064nm, :, proIndx), 3));   % photon count
    [molBsc1064, molExt1064] = rayleigh_scattering(1064, pressure, temperature + 273.17, 380, 70);
    molSig1064 = molBsc1064 .* exp(-2 * cumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]));

    fprintf('\nStart to search reference height for 1064 nm, period from %s to %s.\n', datestr(data.mTime(proIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(proIndx(end)), 'HH:MM'))
    [thisRefH1064, thisDpIndx1064] = polly_rayleighfit(data.distance0, sig1064PC, sig1064PCR, bg1064PC, molSig1064, config.minDecomLogDist1064, config.heightFullOverlap(config.isFR & config.isTot & config.is1064nm), config.maxDecomHeight1064, config.maxDecomThickness1064, config.decomSmoothWin1064, config.minRefThickness1064, config.minRefDeltaExt1064, config.minRefSNR1064);

    % concatenate the results
    refH355 = cat(1, refH355, thisRefH355);
    refH532 = cat(1, refH532, thisRefH532);
    refH1064 = cat(1, refH1064, thisRefH1064);
    dpIndx355{end + 1} = thisDpIndx355;
    dpIndx532{end + 1} = thisDpIndx532;
    dpIndx1064{end + 1} = thisDpIndx1064;
end

end