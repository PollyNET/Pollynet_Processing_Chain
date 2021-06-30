function pollyDisplayOCProfiles(data)
% POLLYDISPLAYPROFILES display (overlap-corrected) averaged profiles.
% USAGE:
%    pollyDisplayOCProfiles(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-11: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

if isempty(data.rawSignal) || (PollyConfig.overlapCorMode == 0)
    return;
end

%% initial the channels
imgFormat = PollyConfig.imgFormat;
partnerLabel = PollyConfig.partnerLabel;
smoothWin_355 = PollyConfig.smoothWin_klett_355;
smoothWin_532 = PollyConfig.smoothWin_klett_532;
smoothWin_1064 = PollyConfig.smoothWin_klett_1064;
smoothWin_NR_355 = PollyConfig.smoothWin_klett_355;
smoothWin_NR_532 = PollyConfig.smoothWin_klett_532;
yLim_Profi_Ext = PollyConfig.yLim_Profi_Ext;
yLim_Profi_LR = PollyConfig.yLim_Profi_LR;
yLim_Profi_DR = PollyConfig.yLim_Profi_DR;
yLim_Profi_Bsc = PollyConfig.yLim_Profi_Bsc;
yLim_Profi_WV_RH = PollyConfig.yLim_Profi_WV_RH;
yLim_FR_RCS = PollyConfig.yLim_FR_RCS;
yLim_NR_RCS = PollyConfig.yLim_NR_RCS;
xLim_Profi_Bsc = PollyConfig.xLim_Profi_Bsc;
xLim_Profi_NR_Bsc = PollyConfig.xLim_Profi_NR_Bsc;
xLim_Profi_Ext = PollyConfig.xLim_Profi_Ext;
xLim_Profi_NR_Ext = PollyConfig.xLim_Profi_NR_Ext;
xLim_Profi_WV_RH = PollyConfig.xLim_Profi_WV_RH;
xLim_Profi_RCS = PollyConfig.xLim_Profi_RCS;
xLim_Profi_LR = PollyConfig.xLim_Profi_LR;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
figDPI = PicassoConfig.figDPI;

height = data.height;
time = data.mTime;
flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag1064FR = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel;
flag387FR = data.flagFarRangeChannel & data.flag387nmChannel;
flag607FR = data.flagFarRangeChannel & data.flag607nmChannel;
flag387NR = data.flagNearRangeChannel & data.flag387nmChannel;
flag607NR = data.flagNearRangeChannel & data.flag607nmChannel;
flag407FR = data.flagFarRangeChannel & data.flag407nmChannel;
flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag355C = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;

%% data visualization for each cloud free period
for iGrp = 1:size(data.clFreGrps, 1)
    startInd = data.clFreGrps(iGrp, 1);
    endInd = data.clFreGrps(iGrp, 2);
    
    % meteor data
    meteorSource = data.meteorAttri.dataSource{iGrp};
    temperature = data.temperature(iGrp, :);
    pressure = data.pressure(iGrp, :);

    %% signal profile
    if sum(flag355FR) == 1
        sig355 = squeeze(transpose(mean(data.sigOLCor355(:, startInd:endInd), 2))) / mean(data.mShots(flag355FR, startInd:endInd), 2) * 150 / data.hRes;
    else
        sig355 = NaN(1, size(data.signal, 2));
    end
    rcs355 = sig355 .* data.height.^2;
    rcs355 = transpose(smooth(rcs355, smoothWin_355));
    if sum(flag532FR) == 1
        sig532 = squeeze(transpose(mean(data.sigOLCor532(:, startInd:endInd), 2))) / mean(data.mShots(flag532FR, startInd:endInd), 2) * 150 / data.hRes;
    else
        sig532 = NaN(1, size(data.signal, 2));
    end
    rcs532 = sig532 .* data.height.^2;
    rcs532 = transpose(smooth(rcs532, smoothWin_532));
    if sum(flag1064FR) == 1
        sig1064 = squeeze(transpose(mean(data.sigOLCor1064(:, startInd:endInd), 2))) / mean(data.mShots(flag1064FR, startInd:endInd), 2) * 150 / data.hRes;
    else
        sig1064 = NaN(1, size(data.signal, 2));
    end
    rcs1064 = sig1064 .* data.height.^2;
    rcs1064 = transpose(smooth(rcs1064, smoothWin_1064));

    % molecule signal
    [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGrp, :), data.temperature(iGrp, :) + 273.17, 380, 70);
    molRCS355 = molBsc355 .* exp(- 2 * cumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]));
    molRCS532 = molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));
    molRCS1064 = molBsc1064 .* exp(- 2 * cumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]));

    % normalize the range-corrected signal to molecular signal
    if (~ isnan(data.refHInd355(iGrp, 1))) && (sum(flag355FR) == 1)
        % according to the ratio at the reference height
        factor355 = sum(molRCS355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2))) / sum(rcs355(data.refHInd355(iGrp, 1):data.refHInd355(iGrp, 2)));
        rcs355 = rcs355 * factor355;
    elseif sum(flag355FR) == 1 
        % if no reference height was found, using the lidar constants
        rcs355 = rcs355 / data.LCUsed.LCUsed355 * mean(data.mShots(flag355FR, startInd:endInd), 2) / 150 * data.hRes;
    else
        rcs355 = NaN(1, length(data.height));
    end
    if (~ isnan(data.refHInd532(iGrp, 1))) && (sum(flag532FR) == 1)
        % according to the ratio at the reference height
        factor532 = sum(molRCS532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2))) / sum(rcs532(data.refHInd532(iGrp, 1):data.refHInd532(iGrp, 2)));
        rcs532 = rcs532 * factor532;
    elseif sum(flag532FR) == 1 
        % if no reference height was found, using the lidar constants
        rcs532 = rcs532 / data.LCUsed.LCUsed532 * mean(data.mShots(flag532FR, startInd:endInd), 2) / 150 * data.hRes;
    else
        rcs532 = NaN(1, length(data.height));
    end
    if (~ isnan(data.refHInd1064(iGrp, 1))) && (sum(flag1064FR) == 1)
        % according to the ratio at the reference height
        factor1064 = sum(molRCS1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2))) / sum(rcs1064(data.refHInd1064(iGrp, 1):data.refHInd1064(iGrp, 2)));
        rcs1064 = rcs1064 * factor1064;
    elseif sum(flag1064FR) == 1 
        % if no reference height was found, using the lidar constants
        rcs1064 = rcs1064 / data.LCUsed.LCUsed1064 * mean(data.mShots(flag1064FR, startInd:endInd), 2) / 150 * data.hRes;
    else
        rcs1064 = NaN(1, length(data.height));
    end

    % reference height
    refHInd355 = [data.refHInd355(iGrp, 1), data.refHInd355(iGrp, 2)];
    refHInd532 = [data.refHInd532(iGrp, 1), data.refHInd532(iGrp, 2)];
    refHInd1064 = [data.refHInd1064(iGrp, 1), data.refHInd1064(iGrp, 2)];

    % display range corrected signal
    pyFolder = fileparts(mfilename('fullpath'));   % folder of python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'startInd', 'endInd', 'rcs355', 'rcs532', 'rcs1064', 'height', 'time', 'molRCS355', 'molRCS532', 'molRCS1064', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_FR_RCS', 'xLim_Profi_RCS', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCRCS.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayOCRCS.py');
    end
    delete(tmpFile);

    %% backscatter (Klett method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        aerBsc_355_klett = data.aerBsc355_OC_klett(iGrp, :);
        aerBsc_532_klett = data.aerBsc532_OC_klett(iGrp, :);
        aerBsc_1064_klett = data.aerBsc1064_OC_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCBscKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCBscKlett.py');
        end
        delete(tmpFile);
    end

    %% backscatter (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        aerBsc_355_raman = data.aerBsc355_OC_raman(iGrp, :);
        aerBsc_532_raman = data.aerBsc532_OC_raman(iGrp, :);
        aerBsc_1064_raman = data.aerBsc1064_OC_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCBscRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCBscRaman.py');
        end
        delete(tmpFile);
    end

    %% extinction (Klett method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        aerExt_355_klett = data.aerExt355_OC_klett(iGrp, :);
        aerExt_532_klett = data.aerExt532_OC_klett(iGrp, :);
        aerExt_1064_klett = data.aerExt1064_OC_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_klett', 'aerExt_532_klett', 'aerExt_1064_klett', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'xLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCExtKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCExtKlett.py');
        end
        delete(tmpFile);
    end

    %% extinction (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        aerExt_355_raman = data.aerExt355_OC_raman(iGrp, :);
        aerExt_532_raman = data.aerExt532_OC_raman(iGrp, :);
        aerExt_1064_raman = data.aerExt1064_OC_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_raman', 'aerExt_532_raman', 'aerExt_1064_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'xLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCExtRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCExtRaman.py');
        end
        delete(tmpFile);
    end

    %% lidar ratio (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        LR355_raman = data.LR355_OC_raman(iGrp, :);
        LR532_raman = data.LR532_OC_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'LR355_raman', 'LR532_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_LR', 'xLim_Profi_LR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCLRRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCLRRaman.py');
        end
        delete(tmpFile);
    end

    %% Ångström exponent (Klett method based on far-field signal)
    if ((sum(flag355FR) == 1) + (sum(flag532FR) == 1) + sum(flag1064FR)) >= 2
        AE_Bsc_355_532_klett = data.AE_Bsc_355_532_OC_klett(iGrp, :);
        AE_Bsc_532_1064_klett = data.AE_Bsc_532_1064_OC_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'AE_Bsc_355_532_klett', 'AE_Bsc_532_1064_klett', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCAEKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCAEKlett.py');
        end
        delete(tmpFile);
    end

    %% Ångström exponent (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) + (sum(flag532FR) == 1) + sum(flag1064FR)) >= 2
        AE_Bsc_355_532_raman = data.AE_Bsc_355_532_OC_raman(iGrp, :);
        AE_Bsc_532_1064_raman = data.AE_Bsc_532_1064_OC_raman(iGrp, :);
        AE_Ext_355_532_raman = data.AE_Ext_355_532_OC_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'AE_Bsc_355_532_raman', 'AE_Bsc_532_1064_raman', 'AE_Ext_355_532_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCAERaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCAERaman.py');
        end
        delete(tmpFile);
    end

    %% Volume/particle depolarization ratio (Klett method based on far-field signal)
    if ((sum(flag355FR) == 1) && (sum(flag355C) == 1)) || ((sum(flag532FR) == 1) && (sum(flag532C) == 1))
        vdr355_klett = data.vdr355_klett(iGrp, :);
        vdr532_klett = data.vdr532_klett(iGrp, :);
        pdr355_klett = data.pdr355_OC_klett(iGrp, :);
        pdr532_klett = data.pdr532_OC_klett(iGrp, :);
        pdrStd355_klett = data.pdrStd355_OC_klett(iGrp, :);
        pdrStd532_klett = data.pdrStd532_OC_klett(iGrp, :);
        flag_pdr355_klett = (abs(pdrStd355_klett ./ pdr355_klett) > 0.6) | ...
                                 (pdrStd355_klett > 0.5) | ...
                                 (vdr355_klett < data.mdr355(iGrp)) | ...
                                 (pdr355_klett <= 0);
        pdr355_klett(flag_pdr355_klett) = NaN;
        flag_pdr532_klett = (abs(pdrStd532_klett ./ pdr532_klett) > 0.6) | ...
                                 (pdrStd532_klett > 0.5) | ...
                                 (vdr532_klett < data.mdr532(iGrp)) | ...
                                 (pdr532_klett <= 0);
        pdr532_klett(flag_pdr532_klett) = NaN;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'vdr355_klett', 'vdr532_klett', 'pdr355_klett', 'pdr532_klett', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_DR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCDRKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCDRKlett.py');
        end
        delete(tmpFile);
    end

    %% Volume/particle depolarization ratio (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) && (sum(flag355C) == 1)) || ((sum(flag532FR) == 1) && (sum(flag532C) == 1))
        vdr355_raman = data.vdr355_raman(iGrp, :);
        vdr532_raman = data.vdr532_raman(iGrp, :);
        pdr355_raman = data.pdr355_OC_raman(iGrp, :);
        pdr532_raman = data.pdr532_OC_raman(iGrp, :);
        pdrStd355_raman = data.pdrStd355_OC_raman(iGrp, :);
        pdrStd532_raman = data.pdrStd532_OC_raman(iGrp, :);
        flag_pdr355_raman = (abs(pdrStd355_raman ./ pdr355_raman) > 0.6) | ...
                                 (pdrStd355_raman > 0.5) | ...
                                 (vdr355_raman < data.mdr355(iGrp)) | ...
                                 (pdr355_raman <= 0);
        pdr355_raman(flag_pdr355_raman) = NaN;
        flag_pdr532_raman = (abs(pdrStd532_raman ./ pdr532_raman) > 0.6) | ...
                                 (pdrStd532_raman > 0.5) | ...
                                 (vdr532_raman < data.mdr532(iGrp)) | ...
                                 (pdr532_raman <= 0);
        pdr532_raman(flag_pdr532_raman) = NaN;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'vdr355_raman', 'vdr532_raman', 'pdr355_raman', 'pdr532_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_DR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOCDRRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayOCDRRaman.py');
        end
        delete(tmpFile);
    end

end

end