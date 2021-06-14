function pollyxt_display_OC_retrieving(data, taskInfo, config)
%POLLYXT_DISPLAY_OC_RETRIEVING display aerosol optical products
%Example:
%   pollyxt_display_OC_retrieving(data, taskInfo, config)
%Inputs:
%   data, taskInfo, config
%History:
%   2018-12-30. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo defaults campaignInfo

%% initial the channels
flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

height = data.height;
time = data.mTime;
figDPI = processInfo.figDPI;
partnerLabel = config.partnerLabel;
flagWatermarkOn = processInfo.flagWatermarkOn;

%% data visualization for each cloud free period
for iGroup = 1:size(data.cloudFreeGroups, 1)

    % read data
    smoothWin_355 = config.smoothWin_klett_355;
    smoothWin_532 = config.smoothWin_klett_532;
    smoothWin_1064 = config.smoothWin_klett_1064;

    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);
    sig355 = squeeze(transpose(mean(data.signal355OverlapCor(:, startIndx:endIndx), 2))) / mean(data.mShots(flagChannel355, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs355 = sig355 .* data.height.^2;
    rcs355 = transpose(smooth(rcs355, smoothWin_355));
    sig532 = squeeze(transpose(mean(data.signal532OverlapCor(:, startIndx:endIndx), 2))) / mean(data.mShots(flagChannel532, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs532 = sig532 .* data.height.^2;
    rcs532 = transpose(smooth(rcs532, smoothWin_532));
    sig1064 = squeeze(transpose(mean(data.signal1064OverlapCor(:, startIndx:endIndx), 2))) / mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) * 150 / data.hRes;
    rcs1064 = sig1064 .* data.height.^2;
    rcs1064 = transpose(smooth(rcs1064, smoothWin_1064));

    % molecule signal
    [molBsc355, molExt355] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    [molBsc532, molExt532] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    [molBsc1064, molExt1064] = rayleigh_scattering(1064, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);
    molRCS355 = molBsc355 .* exp(- 2 * cumsum(molExt355 .* [data.distance0(1), diff(data.distance0)]));
    molRCS532 = molBsc532 .* exp(- 2 * cumsum(molExt532 .* [data.distance0(1), diff(data.distance0)]));
    molRCS1064 = molBsc1064 .* exp(- 2 * cumsum(molExt1064 .* [data.distance0(1), diff(data.distance0)]));  

    % normalize the range-corrected signal to molecular signal
    if ~ isnan(data.refHIndx355(iGroup, 1))
        % according to the ratio at the reference height
        factor_355 = sum(molRCS355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2))) / sum(rcs355(data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2)));
        rcs355 = rcs355 * factor_355;
    else 
        % if no reference height was found, using the lidar constants
        rcs355 = rcs355 / data.LCUsed.LCUsed355 * mean(data.mShots(flagChannel355, startIndx:endIndx), 2) / 150 * data.hRes;
    end
    if ~ isnan(data.refHIndx532(iGroup, 1))
        % according to the ratio at the reference height
        factor_532 = sum(molRCS532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2))) / sum(rcs532(data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2)));
        rcs532 = rcs532 * factor_532;
    else 
        % if no reference height was found, using the lidar constants
        rcs532 = rcs532 / data.LCUsed.LCUsed532 * mean(data.mShots(flagChannel532, startIndx:endIndx), 2) / 150 * data.hRes;
    end
    if ~ isnan(data.refHIndx1064(iGroup, 1))
        % according to the ratio at the reference height
        factor_1064 = sum(molRCS1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2))) / sum(rcs1064(data.refHIndx1064(iGroup, 1):data.refHIndx1064(iGroup, 2)));
        rcs1064 = rcs1064 * factor_1064;
    else 
        % if no reference height was found, using the lidar constants
        rcs1064 = rcs1064 / data.LCUsed.LCUsed1064 * mean(data.mShots(flagChannel1064, startIndx:endIndx), 2) / 150 * data.hRes;
    end

    % reference height
    refHIndx355 = [data.refHIndx355(iGroup, 1), data.refHIndx355(iGroup, 2)];
    refHIndx532 = [data.refHIndx532(iGroup, 1), data.refHIndx532(iGroup, 2)];
    refHIndx1064 = [data.refHIndx1064(iGroup, 1), data.refHIndx1064(iGroup, 2)];

    % backscatter
    aerBsc_355_klett = data.aerBsc355_OC_klett(iGroup, :);
    aerBsc_532_klett = data.aerBsc532_OC_klett(iGroup, :);
    aerBsc_1064_klett = data.aerBsc1064_OC_klett(iGroup, :);
    aerBsc_355_raman = data.aerBsc355_OC_raman(iGroup, :);
    aerBsc_532_raman = data.aerBsc532_OC_raman(iGroup, :);
    aerBsc_1064_raman = data.aerBsc1064_OC_raman(iGroup, :);

    % extinction
    aerExt_355_klett = data.aerExt355_OC_klett(iGroup, :);
    aerExt_532_klett = data.aerExt532_OC_klett(iGroup, :);
    aerExt_1064_klett = data.aerExt1064_OC_klett(iGroup, :);
    aerExt_355_raman = data.aerExt355_OC_raman(iGroup, :);
    aerExt_532_raman = data.aerExt532_OC_raman(iGroup, :);
    aerExt_1064_raman = data.aerExt1064_OC_raman(iGroup, :);

    % lidar ratio
    LR355_raman = data.LR355_OC_raman(iGroup, :);
    LR532_raman = data.LR532_OC_raman(iGroup, :);

    % angstroem exponent
    ang_bsc_355_532_klett = data.ang_bsc_355_532_klett_OC(iGroup, :);
    ang_bsc_532_1064_klett = data.ang_bsc_532_1064_klett_OC(iGroup, :);
    ang_bsc_355_532_raman = data.ang_bsc_355_532_raman_OC(iGroup, :);
    ang_bsc_532_1064_raman = data.ang_bsc_532_1064_raman_OC(iGroup, :);
    ang_ext_355_532_raman = data.ang_ext_355_532_raman_OC(iGroup, :);

    % depol ratio
    voldepol355_klett = data.voldepol355_OC_klett(iGroup, :);
    voldepol532_klett = data.voldepol532_OC_klett(iGroup, :);
    voldepol355_raman = data.voldepol355_OC_raman(iGroup, :);
    voldepol532_raman = data.voldepol532_OC_raman(iGroup, :);
    pardepol355_klett = data.pardepol355_OC_klett(iGroup, :);
    pardepol532_klett = data.pardepol532_OC_klett(iGroup, :);
    pardepolStd355_klett = data.pardepolStd355_OC_klett(iGroup, :);
    pardepolStd532_klett = data.pardepolStd532_OC_klett(iGroup, :);
    flag_pardepol355_klett = (abs(pardepolStd355_klett ./ pardepol355_klett) > 0.6) | ...
                             (pardepolStd355_klett > 0.5) | ...
                             (voldepol355_klett < data.moldepol355(iGroup)) | ...
                             (pardepol355_klett <= 0);
    pardepol355_klett(flag_pardepol355_klett) = NaN;
    flag_pardepol532_klett = (abs(pardepolStd532_klett ./ pardepol532_klett) > 0.6) | ...
                             (pardepolStd532_klett > 0.5) | ...
                             (voldepol532_klett < data.moldepol532(iGroup)) | ...
                             (pardepol532_klett <= 0);
    pardepol532_klett(flag_pardepol532_klett) = NaN;
    pardepol355_raman = data.pardepol355_OC_raman(iGroup, :);
    pardepol532_raman = data.pardepol532_OC_raman(iGroup, :);
    pardepolStd355_raman = data.pardepolStd355_OC_raman(iGroup, :);
    pardepolStd532_raman = data.pardepolStd532_OC_raman(iGroup, :);
    flag_pardepol355_raman = (abs(pardepolStd355_raman ./ pardepol355_raman) > 0.6) | ...
                             (pardepolStd355_raman > 0.5) | ...
                             (voldepol355_raman < data.moldepol355(iGroup)) | ...
                             (pardepol355_raman <= 0);
    pardepol355_raman(flag_pardepol355_raman) = NaN;
    flag_pardepol532_raman = (abs(pardepolStd532_raman ./ pardepol532_raman) > 0.6) | ...
                             (pardepolStd532_raman > 0.5) | ...
                             (voldepol532_raman < data.moldepol532(iGroup)) | ...
                             (pardepol532_raman <= 0);
    pardepol532_raman(flag_pardepol532_raman) = NaN;

    % meteor data
    meteorSource = data.meteorAttri.dataSource{iGroup};
    temperature = data.temperature(iGroup, :);
    pressure = data.pressure(iGroup, :);

    % display range
    yLim_Profi_Ext = config.yLim_Profi_Ext;
    yLim_Profi_LR = config.yLim_Profi_LR;
    yLim_Profi_DR = config.yLim_Profi_DR;
    yLim_Profi_Bsc = config.yLim_Profi_Bsc;
    yLim_FR_RCS = config.yLim_FR_RCS;
    xLim_Profi_Bsc = config.xLim_Profi_Bsc;
    xLim_Profi_Ext = config.xLim_Profi_Ext;
    xLim_Profi_RCS = config.xLim_Profi_RCS;
    xLim_Profi_LR = config.xLim_Profi_LR;
    imgFormat = config.imgFormat;

    if strcmpi(processInfo.visualizationMode, 'matlab')

        warning('TODO...');

    elseif strcmpi(processInfo.visualizationMode, 'python')
        fprintf('Display the overlap corrected results with Python.\n');
        pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
        tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
        saveFolder = fullfile(processInfo.pic_folder, taskInfo.pollyVersion, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

        % create tmp folder by force, if it does not exist.
        if ~ exist(tmpFolder, 'dir')
            fprintf('Create the tmp folder to save the temporary results.\n');
            mkdir(tmpFolder);
        end
        
        %% display rcs 
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'startIndx', 'endIndx', 'rcs355', 'rcs532', 'rcs1064', 'height', 'time', 'molRCS355', 'molRCS532', 'molRCS1064', 'refHIndx355', 'refHIndx532', 'refHIndx1064', 'aerBsc_355_klett', 'aerBsc_532_klett', 'aerBsc_1064_klett', 'aerBsc_355_raman', 'aerBsc_532_raman', 'aerBsc_1064_raman', 'aerExt_355_klett', 'aerExt_532_klett', 'aerExt_1064_klett', 'aerExt_355_raman', 'aerExt_532_raman', 'aerExt_1064_raman', 'LR355_raman', 'LR532_raman', 'ang_bsc_355_532_klett', 'ang_bsc_532_1064_klett', 'ang_bsc_355_532_raman', 'ang_bsc_532_1064_raman', 'ang_ext_355_532_raman', 'voldepol355_klett', 'voldepol355_raman', 'voldepol532_klett', 'voldepol532_raman', 'pardepol355_klett', 'pardepol532_klett', 'pardepolStd355_klett', 'pardepolStd532_klett', 'pardepol355_raman', 'pardepol532_raman', 'pardepolStd355_raman', 'pardepolStd532_raman', 'meteorSource', 'temperature', 'pressure', 'processInfo', 'campaignInfo', 'taskInfo', 'yLim_Profi_Ext', 'yLim_Profi_LR', 'yLim_Profi_DR', 'yLim_Profi_Bsc', 'yLim_FR_RCS', 'xLim_Profi_Bsc', 'xLim_Profi_Ext', 'xLim_Profi_RCS', 'xLim_Profi_LR', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(processInfo.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_display_OC_retrieving.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyxt_display_OC_retrieving.py');
        end
        delete(tmpFile);
    else
        error('Unknow visualization mode. Please check the settings in pollynet_processing_chain_config.json');
    end

end