function [aerBsc355_aeronet, aerBsc532_aeronet, aerBsc1064_aeronet, aerExt355_aeronet, aerExt532_aeronet, aerExt1064_aeronet, LR355_aeronet, LR532_aeronet, LR1064_aeronet, deltaAOD355, deltaAOD532, deltaAOD1064] = pollyxt_tropos_constrainedklett(data, AERONET, config)
%pollyxt_tropos_constrainedklett Retrieve the aerosol optical properties with the constrains from AERONET.
%   Example:
%       [aerBsc355_aeronet, aerBsc532_aeronet, aerBsc1064_aeronet, aerExt355_aeronet, aerExt532_aeronet, aerExt1064_aeronet, LR355_aeronet, LR532_aeronet, LR1064_aeronet] = pollyxt_tropos_constrainedklett(data, AERONET, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       AERONET: struct
%          datetime: array
%              time of each measurment point.
%          AOD_{wavelength}: array
%              AOD at wavelength.
%          wavelength: array
%              wavelength of each channel. [nm]
%          IWV: array
%              Integrated Water Vapor. [cm] 
%          angstrexp440_870: array
%              angstroem exponent 440-870 nm
%          AERONETAttri: struct     
%              URL: char
%                  URL to retrieve the data.
%              level: char
%                  product level. ('10', '15', '20')
%              status: logical
%                  status to show whether retrieve the data successfully.
%              IWVUnit: char
%                  unit of integrated water vapor. [cm]
%              location: char
%                  AERONET site
%              PI: char
%                  PI of the current AERONET site.
%              contact: char
%                  email of the PI.
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       aerBsc355_aeronet: matrix
%           aerosol backscatter coefficient at 355 nm. [m^{-1}Sr^{-1}] 
%       aerBsc532_aeronet: matrix
%           aerosol backscatter coefficient at 532 nm. [m^{-1}Sr^{-1}]  
%       aerBsc1064_aeronet: matrix
%           aerosol backscatter coefficient at 1064 nm. [m^{-1}Sr^{-1}] 
%       aerExt355_aeronet: matrix
%           aerosol extinction coefficient at 355 nm. [m^{-1}] 
%       aerExt532_aeronet: matrix
%           aerosol extinction coefficient at 532 nm. [m^{-1}] 
%       aerExt1064_aeronet: matrix
%           aerosol extinction coefficient at 1064 nm. [m^{-1}]  
%       LR355_aeronet: array
%           lidar ration at 355 nm. [Sr] 
%       LR532_aeronet: array
%           lidar ration at 532 nm. [Sr]  
%       LR1064_aeronet: array
%           lidar ration at 1064 nm. [Sr]
%       deltaAOD355: array
%           the minimum deviation between lidar retrieved AOD and AEROENT AOD. 
%       deltaAOD532: array
%           the minimum deviation between lidar retrieved AOD and AEROENT AOD. 
%       deltaAOD1064: array
%           the minimum deviation between lidar retrieved AOD and AEROENT AOD. 
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

aerBsc355_aeronet = [];
aerBsc532_aeronet = [];
aerBsc1064_aeronet = [];
aerExt355_aeronet = [];
aerExt532_aeronet = [];
aerExt1064_aeronet = [];
LR355_aeronet = [];
LR532_aeronet = [];
LR1064_aeronet = [];
deltaAOD355 = [];
deltaAOD532 = [];
deltaAOD1064 = [];

if isempty(data.rawSignal)
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc355_aeronet = NaN(size(data.height));
    thisAerExt355_aeronet = NaN(size(data.height));
    thisLR_355 = NaN;
    thisDeltaAOD355 = NaN;
    thisNIters355 = NaN;

    if ~ isnan(data.refHIndx355(iGroup, 1))
        flagChannel355 = config.isFR & config.isTot & config.is355nm;
        sig355 = squeeze(sum(data.el355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        bg355 = squeeze(sum(data.bgEl355(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        snr355 = polly_SNR(sig355, bg355);
        refH = [data.distance0(data.refHIndx355(iGroup, 1)), data.distance0(data.refHIndx355(iGroup, 2))];
        [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the closest AERONET AOD
        AERONETIndx = search_close_AERONET_AOD(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), AERONET.datetime, datenum(0,1,0,2,0,0));
        if ~ isempty(AERONETIndx)
            AOD_355_aeronet = interp_AERONET_AOD(340, AERONET.AOD_340(AERONETIndx), 380, AERONET.AOD_380(AERONETIndx), 355);

            % constrained klett method
            [thisAerBsc355_aeronet, thisLR_355, thisDeltaAOD355, thisNIters355] = polly_constrainedfernald(data.distance0, sig355, snr355, refH, config.refBeta355, molBsc355, config.maxIterConstrainFernald, config.minLRConstrainFernald, config.maxLRConstrainFernald, AOD_355_aeronet, config.minDeltaAOD, config.heightFullOverlap(flagChannel355), config.mask_SNRmin(flagChannel355), config.smoothWin_klett_355);
            thisAerExt355_aeronet = thisAerBsc355_aeronet * thisLR_355;
        end
    end
    
    % concatenate the results
    aerBsc355_aeronet = cat(1, aerBsc355_aeronet, thisAerBsc355_aeronet);
    aerExt355_aeronet = cat(1, aerExt355_aeronet, thisAerExt355_aeronet);
    LR355_aeronet = cat(1, LR355_aeronet, thisLR_355);
    deltaAOD355 = cat(1, deltaAOD355, thisDeltaAOD355);
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_aeronet = NaN(size(data.height));
    thisAerExt532_aeronet = NaN(size(data.height));
    thisLR_532 = NaN;
    thisDeltaAOD532 = NaN;
    thisNIters532 = NaN;

    if ~ isnan(data.refHIndx532(iGroup, 1))
        flagChannel532 = config.isFR & config.isTot & config.is532nm;
        sig532 = squeeze(sum(data.el532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        bg532 = squeeze(sum(data.bgEl532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        snr532 = polly_SNR(sig532, bg532);
        refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
        [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the closest AERONET AOD
        AERONETIndx = search_close_AERONET_AOD(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), AERONET.datetime, datenum(0,1,0,2,0,0));
        if ~ isempty(AERONETIndx)
            AOD_532_aeronet = interp_AERONET_AOD(500, AERONET.AOD_500(AERONETIndx), 675, AERONET.AOD_675(AERONETIndx), 532);

            % constrained klett method
            [thisAerBsc532_aeronet, thisLR_532, thisDeltaAOD532, thisNIters532] = polly_constrainedfernald(data.distance0, sig532, snr532, refH, config.refBeta532, molBsc532, config.maxIterConstrainFernald, config.minLRConstrainFernald, config.maxLRConstrainFernald, AOD_532_aeronet, config.minDeltaAOD, config.heightFullOverlap(flagChannel532), config.mask_SNRmin(flagChannel532), config.smoothWin_klett_532);
            thisAerExt532_aeronet = thisAerBsc532_aeronet * thisLR_532;
        end
    end
    
    % concatenate the results
    aerBsc532_aeronet = cat(1, aerBsc532_aeronet, thisAerBsc532_aeronet);
    aerExt532_aeronet = cat(1, aerExt532_aeronet, thisAerExt532_aeronet);
    LR532_aeronet = cat(1, LR532_aeronet, thisLR_532);
    deltaAOD532 = cat(1, deltaAOD532, thisDeltaAOD532);
end
    
%% 1064 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc1064_aeronet = NaN(size(data.height));
    thisAerExt1064_aeronet = NaN(size(data.height));
    thisLR_1064 = NaN;
    thisDeltaAOD1064 = NaN;
    thisNIters1064 = NaN;

    if ~ isnan(data.refHIndx1064(iGroup, 1))
        flagChannel1064 = config.isFR & config.isTot & config.is1064nm;
        sig1064 = squeeze(sum(data.signal(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        bg1064 = squeeze(sum(data.bg(flagChannel1064, :, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 3));
        snr1064 = polly_SNR(sig1064, bg1064);
        refH = [data.distance0(data.refHIndx1064(iGroup, 1)), data.distance0(data.refHIndx1064(iGroup, 2))];
        [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % search the closest AERONET AOD
        AERONETIndx = search_close_AERONET_AOD(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), AERONET.datetime, datenum(0,1,0,2,0,0));
        if ~ isempty(AERONETIndx)
            AOD_1064_aeronet = interp_AERONET_AOD(1020, AERONET.AOD_1020(AERONETIndx), 1640, AERONET.AOD_1640(AERONETIndx), 1064);

            % constrained klett method
            [thisAerBsc1064_aeronet, thisLR_1064, thisDeltaAOD1064, thisNIters1064] = polly_constrainedfernald(data.distance0, sig1064, snr1064, refH, config.refBeta1064, molBsc1064, config.maxIterConstrainFernald, config.minLRConstrainFernald, config.maxLRConstrainFernald, AOD_1064_aeronet, config.minDeltaAOD, config.heightFullOverlap(flagChannel1064), config.mask_SNRmin(flagChannel1064), config.smoothWin_klett_1064);
            thisAerExt1064_aeronet = thisAerBsc1064_aeronet * thisLR_1064;
        end
    end
    
    % concatenate the results
    aerBsc1064_aeronet = cat(1, aerBsc1064_aeronet, thisAerBsc1064_aeronet);
    aerExt1064_aeronet = cat(1, aerExt1064_aeronet, thisAerExt1064_aeronet);
    LR1064_aeronet = cat(1, LR1064_aeronet, thisLR_1064);
    deltaAOD1064 = cat(1, deltaAOD1064, thisDeltaAOD1064);
end

end