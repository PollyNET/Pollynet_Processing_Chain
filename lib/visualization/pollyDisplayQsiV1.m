function pollyDisplayQsiV1(data)
% POLLYDISPLAYQSIV1 display quasi-retrieved prodcuts (V1)
% USAGE:
%    pollyDisplayQsiV1(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

height = data.height;
time = data.mTime;
figDPI = PicassoConfig.figDPI;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
yLim_Quasi_Params = PollyConfig.yLim_Quasi_Params;
quasi_Par_DR_cRange_532 = PollyConfig.zLim_quasi_Par_DR_532;
quasi_beta_cRange_355 = PollyConfig.zLim_quasi_beta_355;
quasi_beta_cRange_532 = PollyConfig.zLim_quasi_beta_532;
quasi_beta_cRange_1064 = PollyConfig.zLim_quasi_beta_1064;
[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
imgFormat = PollyConfig.imgFormat;
colormap_basic = PollyConfig.colormap_basic;

flag355 = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
if (sum(flag355) == 1)
    % save quasi-retrieved backscatter at 355 nm
    quasi_bsc_355 = data.qsiBsc355V1;
    quality_mask_355 = data.quality_mask_355;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_bsc_355', 'quality_mask_355', 'quasi_beta_cRange_355', 'yLim_Quasi_Params', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayQsiBsc355V1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayQsiBsc355V1.py');
    end
    delete(tmpFile);
end

flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
if (sum(flag532) == 1)
    % save quasi-retrieved backscatter at 532 nm
    quasi_bsc_532 = data.qsiBsc532V1;
    quality_mask_532 = data.quality_mask_532;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_bsc_532', 'quality_mask_532', 'quasi_beta_cRange_532', 'yLim_Quasi_Params', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayQsiBsc532V1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayQsiBsc532V1.py');
    end
    delete(tmpFile);
end

flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
if (sum(flag1064) == 1)
    % save quasi-retrieved backscatter at 1064 nm
    quasi_bsc_1064 = data.qsiBsc1064V1;
    quality_mask_1064 = data.quality_mask_1064;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_bsc_1064', 'quality_mask_1064', 'quasi_beta_cRange_1064', 'yLim_Quasi_Params', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayQsiBsc1064V1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayQsiBsc1064V1.py');
    end
    delete(tmpFile);
end

flag532T = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
if (sum(flag532T) == 1) && (sum(flag532C) == 1)
    % save quasi-retrieved particle depolarization ratio at 532 nm
    quasi_pdr_532 = data.qsiPDR532V1;
    quality_mask_532 = data.quality_mask_532;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_pdr_532', 'quality_mask_532', 'yLim_Quasi_Params', 'quasi_Par_DR_cRange_532', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayQsiPDR532V1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayQsiPDR532V1.py');
    end
    delete(tmpFile);
end

flag532 = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagCrossChannel;
if (sum(flag532) == 1) && (sum(flag1064) == 1)
    % save quasi-retrieved particle depolarization ratio at 532 nm
    quasi_ang_532_1064 = data.qsiAE_532_1064_V1;
    quality_mask_532 = data.quality_mask_532;
    quality_mask_1064 = data.quality_mask_1064;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display quasi results
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'quasi_ang_532_1064', 'quality_mask_532', 'quality_mask_1064', 'yLim_Quasi_Params', 'quas', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayQsiAE_532_1064V1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayQsiAE_532_1064V1.py');
    end
    delete(tmpFile);
end

end