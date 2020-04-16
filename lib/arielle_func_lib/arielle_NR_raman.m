function [aerBsc355_NR_raman, aerBsc532_NR_raman, aerExt355_NR_raman, aerExt532_NR_raman, LR355_NR_raman, LR532_NR_raman, refBeta355_NR_raman, refBeta532_NR_raman] = arielle_NR_raman(data, config)
%arielle_NR_raman Retrieve aerosol optical properties for near-range channels
%with raman method
%Example:
%   [aerBsc355_NR_raman, aerBsc532_NR_raman, aerExt355_NR_raman,
%    aerExt532_NR_raman, LR355_NR_raman, LR532_NR_raman, refBeta355_NR_raman,
%    refBeta532_NR_raman] = arielle_NR_raman(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%Outputs:
%   aerBsc355_NR_raman: matrix
%       aerosol backscatter coefficient at 355 nm with raman method.
%       [m^{-1}*sr^{-1}] 
%   aerBsc532_NR_raman: matrix
%       aerosol backscatter coefficient at 532 nm with raman method.
%       [m^{-1}*sr^{-1}] 
%   aerExt355_NR_raman: matrix
%       aerosol extinction coefficient at 355 nm with raman method. [m^{-1}]
%   aerExt532_NR_raman: matrix
%       aerosol extinction coefficient at 355 nm with raman method. [m^{-1}] 
%   LR355_NR_raman: matrix
%       lidar ratio at 355 nm. [sr]
%   LR532_NR_raman: matrix
%       lidar ratio at 532 nm. [sr] 
%   refBeta355_NR_raman: array
%       reference value used for retrieving the Near-range backscatter
%       at 355 nm with Raman method. [m^{-1}*sr^{-1}]
%   refBeta532_NR_raman: array
%       reference value used for retrieving the Near-range backscatter
%       at 532 nm with Raman method. [m^{-1}*sr^{-1}]
%History:
%   2019-08-06. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

aerBsc355_NR_raman = [];
aerBsc532_NR_raman = [];
aerExt355_NR_raman = [];
aerExt532_NR_raman = [];
LR355_NR_raman = [];
LR532_NR_raman = [];
refBeta355_NR_raman = [];
refBeta532_NR_raman = [];

if isempty(data.rawSignal)
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc355_NR_raman = NaN(size(data.height));
    thisAerExt355_NR_raman = NaN(size(data.height));
    thisLR355_NR_raman = NaN(size(data.height));
    refBeta355 = NaN;
    flagRefSNRLow_355 = false;

    flagChannel355_NR = config.isNR & config.isTot & config.is355nm;
    flagChannel387_NR = config.isNR & config.is387nm;

    if any(flagChannel355_NR) && any(flagChannel387_NR)

        sig355 = squeeze(sum(data.signal(flagChannel355_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg355 = squeeze(sum(data.bg(flagChannel355_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        sig387 = squeeze(sum(data.signal(flagChannel387_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg387 = squeeze(sum(data.bg(flagChannel387_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));

        refH355 = config.refH_NR_355;

        % retrieve extinction
        thisAerExt355_NR_raman = polly_raman_ext(data.distance0, sig387, 355, 387, config.angstrexp_NR, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_NR_355, 380, 70, 'moving');

        hBaseIndx355 = find(data.height >= config.heightFullOverlap(flagChannel355_NR) + config.smoothWin_raman_NR_355/2 * data.hRes, 1);
        if isempty(hBaseIndx355)
            warning('Warning in %s: Failure in searching the index of minHeight for Near-Range channel. Set the index of the minimum integral range to be 40', mfilename);
            hBaseIndx355 = 40;
        end
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the index for the reference height
        if ((refH355(1) < data.height(1)) || (refH355(1) > data.height(end))) || ((refH355(2) < data.height(1)) || (refH355(2) > data.height(end)))
            warning('refH_NR_532 (%f - %f m) in the polly configu file is out of range.', refH355(1), refH355(2));
            warning('Set refH_NR_532 to [2500 - 3000 m]');
            refH355 = [2500, 3000];
        end
        refHTopIndx355 = find(data.height <= refH355(2), 1, 'last');
        refHBottomIndx355 = find(data.height >= refH355(1), 1, 'first');

        % criteria on the SNR at the reference height
        refSig355 = sum(sig355(refHBottomIndx355:refHTopIndx355));
        refBg355 = sum(bg355(refHBottomIndx355:refHTopIndx355));
        refSig387 = sum(sig387(refHBottomIndx355:refHTopIndx355));
        refBg387 = sum(bg387(refHBottomIndx355:refHTopIndx355));
        snr355 = polly_SNR(refSig355, refBg355);
        snr387 = polly_SNR(refSig387, refBg387);
        if (snr355 < config.minRefSNR_NR_355) || (snr387 < config.minRamanRefSNR387)
            warning('355 nm (387 nm) Near-range signal is too noisy at the reference height [%f - %f m].', refH355(1), refH355(2));
            flagRefSNRLow_355 = true;
        end

        % retrieve the reference value from the far-range retrieving results
        refBeta355 = mean(data.aerBsc355_raman(iGroup, refHBottomIndx355:refHTopIndx355), 2);
        
        if (~ flagRefSNRLow_355) && (~ isnan(refBeta355))
            tmpAerExt355_NR_raman = thisAerExt355_NR_raman;
            tmpAerExt355_NR_raman(1:hBaseIndx355) = tmpAerExt355_NR_raman(hBaseIndx355);
            [thisAerBsc355_NR_raman, ~] = polly_raman_bsc(data.distance0, sig355, sig387, tmpAerExt355_NR_raman, config.angstrexp_NR, molExt355, molBsc355, refH355, 355, refBeta355, config.smoothWin_raman_NR_355, true);
            thisLR355_NR_raman = thisAerExt355_NR_raman ./ thisAerBsc355_NR_raman;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc355_NR_raman = cat(1, aerBsc355_NR_raman, thisAerBsc355_NR_raman);
    aerExt355_NR_raman = cat(1, aerExt355_NR_raman, thisAerExt355_NR_raman);
    LR355_NR_raman = cat(1, LR355_NR_raman, thisLR355_NR_raman);
    refBeta355_NR_raman = cat(2, refBeta355_NR_raman, refBeta355);
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_NR_raman = NaN(size(data.height));
    thisAerExt532_NR_raman = NaN(size(data.height));
    thisLR532_NR_raman = NaN(size(data.height));
    refBeta532 = NaN;
    flagRefSNRLow_532 = false;

    flagChannel532_NR = config.isNR & config.isTot & config.is532nm;
    flagChannel607_NR = config.isNR & config.is607nm;

    if any(flagChannel532_NR) && any(flagChannel607_NR)
        sig532 = squeeze(sum(data.signal(flagChannel532_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg532 = squeeze(sum(data.bg(flagChannel532_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        sig607 = squeeze(sum(data.signal(flagChannel607_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg607 = squeeze(sum(data.bg(flagChannel607_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));

        refH532 = config.refH_NR_532;

        % retrieve extinction
        thisAerExt532_NR_raman = polly_raman_ext(data.distance0, sig607, 532, 607, config.angstrexp_NR, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_NR_532, 380, 70, 'moving');

        hBaseIndx532 = find(data.height >= config.heightFullOverlap(flagChannel532_NR) + config.smoothWin_raman_NR_532/2 * data.hRes, 1);
        if isempty(hBaseIndx532)
            warning('Warning in %s: Failure in searching the index of minHeight for Near-Range channel. Set the index of the minimum integral range to be 40', mfilename);
            hBaseIndx532 = 40;
        end
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the index for the reference height
        if ((refH532(1) < data.height(1)) || (refH532(1) > data.height(end))) || ((refH532(2) < data.height(1)) || (refH532(2) > data.height(end)))
            warning('refH_NR_532 (%f - %f m) in the polly configu file is out of range.', refH532(1), refH532(2));
            warning('Set refH_NR_532 to [2500 - 3000 m]');
            refH532 = [2500, 3000];
        end
        refHTopIndx532 = find(data.height <= refH532(2), 1, 'last');
        refHBottomIndx532 = find(data.height >= refH532(1), 1, 'first');

        % criteria on the SNR at the reference height
        refSig532 = sum(sig532(refHBottomIndx532:refHTopIndx532));
        refBg532 = sum(bg532(refHBottomIndx532:refHTopIndx532));
        refSig607 = sum(sig607(refHBottomIndx532:refHTopIndx532));
        refBg607 = sum(bg607(refHBottomIndx532:refHTopIndx532));
        snr532 = polly_SNR(refSig532, refBg532);
        snr607 = polly_SNR(refSig607, refBg607);
        if (snr532 < config.minRefSNR_NR_532) || (snr607 < config.minRamanRefSNR607)
            warning('532 nm (607 nm) Near-range signal is too noisy at the reference height [%f - %f m].', refH532(1), refH532(2));
            flagRefSNRLow_532 = true;
        end

        % retrieve the reference value from the far-range retrieving results
        refBeta532 = mean(data.aerBsc532_raman(iGroup, refHBottomIndx532:refHTopIndx532), 2);

        if (~ flagRefSNRLow_532) && (~ isnan(refBeta532))
            tmpAerExt532_NR_raman = thisAerExt532_NR_raman;
            tmpAerExt532_NR_raman(1:hBaseIndx532) = tmpAerExt532_NR_raman(hBaseIndx532);
            [thisAerBsc532_NR_raman, ~] = polly_raman_bsc(data.distance0, sig532, sig607, tmpAerExt532_NR_raman, config.angstrexp_NR, molExt532, molBsc532, refH532, 532, refBeta532, config.smoothWin_raman_NR_532, true);
            thisLR532_NR_raman = thisAerExt532_NR_raman ./ thisAerBsc532_NR_raman;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc532_NR_raman = cat(1, aerBsc532_NR_raman, thisAerBsc532_NR_raman);
    aerExt532_NR_raman = cat(1, aerExt532_NR_raman, thisAerExt532_NR_raman);
    LR532_NR_raman = cat(1, LR532_NR_raman, thisLR532_NR_raman);
    refBeta532_NR_raman = cat(2, refBeta532_NR_raman, refBeta532);
end

end