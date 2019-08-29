function [aerBsc532_klett, aerExt532_klett] = polly_1v2_klett(data, config)
%polly_1v2_klett Retrieve aerosol optical properties with klett method
%   Example:
%       [aerBsc532_klett, aerExt532_klett] = polly_1v2_klett(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc532_klett: matrix
%           aerosol backscatter coefficient at 532 nm with klett method. [m^{-1}Sr^{-1}] 
%       aerExt532_klett: matrix
%           aerosol extinction coefficient at 355 nm with klett method. [m^{-1}] 
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

aerBsc532_klett = [];
aerExt532_klett = [];

if isempty(data.rawSignal);
    return;
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

        [thisAerBsc532_klett, ~] = polly_fernald(data.distance0, sig532, config.LR532, refH, config.refBeta532, molBsc532, config.smoothWin_klett_532);
        thisAerExt532_klett = config.LR532 * thisAerBsc532_klett;

        % TODO: uncertainty analysis
    end

    % concatenate the results
    aerBsc532_klett = cat(1, aerBsc532_klett, thisAerBsc532_klett);
    aerExt532_klett = cat(1, aerExt532_klett, thisAerExt532_klett);
end

end