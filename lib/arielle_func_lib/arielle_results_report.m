function [reportStr] = pollyxt_lacros_results_report(data, taskInfo, config)
%pollyxt_lacros_results_report Write the info to done list file and generate the report for the current task. These report can be used for further examination.
%   Example:
%       [reportStr] = pollyxt_lacros_results_report(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       reportStr
%   History:
%       2019-01-04. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global campaignInfo defaults processInfo

reportStr = cell(0);

reportStr{end + 1} = sprintf('Task: %s', taskInfo.dataFilename);
reportStr{end + 1} = sprintf('Start time: %s', datestr(taskInfo.startTime, 'yyyy-mm-dd HH:MM:SS'));
reportStr{end + 1} = sprintf('Instrument: %s', taskInfo.pollyVersion);
reportStr{end + 1} = sprintf('Location: %s', campaignInfo.location);

if isempty(data.rawSignal)
    reportStr{end + 1} = sprintf('comment: %s', 'no measurement');
    return;
end

reportStr{end + 1} = sprintf('Measruement time: %s - %s', datestr(data.mTime(1), 'yyyy-mm-dd HH:MM:SS'), datestr(data.mTime(end), 'HH:MM:SS'));
reportStr{end + 1} = sprintf('Continuous cloud free profiles: %d', size(data.cloudFreeGroups, 1));
cloudFreeStr = '';
meteorStr = '';
ref355Str = '';
ref532Str = '';
ref1064Str = '';
flagSNR387 = '';
flagSNR607 = '';
for iGroup = 1:size(data.cloudFreeGroups, 1)
    cloudFreeStr = [cloudFreeStr, sprintf('%s - %s; ', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'))];
    meteorStr = [meteorStr, sprintf('%s; ', data.meteorAttri.dataSource{iGroup})];

    if isnan(data.refHIndx355(iGroup, 1))
        ref355Str = [ref355Str, sprintf('NaN - NaN m; ')];
    else
        ref355Str = [ref355Str, sprintf('%7.1f - %7.1f m; ', data.height(data.refHIndx355(iGroup, 1)), data.height(data.refHIndx355(iGroup, 2)))];
    end

    if isnan(data.refHIndx532(iGroup, 1))
        ref532Str = [ref532Str, sprintf('NaN - NaN m; ')];
    else
        ref532Str = [ref532Str, sprintf('%7.1f - %7.1f m; ', data.height(data.refHIndx532(iGroup, 1)), data.height(data.refHIndx532(iGroup, 2)))];
    end

    if isnan(data.refHIndx1064(iGroup, 1))
        ref1064Str = [ref1064Str, sprintf('NaN - NaN m; ')];
    else
        ref1064Str = [ref1064Str, sprintf('%7.1f - %7.1f m; ', data.height(data.refHIndx1064(iGroup, 1)), data.height(data.refHIndx1064(iGroup, 2)))];
    end

    if isnan(data.aerBsc355_raman(iGroup, 100))
        flagSNR387 = [flagSNR387, 'low; '];
    else
        flagSNR387 = [flagSNR387, 'high; '];
    end

    if isnan(data.aerBsc532_raman(iGroup, 100))
        flagSNR607 = [flagSNR607, 'low; '];
    else
        flagSNR607 = [flagSNR607, 'high; '];
    end

end
reportStr{end + 1} = sprintf('Cloud-free regions: %s', cloudFreeStr);
reportStr{end + 1} = sprintf('Meteorological data from: %s', meteorStr);
reportStr{end + 1} = sprintf('Reference height for 355 nm: %s', ref355Str);
reportStr{end + 1} = sprintf('Reference height for 532 nm: %s', ref532Str);
reportStr{end + 1} = sprintf('Reference height for 1064 nm: %s', ref1064Str);
reportStr{end + 1} = sprintf('SNR of 387 nm at reference height: %s', flagSNR387);
reportStr{end + 1} = sprintf('SNR of 607 nm at reference height: %s', flagSNR607);
reportStr{end + 1} = sprintf('Depol constant for 355 nm: %f', data.depol_cal_fac_355);
reportStr{end + 1} = sprintf('Depol constant for 532 nm: %f', data.depol_cal_fac_532);
flagWVCali = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
reportStr{end + 1} = sprintf('WV calibrated?: %s', flagWVCali{1});
reportStr{end + 1} = sprintf('WV calibration constant: %f g*kg^{-1}', data.wvconstUsed);
reportStr{end + 1} = sprintf('Lidar constant at 355 nm: %3.1e', data.LCUsed.LCUsed355);
reportStr{end + 1} = sprintf('Lidar calibration status at 355 nm: %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1});
reportStr{end + 1} = sprintf('Lidar constant at 532 nm: %3.1e', data.LCUsed.LCUsed532);
reportStr{end + 1} = sprintf('Lidar calibration status at 532 nm: %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1});
reportStr{end + 1} = sprintf('Lidar constant at 1064 nm: %3.1e', data.LCUsed.LCUsed355);
reportStr{end + 1} = sprintf('Lidar calibration status at 1064 nm: %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1});

%% write the pic info to done list file
if (data.mTime(end) - data.mTime(1)) >= datenum(0, 1, 0, 0, 10, 0)
    active = 1;
else
    active = 0;
end

flag355FR = config.isFR & config.is355nm & config.isTot;
flag532FR = config.isFR & config.is532nm & config.isTot;
flag1064FR = config.isFR & config.is1064nm & config.isTot;
flag355NR = config.isNR & config.is355nm & config.isTot;
flag532NR = config.isNR & config.is532nm & config.isTot;

% monitor data
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_monitor.png', rmext(taskInfo.dataFilename))), '0', 'data based on laserlogbook.', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 355 nm RCS FR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_FR_355.png', rmext(taskInfo.dataFilename))), '0', '355 nm Far-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 532 nm RCS FR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_FR_532.png', rmext(taskInfo.dataFilename))), '0', '532 nm Far-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 1064 nm RCS FR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '1064', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_FR_1064.png', rmext(taskInfo.dataFilename))), '0', '1064 nm Far-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 532 nm RCS NR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_NR_532.png', rmext(taskInfo.dataFilename))), '0', '532 nm Near-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 355 depol cali
for iCali = 1:length(data.depCaliAttri.depCalAttri355.thisCaliTime) 
    thisCaliTime = data.depCaliAttri.depCalAttri355.thisCaliTime{iCali};
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%d.png', datestr(thisCaliTime, 'yyyymmdd-HHMM'), '355')), '0', '355 nm depolarization calibration results. (+- 45 \degree method)', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
end

