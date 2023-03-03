function pollyDisplayAttnBsc(data)
% POLLYDISPLAYATTNBSC display attenuated backscatter.
%
% USAGE:
%    pollyDisplayAttnBsc(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-10: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

try
    height = data.height;
    time = data.mTime;
    figDPI = PicassoConfig.figDPI;
    partnerLabel = PollyConfig.partnerLabel;
    flagWatermarkOn = PicassoConfig.flagWatermarkOn;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    att_beta_cRange_355 = PollyConfig.zLim_att_beta_355;
    att_beta_cRange_532 = PollyConfig.zLim_att_beta_532;
    att_beta_cRange_1064 = PollyConfig.zLim_att_beta_1064;
    imgFormat = PollyConfig.imgFormat;
    colormap_basic = PollyConfig.colormap_basic;

    %% 355 nm far-field
    flag355FR = data.flag355nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag355FR) == 1)
        ATT_BETA_355 = data.att_beta_355;
        quality_mask_355 = data.quality_mask_355;
        yLim_att_beta = PollyConfig.yLim_att_beta;
        flagLC355 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed355 = data.LCUsed.LCUsed355;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_355', 'quality_mask_355', 'height', 'time', 'LCUsed355', 'flagLC355', 'att_beta_cRange_355', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc355FR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc355FR.py');
        end
        delete(tmpFile);
    end

    %% 532 nm far-field
    flag532FR = data.flag532nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag532FR) == 1)
        ATT_BETA_532 = data.att_beta_532;
        quality_mask_532 = data.quality_mask_532;
        yLim_att_beta = PollyConfig.yLim_att_beta;
        flagLC532 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed532 = data.LCUsed.LCUsed532;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_532', 'quality_mask_532', 'height', 'time', 'LCUsed532', 'flagLC532', 'att_beta_cRange_532', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc532FR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc532FR.py');
        end
        delete(tmpFile);
    end

    %% 1064 nm far-field
    flag1064FR = data.flag1064nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag1064FR) == 1)
        ATT_BETA_1064 = data.att_beta_1064;
        quality_mask_1064 = data.quality_mask_1064;
        yLim_att_beta = PollyConfig.yLim_att_beta;
        flagLC1064 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed1064 = data.LCUsed.LCUsed1064;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_1064', 'quality_mask_1064', 'height', 'time', 'LCUsed1064', 'flagLC1064', 'att_beta_cRange_1064', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc1064FR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc1064FR.py');
        end
        delete(tmpFile);
    end

    %% 355 nm far-field overlap corrected
    flag355FR = data.flag355nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag355FR) == 1) && (PollyConfig.overlapCorMode ~= 0)
        ATT_BETA_355 = data.att_beta_OC_355;
        quality_mask_355 = data.quality_mask_355;
        yLim_att_beta = PollyConfig.yLim_OC_att_beta;
        flagLC355 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed355 = data.LCUsed.LCUsed355;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_355', 'quality_mask_355', 'height', 'time', 'LCUsed355', 'flagLC355', 'att_beta_cRange_355', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc355FROC.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc355FROC.py');
        end
        delete(tmpFile);
    end

    %% 532 nm far-field overlap corrected
    flag532FR = data.flag532nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag532FR) == 1) && (PollyConfig.overlapCorMode ~= 0)
        ATT_BETA_532 = data.att_beta_OC_532;
        quality_mask_532 = data.quality_mask_532;
        yLim_att_beta = PollyConfig.yLim_OC_att_beta;
        flagLC532 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed532 = data.LCUsed.LCUsed532;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_532', 'quality_mask_532', 'height', 'time', 'LCUsed532', 'flagLC532', 'att_beta_cRange_532', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc532FROC.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc532FROC.py');
        end
        delete(tmpFile);
    end

    %% 1064 nm far-field overlap corrected
    flag1064FR = data.flag1064nmChannel & data.flagFarRangeChannel & data.flagTotalChannel;
    if (sum(flag1064FR) == 1) && (PollyConfig.overlapCorMode ~= 0)
        ATT_BETA_1064 = data.att_beta_OC_1064;
        quality_mask_1064 = data.quality_mask_1064;
        yLim_att_beta = PollyConfig.yLim_OC_att_beta;
        flagLC1064 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed1064 = data.LCUsed.LCUsed1064;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_1064', 'quality_mask_1064', 'height', 'time', 'LCUsed1064', 'flagLC1064', 'att_beta_cRange_1064', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc1064FROC.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc1064FROC.py');
        end
        delete(tmpFile);
    end

    %% 355 nm near-field
    flag355NR = data.flag355nmChannel & data.flagNearRangeChannel & data.flagTotalChannel;
    if (sum(flag355NR) == 1)
        ATT_BETA_355 = data.att_beta_NR_355;
        quality_mask_355 = data.quality_mask_355;
        yLim_att_beta = PollyConfig.yLim_att_beta_NR;
        flagLC355 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed355 = data.LCUsed.LCUsed355NR;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_355', 'quality_mask_355', 'height', 'time', 'LCUsed355', 'flagLC355', 'att_beta_cRange_355', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc355NR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc355NR.py');
        end
        delete(tmpFile);
    end

    %% 532 nm near-field
    flag532NR = data.flag532nmChannel & data.flagNearRangeChannel & data.flagTotalChannel;
    if (sum(flag532NR) == 1)
        ATT_BETA_532 = data.att_beta_NR_532;
        quality_mask_532 = data.quality_mask_532;
        yLim_att_beta = PollyConfig.yLim_att_beta_NR;
        flagLC532 = char(PollyConfig.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1});
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
        LCUsed532 = data.LCUsed.LCUsed532NR;

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end

        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'ATT_BETA_532', 'quality_mask_532', 'height', 'time', 'LCUsed532', 'flagLC532', 'att_beta_cRange_532', 'yLim_att_beta', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAttnBsc532NR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAttnBsc532NR.py');
        end
        delete(tmpFile);
    end

catch
    warning('Failure in producing attenuated backscatter plot.');
end

end