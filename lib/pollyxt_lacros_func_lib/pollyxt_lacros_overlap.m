function [data] = pollyxt_lacros_overlap(data, config, taskInfo, saveFolder)
%pollyxt_lacros_overlap description
%   Example:
%       [data] = pollyxt_lacros_overlap(data, config, taskInfo, defaults, saveFolder)
%   Inputs:
%       data, config, taskInfo, defaults, saveFolder
%   Outputs:
%       data
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

if isempty(data.rawSignal)
    return;
end

%% calculate the overlap
overlap532 = [];   
overlap355 = [];
switch config.overlapCorMode
case 1   % ratio of near and far range signal

    if sum(data.flagCloudFree2km) == 0
        return;
    end

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
        return;
    end
    lowSNRBaseIndx = lowSNRBaseIndx + fullOverlapIndx - 1;

    % calculate the channel ratio of near range and far range total signal
    [sigRatio, normRange, ~] = mean_stable(sig355NR./sig355FR, 40, fullOverlapIndx, lowSNRBaseIndx, 0.1);

    % calculate the overlap of FR channel
    if isempty(normRange)
        return;
    else
        SNRNormRangeFR = polly_SNR(sum(sig355FR(normRange)), sum(bg355FR(normRange)));
        SNRNormRangeNR = polly_SNR(sum(sig355NR(normRange)), sum(bg355NR(normRange)));
        sigRatioStd = sigRatio * sqrt(1 / SNRNormRangeFR.^2 + 1 / SNRNormRangeNR.^2);
    end

    overlap355 = sig355FR ./ sig355NR * sigRatio;
    overlap355_std = overlap355 .* sqrt(sigRatioStd.^2/sigRatio.^2 + 1./sig355FR.^2 + 1./sig355NR.^2);


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
        return;
    end
    lowSNRBaseIndx = lowSNRBaseIndx + fullOverlapIndx - 1;

    % calculate the channel ratio of near range and far range total signal
    [sigRatio, normRange, ~] = mean_stable(sig532NR./sig532FR, 40, fullOverlapIndx, lowSNRBaseIndx, 0.1);

    % calculate the overlap of FR channel
    if isempty(normRange)
        return;
    else
        SNRNormRangeFR = polly_SNR(sum(sig532FR(normRange)), sum(bg532FR(normRange)));
        SNRNormRangeNR = polly_SNR(sum(sig532NR(normRange)), sum(bg532NR(normRange)));
        sigRatioStd = sigRatio * sqrt(1 / SNRNormRangeFR.^2 + 1 / SNRNormRangeNR.^2);
    end

    overlap532 = sig532FR ./ sig532NR * sigRatio;
    overlap532_std = overlap532 .* sqrt(sigRatioStd.^2/sigRatio.^2 + 1./sig532FR.^2 + 1./sig532NR.^2);

case 2   % raman method
end

%% read default overlap function to compare with the estimated ones.
[height532, overlap532Default] = read_default_overlap(defaults.overlapFile532);
[height355, overlap355Default] = read_default_overlap(defaults.overlapFile355);

%% interpolate the default overlap
if ~ isempty(overlap355Default)
    overlap355DefaultInterp = interp1(height355, overlap355Default, data.height, 'linear');
end
if ~ isempty(overlap532Default)
    overlap532DefaultInterp = interp1(height532, overlap532Default, data.height, 'linear');
end

%% saving the results
saveFile = fullfile(saveFolder, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_overlap.nc', datestr(taskInfo.dataTime, 'yyyy_mm_dd_HH_MM_SS'), taskInfo.pollyVersion));
picFile = fullfile(saveFolder, datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_overlap.png', datestr(taskInfo.dataTime, 'yyyy_mm_dd_HH_MM_SS'), taskInfo.pollyVersion));
globalAttribute = struct();
globalAttribute.location = campaignInfo.location;
globalAttribute.institute = processInfo.institute;
globalAttribute.contact = processInfo.contact;
globalAttribute.version = processInfo.programVersion;
pollyxt_lacros_save_overlap(data.height, overlap532, overlap355, overlap532DefaultInterp, overlap355DefaultInterp, saveFile, config, globalAttribute);
pollyxt_lacros_display_overlap(data.height, overlap532, overlap355, overlap532DefaultInterp, overlap355DefaultInterp, picFile, config, taskInfo, globalAttribute);

%% append the overlap to data
if isempty(overlap532)
    data.overlap532 = interp2(height532, overlap532Default, data.height, 'linear');
    data.flagOverlapUseDefault = true;
else
    data.overlap532 = overlap532;
    data.flagOverlapUseDefault = false;
end

if isempty(overlap355)
    data.overlap355 = interp2(height355, overlap355Default, data.height, 'linear');
    data.flagOverlapUseDefault = true;
else
    data.overlap355 = overlap355;
    data.flagOverlapUseDefault = false;
end

end