% 532 depol cali
for iCali = 1:length(data.depCaliAttri.depCalAttri532.thisCaliTime) 
    thisCaliTime = data.depCaliAttri.depCalAttri532.thisCaliTime{iCali};
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%d.png', datestr(thisCaliTime, 'yyyymmdd-HHMM'), '532')), '0', '532 nm depolarization calibration results.  (+- 45 \degree method)', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
end

% 355 nm signal status
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_FR_355.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 355 nm. SNR threshold is %d', config.mask_SNRmin(flag355FR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 532 nm signal status
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_FR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 532 nm. SNR threshold is %d', config.mask_SNRmin(flag532FR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 1064 nm signal status
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '1064', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_FR_1064.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 1064 nm. SNR threshold is %d', config.mask_SNRmin(flag1064FR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% 532 nm signal status NR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_NR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 532 nm NR. SNR threshold is %d', config.mask_SNRmin(flag532NR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% overlap results
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_overlap.png', rmext(taskInfo.dataFilename))), '0', 'overlap function. Preliminary results only for Internal use. The overlap was calculated by comparing the signal between far-range and near-range channel cloud-free signal.', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% profiles info
for iGroup = 1:size(data.cloudFreeGroups, 1)
    startIndx = data.cloudFreeGroups(iGroup, 1);
    endIndx = data.cloudFreeGroups(iGroup, 2);

    % gdas timestamp or standar atmosphere
    meteorStr = '';
    if strcmpi(data.meteorAttri.dataSource{iGroup}, 'gdas1')
        meteorStr = sprintf('Meteorological data from %s at %s on %s UTC', upper(config.meteorDataSource), config.gdas1Site, datestr(data.meteorAttri.datetime(iGroup), 'yyyymmdd HH'));
    elseif strcmpi(data.meteorAttri.dataSource{iGroup}, 'radiosonde')
        meteorStr = sprintf('Meteorological data from %s at %s on %s UTC', upper(config.meteorDataSource), campaignInfo.location, datestr(data.meteorAttri.datetime(iGroup), 'yyyymmdd HH'));
    else
        meteorStr = sprintf('Meteorological data from %s', data.meteorAttri.dataSource{iGroup});
    end

    % rcs 
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % reference height
    if isnan(data.refHIndx355(iGroup, 1))
        refH355 = [NaN, NaN];
    else
        refH355 = data.height(data.refHIndx355(iGroup, :));
    end
    if isnan(data.refHIndx532(iGroup, 1))
        refH532 = [NaN, NaN];
    else
        refH532 = data.height(data.refHIndx532(iGroup, :));
    end
    if isnan(data.refHIndx1064(iGroup, 1))
        refH1064 = [NaN, NaN];
    else
        refH1064 = data.height(data.refHIndx1064(iGroup, :));
    end

    %bsc klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Lidar ratio is %5.1fSr at 355nm, %5.1f at 532nm and %5.1f at 1064nm. Reference height is [%7.1f - %7.1mf] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm and %5.1fm. No overlap correction.', meteorStr, config.LR355, config.LR532, config.LR1064, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_klett_355*data.hRes, config.smoothWin_klett_532*data.hRes, config.smoothWin_klett_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    %bsc raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. Angstroem exponent is %3.1f. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_raman_355*data.hRes, config.smoothWin_raman_532*data.hRes, config.smoothWin_raman_1064*data.hRes, config.angstrexp), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    %bsc aeronet
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). The lidar ratio is tuned to make the AOD from AERONET and lidar converged. Lidar ratio is %5.1fSr at 355nm, %5.1fSr at 532nm and %5.1fSr at 1064nm. Smoothing window is %5.1fm, %5.1fm, %5.1fm. Only for internal use.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), data.LR355_aeronet(iGroup), data.LR532_aeronet(iGroup), data.LR1064_aeronet(iGroup), config.smoothWin_klett_355*data.hRes, config.smoothWin_klett_532*data.hRes, config.smoothWin_klett_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    %ext klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Lidar ratio is %5.1fSr at 355nm, %5.1f at 532nm and %5.1f at 1064nm. Reference height is [%7.1f - %7.1mf] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. No overlap correction.', meteorStr, config.LR355, config.LR532, config.LR1064, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_klett_355*data.hRes, config.smoothWin_klett_532*data.hRes, config.smoothWin_klett_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    %Ext raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_raman_355*data.hRes, config.smoothWin_raman_532*data.hRes, config.smoothWin_raman_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    %Ext aeronet
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Aeronet.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). The lidar ratio is tuned to make the AOD from AERONET and lidar converged. Lidar ratio is %5.1fSr at 355nm, %5.1fSr at 532nm and %5.1fSr at 1064nm. Smoothing window is %5.1fm, %5.1fm, %5.1fm. Only for internal use.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), data.LR355_aeronet(iGroup), data.LR532_aeronet(iGroup), data.LR1064_aeronet(iGroup), config.smoothWin_klett_355*data.hRes, config.smoothWin_klett_532*data.hRes, config.smoothWin_klett_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % LR raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_LR_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_raman_355*data.hRes, config.smoothWin_raman_532*data.hRes, config.smoothWin_raman_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % angstroem exponent with klett method
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_ANGEXP_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Lidar ratio is %5.1fSr at 355nm, %5.1f at 532nm and %5.1f at 1064nm. Reference height is [%7.1f - %7.1mf] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. No overlap correction.', meteorStr, config.LR355, config.LR532, config.LR1064, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_klett_355*data.hRes, config.smoothWin_klett_532*data.hRes, config.smoothWin_klett_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    % angstroem exponent with Raman method
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_ANGEXP_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (355nm), [%7.1f - %7.1fm] (532nm) and [%7.1f - %7.1fm] (1064nm). Smoothing window is %5.1fm, %5.1fm, %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH355(1), refH355(2), refH532(1), refH532(2), refH1064(1), refH1064(2), config.smoothWin_raman_355*data.hRes, config.smoothWin_raman_532*data.hRes, config.smoothWin_raman_1064*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % depol ratio klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Depolarization factor is %6.4f at 355nm and %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 355nm and %6.4f at 532nm.', data.depol_cal_fac_355, data.depol_cal_fac_532, data.moldepol355(iGroup), data.moldepol532(iGroup)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % depol ratio Raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Depolarization factor is %6.4f at 355nm and %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 355nm and %6.4f at 532nm.', data.depol_cal_fac_355, data.depol_cal_fac_532, data.moldepol355(iGroup), data.moldepol532(iGroup)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % WVMR
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '407', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_WVMR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Water vapor calibration constant is %5.1fg*kg^{-1}. Calibration status %s. %s.', data.wvconstUsed, flagWVCali{1}, meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

    % RH
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '407', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_RH.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Water vapor calibration constant is %5.1fg*kg^{-1}. Calibration status %s. %s.', data.wvconstUsed, flagWVCali{1}, meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    % meteor T
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_T.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
    
    % meteor P
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_P.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
end

