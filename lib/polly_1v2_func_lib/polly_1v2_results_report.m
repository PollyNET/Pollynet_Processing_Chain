function [reportStr] = polly_1v2_results_report(data, taskInfo, config)
%polly_1v2_results_report Write the info to done list file and generate the report for the current task. These report can be used for further examination.
%   Example:
%       [reportStr] = polly_1v2_results_report(data, taskInfo, config)
%   Inputs:
%       data, taskInfo, config
%   Outputs:
%       reportStr
%   History:
%       2019-01-04. First Edition by Zhenping
%       2019-03-13. Add entries of VDR_532'. 
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
ref532Str = '';
flagSNR607 = '';
for iGroup = 1:size(data.cloudFreeGroups, 1)
    cloudFreeStr = [cloudFreeStr, sprintf('%s - %s; ', datestr(data.mTime(data.cloudFreeGroups(iGroup, 1)), 'HH:MM'), datestr(data.mTime(data.cloudFreeGroups(iGroup, 2)), 'HH:MM'))];
    meteorStr = [meteorStr, sprintf('%s; ', data.meteorAttri.dataSource{iGroup})];

    if isnan(data.refHIndx532(iGroup, 1))
        ref532Str = [ref532Str, sprintf('NaN - NaN m; ')];
    else
        ref532Str = [ref532Str, sprintf('%7.1f - %7.1f m; ', data.height(data.refHIndx532(iGroup, 1)), data.height(data.refHIndx532(iGroup, 2)))];
    end

    if isnan(data.aerBsc532_raman(iGroup, 100))
        flagSNR607 = [flagSNR607, 'low; '];
    else
        flagSNR607 = [flagSNR607, 'high; '];
    end

end
reportStr{end + 1} = sprintf('Cloud-free regions: %s', cloudFreeStr);
reportStr{end + 1} = sprintf('Meteorological data from: %s', meteorStr);
reportStr{end + 1} = sprintf('Reference height for 532 nm: %s', ref532Str);
reportStr{end + 1} = sprintf('SNR of 607 nm at reference height: %s', flagSNR607);
reportStr{end + 1} = sprintf('Depol constant for 532 nm: %f', data.depol_cal_fac_532);
reportStr{end + 1} = sprintf('Lidar constant at 532 nm: %3.1e', data.LCUsed.LCUsed532);
reportStr{end + 1} = sprintf('Lidar calibration status at 532 nm: %s', config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1});

%% write the pic info to done list file
if (data.mTime(end) - data.mTime(1)) >= datenum(0, 1, 0, 0, 10, 0)
    active = 1;
else
    active = 0;
end

flag532FR = config.isFR & config.is532nm & config.isTot;
flag532NR = config.isFR & config.is532nm & config.isTot;

% monitor data
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_monitor.png', rmext(taskInfo.dataFilename))), '0', 'data based on laserlogbook.', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'monitor', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% 532 nm RCS FR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_FR_532.png', rmext(taskInfo.dataFilename))), '0', '532 nm Far-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'RCS_FR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% 532 nm RCS NR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_RCS_NR_532.png', rmext(taskInfo.dataFilename))), '0', '532 nm Near-Range', taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'RCS_NR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% 532 nm signal status
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_FR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 532 nm. SNR threshold is %d', config.mask_SNRmin(flag532FR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'SAT_FR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% 532 nm signal status NR
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_SAT_NR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('signal status at 532 nm NR. SNR threshold is %d', config.mask_SNRmin(flag532NR)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'SAT_NR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

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
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_SIG.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'SIG', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % reference height
    if isnan(data.refHIndx532(iGroup, 1))
        refH532 = [NaN, NaN];
    else
        refH532 = data.height(data.refHIndx532(iGroup, :));
    end

    %bsc klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Lidar ratio is %5.1f at 532nm. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. No overlap correction.', meteorStr, config.LR532, refH532(1), refH532(2), config.smoothWin_klett_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Bcs_Klett', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));
    
    %ext klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Lidar ratio is %5.1f at 532nm. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. No overlap correction.', meteorStr, config.LR532, refH532(1), refH532(2), config.smoothWin_klett_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Ext_Klett', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    %bsc raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. Angstroem exponent is %3.1f. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr,  refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes, config.angstrexp), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Bsc_Raman', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    %Ext raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Ext_Raman', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % LR raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_LR_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'LR', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    %bsc RR
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Bsc_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. Angstroem exponent is %3.1f. If SNR for RRR signal at reference height is low, the Raman method will not be applied.', meteorStr,  refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes, config.angstrexp), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Bsc_RR', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));
    
    %Ext RR
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Ext_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Ext_RR', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % LR RR
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_LR_RR.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s. Reference height is [%7.1f - %7.1fm] (532nm). Smoothing window is %5.1fm. If SNR for Raman signal at reference height is low, the Raman method will not be applied.', meteorStr, refH532(1), refH532(2), config.smoothWin_raman_532*data.hRes), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'LR_RR', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % depol ratio klett
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Klett.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Depolarization factor is %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 532nm.', data.depol_cal_fac_532, data.moldepol532(iGroup)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'DepRatio_Klett', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % depol ratio Raman
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_DepRatio_Raman.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('Depolarization factor is %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 532nm.', data.depol_cal_fac_532, data.moldepol532(iGroup)), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'DepRatio_Raman', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));

    % meteor T
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_T.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Meteor_T', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));
    
    % meteor P
    write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_%s_%s_Meteor_P.png', rmext(taskInfo.dataFilename), datestr(data.mTime(startIndx), 'HHMM'), datestr(data.mTime(endIndx), 'HHMM'))), '0', sprintf('%s.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Meteor_P', datestr(data.mTime(startIndx), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(endIndx), 'yyyymmdd HH:MM:SS'));
end

% att-beta 532
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_ATT_BETA_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 532nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed532, config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'ATT_BETA_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% high temporal resolved VDR at 532 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_VDR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Depolarization calibration factor is %f+-%f', data.depol_cal_fac_532, data.depol_cal_fac_std_532), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'VDR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% quasi backscatter 532
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_Bsc_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Lidar constant at 532nm is %3.1e. Lidar constant calibration status: %s', data.LCUsed.LCUsed532, config.LCCalibrationStatus{data.LCUsed.LCUsedTag532 + 1}), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Quasi_Bsc_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

% quasi particle depolarization at 532 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_Quasi_PDR_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('Depolarization factor is %6.4f at 532nm. Molecule volume depolarization ratio is %6.4f at 532nm. %s.', data.depol_cal_fac_532, data.moldepol532(iGroup), meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'Quasi_PDR_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));
   
% lidar constant at 532 nm
write_2_donelist(processInfo.doneListFile, 'a', taskInfo.pollyVersion, campaignInfo.location, datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'), datestr(taskInfo.startTime, 'yyyymmdd HH:MM:SS'), '532', fullfile(datestr(data.mTime(1), 'yyyymmdd'), sprintf('%s_LC_532.png', rmext(taskInfo.dataFilename))), '0', sprintf('%s. Lidar constant is sensible to the system condition, like temperature, humidity.', meteorStr), taskInfo.zipFile, num2str(taskInfo.dataSize), num2str(active), num2str(data.quasiAttri.flagGDAS1), datestr(data.quasiAttri.timestamp, 'yyyymmddHH'), '50', processInfo.programVersion, 'LC_532', datestr(data.mTime(1), 'yyyymmdd HH:MM:SS'), datestr(data.mTime(end), 'yyyymmdd HH:MM:SS'));

end