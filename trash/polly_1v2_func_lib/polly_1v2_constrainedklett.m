function [aerBsc532_aeronet, aerExt532_aeronet, LR532_aeronet, deltaAOD532] = polly_1v2_constrainedklett(data, AERONET, config)
%POLLY_1V2_CONSTRAINEDKLETT Retrieve the aerosol optical properties with the constrains from AERONET.
%Example:
%   [aerBsc532_aeronet, aerExt532_aeronet, LR532_aeronet] = polly_1v2_constrainedklett(data, AERONET, config)
%Inputs:
%   data: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   AERONET: struct
%      datetime: array
%          time of each measurment point.
%      AOD_{wavelength}: array
%          AOD at wavelength.
%      wavelength: array
%          wavelength of each channel. [nm]
%      IWV: array
%          Integrated Water Vapor. [cm] 
%      angstrexp440_870: array
%          angstroem exponent 440-870 nm
%      AERONETAttri: struct 
%          URL: char
%              URL to retrieve the data.
%          level: char
%              product level. ('10', '15', '20')
%          status: logical
%              status to show whether retrieve the data successfully.
%          IWVUnit: char
%              unit of integrated water vapor. [cm]
%          location: char
%              AERONET site
%          PI: char
%              PI of the current AERONET site.
%          contact: char
%              email of the PI.
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%Outputs:
%   aerBsc532_aeronet: matrix
%       aerosol backscatter coefficient at 532 nm. [m^{-1}Sr^{-1}]  
%   aerExt532_aeronet: matrix
%       aerosol extinction coefficient at 532 nm. [m^{-1}] 
%   LR532_aeronet: array
%       lidar ration at 532 nm. [Sr]  
%   deltaAOD532: array
%       the minimum deviation between lidar retrieved AOD and AEROENT AOD. 
%History:
%   2018-12-23. First Edition by Zhenping
%   2019-08-31. Add SNR control for the signal at reference height
%Contact:
%   zhenping@tropos.de

aerBsc532_aeronet = [];
aerExt532_aeronet = [];
LR532_aeronet = [];
deltaAOD532 = [];

if isempty(data.rawSignal)
    return;
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisAerBsc532_aeronet = NaN(size(data.height));
    thisAerExt532_aeronet = NaN(size(data.height));
    thisLR_532 = NaN;
    thisDeltaAOD532 = NaN;

    if ~ isnan(data.refHIndx532(iGroup, 1))
        flagChannel532 = config.isFR & config.isTot & config.is532nm;
        sig532 = squeeze(sum(data.el532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        bg532 = squeeze(sum(data.bgEl532(:, data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2)), 2));
        snr532 = polly_SNR(sig532, bg532);
        refH = [data.distance0(data.refHIndx532(iGroup, 1)), data.distance0(data.refHIndx532(iGroup, 2))];
        [molBsc532, ~] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

        % calculate the SNR at the reference height
        refSig532 = sum(sig532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        refBg532 = sum(bg532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        snrRef532 = polly_SNR(refSig532, refBg532);

        % search the closest AERONET AOD
        AERONETIndx = search_close_AERONET_AOD(mean(data.mTime(data.cloudFreeGroups(iGroup, :))), AERONET.datetime, datenum(0,1,0,2,0,0));

        if (~ isempty(AERONETIndx)) && (snrRef532 >= config.minRefSNR532)
            AOD_532_aeronet = interp_AERONET_AOD(500, AERONET.AOD_500(AERONETIndx), 675, AERONET.AOD_675(AERONETIndx), 532);

            % constrained klett method
            [thisAerBsc532_aeronet, thisLR_532, thisDeltaAOD532, ~] = polly_constrainedfernald(data.distance0, sig532, snr532, refH, config.refBeta532, molBsc532, config.maxIterConstrainFernald, config.minLRConstrainFernald, config.maxLRConstrainFernald, AOD_532_aeronet, config.minDeltaAOD, config.heightFullOverlap(flagChannel532), config.mask_SNRmin(flagChannel532), config.smoothWin_klett_532);
            thisAerExt532_aeronet = thisAerBsc532_aeronet * thisLR_532;
        end
    end

    % concatenate the results
    aerBsc532_aeronet = cat(1, aerBsc532_aeronet, thisAerBsc532_aeronet);
    aerExt532_aeronet = cat(1, aerExt532_aeronet, thisAerExt532_aeronet);
    LR532_aeronet = cat(1, LR532_aeronet, thisLR_532);
    deltaAOD532 = cat(1, deltaAOD532, thisDeltaAOD532);
end

end