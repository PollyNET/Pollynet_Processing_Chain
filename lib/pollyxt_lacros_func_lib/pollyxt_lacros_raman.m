function [aerBsc355_raman, aerBsc532_raman, aerBsc1064_raman, aerExt355_raman, aerExt532_raman, aerExt1064_raman, LR355_raman, LR532_raman, LR1064_raman] = pollyxt_lacros_raman(data, config)
%pollyxt_lacros_raman Retrieve aerosol optical properties with raman method
%   Example:
%       [aerBsc355_raman, aerBsc532_raman, aerBsc1064_raman, aerExt355_raman, aerExt532_raman, aerExt1064_raman, aerLR355_raman, aerLR532_raman, aerLR1064_raman] = pollyxt_lacros_raman(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc355_raman: matrix
%           aerosol backscatter coefficient at 355 nm with raman method. [m^{-1}Sr^{-1}] 
%       aerBsc532_raman: matrix
%           aerosol backscatter coefficient at 532 nm with raman method. [m^{-1}Sr^{-1}] 
%       aerBsc1064_raman: matrix
%           aerosol backscatter coefficient at 1064 nm with raman method. [m^{-1}Sr^{-1}] 
%       aerExt355_raman: matrix
%           aerosol extinction coefficient at 355 nm with raman method. [m^{-1}]
%       aerExt532_raman: matrix
%           aerosol extinction coefficient at 355 nm with raman method. [m^{-1}] 
%       aerExt1064_raman: matrix
%           aerosol extinction coefficient at 355 nm with raman method. [m^{-1}]
%       LR355_raman: matrix
%           lidar ratio at 355 nm. [Sr]
%       LR532_raman: matrix
%           lidar ratio at 532 nm. [Sr]
%       LR1064_raman: matrix
%           lidar ratio at 1064 nm. [Sr]
%   History:
%       2018-12-23. First Edition by Zhenping
%       2019-08-31. Add SNR control for elastic signal at reference height as well.
%   Contact:
%       zhenping@tropos.de

aerBsc355_raman = [];
aerBsc532_raman = [];
aerBsc1064_raman = [];
aerExt355_raman = [];
aerExt532_raman = [];
aerExt1064_raman = [];
LR355_raman = [];
LR532_raman = [];
LR1064_raman = [];

if isempty(data.rawSignal);
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc355_raman = NaN(size(data.height));
    thisAerExt355_raman = NaN(size(data.height));
    thisLR355_raman = NaN(size(data.height));

    flagChannel355 = config.isFR & config.isTot & config.is355nm;
    flagChannel387 = config.isFR & config.is387nm;

    % Only take into account of profiles with PMT on
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagCloudFree = false(size(data.mTime));
    flagCloudFree(proIndx) = true;
    proIndx_387On = flagCloudFree & (~ data.mask387Off);
    if sum(proIndx_387On) == 0
        warning('No Raman measurement during %s - %s', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));

        % concatenate the results
        aerBsc355_raman = cat(1, aerBsc355_raman, thisAerBsc355_raman);
        aerExt355_raman = cat(1, aerExt355_raman, thisAerExt355_raman);
        LR355_raman = cat(1, LR355_raman, thisLR355_raman);
        
        continue;
    end

    sig355 = squeeze(sum(data.signal(flagChannel355, :, proIndx_387On), 3));
    bg355 = squeeze(sum(data.bg(flagChannel355, :, proIndx_387On), 3));
    sig387 = squeeze(sum(data.signal(flagChannel387, :, proIndx_387On), 3));
    bg387 = squeeze(sum(data.bg(flagChannel387, :, proIndx_387On), 3));

    % retrieve extinction
    thisAerExt355_raman = polly_raman_ext(data.distance0, sig387, 355, 387, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_355, 380, 70, 'moving');
    
    if ~ isnan(data.refHIndx355(iGroup, 1))
        refH = [data.distance0(data.refHIndx355(iGroup, 1)), data.distance0(data.refHIndx355(iGroup, 2))];
        hBaseIndx355 = find(data.height >= config.heightFullOverlap(flagChannel355) + config.smoothWin_raman_355/2 * data.hRes, 1);
        if isempty(hBaseIndx355)
            warning('Warning in %s: Failure in searching the index of minHeight. Set the index of the minimum integral range to be 100', mfilename);
            hBaseIndx355 = 100;
        end
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig355 = sum(sig355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        refBg355 = sum(bg355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        refSig387 = sum(sig387(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        refBg387 = sum(bg387(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        snr355 = polly_SNR(refSig355, refBg355);
        snr387 = polly_SNR(refSig387, refBg387);
        
        if (snr387 >= config.minRamanRefSNR387) && (snr355 >= config.minRamanRefSNR355)
            tmpAerExt355_raman = thisAerExt355_raman;
            tmpAerExt355_raman(1:hBaseIndx355) = tmpAerExt355_raman(hBaseIndx355);
            [thisAerBsc355_raman, thisLR355_raman] = polly_raman_bsc(data.distance0, sig355, sig387, tmpAerExt355_raman, config.angstrexp, molExt355, molBsc355, refH, 355, config.refBeta355, config.smoothWin_raman_355, true);
            thisLR355_raman = thisAerExt355_raman ./ thisAerBsc355_raman;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc355_raman = cat(1, aerBsc355_raman, thisAerBsc355_raman);
    aerExt355_raman = cat(1, aerExt355_raman, thisAerExt355_raman);
    LR355_raman = cat(1, LR355_raman, thisLR355_raman);
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

%% 1064 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc1064_raman = NaN(size(data.height));
    thisAerExt1064_raman = NaN(size(data.height));
    thisLR1064_raman = NaN(size(data.height));

    flagChannel1064 = config.isFR & config.isTot & config.is1064nm;
    flagChannel607 = config.isFR & config.is607nm;
    % Only take into account of profiles with PMT on
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagCloudFree = false(size(data.mTime));
    flagCloudFree(proIndx) = true;
    proIndx_607On = flagCloudFree & (~ data.mask607Off);
    if sum(proIndx_607On) == 0
        warning('No Raman measurement during %s - %s', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'));

        % concatenate the results
        aerBsc1064_raman = cat(1, aerBsc1064_raman, thisAerBsc1064_raman);
        aerExt1064_raman = cat(1, aerExt1064_raman, thisAerExt1064_raman);
        LR1064_raman = cat(1, LR1064_raman, thisLR1064_raman);
        
        continue;
    end
    
    sig1064 = squeeze(sum(data.signal(flagChannel1064, :, proIndx_607On), 3));
    bg1064 = squeeze(sum(data.bg(flagChannel1064, :, proIndx_607On), 3));
    sig607 = squeeze(sum(data.signal(flagChannel607, :, proIndx_607On), 3));
    bg607 = squeeze(sum(data.bg(flagChannel607, :, proIndx_607On), 3));

    % retrieve extinction
    thisAerExt532_raman = polly_raman_ext(data.distance0, sig607, 532, 607, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, config.smoothWin_raman_1064, 380, 70, 'moving');
    
    if ~ isnan(data.refHIndx1064(iGroup, 1))
        refH = [data.distance0(data.refHIndx1064(iGroup, 1)), data.distance0(data.refHIndx1064(iGroup, 2))];
        hBaseIndx1064 = find(data.height >= config.heightFullOverlap(flagChannel1064) + config.smoothWin_raman_1064/2 * data.hRes, 1);
        if isempty(hBaseIndx1064)
            warning('Warning in %s: Failure in searching the index of minHeight. Set the index of the minimum integral range to be 100', mfilename);
            hBaseIndx1064 = 100;
        end
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig1064 = sum(sig1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        refBg1064 = sum(bg1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        refSig607 = sum(sig607(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        refBg607 = sum(bg607(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        snr1064 = polly_SNR(refSig1064, refBg1064);
        snr607 = polly_SNR(refSig607, refBg607);
        
        if (snr607 >= config.minRamanRefSNR607) && (snr1064 >= config.minRamanRefSNR1064)
            thisAerExt1064_raman = thisAerExt532_raman / (1064/532).^config.angstrexp;
            tmpAerExt1064_raman = thisAerExt1064_raman;
            tmpAerExt1064_raman(1:hBaseIndx1064) = tmpAerExt1064_raman(hBaseIndx1064);
            [thisAerBsc1064_raman, thisLR1064_raman] = polly_raman_bsc(data.distance0, sig1064, sig607, tmpAerExt1064_raman, config.angstrexp, molExt1064, molBsc1064, refH, 1064, config.refBeta1064, config.smoothWin_raman_1064, true);
            thisLR1064_raman = thisAerExt1064_raman ./ thisAerBsc1064_raman;
            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc1064_raman = cat(1, aerBsc1064_raman, thisAerBsc1064_raman);
    aerExt1064_raman = cat(1, aerExt1064_raman, thisAerExt1064_raman);
    LR1064_raman = cat(1, LR1064_raman, thisLR1064_raman);
end

end