% att-beta 355
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_ATT_BETA_355.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 355nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed355, config.LCCalibrationStatus{data.LCUsed.LCUsedTag355 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% att-beta 532
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_ATT_BETA_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 532nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed532, config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% att-beta 1064
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '1064', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_ATT_BETA_1064.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 1064nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed1064, config.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% higl resolved WVMR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '407', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_WVMR.png', rmext(taskInfo.dataFilename))), '0', sprintf('Water vapor calibration constant is %5.1fg*kg^{-1}. Calibration status %s. %s.', data.wvconstUsed, flagWVCali{1}, meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% higl resolved RH
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '407', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RH.png', rmext(taskInfo.dataFilename))), '0', sprintf('Water vapor calibration constant is %5.1fg*kg^{-1}. Calibration status %s. %s.', data.wvconstUsed, flagWVCali{1}, meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% quasi backscatter 532
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_Bsc_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 532nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed532, config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% quasi backscatter 1064
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '1064', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_Bsc_1064.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 1064nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed1064, config.LCCalibrationStatus{data.LCUsed.LCUsedTag1064 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% quasi particle depolarization at 532 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_PDR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Depolarization factor is %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 532nm. %s.', data.depol_cal_fac_532, data.moldepol532(iGroup), meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);
   
% quasi backscatter-related angstroem exponent 532-1064
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_ANGEXP_532_1064.png', rmext(taskInfo.dataFilename))), '0', sprintf('%s.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% lidar constant at 355 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '355', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_355.png', rmext(taskInfo.dataFilename))), '0', sprintf('%s. Lidar constant is sensible to the system condition, like temperature, humidity.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% lidar constant at 532 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('%s. Lidar constant is sensible to the system condition, like temperature, humidity.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

% lidar constant at 1064 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '1064', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_1064.png', rmext(taskInfo.dataFilename))), '0', sprintf('%s. Lidar constant is sensible to the system condition, like temperature, humidity.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion);

end