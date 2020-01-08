function [wvmr, rh, wvProfileInfo, WVMR, RH, IWV, quality_mask_WVMR, quality_mask_RH] = polly_1v2_wv_retrieve(data, config, IWVIntRangeIndx)
%polly_1v2_wv_retrieve retrieve the water vapor mixing ratio and relative humidity.
%   Example:
%       [wvmr, rh, wvProfileInfo, WVMR, RH] = polly_1v2_wv_retrieve(data, config, IWVIntRangeIndx)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       IWVIntRangeIndx: matrix
%           integration range for IWV.
%   Outputs:
%       wvmr: matrix
%           water vapor mixing ratio profile. [g*kg^{-1}] numel(data.cloudFreeGroups)*numel(data.height)
%       rh: matrix
%           relative humidity. [%] numel(data.cloudFreeGroups)*numel(data.height)
%       wvProfileInfo: struct
%           n407Pros: array
%               number of accumulated 407nm profiles for each wvmr profile in cloud free period. 
%       WVMR: matrix
%           spatial-temporal resolved water vapor mixing ratio. [g*kg^{-1}] 
%       RH: matrix
%           spatial-temporal resolved relative humidity. [%] 
%       IWV: array
%           time series of IWV. [kg*m^{-2}] 
%       quality_mask_WVMR: matrix
%           0 means valid point; 1 means low SNR; 2 means depol calibration; 3 turned off
%       quality_mask_RH : matrix
%           see above.
%   History:
%       2018-12-26. First Edition by Zhenping
%       2019-05-22. Add quality control for wvmr and RH.
%   Contact:
%       zhenping@tropos.de

global processInfo

wvmr = [];
rh = [];
WVMR = [];
RH = [];
wvProfileInfo = struct();
wvProfileInfo.n407Pros = [];
wvProfileInfo.IWV = [];

if isempty(data.rawSignal)
    return;
end

flagChannel387 = config.isFR & config.is387nm;
flagChannel407 = config.isFR & config.is407nm;

