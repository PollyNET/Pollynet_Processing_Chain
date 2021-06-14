function [aerBsc532_raman, aerExt532_raman,LR532_raman] = polly_first_raman(data, config)
%POLLY_FIRST_RAMAN Retrieve aerosol optical properties with raman method
%Example:
%   [aerBsc532_raman,  aerExt532_raman,  LR532_raman] = polly_first_raman(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%Outputs:
%   aerBsc532_raman: matrix
%       aerosol backscatter coefficient at 532 nm with raman method. [m^{-1}Sr^{-1}] 
%   aerExt532_raman: matrix
%       aerosol extinction coefficient at 355 nm with raman method. [m^{-1}] 
%   
%   LR532_raman: matrix
%       lidar ratio at 532 nm. [Sr]
%   
%History:
%   2018-12-23. First Edition by Zhenping
%   2019-08-31. Add SNR control for elastic signal at reference height as well.
%Contact:
%   zhenping@tropos.de

aerBsc532_raman = [];
aerExt532_raman = [];
LR532_raman = [];

if isempty(data.rawSignal)
    return;
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_raman = NaN(size(data.height));
    thisAerExt532_raman = NaN(size(data.height));
    thisLR532_raman = NaN(size(data.height));

    flagChannel532 = config.isFR & config.isTot & config.is532nm;
    flagChannel607 = config.isFR & config.is607nm;
    % Only take into account of profiles with PMT on
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagCloudFree = false(size(data.mTime));
    flagCloudFree(proIndx) = true;
    proIndx_607On = flagCloudFree & (~ data.mask607Off);
    if sum(proIndx_607On) == 0
        warning('No Raman measurement during %s - %s', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));

        % concatenate the results
        aerBsc532_raman = cat(1, aerBsc532_raman, thisAerBsc532_raman);
        aerExt532_raman = cat(1, aerExt532_raman, thisAerExt532_raman);
        LR532_raman = cat(1, LR532_raman, thisLR532_raman);

        continue;
    end

    sig532 = transpose(squeeze(sum(data.el532(:, proIndx_607On), 2)));
    bg532 = transpose(squeeze(sum(data.bgEl532(:, proIndx_607On), 2)));
    sig607 = squeeze(sum(data.signal(flagChannel607, :, proIndx_607On), 3));
    bg607 = squeeze(sum(data.bg(flagChannel607, :, proIndx_607On), 3));

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

        refSig532 = sum(sig532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg532 = sum(bg532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refSig607 = sum(sig607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg607 = sum(bg607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        snr532 = polly_SNR(refSig532, refBg532);
        snr607 = polly_SNR(refSig607, refBg607);

        if (snr607 >= config.minRamanRefSNR607) && (snr532 >= config.minRamanRefSNR532)
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

end