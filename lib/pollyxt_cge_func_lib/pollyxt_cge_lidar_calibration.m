function [LC] = pollyxt_cge_lidar_calibration(data, config)
%pollyxt_cge_lidar_calibration calibrate the lidar system
%   Example:
%       [LC] = pollyxt_cge_lidar_calibration(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       LC: struct
%           LC_klett_355: array
%               lidar calibration constants for 30s profile.
%           LC_klett_532: array
%               lidar calibration constants for 30s profile.
%           LC_klett_1064: array
%               lidar calibration constants for 30s profile.
%           LC_raman_355: array
%               lidar calibration constants for 30s profile.
%           LC_raman_532: array
%               lidar calibration constants for 30s profile.
%           LC_raman_1064: array
%               lidar calibration constants for 30s profile.
%           LC_aeronet_355: array
%               lidar calibration constants for 30s profile.
%           LC_aeronet_532: array
%               lidar calibration constants for 30s profile.
%           LC_aeronet_1064: array
%               lidar calibration constants for 30s profile.
%           LC_raman_387: array
%               lidar calibration constants for 30s profile.
%           LC_raman_607: array
%               lidar calibration constants for 30s profile.
%   History:
%       2018-12-24. First Edition by Zhenping
%       2019-01-28. Add calibration for Raman channels.
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
LC.LC_raman_607 = [];
LC.LC_raman_387 = [];

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel607 = config.isFR & config.is607nm;
flagChannel387 = config.isFR & config.is387nm;

% index of full overlap adding half of the smoothing window for klett method
hIndxFullOverlap355 = find(data.height >= config.heightFullOverlap(flagChannel355), 1);
hIndxFullOverlap532 = find(data.height >= config.heightFullOverlap(flagChannel532), 1);
hIndxFullOverlap1064 = find(data.height >= config.heightFullOverlap(flagChannel1064), 1);
if isempty(hIndxFullOverlap355)
    fprintf('Failure in searching the index of full overlap at %s. Set it to be .\nheightFullOverlap: %f\n', config.channelTag(flagChannel355), config.heightFullOverlap(flagChannel355));
    hIndxFullOverlap355 = 70;
end
if isempty(hIndxFullOverlap532)
    fprintf('Failure in searching the index of full overlap at %s. Set it to be .\nheightFullOverlap: %f\n', config.channelTag(flagChannel532), config.heightFullOverlap(flagChannel532));
    hIndxFullOverlap532 = 70;
end
if isempty(hIndxFullOverlap1064)
    fprintf('Failure in searching the index of full overlap at %s. Set it to be .\nheightFullOverlap: %f\n', config.channelTag(flagChannel1064), config.heightFullOverlap(flagChannel1064));
    hIndxFullOverlap1064 = 70;
end
hIndxBaseKlett355 = hIndxFullOverlap355 + ceil(config.smoothWin_klett_355/2);
hIndxBaseKlett532 = hIndxFullOverlap532 + ceil(config.smoothWin_klett_532/2);
hIndxBaseKlett1064 = hIndxFullOverlap1064 + ceil(config.smoothWin_klett_1064/2);
hIndxBaseRaman355 = hIndxFullOverlap355 + ceil(config.smoothWin_raman_355/2);
hIndxBaseRaman532 = hIndxFullOverlap532 + ceil(config.smoothWin_raman_532/2);
hIndxBaseRaman1064 = hIndxFullOverlap1064 + ceil(config.smoothWin_raman_1064/2);
hIndxBaseAERONET355 = hIndxBaseKlett355;
hIndxBaseAERONET532 = hIndxBaseKlett532;
hIndxBaseAERONET1064 = hIndxBaseKlett1064;

%% calibrate with klett-retrieved profiles
for iGroup = 1:size(data.cloudFreeGroups, 1)
    LC_klett_355 = NaN;
    LC_klett_532 = NaN;
    LC_klett_1064 = NaN;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    nPros = numel(proIndx);

    % 355 nm
    if ~ isnan(data.aerBsc355_klett(iGroup, 80))
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig355 = squeeze(sum(data.signal(flagChannel355, :, proIndx), 3)) / nPros;

        % AOD
        aerExt355_klett = data.aerExt355_klett(iGroup, :);
        aerExt355_klett(1:hIndxBaseKlett355) = aerExt355_klett(hIndxBaseKlett355);
        aerBsc355_klett = data.aerBsc355_klett(iGroup, :);
        aerAOD355 = nancumsum(aerExt355_klett .* [data.distance0(1), diff(data.distance0)]);
        molAOD355 = nancumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aerAOD355 + molAOD355));
        totBsc355 = molBsc355 + aerBsc355_klett;

        % lidar calibration
        LC_klett_355_Profile = sig355 .* data.distance0.^2 ./ totBsc355 ./ trans355;
        [LC_klett_355, ~] = mean_stable(LC_klett_355_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end

    % concatenate the results
    LC.LC_klett_355 = cat(1, LC.LC_klett_355, LC_klett_355);

    % 532 nm
    if ~ isnan(data.aerBsc532_klett(iGroup, 80))
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig532 = squeeze(sum(data.signal(flagChannel532, :, proIndx), 3)) / nPros;

        % AOD
        aerExt532_klett = data.aerExt532_klett(iGroup, :);
        aerExt532_klett(1:hIndxBaseKlett532) = aerExt532_klett(hIndxBaseKlett532);
        aerBsc532_klett = data.aerBsc532_klett(iGroup, :);
        aerAOD532 = nancumsum(aerExt532_klett .* [data.distance0(1), diff(data.distance0)]);
        molAOD532 = nancumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aerAOD532 + molAOD532));
        totBsc532 = molBsc532 + aerBsc532_klett;

        % lidar calibration
        LC_klett_532_Profile = sig532 .* data.distance0.^2 ./ totBsc532 ./ trans532;
        [LC_klett_532, ~] = mean_stable(LC_klett_532_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_klett_532 = cat(1, LC.LC_klett_532, LC_klett_532);

    % 1064 nm
    if ~ isnan(data.aerBsc1064_klett(iGroup, 80))
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig1064 = squeeze(sum(data.signal(flagChannel1064, :, proIndx), 3)) / nPros;

        % AOD
        aerExt1064_klett = data.aerExt1064_klett(iGroup, :);
        aerExt1064_klett(1:hIndxBaseKlett1064) = aerExt1064_klett(hIndxBaseKlett1064);
        aerBsc1064_klett = data.aerBsc1064_klett(iGroup, :);
        aerAOD1064 = nancumsum(aerExt1064_klett .* [data.distance0(1), diff(data.distance0)]);
        molAOD1064 = nancumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aerAOD1064 + molAOD1064));
        totBsc1064 = molBsc1064 + aerBsc1064_klett;

        % lidar calibration
        LC_klett_1064_Profile = sig1064 .* data.distance0.^2 ./ totBsc1064 ./ trans1064;
        [LC_klett_1064, ~] = mean_stable(LC_klett_1064_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_klett_1064 = cat(1, LC.LC_klett_1064, LC_klett_1064);
end
    
%% calibrate with raman-retrieved profiles
for iGroup = 1:size(data.cloudFreeGroups, 1)
    LC_raman_355 = NaN;
    LC_raman_532 = NaN;
    LC_raman_1064 = NaN;
    LC_raman_387 = NaN;
    LC_raman_607 = NaN;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    nPros = numel(proIndx);

    % 355 nm
    if ~ isnan(data.aerBsc355_raman(iGroup, 80))
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % Only take into account of profiles with PMT on
        flagCloudFree = false(size(data.mTime));
        flagCloudFree(proIndx) = true;
        proIndx_387On = flagCloudFree & (~ data.mask387Off);
        sig355 = squeeze(sum(data.signal(flagChannel355, :, proIndx_387On), 3)) / sum(proIndx_387On);

        % AOD
        aerExt355_raman = data.aerBsc355_raman(iGroup, :) * config.LR355;
        % aerExt355_raman(1:hIndxBaseRaman355) = aerExt355_raman(hIndxBaseRaman355);
        aerBsc355_raman = data.aerBsc355_raman(iGroup, :);
        aerAOD355 = nancumsum(aerExt355_raman .* [data.distance0(1), diff(data.distance0)]);
        molAOD355 = nancumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aerAOD355 + molAOD355));
        totBsc355 = molBsc355 + aerBsc355_raman;

        % lidar calibration
        LC_raman_355_Profile = sig355 .* data.distance0.^2 ./ totBsc355 ./ trans355;
        [LC_raman_355, ~] = mean_stable(LC_raman_355_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_raman_355 = cat(1, LC.LC_raman_355, LC_raman_355);

    % 532 nm
    if ~ isnan(data.aerBsc532_raman(iGroup, 80))
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % Only take into account of profiles with PMT on
        flagCloudFree = false(size(data.mTime));
        flagCloudFree(proIndx) = true;
        proIndx_607On = flagCloudFree & (~ data.mask607Off);
        sig532 = squeeze(sum(data.signal(flagChannel532, :, proIndx_607On), 3)) / sum(proIndx_607On);

        % AOD
        aerExt532_raman = data.aerBsc532_raman(iGroup, :) * config.LR532;
        % aerExt532_raman(1:hIndxBaseRaman532) = aerExt532_raman(hIndxBaseRaman532);
        aerBsc532_raman = data.aerBsc532_raman(iGroup, :);
        aerAOD532 = nancumsum(aerExt532_raman .* [data.distance0(1), diff(data.distance0)]);
        molAOD532 = nancumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aerAOD532 + molAOD532));
        totBsc532 = molBsc532 + aerBsc532_raman;

        % lidar calibration
        LC_raman_532_Profile = sig532 .* data.distance0.^2 ./ totBsc532 ./ trans532;
        [LC_raman_532, ~] = mean_stable(LC_raman_532_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_raman_532 = cat(1, LC.LC_raman_532, LC_raman_532);

    % 1064 nm
    if ~ isnan(data.aerBsc1064_raman(iGroup, 80))
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % Only take into account of profiles with PMT on
        flagCloudFree = false(size(data.mTime));
        flagCloudFree(proIndx) = true;
        proIndx_607On = flagCloudFree & (~ data.mask607Off);
        sig1064 = squeeze(sum(data.signal(flagChannel1064, :, proIndx_607On), 3)) / sum(proIndx_607On);

        % AOD
        aerExt1064_raman = data.aerBsc1064_raman(iGroup, :) * config.LR1064;
        % aerExt1064_raman(1:hIndxBaseRaman1064) = aerExt1064_raman(hIndxBaseRaman1064);
        aerBsc1064_raman = data.aerBsc1064_raman(iGroup, :);
        aerAOD1064 = nancumsum(aerExt1064_raman .* [data.distance0(1), diff(data.distance0)]);
        molAOD1064 = nancumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aerAOD1064 + molAOD1064));
        totBsc1064 = molBsc1064 + aerBsc1064_raman;

        % lidar calibration
        LC_raman_1064_Profile = sig1064 .* data.distance0.^2 ./ totBsc1064 ./ trans1064;
        [LC_raman_1064, ~] = mean_stable(LC_raman_1064_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_raman_1064 = cat(1, LC.LC_raman_1064, LC_raman_1064);

    % 387 nm
    if ~ isnan(data.aerBsc355_raman(iGroup, 80))
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [molBsc387, molExt387] = rayleigh_scattering(387, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    
        % Only take into account of profiles with PMT on
        flagCloudFree = false(size(data.mTime));
        flagCloudFree(proIndx) = true;
        proIndx_387On = flagCloudFree & (~ data.mask387Off);
        sig387 = squeeze(sum(data.signal(flagChannel387, :, proIndx_387On), 3)) / sum(proIndx_387On);
    
        % AOD
        aerExt355_raman = data.aerBsc355_raman(iGroup, :) * config.LR355;
        aerExt387_raman = aerExt355_raman * (355/387) .^ config.angstrexp;
        aerAOD355 = nancumsum(aerExt355_raman .* [data.distance0(1), diff(data.distance0)]);
        aerAOD387 = nancumsum(aerExt387_raman .* [data.distance0(1), diff(data.distance0)]);
        molAOD355 = nancumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]);
        molAOD387 = nancumsum(molExt387 .* [data.distance0(1), diff(data.distance0)]);
    
        % round-trip transmission
        trans_355_387 = exp(- (aerAOD355 + molAOD355 + aerAOD387 + molAOD387));
        totBsc355 = molBsc355;
    
        % lidar calibration
        LC_raman_387_Profile = transpose(smooth(sig387 .* data.distance0.^2, config.smoothWin_raman_355)) ./ totBsc355 ./ trans_355_387;
        [LC_raman_387, ~] = mean_stable(LC_raman_387_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);
    
    end
    
    % concatenate the results
    LC.LC_raman_387 = cat(1, LC.LC_raman_387, LC_raman_387);
    
    % 607 nm
    if ~ isnan(data.aerBsc532_raman(iGroup, 80))
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [molBsc607, molExt607] = rayleigh_scattering(607, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    
        % Only take into account of profiles with PMT on
        flagCloudFree = false(size(data.mTime));
        flagCloudFree(proIndx) = true;
        proIndx_607On = flagCloudFree & (~ data.mask607Off);
        sig607 = squeeze(sum(data.signal(flagChannel607, :, proIndx_607On), 3)) / sum(proIndx_607On);
    
        % AOD
        aerExt532_raman = data.aerBsc532_raman(iGroup, :) * config.LR532;
        aerExt607_raman = aerExt532_raman * (532/607) .^ config.angstrexp;
        aerAOD532 = nancumsum(aerExt532_raman .* [data.distance0(1), diff(data.distance0)]);
        aerAOD607 = nancumsum(aerExt607_raman .* [data.distance0(1), diff(data.distance0)]);
        molAOD532 = nancumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]);
        molAOD607 = nancumsum(molExt607 .* [data.distance0(1), diff(data.distance0)]);
    
        % round-trip transmission
        trans_532_607 = exp(- (aerAOD532 + molAOD532 + aerAOD607 + molAOD607));
        totBsc532 = molBsc532;
    
        % lidar calibration
        LC_raman_607_Profile = transpose(smooth(sig607 .* data.distance0.^2, config.smoothWin_raman_532)) ./ totBsc532 ./ trans_532_607;
        [LC_raman_607, ~] = mean_stable(LC_raman_607_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);
    
    end
    
    % concatenate the results
    LC.LC_raman_607 = cat(1, LC.LC_raman_607, LC_raman_607);
