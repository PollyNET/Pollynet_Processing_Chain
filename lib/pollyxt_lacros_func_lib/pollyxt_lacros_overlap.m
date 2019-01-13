function [data, overlapAttri] = pollyxt_lacros_overlap(data, config)
%pollyxt_lacros_overlap description
%   Example:
%       [data] = pollyxt_lacros_overlap(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       overlapAttri: struct
%           All information about overlap.
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

overlapAttri = struct();
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = [];
overlapAttri.overlap355 = [];
overlapAttri.overlap532 = [];
overlapAttri.overlap355_std = [];
overlapAttri.overlap532_std = [];
overlapAttri.overlap355DefaultInterp = [];
overlapAttri.overlap532DefaultInterp = [];
overlapAttri.sig355FR = [];   % Photon count rate [MHz]
overlapAttri.sig355NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio355 = [];
overlapAttri.normRange355 = [];
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
overlap355 = [];
overlap355_std = [];

if ~ sum(data.flagCloudFree2km) == 0

    switch config.overlapCalMode
    case 1   % ratio of near and far range signal

        % 355 nm
        sig355NR = squeeze(sum(data.signal(config.isNR & config.is355nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg355NR = squeeze(sum(data.bg(config.isNR & config.is355nm & config.isTot, :, data.flagCloudFree2km), 3));
        sig355FR = squeeze(sum(data.signal(config.isFR & config.is355nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg355FR = squeeze(sum(data.bg(config.isFR & config.is355nm &config.isTot, :, data.flagCloudFree2km), 3));

        % calculate the SNR
        snr355NR = polly_SNR(sig355NR, bg355NR);
        snr355FR = polly_SNR(sig355FR, bg355FR);

        % find the index for full overlap (base of signal normalization)
        fullOverlapIndx = find(data.height >= config.heightFullOverlap(config.isFR & config.is355nm & config.isTot), 1);
        if isempty(fullOverlapIndx)
            error('The index of full overlap can not be found for 355 nm.');
        end
        
        % find the top boundary for signal normalization
        lowSNRBaseIndx = find(snr355NR(fullOverlapIndx:end) < config.minSNR_4_sigNorm, 1);
        if isempty(lowSNRBaseIndx)
            warning('Signal is too noisy to perform signal normalization for 355 nm.');
        else
            lowSNRBaseIndx = lowSNRBaseIndx + fullOverlapIndx - 1;

            % calculate the channel ratio of near range and far range total signal
            [sigRatio355, normRange355, ~] = mean_stable(sig355NR./sig355FR, 40, fullOverlapIndx, lowSNRBaseIndx, 0.1);

            % calculate the overlap of FR channel
            if ~ isempty(normRange355)
                SNRNormRange355FR = polly_SNR(sum(sig355FR(normRange355)), sum(bg355FR(normRange355)));
                SNRNormRange355NR = polly_SNR(sum(sig355NR(normRange355)), sum(bg355NR(normRange355)));
                sigRatio355Std = sigRatio355 * sqrt(1 / SNRNormRange355FR.^2 + 1 / SNRNormRange355NR.^2);
                overlap355 = sig355FR ./ sig355NR * sigRatio355;
                overlap355_std = overlap355 .* sqrt(sigRatio355Std.^2/sigRatio355.^2 + 1./sig355FR.^2 + 1./sig355NR.^2);
            end
        end

        % 532 nm
        sig532NR = squeeze(sum(data.signal(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg532NR = squeeze(sum(data.bg(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        sig532FR = squeeze(sum(data.signal(config.isFR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg532FR = squeeze(sum(data.bg(config.isFR & config.is532nm &config.isTot, :, data.flagCloudFree2km), 3));

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
        if isempty(lowSNRBaseIndx)
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
            end
        end

        overlapAttri.sig355FR = sig355FR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
        overlapAttri.sig355NR = sig355NR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
        overlapAttri.sigRatio355 = sigRatio355;
        overlapAttri.normRange355 = normRange355;
        overlapAttri.sig532FR = sig532FR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
        overlapAttri.sig532NR = sig532NR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
        overlapAttri.sigRatio532 = sigRatio532;
        overlapAttri.normRange532 = normRange532;
    case 2   % raman method
    end
    
end

%% read default overlap function to compare with the estimated ones.
[height532, overlap532Default] = read_default_overlap(fullfile(processInfo.defaultsFile_folder, defaults.overlapFile532));
[height355, overlap355Default] = read_default_overlap(fullfile(processInfo.defaultsFile_folder, defaults.overlapFile355));

%% interpolate the default overlap
if ~ isempty(overlap355Default)
    overlap355DefaultInterp = interp1(height355, overlap355Default, data.height, 'linear');
end
if ~ isempty(overlap532Default)
    overlap532DefaultInterp = interp1(height532, overlap532Default, data.height, 'linear');
end

%% saving the results
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = data.height;
overlapAttri.overlap355 = overlap355;
overlapAttri.overlap532 = overlap532;
overlapAttri.overlap355_std = overlap355_std;
overlapAttri.overlap532_std = overlap532_std;
overlapAttri.overlap355DefaultInterp = overlap355DefaultInterp;
overlapAttri.overlap532DefaultInterp = overlap532DefaultInterp;

%% append the overlap to data
if isempty(overlap532)
    data.overlap532 = interp1(height532, overlap532Default, data.height, 'linear');
    data.flagOverlapUseDefault532 = true;
else
    data.overlap532 = overlap532;
    data.flagOverlapUseDefault532 = false;
end

if isempty(overlap355)
    data.overlap355 = interp1(height355, overlap355Default, data.height, 'linear');
    data.flagOverlapUseDefault355 = true;
else
    data.overlap355 = overlap355;
    data.flagOverlapUseDefault355 = false;
end

end