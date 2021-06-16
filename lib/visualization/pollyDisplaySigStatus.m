function pollyDisplaySigStatus(data)
% POLLYDISPLAYSIGSTATUS display signal status.
% USAGE:
%    pollyDisplaySigStatus(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

time = data.mTime;
figDPI = PicassoConfig.figDPI;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
height = data.height;
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');

yLim_FR_RCS = PollyConfig.yLim_FR_RCS;
yLim_NR_RCS = PollyConfig.yLim_NR_RCS;
yLim_WV_RH = PollyConfig.yLim_WV_RH;
imgFormat = PollyConfig.imgFormat;

%% 355 nm far-field signal
flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;

if (sum(flag355FR) == 1)
    SAT_FR_355 = double(squeeze(data.flagSaturation(flag355FR, :, :)));
    SAT_FR_355(data.lowSNRMask(flag355FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_355', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus355FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus355FR.py');
    end
    delete(tmpFile);
end

%% 355 nm far-field cross signal
flag355CFR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;

if (sum(flag355CFR) == 1)
    SAT_FR_355C = double(squeeze(data.flagSaturation(flag355CFR, :, :)));
    SAT_FR_355C(data.lowSNRMask(flag355CFR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_355C', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus355CFR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus355CFR.py');
    end
    delete(tmpFile);
end

%% 387 nm far-field signal
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;

if (sum(flag387FR) == 1)
    SAT_FR_387 = double(squeeze(data.flagSaturation(flag387FR, :, :)));
    SAT_FR_387(data.lowSNRMask(flag387FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_387', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus387FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus387FR.py');
    end
    delete(tmpFile);
end

%% 407 nm far-field signal
flag407FR = data.flagFarRangeChannel & data.flag407nmChannel;

if (sum(flag407FR) == 1)
    SAT_FR_407 = double(squeeze(data.flagSaturation(flag407FR, :, :)));
    SAT_FR_407(data.lowSNRMask(flag407FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_407', 'yLim_WV_RH', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus407FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus407FR.py');
    end
    delete(tmpFile);
end

%% 532 nm far-field signal
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;

if (sum(flag532FR) == 1)
    SAT_FR_532 = double(squeeze(data.flagSaturation(flag532FR, :, :)));
    SAT_FR_532(data.lowSNRMask(flag532FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_532', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus532FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus532FR.py');
    end
    delete(tmpFile);
end

%% 532 nm far-field cross signal
flag532CFR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;

if (sum(flag532CFR) == 1)
    SAT_FR_532C = double(squeeze(data.flagSaturation(flag532CFR, :, :)));
    SAT_FR_532C(data.lowSNRMask(flag532CFR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_532C', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus532CFR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus532CFR.py');
    end
    delete(tmpFile);
end

%% 607 nm far-field signal
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;

if (sum(flag607FR) == 1)
    SAT_FR_607 = double(squeeze(data.flagSaturation(flag607FR, :, :)));
    SAT_FR_607(data.lowSNRMask(flag607FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_607', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus607FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus607FR.py');
    end
    delete(tmpFile);
end

%% 1064 nm far-field signal
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;

if (sum(flag1064FR) == 1)
    SAT_FR_1064 = double(squeeze(data.flagSaturation(flag1064FR, :, :)));
    SAT_FR_1064(data.lowSNRMask(flag1064FR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_FR_1064', 'yLim_FR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus1064FR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus1064FR.py');
    end
    delete(tmpFile);
end

%% 355 nm near-field signal
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;

if (sum(flag355NR) == 1)
    SAT_NR_355 = double(squeeze(data.flagSaturation(flag355NR, :, :)));
    SAT_NR_355(data.lowSNRMask(flag355NR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_NR_355', 'yLim_NR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus355NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus355NR.py');
    end
    delete(tmpFile);
end

%% 387 nm near-field signal
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;

if (sum(flag387NR) == 1)
    SAT_NR_387 = double(squeeze(data.flagSaturation(flag387NR, :, :)));
    SAT_NR_387(data.lowSNRMask(flag387NR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_NR_387', 'yLim_NR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus387NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus387NR.py');
    end
    delete(tmpFile);
end

%% 532 nm near-field signal
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;

if (sum(flag532NR) == 1)
    SAT_NR_532 = double(squeeze(data.flagSaturation(flag532NR, :, :)));
    SAT_NR_532(data.lowSNRMask(flag532NR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_NR_532', 'yLim_NR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus532NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus532NR.py');
    end
    delete(tmpFile);
end

%% 607 nm near-field signal
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;

if (sum(flag607NR) == 1)
    SAT_NR_607 = double(squeeze(data.flagSaturation(flag607NR, :, :)));
    SAT_NR_607(data.lowSNRMask(flag607NR, :, :)) = 2;
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
    
    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'time', 'height', 'xtick', 'xtickstr', 'SAT_NR_607', 'yLim_NR_RCS', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplaySigStatus607NR.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplaySigStatus607NR.py');
    end
    delete(tmpFile);
end

end