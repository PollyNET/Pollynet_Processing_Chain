function [refH532, dpIndx532] = polly_1v2_rayleighfit(data, config)
%polly_1v2_rayleighfit Find the reference height with rayleigh fitting algorithm.
%   Example:
%       [rrefH532] = polly_1v2_rayleighfit(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       refH532: matrix
%           [[refHBaseIndx532_1, refHTopIndx532_1], [refHBaseIndx532_2, refHTopIndx532_2], ...]. The number of layers reference height is compatible with the number of cloudfreegroups. If no reference height was found, the corresponding layer will be filled with NaN. 
%       dpIndx532: cell
%           Douglas-Peucker decomposition points for each cloud-free group.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

refH532 = [];
dpIndx532 = {};

if isempty(data.rawSignal)
    return;
end

flagChannel532 = config.isFR & config.is532nm & config.isTot;

%% search reference height 
for iGroup = 1:size(data.cloudFreeGroups, 1)
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    temperature = data.temperature(iGroup, :);
    pressure = data.pressure(iGroup, :);

    % rayleigh fitting for 532 nm
    sig532PC = squeeze(sum(data.signal(config.isFR & config.isTot & config.is532nm, :, proIndx), 3));   % photon count
    nShots532 = nansum(data.mShots(flagChannel532, proIndx), 2);
    sig532PCR = sig532PC / nShots532 * (150 / data.hRes);
    bg532PC = squeeze(sum(data.bg(config.isFR & config.isTot & config.is532nm, :, proIndx), 3));   % photon count
    [molBsc532, molExt532] = rayleigh_scattering(532, pressure, temperature + 273.17, 380, 70);
    molSig532 = molBsc532 .* exp(-2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));

    fprintf('\nStart to search reference height for 532 nm, period from %s to %s.\n', datestr(data.mTime(proIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(proIndx(end)), 'HH:MM'))
    [thisRefH532, thisDpIndx532] = polly_rayleighfit(data.distance0, sig532PC, sig532PCR, bg532PC, molSig532, config.minDecomLogDist532, config.heightFullOverlap(config.isFR & config.isTot & config.is532nm), config.maxDecomHeight532, config.maxDecomThickness532, config.decomSmoothWin532, config.minRefThickness532, config.minRefDeltaExt532, config.minRefSNR532);
    
    % concatenate the results
    refH532 = cat(1, refH532, thisRefH532);
    dpIndx532{end + 1} = thisDpIndx532;
end

end