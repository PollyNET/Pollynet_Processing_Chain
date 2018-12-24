function [LC] = pollyxt_dwd_wv_calibration(data, config)
%pollyxt_dwd_wv_calibration calibrate the lidar system
%   Example:
%       [LC] = pollyxt_dwd_wv_calibration(data, config)
%   Inputs:
%       data, config
%   Outputs:
%       LC
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

LC = struct();
LC.LC_klett_355 = [];
LC.LC_klett_532 = [];
LC.LC_klett_1064 = [];
LC.LC_raman_355 = [];
LC.LC_raman_532 = [];
LC.LC_raman_1064 = [];
LC.LC_aeronet_355 = [];
LC.LC_aeronet_532 = [];
LC.LC_aeronet_1064 = [];

%% calibrate with klett-retrieved profiles
for iGroup = 1:size(data.cloudFreeGroups, 1)
    LC_klett_355 = NaN;
    LC_klett_532 = NaN;
    LC_klett_1064 = NaN;

    flagChannel355 = config.isFR & config.is355nm & config.isTot;
    flagChannel532 = config.isFR & config.is532nm & config.isTot;
    flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    nPros = numel(proIndx);

    % index of full overlap adding half of the smoothing window
    hIndxFullOverlap = find(data.height >= config.heightFullOverlap, 1);
    if isempty(hIndxFullOverlap)
        fprintf('Failure in searching the index of full overlap. Set it to be .\nheightFullOverlap: %f\n', config.heightFullOverlap);
        hIndxFullOverlap = 70;
    end
    hIndxBase = 

    % 355 nm
    if ~ isnan(data.aerBsc355_klett(iGroup, 80))
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig355 = squeeze(sum(data.signal(flagChannel355, :, proIndx), 3)) / nPros;

        % AOD
        aerExt355_klett = data.aerExt355_klett(iGroup, :);
        aerAOD = nancumsum(data.aerExt355_klett(iGroup, :))
    end
end

end