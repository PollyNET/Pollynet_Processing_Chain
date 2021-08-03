function pollyDisplayVDR(data)
% POLLYDISPLAYVDR display volume depolarization ratio.
% USAGE:
%    pollyDisplayVDR(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyDataInfo PollyConfig

%% preparing the data
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
mTime = data.mTime;
height = data.height;
figDPI = PicassoConfig.figDPI;
depCalMask = data.depCalMask;
fogMask = data.fogMask;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
yLim_FR_DR = PollyConfig.yLim_FR_DR;
imgFormat = PollyConfig.imgFormat;
colormap_basic = PollyConfig.colormap_basic;
Voldepol355ColorRange = PollyConfig.zLim_VolDepol_355;
Voldepol532ColorRange = PollyConfig.zLim_VolDepol_532;

%% volume depolarization ratio at 355 nm
flag355C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag355nmChannel;
flag355T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;

if (sum(flag355C) == 1) && (sum(flag355T) == 1)

    vdr355 = data.vdr355;
    polCaliEta355 = data.polCaliEta355;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_DR', 'vdr355', 'polCaliEta355', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'Voldepol355ColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayVDR355.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayVDR355.py');
    end
    delete(tmpFile);

end

%% volume depolarization ratio at 532 nm
flag532C = data.flagCrossChannel & data.flagFarRangeChannel & data.flag532nmChannel;
flag532T = data.flagTotalChannel & data.flagFarRangeChannel & data.flag532nmChannel;

if (sum(flag532C) == 1) && (sum(flag532T) == 1)

    vdr532 = data.vdr532;
    polCaliEta532 = data.polCaliEta532;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'mTime', 'height', 'depCalMask', 'fogMask', 'yLim_FR_DR', 'vdr532', 'polCaliEta532', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'Voldepol532ColorRange', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayVDR532.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayVDR532.py');
    end
    delete(tmpFile);

end

end