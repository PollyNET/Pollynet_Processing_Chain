function [wvconst, wvconstStd, globalAttri] = polly_1v2_wv_calibration(data, config)
%polly_1v2_wv_calibration water vapor calibration. The whole idea is based on the work of Guangyao. More detailed information can be found Guangyao et al, 2018, AMT.
%   Example:
%       [wvconst, wvconstStd, globalAttri] = polly_1v2_wv_calibration(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       wvconst: array
%           water vapor calibration constant. [g/kg] 
%       wvconstStd: array
%           uncertainty of water vapor calibration constant. [g/kg]
%       globalAttri: struct
%           datetime: array
%               water vapor calibration time. [datenum]
%           WVCaliInfo: cell
%               calibration information for each calibration period.
%           IntRange: matrix
%               index of integration range for calculate the raw IWV from lidar.
%   History:
%       2018-12-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo

wvconst = [];
wvconstStd = [];
globalAttri = struct();
globalAttri.datetime = [];
globalAttri.WVCaliInfo = {};
globalAttri.IntRange = [];

if isempty(data.rawSignal)
    return;
end

flagChannel387 = config.isFR & config.is387nm;
flagChannel407 = config.isFR & config.is407nm;
flagChannel1064 = config.isFR & config.is1064nm;
flag407On = (~ polly_is407Off(squeeze(data.signal(flagChannel407, :, :))));

for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisWVconst = NaN;
    thisWVconstStd = NaN;
    thisDatetime = NaN;
    thisWVCaliInfo = '407 off';
    thisIntRange = [NaN, NaN];

    flagWVCali = false(size(flag407On));
    wvCaliIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagWVCali(wvCaliIndx) = true;
    flagNotEnough407Profiles = false;
    flagLowSNR = false;
    flagNoIWVMeas = false;
    flagNotMeteorStable = false;

    %% determine whether 407 is on during the calibration period
    if sum(flag407On & flagWVCali) < 10
        fprintf('No enough water vapor measurement during %s to %s at %s.\n', datestr(data.mTime(wvCaliIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(wvCaliIndx(end)), 'HH:MM'), campaignInfo.location);
        flagNotEnough407Profiles = true;
        thisWVCaliInfo = 'No enough water vapor measurements.';
    end

    %% determine whehter there is IWV measurement
    if isnan(data.IWV(iGroup))
        fprintf('No close IWV measurement for %s at %s during %s to %s.\n', data.IWVAttri.source, campaignInfo.location, datestr(data.mTime(wvCaliIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(wvCaliIndx(end)), 'HH:MM'));
        flagNoIWVMeas = true;
        thisWVCaliInfo = sprintf('No close IWV measurement from %s', data.IWVAttri.source);
    end

    %% determine SNR
    sig387 = squeeze(sum(data.signal(flagChannel387, :, flag407On & flagWVCali), 3));
    bg387 = squeeze(sum(data.bg(flagChannel387, :, flag407On & flagWVCali), 3));
    snr387 = polly_SNR(sig387, bg387);
    sig407 = squeeze(sum(data.signal(flagChannel407, :, flag407On & flagWVCali), 3));
    bg407 = squeeze(sum(data.bg(flagChannel407, :, flag407On & flagWVCali), 3));
    snr407 = polly_SNR(sig407, bg407);
    hIntBaseIndx = find(data.height >= config.hWVCaliBase, 1);
    if isempty(hIntBaseIndx)
        hIntBaseIndx = 3;
    end

    % index of full overlap
    hIndxFullOverlap387 = find(data.height >= config.heightFullOverlap(flagChannel387), 1);
    hIndxFullOverlap407 = find(data.height >= config.heightFullOverlap(flagChannel407), 1);
    if isempty(hIndxFullOverlap387) 
        hIndxFullOverlap387 = 70;
    end
    if isempty(hIndxFullOverlap407)
        hIndxFullOverlap407 = 70;
    end

    % search the index of low SNR
    hIntTopIndx = hIntBaseIndx;   % initialize hIntTopIndx
    hIndxLowSNR387 = find(snr387(hIndxFullOverlap387:end) <= config.mask_SNRmin(flagChannel387), 1);
    hIndxLowSNR407 = find(snr407(hIndxFullOverlap407:end) <= config.mask_SNRmin(flagChannel407), 1);
    if isempty(hIndxLowSNR387) || isempty(hIndxLowSNR407)
        fprintf('Signal is too noisy to perform water calibration at %s during %s to %s.\n', campaignInfo.location, datestr(data.mTime(wvCaliIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(wvCaliIndx(end)), 'HH:MM'));
        flagLowSNR = true;
        thisWVCaliInfo = 'Signal at 387nm or 407nm channel is too noisy.';
    elseif (data.height(hIndxLowSNR387) <= config.hWVCaliBase) || (data.height(hIndxLowSNR407) <= config.hWVCaliBase)
        fprintf('Signal is too noisy to perform water calibration at %s during %s to %s.\n', campaignInfo.location, datestr(data.mTime(wvCaliIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(wvCaliIndx(end)), 'HH:MM'));
        flagLowSNR = true;
        thisWVCaliInfo = 'Signal at 387nm or 407nm channel is too noisy.';
    else
        hIndxLowSNR387 = hIndxLowSNR387 + hIndxFullOverlap387 - 1;
        hIndxLowSNR407 = hIndxLowSNR407 + hIndxFullOverlap407 - 1;
        hIntTopIndx = min([hIndxLowSNR387, hIndxLowSNR407]);
        if data.height(hIntTopIndx) <= config.minHWVCaliTop
            fprintf('Integration top is less than %dm to perform water calibration at %s during %s to %s.\n', config.minHWVCaliTop, campaignInfo.location, datestr(data.mTime(wvCaliIndx(1)), 'yyyymmdd HH:MM'), datestr(data.mTime(wvCaliIndx(end)), 'HH:MM'));
            flagLowSNR = true;
            thisWVCaliInfo = 'Signal at 387nm or 407nm channel is too noisy.';
        end
        thisIntRange = [hIntBaseIndx, hIntTopIndx];
    end

    %% determine meteorological stability
    if ~ flagNoIWVMeas
        [minLag, closestIndx] = min(abs(data.mTime - data.IWVAttri.datetime(iGroup)));
        E_tot_1064_IWV = sum(squeeze(data.signal(flagChannel1064, :, closestIndx)));
        E_tot_1064_cali = sum(squeeze(mean(data.signal(flagChannel1064, :, flag407On & flagWVCali), 3)));
        E_tot_1064_cali_std = std(squeeze(sum(data.signal(flagChannel1064, :, flag407On & flagWVCali), 2)));

        if (abs(E_tot_1064_IWV - E_tot_1064_cali) / E_tot_1064_IWV > 0.2) || ((E_tot_1064_cali_std / E_tot_1064_cali) > 0.2)
            fprintf('Meteorological condition is not stable enough for the calibration at %s during %s to %s.\n', campaignInfo.location, datestr(min([data.mTime(closestIndx), data.mTime(flag407On & flagWVCali)]), 'yyyymmdd HH:MM'), datestr(max([data.mTime(closestIndx), data.mTime(flag407On & flagWVCali)]), 'HH:MM'));
            flagNotMeteorStable = true;
            thisWVCaliInfo = 'Meteorological condition is not stable.';
        end
    end

    %% wv calibration
    if (~ flagLowSNR) && (~ flagNoIWVMeas) && (~ flagNotEnough407Profiles) && (~ flagNotMeteorStable)
        IWV_Cali = data.IWV(iGroup);   % kg*m{-2}

        [~, molExt387] = rayleigh_scattering(387, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [~, molExt407] = rayleigh_scattering(407, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        trans387 = exp(-cumsum(molExt387 .* [data.distance0(1), diff(data.distance0)]));
        trans407 = exp(-cumsum(molExt407 .* [data.distance0(1), diff(data.distance0)]));

        wvmrRaw = sig407 ./ sig387 .* trans387 ./ trans407;
        rhoAir = rho_air(data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17);
        IWVRaw = sum(wvmrRaw(hIntBaseIndx:hIntTopIndx) .* rhoAir(hIntBaseIndx:hIntTopIndx) .* [data.height(hIntBaseIndx), diff(data.height(hIntBaseIndx:hIntTopIndx))]) / 1e6;   % 1000 kg*m^{-2}

        thisWVconst = IWV_Cali ./ IWVRaw;   % g*kg^{-1}
        thisWVconstStd = 0;   % TODO: this can be done by taking into account the uncertainty of IWV by AERONET and the signal uncertainty by lidar.
        thisDatetime = mean(data.mTime(data.cloudFreeGroups(iGroup, :)));
    end

    % concatenate data
    wvconst = cat(1, wvconst, thisWVconst);
    wvconstStd = cat(1, wvconstStd, thisWVconstStd);
    globalAttri.datetime = cat(1, globalAttri.datetime, thisDatetime);
    globalAttri.WVCaliInfo{end + 1} = thisWVCaliInfo;
    globalAttri.IntRange = cat(1, globalAttri.IntRange, thisIntRange);
    
end

end