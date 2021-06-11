function pollyDisplayRCS(data)
% POLLYDISPLAYRCS display range corrected signal.
% USAGE:
%    pollyDisplayRCS(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-09: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global CampaignConfig PicassoConfig PollyConfig PollyDataInfo

%% preparing the data
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
mTime = data.mTime;
height = data.height;
figDPI = PicassoConfig.figDPI;
depCalMask = data.depCalMask;
fogMask = data.fogMask;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
imgFormat = PollyConfig.imgFormat;
colormap_basic = PollyConfig.colormap_basic;

yLim_FR_RCS = PollyConfig.yLim_FR_RCS;
yLim_NR_RCS = PollyConfig.yLim_NR_RCS;

%% 355 nm far-range total channel
flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;

if (sum(flag355FR) == 1)
    RCS_FR_355 = squeeze(data.signal(flag355FR, :, :)) ./ repmat(data.mShots(flag355FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

    if PollyConfig.flagAutoscaleRCS
        RCS355FRColorRange = auto_RCS_cRange(data.height, RCS_FR_355, 'hRange', [0, 4000] ./ 1e6);
    else
        RCS355FRColorRange = PollyConfig.zLim_FR_RCS_355;
    end

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_RCS', 'RCS_FR_355', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'RCS355FRColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS355FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS355FR.py');
    end
    delete(tmpFile);
end

%% 532 nm far-range total channel
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;

if (sum(flag532FR) == 1)
    RCS_FR_532 = squeeze(data.signal(flag532FR, :, :)) ./ repmat(data.mShots(flag532FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

    if PollyConfig.flagAutoscaleRCS
        RCS532FRColorRange = auto_RCS_cRange(data.height, RCS_FR_532, 'hRange', [0, 4000] ./ 1e6);
    else
        RCS532FRColorRange = PollyConfig.zLim_FR_RCS_532;
    end

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_RCS', 'RCS_FR_532', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'RCS532FRColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS532FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS532FR.py');
    end
    delete(tmpFile);
end

%% 1064 nm far-range total channel
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;

if (sum(flag1064FR) == 1)
    RCS_FR_1064 = squeeze(data.signal(flag1064FR, :, :)) ./ repmat(data.mShots(flag1064FR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

    if PollyConfig.flagAutoscaleRCS
        RCS1064FRColorRange = auto_RCS_cRange(data.height, RCS_FR_1064, 'hRange', [0, 4000] ./ 1e6);
    else
        RCS1064FRColorRange = PollyConfig.zLim_FR_RCS_1064;
    end

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_RCS', 'RCS_FR_1064', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'RCS1064FRColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS1064FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS1064FR.py');
    end
    delete(tmpFile);
end

%% 355 nm near-range total channel
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;

if (sum(flag355NR) == 1)
    RCS_NR_355 = squeeze(data.signal(flag355NR, :, :)) ./ repmat(data.mShots(flag355NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

    if PollyConfig.flagAutoscaleRCS
        RCS355NRColorRange = auto_RCS_cRange(data.height, RCS_NR_355, 'hRange', [0, 3000] ./ 1e6);
    else
        RCS355NRColorRange = PollyConfig.zLim_NR_RCS_355;
    end

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_NR_RCS', 'RCS_NR_355', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'RCS355NRColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS355NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS355NR.py');
    end
    delete(tmpFile);
end

%% 532 nm near-range total channel
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;

if (sum(flag532NR) == 1)
    RCS_NR_532 = squeeze(data.signal(flag532NR, :, :)) ./ repmat(data.mShots(flag532NR, :), numel(data.height), 1) * 150 / double(data.hRes) .* repmat(transpose(data.height), 1, numel(data.mTime)).^2;

    if PollyConfig.flagAutoscaleRCS
        RCS532NRColorRange = auto_RCS_cRange(data.height, RCS_NR_532, 'hRange', [0, 3000] ./ 1e6);
    else
        RCS532NRColorRange = PollyConfig.zLim_NR_RCS_532;
    end

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_NR_RCS', 'RCS_NR_532', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'RCS532NRColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS532NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS532NR.py');
    end
    delete(tmpFile);
end

end