end

        
%% calibrate with constrained-AOD-retrieved profiles
for iGroup = 1:size(data.cloudFreeGroups, 1)
    LC_aeronet_355 = NaN;
    LC_aeronet_532 = NaN;
    LC_aeronet_1064 = NaN;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    nPros = numel(proIndx);

    % 355 nm
    if ~ isnan(data.aerBsc355_aeronet(iGroup, 80))
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig355 = squeeze(sum(data.signal(flagChannel355, :, proIndx), 3)) / nPros;

        % AOD
        aerExt355_aeronet = data.aerExt355_aeronet(iGroup, :);
        aerExt355_aeronet(1:hIndxBaseAERONET355) = aerExt355_aeronet(hIndxBaseAERONET355);
        aerBsc355_aeronet = data.aerBsc355_aeronet(iGroup, :);
        aerAOD355 = nancumsum(aerExt355_aeronet .* [data.distance0(1), diff(data.distance0)]);
        molAOD355 = nancumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans355 = exp(-2 * (aerAOD355 + molAOD355));
        totBsc355 = molBsc355 + aerBsc355_aeronet;

        % lidar calibration
        LC_aeronet_355_Profile = sig355 .* data.distance0.^2 ./ totBsc355 ./ trans355;
        [LC_aeronet_355, ~] = mean_stable(LC_aeronet_355_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_aeronet_355 = cat(1, LC.LC_aeronet_355, LC_aeronet_355);

    % 532 nm
    if ~ isnan(data.aerBsc532_aeronet(iGroup, 80))
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig532 = squeeze(sum(data.signal(flagChannel532, :, proIndx), 3)) / nPros;

        % AOD
        aerExt532_aeronet = data.aerExt532_aeronet(iGroup, :);
        aerExt532_aeronet(1:hIndxBaseAERONET532) = aerExt532_aeronet(hIndxBaseAERONET532);
        aerBsc532_aeronet = data.aerBsc532_aeronet(iGroup, :);
        aerAOD532 = nancumsum(aerExt532_aeronet .* [data.distance0(1), diff(data.distance0)]);
        molAOD532 = nancumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans532 = exp(-2 * (aerAOD532 + molAOD532));
        totBsc532 = molBsc532 + aerBsc532_aeronet;

        % lidar calibration
        LC_aeronet_532_Profile = sig532 .* data.distance0.^2 ./ totBsc532 ./ trans532;
        [LC_aeronet_532, ~] = mean_stable(LC_aeronet_532_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_aeronet_532 = cat(1, LC.LC_aeronet_532, LC_aeronet_532);

    % 1064 nm
    if ~ isnan(data.aerBsc1064_aeronet(iGroup, 80))
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        sig1064 = squeeze(sum(data.signal(flagChannel1064, :, proIndx), 3)) / nPros;

        % AOD
        aerExt1064_aeronet = data.aerExt1064_aeronet(iGroup, :);
        aerExt1064_aeronet(1:hIndxBaseAERONET1064) = aerExt1064_aeronet(hIndxBaseAERONET1064);
        aerBsc1064_aeronet = data.aerBsc1064_aeronet(iGroup, :);
        aerAOD1064 = nancumsum(aerExt1064_aeronet .* [data.distance0(1), diff(data.distance0)]);
        molAOD1064 = nancumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]);

        % round-trip transmission
        trans1064 = exp(-2 * (aerAOD1064 + molAOD1064));
        totBsc1064 = molBsc1064 + aerBsc1064_aeronet;

        % lidar calibration
        LC_aeronet_1064_Profile = sig1064 .* data.distance0.^2 ./ totBsc1064 ./ trans1064;
        [LC_aeronet_1064, ~] = mean_stable(LC_aeronet_1064_Profile, config.LCMeanWindow, config.LCMeanMinIndx, config.LCMeanMaxIndx);

    end
    
    % concatenate the results
    LC.LC_aeronet_1064 = cat(1, LC.LC_aeronet_1064, LC_aeronet_1064);
    
end

end