function [aerBsc355_NR_klett, aerBsc532_NR_klett, aerExt355_NR_klett, aerExt532_NR_klett, refBeta_NR_355_klett, refBeta_NR_532_klett] = pollyxt_lacros_NR_klett(data, config)
%pollyxt_lacros_NR_klett Retrieve aerosol optical properties from NR channels with klett method
%   Example:
%       [aerBsc355_NR_klett, aerBsc532_NR_klett, aerExt355_NR_klett, aerExt532_NR_klett, refBeta_NR_355_klett, refBeta_NR_532_klett] = pollyxt_lacros_NR_klett(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc355_NR_klett: matrix
%           aerosol backscatter coefficient at 355 nm with klett method. [m^{-1}*sr^{-1}] 
%       aerBsc532_NR_klett: matrix
%           aerosol backscatter coefficient at 532 nm with klett method. [m^{-1}*sr^{-1}] 
%       aerExt355_NR_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}]
%       aerExt532_NR_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}] 
%       refBeta_NR_355_klett: array
%           reference value for retrieving the NR aerosol backscatter at 355 nm. [m^{-1}*sr^{-1}]
%       refBeta_NR_532_klett: array
%           reference value for retrieving the NR aerosol backscatter at 532 nm. [m^{-1}*sr^{-1}]
%   History:
%       2019-08-05. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

aerBsc355_NR_klett = [];
aerBsc532_NR_klett = [];
aerExt355_NR_klett = [];
aerExt532_NR_klett = [];
refBeta_NR_355_klett = [];
refBeta_NR_532_klett = [];

if isempty(data.rawSignal);
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc355_NR_klett = NaN(size(data.height));
    thisAerExt355_NR_klett = NaN(size(data.height));
    flagRefSNRLow_355 = false;
    refBeta355 = NaN;

    if ~ isnan(data.refHIndx355(iGroup, 1))
        flagChannel355_NR = config.isNR & config.isTot & config.is355nm;
        sig355 = squeeze(sum(data.signal(flagChannel355_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg355 = squeeze(sum(data.bg(flagChannel355_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        refH355 = config.refH_NR_355;
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the index for the reference height
        if ((refH355(1) < data.height(1)) || (refH355(1) > data.height(end))) || ((refH355(2) < data.height(1)) || (refH355(2) > data.height(end)))
            warning('refH_NR_355 (%f - %f m) in the polly configu file is out of range.', refH355(1), refH355(2));
            warning('Set refH_NR_355 to [2500 - 3000 m]');
            refH355 = [2500, 3000];
        end
        refHTopIndx355 = find(data.height <= refH355(2), 1, 'last');
        refHBottomIndx355 = find(data.height >= refH355(1), 1, 'first');

        % criteria on the SNR at the reference height
        SNR_refH = polly_SNR(sum(sig355(refHBottomIndx355:refHTopIndx355)), sum(bg355(refHBottomIndx355:refHTopIndx355)));
        if SNR_refH < config.minRefSNR_NR_355
            warning('355 nm Near-range signal is too noisy at the reference height [%f - %f m].', refH355(1), refH355(2));
            flagRefSNRLow_355 = true;
        end

        % retrieve the reference value from the far-range retrieving results
        refBeta355 = mean(data.aerBsc355_klett(iGroup, refHBottomIndx355:refHTopIndx355), 2);

        if (~ flagRefSNRLow_355) && (~ isnan(refBeta355))
            [thisAerBsc355_NR_klett, ~] = polly_fernald(data.distance0, sig355, config.LR_NR_355, refH355, refBeta355, molBsc355, config.smoothWin_klett_NR_355);
            thisAerExt355_NR_klett = config.LR_NR_355 * thisAerBsc355_NR_klett;

            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc355_NR_klett = cat(1, aerBsc355_NR_klett, thisAerBsc355_NR_klett);
    aerExt355_NR_klett = cat(1, aerExt355_NR_klett, thisAerExt355_NR_klett);
    refBeta_NR_355_klett = [refBeta_NR_355_klett, refBeta355];
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_NR_klett = NaN(size(data.height));
    thisAerExt532_NR_klett = NaN(size(data.height));
    flagRefSNRLow_532 = false;
    refBeta532 = NaN;

    if ~ isnan(data.refHIndx532(iGroup, 1))
        flagChannel532_NR = config.isNR & config.isTot & config.is532nm;
        sig532 = squeeze(sum(data.signal(flagChannel532_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg532 = squeeze(sum(data.bg(flagChannel532_NR, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        refH532 = config.refH_NR_532;
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
        SNR_refH = polly_SNR(sum(sig532(refHBottomIndx532:refHTopIndx532)), sum(bg532(refHBottomIndx532:refHTopIndx532)));
        if SNR_refH < config.minRefSNR_NR_532
            warning('532 nm Near-range signal is too noisy at the reference height [%f - %f m].', refH532(1), refH532(2));
            flagRefSNRLow_532 = true;
        end

        % retrieve the reference value from the far-range retrieving results
        refBeta532 = mean(data.aerBsc532_klett(iGroup, refHBottomIndx532:refHTopIndx532), 2);

        if (~ flagRefSNRLow_532) && (~ isnan(refBeta532))
            [thisAerBsc532_NR_klett, ~] = polly_fernald(data.distance0, sig532, config.LR_NR_532, refH532, refBeta532, molBsc532, config.smoothWin_klett_NR_532);
            thisAerExt532_NR_klett = config.LR_NR_532 * thisAerBsc532_NR_klett;

            % TODO: uncertainty analysis
        end
    end

    % concatenate the results
    aerBsc532_NR_klett = cat(1, aerBsc532_NR_klett, thisAerBsc532_NR_klett);
    aerExt532_NR_klett = cat(1, aerExt532_NR_klett, thisAerExt532_NR_klett);
    refBeta_NR_532_klett = [refBeta_NR_532_klett, refBeta532];
end

end