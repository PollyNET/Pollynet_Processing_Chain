function [aerBsc532_raman, aerBsc532_RR, aerExt532_raman, aerExt532_RR, LR532_raman, LR532_RR] = polly_1v2_raman(data, config)
%polly_1v2_raman Retrieve aerosol optical properties with raman method
%   Example:
%       [aerBsc532_raman, aerBsc532_RR, aerExt532_raman, aerExt532_RR, LR532_raman, LR532_RR] = polly_1v2_raman(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc532_raman: matrix
%           aerosol backscatter coefficient at 532 nm with raman method. [m^{-1}Sr^{-1}] 
%       aerBsc532_RR: matrix
%           aerosol backscatter coefficient at 532 nm with RR signal. [m^{-1}Sr^{-1}] 
%       aerExt532_raman: matrix
%           aerosol extinction coefficient at 355 nm with raman method. [m^{-1}] 
%       aerExt532_RR: matrix
%           aerosol extinction coefficient at 355 nm with RR signal. [m^{-1}] 
%       LR532_raman: matrix
%           lidar ratio at 532 nm. [Sr]
%       LR532_RR: matrix
%           lidar ratio at 532 nm with RR signal. [Sr]
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

aerBsc532_raman = [];
aerExt532_raman = [];
LR532_raman = [];
aerBsc532_RR = [];
aerExt532_RR = [];
LR532_RR = [];

if isempty(data.rawSignal);
    return;
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_raman = NaN(size(data.height));
    thisAerExt532_raman = NaN(size(data.height));
    thisLR532_raman = NaN(size(data.height));
    
    flagChannel532 = config.isFR & config.isTot & config.is532nm;
    flagChannel607 = config.isFR & config.is607nm;
    sig532 = transpose(squeeze(sum(data.el532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
    bg532 = transpose(squeeze(sum(data.bgEl532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
    sig607 = squeeze(sum(data.signal(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
    bg607 = squeeze(sum(data.bg(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));

    % retrieve extinction
    thisAerExt532_raman = polly_raman_ext(data.distance0, sig607, 532, 607, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_532, 380, 70, 'moving');
    
    if ~ isnan(data.refHIndx532(iGroup, 1))
        refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
        hBaseIndx532 = find(data.height >= config.heightFullOverlap(flagChannel532) + config.smoothWin_raman_532/2 * data.hRes, 1);
        if isempty(hBaseIndx532)
            warning('Warning in %s: Failure in searching the index of minHeight. Set the index of the minimum integral range to be 100', mfilename);
            hBaseIndx532 = 100;
        end
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig607 = sum(sig607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg607 = sum(bg607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        snr607 = polly_SNR(refSig607, refBg607);
        
        if snr607 >= config.minRamanRefSNR607
            tmpAerExt532_raman = thisAerExt532_raman;
            tmpAerExt532_raman(1:hBaseIndx532) = tmpAerExt532_raman(hBaseIndx532);
            [thisAerBsc532_raman, thisLR532_raman] = polly_raman_bsc(data.distance0, sig532, sig607, tmpAerExt532_raman, config.angstrexp, molExt532, molBsc532, refH, 532, config.refBeta532, config.smoothWin_raman_532, true);
            thisLR532_raman = thisAerExt532_raman ./ thisAerBsc532_raman;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc532_raman = cat(1, aerBsc532_raman, thisAerBsc532_raman);
    aerExt532_raman = cat(1, aerExt532_raman, thisAerExt532_raman);
    LR532_raman = cat(1, LR532_raman, thisLR532_raman);
end

%% 532 nm with RR signal
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_RR = NaN(size(data.height));
    thisAerExt532_RR = NaN(size(data.height));
    thisLR532_RR = NaN(size(data.height));
    
    flagChannel532 = config.isFR & config.isTot & config.is532nm;
    flagChannel532RR = config.isFR & config.isRR;
    sig532 = squeeze(sum(data.signal(flagChannel532, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
    bg532 = squeeze(sum(data.bg(flagChannel532, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
    sig532RR = squeeze(sum(data.signal(flagChannel532RR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
    bg532RR = squeeze(sum(data.bg(flagChannel532RR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));

    % retrieve extinction
    thisAerExt532_RR = polly_raman_ext(data.distance0, sig532RR, 532, 532, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_532, 380, 70, 'moving');
    
    if ~ isnan(data.refHIndx532(iGroup, 1))
        refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
        hBaseIndx532 = find(data.height >= config.heightFullOverlap(flagChannel532) + config.smoothWin_raman_532/2 * data.hRes, 1);
        if isempty(hBaseIndx532)
            warning('Warning in %s: Failure in searching the index of minHeight. Set the index of the minimum integral range to be 100', mfilename);
            hBaseIndx532 = 100;
        end
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig532RR = sum(sig532RR(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg532RR = sum(bg532RR(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        snr532RR = polly_SNR(refSig532RR, refBg532RR);
        
        if snr532RR >= config.minRamanRefSNR607
            tmpAerExt532_RR = thisAerExt532_RR;
            tmpAerExt532_RR(1:hBaseIndx532) = tmpAerExt532_RR(hBaseIndx532);
            [thisAerBsc532_RR, thisLR532_RR] = polly_raman_bsc_rr(data.distance0, sig532, sig532RR, tmpAerExt532_RR, config.angstrexp, molExt532, molBsc532, refH, 532, config.refBeta532, config.smoothWin_raman_532, true);
            thisLR532_RR = thisAerExt532_RR ./ thisAerBsc532_RR;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc532_RR = cat(1, aerBsc532_RR, thisAerBsc532_RR);
    aerExt532_RR = cat(1, aerExt532_RR, thisAerExt532_RR);
    LR532_RR = cat(1, LR532_RR, thisLR532_RR);
end

end