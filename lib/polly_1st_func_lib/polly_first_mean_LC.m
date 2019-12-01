function [LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed607, LCUsedTag607, flagLCWarning607] = polly_first_mean_LC(data, config, taskInfo, folder)
%polly_first_mean_LC calculate and save the lidar calibration constant based on the optional constants and defaults.
%   Example:
%       [LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed607, LCUsedTag607, flagLCWarning607] = polly_first_mean_LC(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       folder: char
%           folder for saving the history lidar constants.
%   Outputs:
%       LCUsed532: float
%           applied lidar constant at 532 nm. 
%       LCUsedTag532: integer
%           source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning532: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed607: float
%           applied lidar constant at 607 nm. 
%       LCUsedTag607: integer
%           source of the applied lidar constant at 607 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning607: integer
%           flag to show whether the calibration constant is unstable. 
%   History:
%       2018-12-24. First Edition by Zhenping
%       2019-08-04. Add the output of lidar constant at 607 nm.
%       2019-08-28. Add flag to control whether to do lidar calibration.
%   Contact:
%       zhenping@tropos.de


global defaults campaignInfo processInfo

LCUsed532 = [];
LCUsedTag532 = 0;
flagLCWarning532 = false;
LCUsed607 = [];
LCUsedTag607 = 0;
flagLCWarning607 = false;
LCCaliFile = fullfile(folder, config.lcCaliFile);

flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel607 = config.isFR & config.is607nm;


%% create the LC file if not exist
if exist(LCCaliFile, 'file') ~= 2
    fprintf('Create the file to save the lidar constants.\n%s\n', LCCaliFile);
    fid = fopen(LCCaliFile, 'w');
    fprintf(fid, 'polly data, LC532, LC532Std, Calibration status 532, LC607, LC532Std, Calibration status 607\n');
    fclose(fid);
end

if isempty(data.rawSignal)
    return;
end

% mean and std values of lidar constants
LC_raman_532_mean = nanmean(data.LC.LC_raman_532);
LC_klett_532_mean = nanmean(data.LC.LC_klett_532);
LC_raman_607_mean = nanmean(data.LC.LC_raman_607);

LC_raman_532_std = nanstd(data.LC.LC_raman_532);
LC_klett_532_std = nanstd(data.LC.LC_klett_532);
LC_raman_607_std = nanstd(data.LC.LC_raman_607);

%% read history lidar constants
[LC532History, LCStd532History, LC607History, LCStd607History] = polly_first_read_history_LC(taskInfo.dataTime, LCCaliFile, config);

% choose the most suitable lidar constants for 532 nm
if ~ isnan(LC_raman_532_mean)
    LCUsed532 = LC_raman_532_mean;
    LCUsedTag532 = 2;
    if (LC_raman_532_std / LC_raman_532_mean) >= 0.1
        flagLCWarning532 = true;
    end
elseif ~ isnan(LC_klett_532_mean)
    LCUsed532 = LC_klett_532_mean;
    LCUsedTag532 = 1;
    if (LC_klett_532_std / LC_klett_532_mean) >= 0.1
        flagLCWarning532 = true;
    end
else
    if (~ isempty(LC532History)) && config.flagUsePreviousLC
        LCUsed532 = LC532History;
        LCUsedTag532 = 4;
        flagLCWarning532 = false;
    else
        LCUsed532 = defaults.LC(flagChannel532);
        LCUsedTag532 = 3;
        flagLCWarning532 = false;
    end
end

% choose the most suitable lidar constants for 607 nm
if ~ isnan(LC_raman_607_mean)
    LCUsed607 = LC_raman_607_mean;
    LCUsedTag607 = 2;
    if (LC_raman_607_std / LC_raman_607_mean) >= 0.1
        flagLCWarning607 = true;
    end
else
    if (~ isempty(LC607History)) && config.flagUsePreviousLC
        LCUsed607 = LC607History;
        LCUsedTag607 = 4;
        flagLCWarning607 = false;
    else
        LCUsed607 = defaults.LC(flagChannel607);
        LCUsedTag607 = 3;
        flagLCWarning607 = false;
    end
end

end