function [aerBsc355_klett, aerBsc532_klett, aerBsc1064_klett, aerExt355_klett, aerExt532_klett, aerExt1064_klett] = pollyxt_lacros_klett(data, config)
%pollyxt_lacros_klett Retrieve aerosol optical properties with klett method
%   Example:
%       [aerBsc355_klett, aerBsc532_klett, aerBsc1064_klett, aerExt355_klett, aerExt532_klett, aerExt1064_klett] = pollyxt_lacros_klett(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc355_klett: matrix
%           aerosol backscatter coefficient at 355 nm with klett method. [m^{-1}Sr^{-1}] 
%       aerBsc532_klett: matrix
%           aerosol backscatter coefficient at 532 nm with klett method. [m^{-1}Sr^{-1}] 
%       aerBsc1064_klett: matrix
%           aerosol backscatter coefficient at 1064 nm with klett method. [m^{-1}Sr^{-1}] 
%       aerExt355_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}]
%       aerExt532_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}] 
%       aerExt1064_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}]
%   History:
%       2018-12-23. First Edition by Zhenping
%       2019-08-31. Add SNR control for the reference height.
%   Contact:
%       zhenping@tropos.de

aerBsc355_klett = [];
aerBsc532_klett = [];
aerBsc1064_klett = [];
aerExt355_klett = [];
aerExt532_klett = [];
aerExt1064_klett = [];

if isempty(data.rawSignal)
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc355_klett = NaN(size(data.height));
    thisAerExt355_klett = NaN(size(data.height));

    if ~ isnan(data.refHIndx355(iGroup, 1))
        flagChannel355 = config.isFR & config.isTot & config.is355nm;
        sig355 = transpose(squeeze(sum(data.el355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
        bg355 = transpose(squeeze(sum(data.bgEl355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
        refH = [data.distance0(data.refHIndx355(iGroup, 1)), data.distance0(data.refHIndx355(iGroup, 2))];
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig355 = sum(sig355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        refBg355 = sum(bg355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        snr355 = polly_SNR(refSig355, refBg355);

        if (snr355 >= config.minRefSNR355)
            % if the SNR at the reference height is large enough
            [thisAerBsc355_klett, ~] = polly_fernald(data.distance0, sig355, config.LR355, refH, config.refBeta355, molBsc355, config.smoothWin_klett_355);
            thisAerExt355_klett = config.LR355 * thisAerBsc355_klett;
        end

        % TODO: uncertainty analysis
    end

    % concatenate the results
    aerBsc355_klett = cat(1, aerBsc355_klett, thisAerBsc355_klett);
    aerExt355_klett = cat(1, aerExt355_klett, thisAerExt355_klett);
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_klett = NaN(size(data.height));
    thisAerExt532_klett = NaN(size(data.height));

    if ~ isnan(data.refHIndx532(iGroup, 1))
        flagChannel532 = config.isFR & config.isTot & config.is532nm;
        sig532 = transpose(squeeze(sum(data.el532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
        bg532 = transpose(squeeze(sum(data.bgEl532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2)));
        refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig532 = sum(sig532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg532 = sum(bg532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        snr532 = polly_SNR(refSig532, refBg532);

        if (snr532 >= config.minRefSNR532)
            [thisAerBsc532_klett, ~] = polly_fernald(data.distance0, sig532, config.LR532, refH, config.refBeta532, molBsc532, config.smoothWin_klett_532);
            thisAerExt532_klett = config.LR532 * thisAerBsc532_klett;
        end

        % TODO: uncertainty analysis
    end

    % concatenate the results
    aerBsc532_klett = cat(1, aerBsc532_klett, thisAerBsc532_klett);
    aerExt532_klett = cat(1, aerExt532_klett, thisAerExt532_klett);
end

%% 1064 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc1064_klett = NaN(size(data.height));
    thisAerExt1064_klett = NaN(size(data.height));

    if ~ isnan(data.refHIndx1064(iGroup, 1))
        flagChannel1064 = config.isFR & config.isTot & config.is1064nm;
        sig1064 = squeeze(sum(data.signal(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg1064 = squeeze(sum(data.bg(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        refH = [data.distance0(data.refHIndx1064(iGroup, 1)), data.distance0(data.refHIndx1064(iGroup, 2))];
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        refSig1064 = sum(sig1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        refBg1064 = sum(bg1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        snr1064 = polly_SNR(refSig1064, refBg1064);

        if (snr1064 >= config.minRefSNR1064)
            [thisAerBsc1064_klett, ~] = polly_fernald(data.distance0, sig1064, config.LR1064, refH, config.refBeta1064, molBsc1064, config.smoothWin_klett_1064);
            thisAerExt1064_klett = config.LR1064 * thisAerBsc1064_klett;
        end

        % TODO: uncertainty analysis
    end

    % concatenate the results
    aerBsc1064_klett = cat(1, aerBsc1064_klett, thisAerBsc1064_klett);
    aerExt1064_klett = cat(1, aerExt1064_klett, thisAerExt1064_klett);
end

end