function pollyDisplayProfiles(data)
% POLLYDISPLAYPROFILES display averaged profiles.
%
% USAGE:
%    pollyDisplayProfiles(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-11: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

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
yLim_beta_532_Poliphon =PollyConfig.yLim_beta_532_Poliphon;
zLim_att_beta_355 = PollyConfig.zLim_att_beta_355;
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
xLim_beta_532_Poliphon =PollyConfig.xLim_beta_532_Poliphon;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;
figDPI = PicassoConfig.figDPI;
if length(PollyConfig.refH_NR_355) == 2
    refHBaseNR355 = PollyConfig.refH_NR_355(1);
    refHTopNR355 = PollyConfig.refH_NR_355(2);
else
    refHBaseNR355 = NaN;
    refHTopNR355 = NaN;
end
if length(PollyConfig.refH_NR_532) == 2
    refHBaseNR532 = PollyConfig.refH_NR_532(1);
    refHTopNR532 = PollyConfig.refH_NR_532(2);
else
    refHBaseNR532 = NaN;
    refHTopNR532 = NaN;
end

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
flag1064C = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagCrossChannel;
flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag355C = data.flagFarRangeChannel & data.flag355nmChannel & data.flagCrossChannel;
flag355RR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagRotRamanChannel;
flag532RR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagRotRamanChannel;
flag1064RR = data.flag1064nmChannel & data.flagRotRamanChannel;

%% data visualization for each cloud free period

Grp_length = size(data.clFreGrps, 1);
Grp_past = 2;

if PicassoConfig.flagPlotLastProfilesOnly
    Grp_past_str = Grp_past + 1;
    str = sprintf('plotting only last %d profiles', Grp_past_str);
    disp(str);
    if Grp_length > Grp_past
        Grp_length_start = Grp_length - Grp_past;
    else
        Grp_length_start = 1;
    end
else
    disp('plotting all profiles');
    Grp_length_start = 1;
end


for iGrp  = Grp_length_start:Grp_length
%for iGrp = 1:size(data.clFreGrps, 1)
    startInd = data.clFreGrps(iGrp, 1);
    endInd = data.clFreGrps(iGrp, 2);

    starttime = datestr(data.mTime(startInd),'HHMM');
    endtime = datestr(data.mTime(endInd),'HHMM');
    fprintf('profile-slice Nr.: %d:\n',iGrp)
    fprintf('from time: %s to: %s.\n',starttime,endtime)

    % meteor data
    meteorSource = data.meteorAttri.dataSource{iGrp};
    temperature = data.temperature(iGrp, :);
    pressure = data.pressure(iGrp, :);

    %% signal profile
    if sum(flag355FR) == 1
        sig355 = squeeze(mean(data.signal(flag355FR, :, startInd:endInd), 3)) / mean(data.mShots(flag355FR, startInd:endInd), 2) * 150 / data.hRes;
    else
        sig355 = NaN(1, size(data.signal, 2));
    end
    rcs355 = sig355 .* data.height.^2;
    rcs355 = transpose(smooth(rcs355, smoothWin_355));
    if sum(flag532FR) == 1
        sig532 = squeeze(mean(data.signal(flag532FR, :, startInd:endInd), 3)) / mean(data.mShots(flag532FR, startInd:endInd), 2) * 150 / data.hRes;
    else
        sig532 = NaN(1, size(data.signal, 2));
    end
    rcs532 = sig532 .* data.height.^2;
    rcs532 = transpose(smooth(rcs532, smoothWin_532));
    if sum(flag1064FR) == 1
        sig1064 = squeeze(mean(data.signal(flag1064FR, :, startInd:endInd), 3)) / mean(data.mShots(flag1064FR, startInd:endInd), 2) * 150 / data.hRes;
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
    print_msg('--> range corrected signal.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
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
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRCS.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayRCS.py');
    end
    delete(tmpFile);

    %% backscatter (Klett method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        print_msg('--> backscatter (Klett method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc_355_klett = data.aerBsc355_klett(iGrp, :);
        aerBsc_532_klett = data.aerBsc532_klett(iGrp, :);
        aerBsc_1064_klett = data.aerBsc1064_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscKlett.py');
        end
        delete(tmpFile);
    end

    %% backscatter (Klett method based on near-field signal)
    if ((sum(flag355NR) == 1) || (sum(flag532NR) == 1)) && ((sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1))
        print_msg('--> backscatter (Klett method based on near-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc_355_klett = data.aerBsc355_klett(iGrp, :);
        aerBsc_532_klett = data.aerBsc532_klett(iGrp, :);
        aerBsc_1064_klett = data.aerBsc1064_klett(iGrp, :);
        aerBsc355_NR_klett = data.aerBsc355_NR_klett(iGrp, :);
        aerBsc532_NR_klett = data.aerBsc532_NR_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'aerBsc355_NR_klett', 'aerBsc532_NR_klett', 'refHBaseNR355', 'refHTopNR355', 'refHBaseNR532', 'refHTopNR532', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'xLim_Profi_NR_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscKlettNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscKlettNR.py');
        end
        delete(tmpFile);
    end

    %% backscatter (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        print_msg('--> backscatter (Raman method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc_355_raman = data.aerBsc355_raman(iGrp, :);
        aerBsc_532_raman = data.aerBsc532_raman(iGrp, :);
        aerBsc_1064_raman = data.aerBsc1064_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscRaman.py');
        end
        delete(tmpFile);
    end

    %% backscatter (Rotation Raman method)
    is355RRRetAvail = ((sum(flag355FR) == 1) && (sum(flag355RR) == 1));
    is532RRRetAvail = ((sum(flag532FR) == 1) && (sum(flag532RR) == 1));
    is1064RRRetAvail = ((sum(flag1064FR) == 1) && (sum(flag1064RR) == 1));
    if is355RRRetAvail || is532RRRetAvail || is1064RRRetAvail
        print_msg('--> backscatter (Rotation Raman method).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc_355_RR = data.aerBsc355_RR(iGrp, :);
        aerBsc_532_RR = data.aerBsc532_RR(iGrp, :);
        aerBsc_1064_RR = data.aerBsc1064_RR(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_RR', 'aerBsc_532_RR', 'aerBsc_1064_RR', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscRR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscRR.py');
        end
        delete(tmpFile);
    end

    %% backscatter (Raman method based on near-field signal)
    if ((sum(flag355NR) == 1) || (sum(flag532NR) == 1)) && ((sum(flag387NR) == 1) || (sum(flag607NR) == 1))
        print_msg('--> backscatter (Raman method based on near-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc355_NR_raman = data.aerBsc355_NR_raman(iGrp, :);
        aerBsc532_NR_raman = data.aerBsc532_NR_raman(iGrp, :);
        aerBsc_355_raman = data.aerBsc355_raman(iGrp, :);
        aerBsc_532_raman = data.aerBsc532_raman(iGrp, :);
        aerBsc_1064_raman = data.aerBsc1064_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'aerBsc355_NR_raman', 'refHBaseNR355', 'refHTopNR355', 'refHBaseNR532', 'refHTopNR532', 'aerBsc532_NR_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'xLim_Profi_NR_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscRamanNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscRamanNR.py');
        end
        delete(tmpFile);
    end

    %% backscatter (AOD-constrained method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        print_msg('--> backscatter (AOD-constrained method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerBsc_355_aeronet = data.aerBsc355_aeronet(iGrp, :);
        aerBsc_532_aeronet = data.aerBsc532_aeronet(iGrp, :);
        aerBsc_1064_aeronet = data.aerBsc1064_aeronet(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_355_aeronet', 'aerBsc_532_aeronet', 'aerBsc_1064_aeronet', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Bsc', 'xLim_Profi_Bsc', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayBscAERONET.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayBscAERONET.py');
        end
        delete(tmpFile);
    end

    %% extinction (Klett method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        print_msg('--> extinction (Klett method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt_355_klett = data.aerExt355_klett(iGrp, :);
        aerExt_532_klett = data.aerExt532_klett(iGrp, :);
        aerExt_1064_klett = data.aerExt1064_klett(iGrp, :);
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
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtKlett.py');
        end
        delete(tmpFile);
    end

    %% extinction (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        print_msg('--> extinction (Raman method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt_355_raman = data.aerExt355_raman(iGrp, :);
        aerExt_532_raman = data.aerExt532_raman(iGrp, :);
        aerExt_1064_raman = data.aerExt1064_raman(iGrp, :);
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
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtRaman.py');
        end
        delete(tmpFile);
    end

    %% extinction (rotation Raman method)
    is355RRRetAvail = ((sum(flag355FR) == 1) && (sum(flag355RR) == 1));
    is532RRRetAvail = ((sum(flag532FR) == 1) && (sum(flag532RR) == 1));
    is1064RRRetAvail = ((sum(flag1064FR) == 1) && (sum(flag1064RR) == 1));
    if is355RRRetAvail || is532RRRetAvail || is1064RRRetAvail
        print_msg('--> extinction (RR method).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt_355_RR = data.aerExt355_RR(iGrp, :);
        aerExt_532_RR = data.aerExt532_RR(iGrp, :);
        aerExt_1064_RR = data.aerExt1064_RR(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_RR', 'aerExt_532_RR', 'aerExt_1064_RR', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'xLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtRR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtRR.py');
        end
        delete(tmpFile);
    end

    %% extinction (AOD-constrained method based on far-field signal)
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        print_msg('--> extinction (AOD-constrained method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt_355_aeronet = data.aerExt355_aeronet(iGrp, :);
        aerExt_532_aeronet = data.aerExt532_aeronet(iGrp, :);
        aerExt_1064_aeronet = data.aerExt1064_aeronet(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_aeronet', 'aerExt_532_aeronet', 'aerExt_1064_aeronet', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_Ext', 'xLim_Profi_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtAERONET.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtAERONET.py');
        end
        delete(tmpFile);
    end

    %% extinction (Klett method based on near-field signal)
    if (sum(flag355NR) == 1) || (sum(flag532NR) == 1)
        print_msg('--> extinction (Klett method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt355_NR_klett = data.aerExt355_NR_klett(iGrp, :);
        aerExt532_NR_klett = data.aerExt532_NR_klett(iGrp, :);
        aerExt_355_klett = data.aerExt355_klett(iGrp, :);
        aerExt_532_klett = data.aerExt532_klett(iGrp, :);
        aerExt_1064_klett = data.aerExt1064_klett(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_klett', 'aerExt_532_klett', 'aerExt_1064_klett', 'aerExt355_NR_klett', 'aerExt532_NR_klett', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'xLim_Profi_NR_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtKlettNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtKlettNR.py');
        end
        delete(tmpFile);
    end

    %% extinction (Raman method based on near-field signal)
    if (sum(flag355NR) == 1) || (sum(flag532NR) == 1)
        print_msg('--> extinction (Raman method based on near-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        aerExt355_NR_raman = data.aerExt355_NR_raman(iGrp, :);
        aerExt532_NR_raman = data.aerExt532_NR_raman(iGrp, :);
        aerExt_355_raman = data.aerExt355_raman(iGrp, :);
        aerExt_532_raman = data.aerExt532_raman(iGrp, :);
        aerExt_1064_raman = data.aerExt1064_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerExt_355_raman', 'aerExt_532_raman', 'aerExt_1064_raman', 'aerExt355_NR_raman', 'aerExt532_NR_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'xLim_Profi_NR_Ext', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayExtRamanNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayExtRamanNR.py');
        end
        delete(tmpFile);
    end

    %% lidar ratio (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) || (sum(flag532FR) == 1)) && ((sum(flag387FR) == 1) || (sum(flag607FR) == 1))
        print_msg('--> lidar ratio (Raman method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        LR355_raman = data.LR355_raman(iGrp, :);
        LR532_raman = data.LR532_raman(iGrp, :);
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
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayLRRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayLRRaman.py');
        end
        delete(tmpFile);
    end

    %% lidar ratio (Rotation Raman method)
    is355RRRetAvail = ((sum(flag355FR) == 1) && (sum(flag355RR) == 1));
    is532RRRetAvail = ((sum(flag532FR) == 1) && (sum(flag532RR) == 1));
    is1064RRRetAvail = ((sum(flag1064FR) == 1) && (sum(flag1064RR) == 1));
    if is355RRRetAvail || is532RRRetAvail || is1064RRRetAvail
        print_msg('--> lidar ratio (RR method).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        LR355_RR = data.LR355_RR(iGrp, :);
        LR532_RR = data.LR532_RR(iGrp, :);
        LR1064_RR = data.LR1064_RR(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'LR355_RR', 'LR532_RR', 'LR1064_RR', 'refHInd355', 'refHInd532', 'refHInd1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_LR', 'xLim_Profi_LR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayLRRR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayLRRR.py');
        end
        delete(tmpFile);
    end

    %% lidar ratio (Raman method based on near-field signal)
    if (sum(flag355NR) == 1) || (sum(flag532NR) == 1)
        print_msg('--> lidar ratio (RR method based on near-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        LR355_raman = data.LR355_raman(iGrp, :);
        LR532_raman = data.LR532_raman(iGrp, :);
        LR355_NR_raman = data.LR355_NR_raman(iGrp, :);
        LR532_NR_raman = data.LR532_NR_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'LR355_raman', 'LR532_raman', 'LR355_NR_raman', 'LR532_NR_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'xLim_Profi_LR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayLRRamanNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayLRRamanNR.py');
        end
        delete(tmpFile);
    end

    %% Angstroem exponent (Klett method based on far-field signal)
    if ((sum(flag355FR) == 1) + (sum(flag532FR) == 1) + sum(flag1064FR)) >= 2
        print_msg('--> Angstroem exponent (Klett method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        AE_Bsc_355_532_klett = data.AE_Bsc_355_532_klett(iGrp, :);
        AE_Bsc_532_1064_klett = data.AE_Bsc_532_1064_klett(iGrp, :);
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
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAEKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAEKlett.py');
        end
        delete(tmpFile);
    end

    %% Angstroem exponent (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) + (sum(flag532FR) == 1) + sum(flag1064FR)) >= 2
        print_msg('--> Angstroem exponent (Raman method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        AE_Bsc_355_532_raman = data.AE_Bsc_355_532_raman(iGrp, :);
        AE_Bsc_532_1064_raman = data.AE_Bsc_532_1064_raman(iGrp, :);
        AE_Ext_355_532_raman = data.AE_Ext_355_532_raman(iGrp, :);
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
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAERaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAERaman.py');
        end
        delete(tmpFile);
    end

    %% Angstroem exponent (Raman method based on near-field signal)
    if (sum(flag355NR) == 1) && (sum(flag532NR))
        print_msg('--> Angstroem exponent (Raman method based on near-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        AE_Bsc_355_532_NR_raman = data.AE_Bsc_355_532_NR_raman(iGrp, :);
        AE_Ext_355_532_NR_raman = data.AE_Ext_355_532_NR_raman(iGrp, :);
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'AE_Bsc_355_532_NR_raman', 'AE_Ext_355_532_NR_raman', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_NR_RCS', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayAERamanNR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayAERamanNR.py');
        end
        delete(tmpFile);
    end

    %% Volume/particle depolarization ratio (Klett method based on far-field signal)
    if ((sum(flag355FR) == 1) && (sum(flag355C) == 1)) || ((sum(flag532FR) == 1) && (sum(flag532C) == 1))|| ((sum(flag1064FR) == 1) && (sum(flag1064C) == 1))
        print_msg('--> Vol/par. depolarization ratio (Klett method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        vdr355_klett = data.vdr355_klett(iGrp, :);
        vdr532_klett = data.vdr532_klett(iGrp, :);
        vdr1064_klett = data.vdr1064_klett(iGrp, :);
        pdr355_klett = data.pdr355_klett(iGrp, :);
        pdr532_klett = data.pdr532_klett(iGrp, :);
        pdr1064_klett = data.pdr1064_klett(iGrp, :);
        pdrStd355_klett = data.pdrStd355_klett(iGrp, :);
        pdrStd532_klett = data.pdrStd532_klett(iGrp, :);
        pdrStd1064_klett = data.pdrStd1064_klett(iGrp, :);
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
        flag_pdr1064_klett = (abs(pdrStd1064_klett ./ pdr1064_klett) > 0.6) | ...
                                 (pdrStd1064_klett > 0.5) | ...
                                 (vdr1064_klett < data.mdr1064(iGrp)) | ...
                                 (pdr1064_klett <= 0);
        pdr1064_klett(flag_pdr1064_klett) = NaN;
        polCaliEta355 = data.polCaliEta355;
        polCaliEta532 = data.polCaliEta532;
        polCaliEta1064 = data.polCaliEta1064;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'vdr355_klett', 'vdr532_klett', 'vdr1064_klett', 'pdr355_klett', 'pdr532_klett', 'pdr1064_klett', 'polCaliEta355', 'polCaliEta532', 'polCaliEta1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_DR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayDRKlett.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayDRKlett.py');
        end
        delete(tmpFile);
    end

    %% Volume/particle depolarization ratio (Raman method based on far-field signal)
    if ((sum(flag355FR) == 1) && (sum(flag355C) == 1)) || ((sum(flag532FR) == 1) && (sum(flag532C) == 1))|| ((sum(flag1064FR) == 1) && (sum(flag1064C) == 1))
        print_msg('--> Vol/par. depolarization ratio (Raman method based on far-field signal).\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        vdr355_raman = data.vdr355_raman(iGrp, :);
        vdr532_raman = data.vdr532_raman(iGrp, :);
        vdr1064_raman = data.vdr1064_raman(iGrp, :);
        pdr355_raman = data.pdr355_raman(iGrp, :);
        pdr532_raman = data.pdr532_raman(iGrp, :);
        pdr1064_raman = data.pdr1064_raman(iGrp, :);
        pdrStd355_raman = data.pdrStd355_raman(iGrp, :);
        pdrStd532_raman = data.pdrStd532_raman(iGrp, :);
        pdrStd1064_raman = data.pdrStd1064_raman(iGrp, :);
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
        flag_pdr1064_raman = (abs(pdrStd1064_raman ./ pdr1064_raman) > 0.6) | ...
                                 (pdrStd1064_raman > 0.5) | ...
                                 (vdr1064_raman < data.mdr1064(iGrp)) | ...
                                 (pdr1064_raman <= 0);
        pdr1064_raman(flag_pdr1064_raman) = NaN;
        polCaliEta355 = data.polCaliEta355;
        polCaliEta532 = data.polCaliEta532;
        polCaliEta1064 = data.polCaliEta1064;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'vdr355_raman', 'vdr532_raman', 'vdr1064_raman', 'pdr355_raman', 'pdr532_raman', 'pdr1064_raman', 'polCaliEta355', 'polCaliEta532', 'polCaliEta1064', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_DR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayDRRaman.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayDRRaman.py');
        end
        delete(tmpFile);
    end

    %% water vapor mixing ratio
    if (sum(flag407FR) == 1) && (sum(flag387FR) == 1)
        print_msg('--> Water vapor mixing ratio.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        wvmr = data.wvmr(iGrp, :);
        flagWVCalibration = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
        flagWVCalibration = flagWVCalibration{1};
        wvconstUsed = data.wvconstUsed;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'wvmr', 'wvconstUsed', 'meteorSource', 'flagWVCalibration', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_WV_RH', 'xLim_Profi_WV_RH', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayWVMR.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayWVMR.py');
        end
        delete(tmpFile);
    end

    %% relative humidity
    if (sum(flag407FR) == 1) && (sum(flag387FR) == 1)
        print_msg('--> Relative humidity.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        rh = data.rh(iGrp, :);
        rh_meteor = data.relh(iGrp, :);
        flagWVCalibration = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
        flagWVCalibration = flagWVCalibration{1};
        wvconstUsed = data.wvconstUsed;
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'rh', 'rh_meteor', 'wvconstUsed', 'meteorSource', 'flagWVCalibration', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_Profi_WV_RH', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayRH.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayRH.py');
        end
        delete(tmpFile);
    end

    %% temperature
    print_msg('--> temperature.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_FR_RCS', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayTemperature.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayTemperature.py');
    end
    delete(tmpFile);

    %% pressure
    print_msg('--> pressure.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'yLim_FR_RCS', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayPressure.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayPressure.py');
    end
    delete(tmpFile);

    %% POLIPHON
    if (sum(flag355FR) == 1) || (sum(flag532FR) == 1) || (sum(flag1064FR) == 1)
        print_msg('--> POLIPHON.\n', 'flagTimestamp', true, 'flagSimpleMsg', true);
        %poliphon =  data.POLIPHON1(iGrp, :);
        aerBsc_532_raman = data.aerBsc532_raman(iGrp, :);
        poliphon_aerBsc532_raman_d1 =  data.POLIPHON1.aerBsc532_raman_d1(iGrp,:);
        poliphon_aerBsc532_raman_nd1 =  data.POLIPHON1.aerBsc532_raman_nd1(iGrp,:);
        err_poliphon_aerBsc532_raman_d1 = data.POLIPHON1.err_aerBsc532_raman_d1(iGrp,:);
        err_poliphon_aerBsc532_raman_nd1 = data.POLIPHON1.err_aerBsc532_raman_nd1(iGrp,:);

        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(PicassoConfig.pic_folder, PollyDataInfo.pollyType, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startInd', 'endInd', 'height', 'time', 'aerBsc_532_raman', 'poliphon_aerBsc532_raman_d1','poliphon_aerBsc532_raman_nd1', 'err_poliphon_aerBsc532_raman_d1', 'err_poliphon_aerBsc532_raman_nd1', 'meteorSource', 'temperature', 'pressure', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xLim_beta_532_Poliphon','yLim_beta_532_Poliphon', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
%        loaded_data=load(tmpFile)
%        disp(loaded_data.poliphon)
%        error('Execution halted!');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayPoliphon.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayPoliphon.py');
        end
        delete(tmpFile);
    end

end

end
