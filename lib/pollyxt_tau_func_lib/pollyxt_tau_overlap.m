function [data, overlapAttri] = pollyxt_tau_overlap(data, config)
%pollyxt_tau_overlap description
%   Example:
%       [data] = pollyxt_tau_overlap(data, config)
%   Inputs:
%       data.struct
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

        if (~ isempty(sig355NR)) && (~ isempty(sig355FR))
            % if both near- and far-range channel exist
            overlapAttri.sig355FR = sig355FR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
            overlapAttri.sig355NR = sig355NR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;

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
            if (lowSNRBaseIndx - fullOverlapIndx) <= 40
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
                    
                    overlapAttri.sigRatio355 = sigRatio355;
                    overlapAttri.normRange355 = normRange355;
                end
            end
        end

        % 532 nm
        sig532NR = squeeze(sum(data.signal(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg532NR = squeeze(sum(data.bg(config.isNR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        sig532FR = squeeze(sum(data.signal(config.isFR & config.is532nm & config.isTot, :, data.flagCloudFree2km), 3));
        bg532FR = squeeze(sum(data.bg(config.isFR & config.is532nm &config.isTot, :, data.flagCloudFree2km), 3));

        if (~ isempty(sig532NR)) && (~ isempty(sig532FR))
            % if both near- and far-range channel exist
            overlapAttri.sig532FR = sig532FR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;
            overlapAttri.sig532NR = sig532NR / sum(data.mShots(data.flagCloudFree2km)) * 150 / data.hRes;

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
                    
                    overlapAttri.sigRatio532 = sigRatio532;
                    overlapAttri.normRange532 = normRange532;
                end
            end
        end
    case 2   % raman method
        % TODO
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

%% overlap correction
if config.overlapSmoothBins <= 3
    error('In order to decrease the effects of signal noise on the overlap correction, config.overlapSmoothBins should be set to be larger than 3');
end

overlap355Sm = smooth(data.overlap355, config.overlapSmoothBins, 'sgolay', 2);
overlap532Sm = smooth(data.overlap532, config.overlapSmoothBins, 'sgolay', 2);

flag355 = config.is355nm & config.isTot & config.isFR;
flag532 = config.is532nm & config.isTot & config.isFR;

% find the minimum range bin with complete overlap function
flagFullOverlap355 = (overlap355Sm >= 1) & (data.height >= config.heightFullOverlap(flag355));
flagFullOverlap532 = (overlap532Sm >= 1) & (data.height >= config.heightFullOverlap(flag532));
minBinFullOverlap355 = find(flagFullOverlap355, 1);
minBinFullOverlap532 = find(flagFullOverlap532, 1);

if isempty(minBinFullOverlap355)
    warning('Error in searching the minimum bin of complete overlap for total signal at 355 nm. Check the default overlap function and your configurations.');
    flagFullOverlap355 = find(data.height >= config.heightFullOverlap(flag355), 1);
end
if isempty(minBinFullOverlap532)
    warning('Error in searching the minimum bin of complete overlap for total signal at 532 nm. Check the default overlap function and your configurations.');
    flagFullOverlap532 = find(data.height >= config.heightFullOverlap(flag532), 1);
end

% set the overlap function to be 1 above the minimun range with complete overlap function
overlap355Sm(minBinFullOverlap355:end) = 1;
overlap532Sm(minBinFullOverlap532:end) = 1;

% overlap correction for the total signal from Far-range channels
data.signal355OverlapCor = squeeze(data.signal(config.isFR & config.is355nm & config.isTot, :, :)) ./ repmat(overlap355Sm, 1, size(data.signal, 3));
data.bg355OverlapCor = squeeze(data.bg(config.isFR & config.is355nm & config.isTot, :, :)) ./ repmat(overlap355Sm, 1, size(data.signal, 3));
data.signal532OverlapCor = squeeze(data.signal(config.isFR & config.is532nm & config.isTot, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));
data.bg532OverlapCor = squeeze(data.bg(config.isFR & config.is532nm & config.isTot, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));
data.signal387OverlapCor = squeeze(data.signal(config.isFR & config.is387nm, :, :)) ./ repmat(overlap355Sm, 1, size(data.signal, 3));
data.bg387OverlapCor = squeeze(data.bg(config.isFR & config.is387nm, :, :)) ./ repmat(overlap355Sm, 1, size(data.signal, 3));
data.signal607OverlapCor = squeeze(data.signal(config.isFR & config.is607nm, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));
data.bg607OverlapCor = squeeze(data.bg(config.isFR & config.is607nm, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));

% overlap correction for signal at 1064 nm (under test)
data.signal1064OverlapCor = squeeze(data.signal(config.isFR & config.is1064nm & config.isTot, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));
data.bg1064OverlapCor = squeeze(data.bg(config.isFR & config.is1064nm & config.isTot, :, :)) ./ repmat(overlap532Sm, 1, size(data.signal, 3));

end