function [data, overlapAttri] = pollyxt_overlap(data, config)
%POLLYXT_OVERLAP calculate and correct the overlap functions.
%Example:
%   [data] = pollyxt_overlap(data, config)
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
overlapAttri.overlap355 = [];
overlapAttri.overlap532 = [];
overlapAttri.overlap387 = [];
overlapAttri.overlap607 = [];
overlapAttri.overlap355_std = [];
overlapAttri.overlap532_std = [];
overlapAttri.overlap387_std = [];
overlapAttri.overlap607_std = [];
overlapAttri.overlap355DefaultInterp = [];
overlapAttri.overlap532DefaultInterp = [];
overlapAttri.overlap387DefaultInterp = [];
overlapAttri.overlap607DefaultInterp = [];
overlapAttri.sig355FR = [];   % Photon count rate [MHz]
overlapAttri.sig355NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio355 = [];
overlapAttri.sigRatio387 = [];
overlapAttri.normRange355 = [];
overlapAttri.normRange387 = [];
overlapAttri.sig532FR = [];   % Photon count rate [MHz]
overlapAttri.sig532NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio532 = [];
overlapAttri.sigRatio607 = [];
overlapAttri.normRange532 = [];
overlapAttri.normRange607 = [];

if isempty(data.rawSignal)
    return;
end

%% calculate the overlap
overlap532 = [];   
overlap532_std = [];
overlap355 = [];
overlap355_std = [];
overlap387 = [];
overlap387_std = [];
overlap607 = [];
overlap607_std = [];

%% parameter definitions
flag355NR = config.isNR & config.is355nm & config.isTot;
flag355FR = config.isFR & config.is355nm & config.isTot;
flag387FR = config.isFR & config.is387nm;
flag387NR = config.isNR & config.is387nm;
flag532NR = config.isNR & config.is532nm & config.isTot;
flag532FR = config.isFR & config.is532nm & config.isTot;
flag607FR = config.isFR & config.is607nm;
flag607NR = config.isNR & config.is607nm;
flag1064FR = config.isFR & config.is1064nm & config.isTot;

if ~ sum(data.flagCloudFree_NR) == 0

    % 355 nm
    sig355NR = squeeze(sum(data.signal(flag355NR, :, data.flagCloudFree_NR), 3));
    bg355NR = squeeze(sum(data.bg(flag355NR, :, data.flagCloudFree_NR), 3));
    sig355FR = squeeze(sum(data.signal(flag355FR, :, data.flagCloudFree_NR), 3));
    bg355FR = squeeze(sum(data.bg(flag355FR, :, data.flagCloudFree_NR), 3));

    [overlap355, overlap355_std, sigRatio355, normRange355] = ...
        pollyxt_overlap_cal(sig355FR, bg355FR, sig355NR, bg355NR, data.height, ...
            'hFullOverlap', config.heightFullOverlap(flag355FR), ...
            'overlapCalMode', config.overlapCalMode);

    if (~ isempty(sig355NR)) && (~ isempty(sig355FR))
        % if both near- and far-range channel exist
        overlapAttri.sig355FR = sig355FR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;
        overlapAttri.sig355NR = sig355NR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;

        overlapAttri.sigRatio355 = sigRatio355;
        overlapAttri.normRange355 = normRange355;
    end

    % 387 nm
    sig387NR = squeeze(sum(data.signal(flag387NR, :, data.flagCloudFree_NR), 3));
    bg387NR = squeeze(sum(data.bg(flag387NR, :, data.flagCloudFree_NR), 3));
    sig387FR = squeeze(sum(data.signal(flag387FR, :, data.flagCloudFree_NR), 3));
    bg387FR = squeeze(sum(data.bg(flag387FR, :, data.flagCloudFree_NR), 3));

    [overlap387, overlap387_std, sigRatio387, normRange387] = ...
        pollyxt_overlap_cal(sig387FR, bg387FR, sig387NR, bg387NR, data.height, ...
            'hFullOverlap', config.heightFullOverlap(flag387FR), ...
            'overlapCalMode', config.overlapCalMode);

    if (~ isempty(sig387NR)) && (~ isempty(sig387FR))
        % if both near- and far-range channel exist
        overlapAttri.sig387FR = sig387FR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;
        overlapAttri.sig387NR = sig387NR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;

        overlapAttri.sigRatio387 = sigRatio387;
        overlapAttri.normRange387 = normRange387;
    end

    % 532 nm
    sig532NR = squeeze(sum(data.signal(flag532NR, :, data.flagCloudFree_NR), 3));
    bg532NR = squeeze(sum(data.bg(flag532NR, :, data.flagCloudFree_NR), 3));
    sig532FR = squeeze(sum(data.signal(flag532FR, :, data.flagCloudFree_NR), 3));
    bg532FR = squeeze(sum(data.bg(flag532FR, :, data.flagCloudFree_NR), 3));

    [overlap532, overlap532_std, sigRatio532, normRange532] = ...
        pollyxt_overlap_cal(sig532FR, bg532FR, sig532NR, bg532NR, data.height, ...
            'hFullOverlap', config.heightFullOverlap(flag532FR), ...
            'overlapCalMode', config.overlapCalMode);

    if (~ isempty(sig532NR)) && (~ isempty(sig532FR))
        % if both near- and far-range channel exist
        overlapAttri.sig532FR = sig532FR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;
        overlapAttri.sig532NR = sig532NR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;

        overlapAttri.sigRatio532 = sigRatio532;
        overlapAttri.normRange532 = normRange532;
    end

    % 607 nm
    sig607NR = squeeze(sum(data.signal(flag607NR, :, data.flagCloudFree_NR), 3));
    bg607NR = squeeze(sum(data.bg(flag607NR, :, data.flagCloudFree_NR), 3));
    sig607FR = squeeze(sum(data.signal(flag607FR, :, data.flagCloudFree_NR), 3));
    bg607FR = squeeze(sum(data.bg(flag607FR, :, data.flagCloudFree_NR), 3));

    [overlap607, overlap607_std, sigRatio607, normRange607] = ...
        pollyxt_overlap_cal(sig607FR, bg607FR, sig607NR, bg607NR, data.height, ...
            'hFullOverlap', config.heightFullOverlap(flag607FR), ...
            'overlapCalMode', config.overlapCalMode);

    if (~ isempty(sig607NR)) && (~ isempty(sig607FR))
        % if both near- and far-range channel exist
        overlapAttri.sig607FR = sig607FR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;
        overlapAttri.sig607NR = sig607NR / sum(data.mShots(data.flagCloudFree_NR)) * 150 / data.hRes;

        overlapAttri.sigRatio607 = sigRatio607;
        overlapAttri.normRange607 = normRange607;
    end

