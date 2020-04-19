function [data, overlapAttri] = polly_1v2_overlap(data, config)
%POLLY_1V2_OVERLAP description
%Example:
%   [data] = polly_1v2_overlap(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%Outputs:
%   data: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   overlapAttri: struct
%       All information about overlap.
%History:
%   2018-12-19. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo campaignInfo defaults

overlapAttri = struct();
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = [];
overlapAttri.overlap532 = [];
overlapAttri.overlap532_std = [];
overlapAttri.overlap532DefaultInterp = [];
overlapAttri.sig532FR = [];   % Photon count rate [MHz]
overlapAttri.sig532NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio532 = [];
overlapAttri.normRange532 = [];

if isempty(data.rawSignal)
    return;
end

%% calculate the overlap
overlap532 = []; 
overlap532_std = [];  

if ~ sum(data.flagCloudFree8km) == 0

    switch config.overlapCalMode
    case 1   % ratio of near and far range signal

        % 532 nm
        sig532NR = squeeze(sum(data.signal(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree8km), 3));
        bg532NR = squeeze(sum(data.bg(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree8km), 3));
        sig532FR = squeeze(sum(data.signal(config.isFR & config.is532nm & config.isTot, :, data.flagCloudFree8km), 3));
        bg532FR = squeeze(sum(data.bg(config.isFR & config.is532nm &config.isTot, :, data.flagCloudFree8km), 3));
        overlapAttri.sig532FR = sig532FR / sum(data.mShots(data.flagCloudFree8km)) * 150 / data.hRes;
        overlapAttri.sig532NR = sig532NR / sum(data.mShots(data.flagCloudFree8km)) * 150 / data.hRes;

        % calculate the SNR
        snr532NR = polly_SNR(sig532NR, bg532NR);
        snr532FR = polly_SNR(sig532FR, bg532FR);

        % find the index for full overlap (base of signal normalization)
        fullOverlapIndx = find(data.height >= config.heightFullOverlap(config.isFR & config.is532nm & config.isTot), 1);
        if isempty(fullOverlapIndx)
            error('The index of full overlap can not be found for 532 nm.');
        end
        
        % find the top boundary for signal normalization
        lowSNRBaseIndx = find(snr532NR(fullOverlapIndx:end) < config.minSNR_4_sigNorm, 1);
        if (lowSNRBaseIndx - fullOverlapIndx) <= 40
            warning('Signal is too noisy to perform signal normalization for 532 nm.');
        else
            lowSNRBaseIndx = lowSNRBaseIndx + fullOverlapIndx - 1;

            % calculate the channel ratio of near range and far range total signal
            [sigRatio532, normRange532, ~] = mean_stable(sig532NR./sig532FR, 40, fullOverlapIndx, lowSNRBaseIndx, 0.1);

            % calculate the overlap of FR channel
            if ~ isempty(normRange532)
                SNRNormRangeFR = polly_SNR(sum(sig532FR(normRange532)), sum(bg532FR(normRange532)));
                SNRNormRangeNR = polly_SNR(sum(sig532NR(normRange532)), sum(bg532NR(normRange532)));
                sigRatio532Std = sigRatio532 * sqrt(1 / SNRNormRangeFR.^2 + 1 / SNRNormRangeNR.^2);
                overlap532 = sig532FR ./ sig532NR * sigRatio532;
                overlap532_std = overlap532 .* sqrt(sigRatio532Std.^2/sigRatio532.^2 + 1./sig532FR.^2 + 1./sig532NR.^2);
                overlapAttri.sigRatio532 = sigRatio5
                32;
                overlapAttri.normRange532 = normRange532;
            end
        end

    case 2   % raman method
    end

end

%% read default overlap function to compare with the estimated ones.
[height532, overlap532Default] = read_default_overlap(fullfile(processInfo.polly_config_folder, 'pollyDefaults', defaults.overlapFile532));

%% interpolate the default overlap
if ~ isempty(overlap532Default)
    overlap532DefaultInterp = interp1(height532, overlap532Default, data.height, 'linear');
else
    overlap532DefaultInterp = NaN(size(data.height));
end

%% saving the results
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = data.height;
overlapAttri.overlap532 = overlap532;
overlapAttri.overlap532_std = overlap532_std;
overlapAttri.overlap532DefaultInterp = overlap532DefaultInterp;

%% append the overlap to data
if isempty(overlap532)
    data.overlap532 = interp1(height532, overlap532Default, data.height, 'linear', NaN);
    data.flagOverlapUseDefault532 = true;
else
    data.overlap532 = overlap532;
    data.flagOverlapUseDefault532 = false;
end

end