%% retrieve the wvxr and rh profiles
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thiswvmr = NaN(size(data.height));
    thisrh = NaN(size(data.height));
    thisIWV = NaN;
    thisn407Pros = 0;

    flagCloudFree = false(size(data.mTime));
    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagCloudFree(proIndx) = true;
    flag407On = (~ data.mask407Off);
    thisn407Pros = sum(flagCloudFree & flag407On);
    
    if thisn407Pros >= 10
        sig387 = sum(data.signal(flagChannel387, :, flag407On & flagCloudFree), 3);
        bg387 = sum(data.bg(flagChannel387, :, flag407On & flagCloudFree), 3);
        snr387 = polly_SNR(sig387, bg387);
        
        sig407 = sum(data.signal(flagChannel407, :, flag407On & flagCloudFree), 3);
        bg407 = sum(data.bg(flagChannel407, :, flag407On & flagCloudFree), 3);
        snr407 = polly_SNR(sig407, bg387);
        
        % calculate the molecule optical properties
        [~, molExt387] = rayleigh_scattering(387, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        [~, molExt407] = rayleigh_scattering(407, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
        trans387 = exp(- cumsum(molExt387 .* [data.distance0(1), diff(data.distance0)]));
        trans407 = exp(- cumsum(molExt407 .* [data.distance0(1), diff(data.distance0)]));

        % calculate the saturation water vapor pressure
        es = saturated_vapor_pres(data.temperature(iGroup, :));

        rhoAir = rho_air(data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17);

        % calculate wvmr and rh
        thiswvmr = sig407 ./ sig387 .* trans387 ./ trans407 .* data.wvconstUsed;
        thisrh = wvmr_2_rh(thiswvmr, es, data.pressure(iGroup, :));
        if ~ isnan(IWVIntRangeIndx(iGroup, 1))
            IWVInt = IWVIntRangeIndx(iGroup, 1):IWVIntRangeIndx(iGroup, 2);
            thisIWV = sum(thiswvmr(IWVInt) .* rhoAir(IWVInt) ./ 1e6 .* [data.height(IWVInt(1)), diff(data.height(IWVInt))]);   % kg*m^{-2}
        end
    end

    % concatenate the results
    wvProfileInfo.n407Pros = cat(1, wvProfileInfo.n407Pros, thisn407Pros);
    wvProfileInfo.IWV = cat(1, wvProfileInfo.IWV, thisIWV);
    wvmr = cat(1, wvmr, thiswvmr);
    rh = cat(1, rh, thisrh);
    
end

%% retrieve the WVMR and RH
SIG387 = squeeze(data.signal(flagChannel387, :, :));
SIG387(:, data.depCalMask) = NaN;
SIG407 = squeeze(data.signal(flagChannel407, :, :));
SIG407(:, data.depCalMask) = NaN;

% SNR after temporal and vertical accumulation
SNR = NaN(size(data.signal));
for iChannel = 1:size(data.signal, 1)
    signal_sm = smooth2(squeeze(data.signal(iChannel, :, :)), config.quasi_smooth_h(iChannel), config.quasi_smooth_t(iChannel));
    signal_int = signal_sm * (config.quasi_smooth_h(iChannel) * config.quasi_smooth_t(iChannel));
    bg_sm = smooth2(squeeze(data.bg(iChannel, :, :)), config.quasi_smooth_h(iChannel), config.quasi_smooth_t(iChannel));
    bg_int = bg_sm * (config.quasi_smooth_h(iChannel) * config.quasi_smooth_t(iChannel));
    SNR(iChannel, :, :) = polly_SNR(signal_int, bg_int);
end

% quality mask to filter low snr bits
quality_mask_WVMR = zeros(size(data.signal, 2), size(data.signal, 3));
quality_mask_WVMR((squeeze(SNR(flagChannel387, :, :)) < config.mask_SNRmin(flagChannel387)) | (squeeze(SNR(flagChannel407, :, :)) < config.mask_SNRmin(flagChannel407))) = 1;
quality_mask_WVMR(:, data.depCalMask) = 2;
quality_mask_RH = quality_mask_WVMR;

% mask the signal
quality_mask_WVMR(:, data.mask407Off) = 3;
SIG407_QC = SIG407;
SIG407_QC(:, data.depCalMask) = NaN;
SIG407_QC(:, data.mask407Off) = NaN;
SIG387_QC = SIG387;
SIG387_QC(:, data.depCalMask) = NaN;
SIG387_QC(:, data.mask407Off) = NaN;

% smooth the signal
SIG387_QC = smooth2(SIG387_QC, config.quasi_smooth_h(flagChannel387), config.quasi_smooth_t(flagChannel387));
SIG407_QC = smooth2(SIG407_QC, config.quasi_smooth_h(flagChannel407), config.quasi_smooth_t(flagChannel407));

% read the meteorological data
[altRaw, tempRaw, presRaw, relhRaw, ~] = read_meteor_data(mean(data.mTime), data.alt, config);

% interp the parameters
temp = interp_meteor(altRaw, tempRaw, data.alt);
pres = interp_meteor(altRaw, presRaw, data.alt);
relh = interp_meteor(altRaw, relhRaw, data.alt);

% repmat the array to matrix as the size of data.signal
temperature = repmat(transpose(temp), 1, numel(data.mTime));
pressure = repmat(transpose(pres), 1, numel(data.mTime));

% calculate the molecule optical properties
[~, molExt387] = rayleigh_scattering(387, transpose(pressure(:, 1)), transpose(temperature(:, 1)) + 273.17, 380, 70);
[~, molExt407] = rayleigh_scattering(407, transpose(pressure(:, 1)), transpose(temperature(:, 1)) + 273.17, 380, 70);
trans387 = exp(- cumsum(molExt387 .* [data.distance0(1), diff(data.distance0)]));
trans407 = exp(- cumsum(molExt407 .* [data.distance0(1), diff(data.distance0)]));
TRANS387 = repmat(transpose(trans387), 1, numel(data.mTime));
TRANS407 = repmat(transpose(trans407), 1, numel(data.mTime));

% calculate the saturation water vapor pressure
es = saturated_vapor_pres(temperature(:, 1));
ES = repmat(es, 1, numel(data.mTime));

rhoAir = rho_air(pressure(:, 1), temperature(:, 1) + 273.17);
RHOAIR = repmat(rhoAir, 1, numel(data.mTime));
DIFFHeight = repmat(transpose([data.height(1), diff(data.height)]), 1, numel(data.mTime));

% calculate wvmr and rh
WVMR = SIG407_QC ./ SIG387_QC .* TRANS387 ./ TRANS407 .* data.wvconstUsed;
RH = wvmr_2_rh(WVMR, ES, pressure);
IWV = sum(WVMR .* RHOAIR .* DIFFHeight .* (quality_mask_WVMR == 0), 1) ./ 1e6;   % kg*m^{-2}

end