end

%% read default overlap function to compare with the estimated ones.
[height532, overlap532Default] = read_default_overlap(fullfile(processInfo.polly_config_folder, 'pollyDefaults', defaults.overlapFile532));
[height607, overlap607Default] = read_default_overlap(fullfile(processInfo.polly_config_folder, 'pollyDefaults', defaults.overlapFile532));
[height355, overlap355Default] = read_default_overlap(fullfile(processInfo.polly_config_folder, 'pollyDefaults', defaults.overlapFile355));
[height387, overlap387Default] = read_default_overlap(fullfile(processInfo.polly_config_folder, 'pollyDefaults', defaults.overlapFile355));

%% interpolate the default overlap
if ~ isempty(overlap355Default)
    overlap355DefaultInterp = interp1(height355, overlap355Default, data.height, 'linear');
else
    overlap355DefaultInterp = NaN(size(data.height));
end
if ~ isempty(overlap387Default)
    overlap387DefaultInterp = interp1(height387, overlap387Default, data.height, 'linear');
else
    overlap387DefaultInterp = NaN(size(data.height));
end
if ~ isempty(overlap532Default)
    overlap532DefaultInterp = interp1(height532, overlap532Default, data.height, 'linear');
else
    overlap532DefaultInterp = NaN(size(data.height));
end
if ~ isempty(overlap607Default)
    overlap607DefaultInterp = interp1(height607, overlap607Default, data.height, 'linear');
else
    overlap607DefaultInterp = NaN(size(data.height));
end

%% saving the results
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = data.height;
overlapAttri.overlap355 = overlap355;
overlapAttri.overlap532 = overlap532;
overlapAttri.overlap387 = overlap387;
overlapAttri.overlap607 = overlap607;
overlapAttri.overlap355_std = overlap355_std;
overlapAttri.overlap532_std = overlap532_std;
overlapAttri.overlap387_std = overlap387_std;
overlapAttri.overlap607_std = overlap607_std;
overlapAttri.overlap355DefaultInterp = overlap355DefaultInterp;
overlapAttri.overlap532DefaultInterp = overlap532DefaultInterp;
overlapAttri.overlap387DefaultInterp = overlap387DefaultInterp;
overlapAttri.overlap607DefaultInterp = overlap607DefaultInterp;

%% append the overlap function to data
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

if isempty(overlap387)
    data.overlap387 = interp1(height387, overlap387Default, data.height, 'linear');
    data.flagOverlapUseDefault387 = true;
else
    data.overlap387 = overlap387;
    data.flagOverlapUseDefault387 = false;
end

if isempty(overlap607)
    data.overlap607 = interp1(height607, overlap607Default, data.height, 'linear');
    data.flagOverlapUseDefault607 = true;
else
    data.overlap607 = overlap607;
    data.flagOverlapUseDefault607 = false;
end

% overlap correction
switch config.overlapCorMode

