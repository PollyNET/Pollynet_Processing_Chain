function [aerBsc355_raman, aerBsc532_raman, aerBsc1064_raman, aerExt355_raman, aerExt532_raman, aerExt1064_raman, LR355_raman, LR532_raman, LR1064_raman] = pollyxt_lacros_raman(data, config)
%pollyxt_lacros_raman Retrieve aerosol optical properties with raman method
%   Example:
%       [aerBsc355_raman, aerBsc532_raman, aerBsc1064_raman, aerExt355_raman, aerExt532_raman, aerExt1064_raman] = pollyxt_lacros_raman(data, config)
%   Inputs:
%		data: struct
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
        
        if ~ isnan(data.refHIndx355(iGroup, 1))
            flagChannel355 = config.isFR & config.isTot & config.is355nm;
            sig355 = transpose(squeeze(sum(data.el355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
            bg355 = transpose(squeeze(sum(data.bgEl355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
            refH = [data.distance0(data.refHIndx355(iGroup, 1)), data.distance0(data.refHIndx355(iGroup, 2))];
            [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            flagChannel387 = config.isFR & config.is387nm;
            sig387 = squeeze(sum(data.signal(flagChannel387, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refSig387 = sum(sig387(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
            bg387 = squeeze(sum(data.bg(flagChannel387, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refBg387 = sum(bg387(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
            snr387 = polly_SNR(refSig387, refBg387);
            
            if snr387 >= config.minRamanRefSNR387
                thisAerExt355_raman = polly_raman_ext(data.distance0, sig387, 355, 387, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :), config.smoothWin_raman_355, 380, 70, 'moving');
                [thisAerBsc355_raman, thisLR355_raman] = polly_raman_bsc(data.distance0, sig355, sig387, thisAerExt355_raman, config.angstrexp, molExt355, molBsc355, refH, 355, config.refBeta355, config.smoothWin_raman_355, false);
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
        
        if ~ isnan(data.refHIndx532(iGroup, 1))
            flagChannel532 = config.isFR & config.isTot & config.is532nm;
            sig532 = transpose(squeeze(sum(data.el532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
            bg532 = transpose(squeeze(sum(data.bgEl532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
            refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
            [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            flagChannel607 = config.isFR & config.is607nm;
            sig607 = squeeze(sum(data.signal(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refSig607 = sum(sig607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
            bg607 = squeeze(sum(data.bg(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refBg607 = sum(bg607(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
            snr607 = polly_SNR(refSig607, refBg607);
            
            if snr607 >= config.minRamanRefSNR607
                thisAerExt532_raman = polly_raman_ext(data.distance0, sig607, 532, 607, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :), config.smoothWin_raman_532, 380, 70, 'moving');
                [thisAerBsc532_raman, thisLR532_raman] = polly_raman_bsc(data.distance0, sig532, sig607, thisAerExt532_raman, config.angstrexp, molExt532, molBsc532, refH, 532, config.refBeta532, config.smoothWin_raman_532, false);
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
        
        if ~ isnan(data.refHIndx1064(iGroup, 1))
            flagChannel1064 = config.isFR & config.isTot & config.is1064nm;
            sig1064 = squeeze(sum(data.signal(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            bg1064 = squeeze(sum(data.bg(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refH = [data.distance0(data.refHIndx1064(iGroup, 1)), data.distance0(data.refHIndx1064(iGroup, 2))];
            [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            flagChannel607 = config.isFR & config.is607nm;
            sig607 = squeeze(sum(data.signal(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refSig607 = sum(sig607(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
            bg607 = squeeze(sum(data.bg(flagChannel607, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
            refBg607 = sum(bg607(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
            snr607 = polly_SNR(refSig607, refBg607);
            
            if snr607 >= config.minRamanRefSNR607
                thisAerExt532_raman = polly_raman_ext(data.distance0, sig607, 532, 607, config.angstrexp, data.pressure(iGroup, :), data.temperature(iGroup, :), config.smoothWin_raman_1064, 380, 70, 'moving');
                thisAerExt1064_raman = thisAerExt532_raman / (1064/532).^config.angstrexp;
                [thisAerBsc1064_raman, ~] = polly_raman_bsc(data.distance0, sig1064, sig607, thisAerExt1064_raman, config.angstrexp, molExt1064, molBsc1064, refH, 1064, config.refBeta1064, config.smoothWin_raman_1064, false);
                % TODO: uncertainty analysis
            end
        end
    
        % concatenate the results
        aerBsc1064_raman = cat(1, aerBsc1064_raman, thisAerBsc1064_raman);
        aerExt1064_raman = cat(1, aerExt1064_raman, thisAerExt1064_raman);
        LR1064_raman = cat(1, LR1064_raman, thisLR1064_raman);
    end

end