case {1, 2}

    %% overlap correction
    if config.overlapSmoothBins <= 3
        error('In order to decrease the effects of signal noise on the overlap correction, config.overlapSmoothBins should be set to be larger than 3');
    end

    if config.overlapCorMode == 1
        % overlap correction with using the default overlap function
        overlap355Sm = smooth(overlap355DefaultInterp, config.overlapSmoothBins, 'sgolay', 2);
        overlap532Sm = smooth(overlap532DefaultInterp, config.overlapSmoothBins, 'sgolay', 2);
        overlap387Sm = smooth(overlap387DefaultInterp, config.overlapSmoothBins, 'sgolay', 2);
        overlap607Sm = smooth(overlap607DefaultInterp, config.overlapSmoothBins, 'sgolay', 2);
    elseif config.overlapCorMode == 2
        % overlap correction with using the calculated overlap function in realtime
        overlap355Sm = smooth(data.overlap355, config.overlapSmoothBins, 'sgolay', 2);
        overlap532Sm = smooth(data.overlap532, config.overlapSmoothBins, 'sgolay', 2);
        overlap387Sm = smooth(data.overlap387, config.overlapSmoothBins, 'sgolay', 2);
        overlap607Sm = smooth(data.overlap607, config.overlapSmoothBins, 'sgolay', 2);
    end

    % overlap correction
    data.signal355OverlapCor = OverlapCor(squeeze(data.signal(flag355FR, :, :)), ...
            transpose(overlap355Sm), data.height, data.height(overlapAttri.normRange355));
    data.bg355OverlapCor = OverlapCor(squeeze(data.bg(flag355FR, :, :)), ...
            transpose(overlap355Sm), data.height, data.height(overlapAttri.normRange355));
    data.signal387OverlapCor = OverlapCor(squeeze(data.signal(flag387FR, :, :)), ...
            transpose(overlap387Sm), data.height, data.height(overlapAttri.normRange387));
    data.bg387OverlapCor = OverlapCor(squeeze(data.bg(flag387FR, :, :)), ...
            transpose(overlap387Sm), data.height, data.height(overlapAttri.normRange387));

    data.signal532OverlapCor = OverlapCor(squeeze(data.signal(flag532FR, :, :)), ...
            transpose(overlap532Sm), data.height, data.height(overlapAttri.normRange532));
    data.bg532OverlapCor = OverlapCor(squeeze(data.bg(flag532FR, :, :)), ...
            transpose(overlap532Sm), data.height, data.height(overlapAttri.normRange532));
    data.signal607OverlapCor = OverlapCor(squeeze(data.signal(flag607FR, :, :)), ...
            transpose(overlap607Sm), data.height, data.height(overlapAttri.normRange607));
    data.bg607OverlapCor = OverlapCor(squeeze(data.bg(flag607FR, :, :)), ...
            transpose(overlap607Sm), data.height, data.height(overlapAttri.normRange607));

    % overlap correction for signal at 1064 nm (under test)
    data.signal1064OverlapCor = squeeze(data.signal(flag1064FR, :, :)) ./ ...
                                repmat(overlap532Sm, 1, size(data.signal, 3));
    data.bg1064OverlapCor = squeeze(data.bg(flag1064FR, :, :)) ./ ...
                                repmat(overlap532Sm, 1, size(data.signal, 3));

case 3

    % signal gluing
    data.signal355OverlapCor = SigGlue(squeeze(data.signal(flag355FR, :, :)), ...
                    squeeze(data.signal(flag355NR, :, :)), overlapAttri.sigRatio355, ...
                    data.height, data.height(overlapAttri.normRange355));
    data.bg355OverlapCor = SigGlue(squeeze(data.bg(flag355FR, :, :)), ...
                    squeeze(data.bg(flag355NR, :, :)), overlapAttri.sigRatio355, ...
                    data.height, data.height(overlapAttri.normRange355));
    data.signal387OverlapCor = SigGlue(squeeze(data.signal(flag387FR, :, :)), ...
                    squeeze(data.signal(flag387NR, :, :)), overlapAttri.sigRatio387, ...
                    data.height, data.height(overlapAttri.normRange387));
    data.bg387OverlapCor = SigGlue(squeeze(data.bg(flag387FR, :, :)), ...
                    squeeze(data.bg(flag387NR, :, :)), overlapAttri.sigRatio387, ...
                    data.height, data.height(overlapAttri.normRange387));

    data.signal532OverlapCor = SigGlue(squeeze(data.signal(flag532FR, :, :)), ...
                    squeeze(data.signal(flag532NR, :, :)), overlapAttri.sigRatio532, ...
                    data.height, data.height(overlapAttri.normRange532));
    data.bg532OverlapCor = SigGlue(squeeze(data.bg(flag532FR, :, :)), ...
                    squeeze(data.bg(flag532NR, :, :)), overlapAttri.sigRatio532, ...
                    data.height, data.height(overlapAttri.normRange532));
    data.signal607OverlapCor = SigGlue(squeeze(data.signal(flag607FR, :, :)), ...
                    squeeze(data.signal(flag607NR, :, :)), overlapAttri.sigRatio607, ...
                    data.height, data.height(overlapAttri.normRange607));
    data.bg607OverlapCor = SigGlue(squeeze(data.bg(flag607FR, :, :)), ...
                    squeeze(data.bg(flag607NR, :, :)), overlapAttri.sigRatio607, ...
                    data.height, data.height(overlapAttri.normRange607));

    % overlap correction for signal at 1064 nm (under test)
    data.signal1064OverlapCor = squeeze(data.signal(flag1064FR, :, :));
    data.bg1064OverlapCor = squeeze(data.bg(flag1064FR, :, :));

otherwise
    error('Unknown overlap correction mode %d', config.overlapCorMode);
end

end