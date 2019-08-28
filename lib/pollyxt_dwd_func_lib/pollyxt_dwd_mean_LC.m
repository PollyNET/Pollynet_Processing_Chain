function [LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064, LCUsed387, LCUsedTag387, flagLCWarning387, LCUsed607, LCUsedTag607, flagLCWarning607] = pollyxt_dwd_mean_LC(data, config, taskInfo, folder)
%pollyxt_dwd_mean_LC calculate and save the lidar calibration constant based on the optional constants and defaults.
%   Example:
%       [LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064, LCUsed387, LCUsedTag387, flagLCWarning387, LCUsed607, LCUsedTag607, flagLCWarning607] = pollyxt_dwd_mean_LC(data, config)
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
%       LCUsed355: float
%           applied lidar constant at 355 nm. 
%       LCUsedTag355: integer
%           source of the applied lidar constant at 355 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning355: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed532: float
%           applied lidar constant at 532 nm. 
%       LCUsedTag532: integer
%           source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning532: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed1064: float
%           applied lidar constant at 1064 nm. 
%       LCUsedTag1064: integer
%           source of the applied lidar constant at 1064 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning1064: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed387: float
%           applied lidar constant at 387 nm. 
%       LCUsedTag387: integer
%           source of the applied lidar constant at 387 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning387: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed607: float
%           applied lidar constant at 607 nm. 
%       LCUsedTag607: integer
%           source of the applied lidar constant at 607 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history) 
%      flagLCWarning607: integer
%           flag to show whether the calibration constant is unstable. 
%   History:
%       2018-12-24. First Edition by Zhenping
%       2019-01-28. Add support for 387 and 607 channels
%       2019-08-28. Add flag to control whether to do lidar calibration.
%   Contact:
%       zhenping@tropos.de


global defaults campaignInfo processInfo

LCUsed355 = [];
LCUsed532 = [];
LCUsed1064 = [];
LCUsed387 = [];
LCUsed607 = [];
LCUsedTag355 = 0;   % 0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history
LCUsedTag532 = 0;
LCUsedTag1064 = 0;
LCUsedTag387 = 0;
LCUsedTag607 = 0;
flagLCWarning355 = false;   % if there is large uncertainty of lidar constants, throw a warning.
flagLCWarning532 = false;
flagLCWarning1064 = false;
flagLCWarning387 = false;
flagLCWarning607 = false;
LCCaliFile = fullfile(folder, config.lcCaliFile);

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel387 = config.isFR & config.is387nm;
flagChannel607 = config.isFR & config.is607nm;

if ~ config.flagLCCalibration
    % disable lidar calibration and use default lidar constants
    LCUsed355 = defaults.LC(flagChannel355);
    LCUsed532 = defaults.LC(flagChannel532);
    LCUsed1064 = defaults.LC(flagChannel1064);
    LCUsed387 = defaults.LC(flagChannel387);
    LCUsed607 = defaults.LC(flagChannel607);

    return;
end

%% create the LC file if not exist
if exist(LCCaliFile, 'file') ~= 2
    fprintf('Create the file to save the lidar constants.\n%s\n', LCCaliFile);
    fid = fopen(LCCaliFile, 'w');
    fprintf(fid, 'polly data, LC355, LC355Std, Calibration status 355, LC532, LC532Std, Calibration status 532, LC1064, LC1064Std, Calibration status 1064, LC387, LC387Std, Calibration status 387, LC607, LC607Std, Calibration status 607\n');
    fclose(fid);
end

if isempty(data.rawSignal)
    return;
end

% mean and std values of lidar constants
LC_raman_355_mean = nanmean(data.LC.LC_raman_355);
LC_raman_532_mean = nanmean(data.LC.LC_raman_532);
LC_raman_1064_mean = nanmean(data.LC.LC_raman_1064);
LC_klett_355_mean = nanmean(data.LC.LC_klett_355);
LC_klett_532_mean = nanmean(data.LC.LC_klett_532);
LC_klett_1064_mean = nanmean(data.LC.LC_klett_1064);
LC_raman_387_mean = nanmean(data.LC.LC_raman_387);
LC_raman_607_mean = nanmean(data.LC.LC_raman_607);

LC_raman_355_std = nanstd(data.LC.LC_raman_355);
LC_raman_532_std = nanstd(data.LC.LC_raman_532);
LC_raman_1064_std = nanstd(data.LC.LC_raman_1064);
LC_klett_355_std = nanstd(data.LC.LC_klett_355);
LC_klett_532_std = nanstd(data.LC.LC_klett_532);
LC_klett_1064_std = nanstd(data.LC.LC_klett_1064);
LC_raman_387_std = nanstd(data.LC.LC_raman_387);
LC_raman_607_std = nanstd(data.LC.LC_raman_607);

%% read history lidar constants
[LC355History, LC532History, LC1064History, LC387History, LC607History, LCStd355History, LCStd532History, LCStd1064History, LCStd387History, LCStd607History] = pollyxt_dwd_read_history_LC(taskInfo.dataTime, LCCaliFile, config);

% choose the most suitable lidar constants for 355 nm
if ~ isnan(LC_raman_355_mean)
    LCUsed355 = LC_raman_355_mean;
    LCUsedTag355 = 2;
    if (LC_raman_355_std / LC_raman_355_mean) >= 0.1
        flagLCWarning355 = true;
    end
elseif ~ isnan(LC_klett_355_mean)
    LCUsed355 = LC_klett_355_mean;
    LCUsedTag355 = 1;
    if (LC_klett_355_std / LC_klett_355_mean) >= 0.1
        flagLCWarning355 = true;
    end
else
    if (~ isempty(LC355History)) && config.flagUsePreviousLC
        LCUsed355 = LC355History;
        LCUsedTag355 = 4;
        flagLCWarning355 = false;
    else
        LCUsed355 = defaults.LC(flagChannel355);
        LCUsedTag355 = 3;
        flagLCWarning355 = false;
    end
end

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

% choose the most suitable lidar constants for 1064 nm
if ~ isnan(LC_raman_1064_mean)
    LCUsed1064 = LC_raman_1064_mean;
    LCUsedTag1064 = 2;
    if (LC_raman_1064_std / LC_raman_1064_mean) >= 0.1
        flagLCWarning1064 = true;
    end
elseif ~ isnan(LC_klett_1064_mean)
    LCUsed1064 = LC_klett_1064_mean;
    LCUsedTag1064 = 1;
    if (LC_klett_1064_std / LC_klett_1064_mean) >= 0.1
        flagLCWarning1064 = true;
    end
else
    if (~ isempty(LC1064History)) && config.flagUsePreviousLC
        LCUsed1064 = LC1064History;
        LCUsedTag1064 = 4;
        flagLCWarning1064 = false;
    else
        LCUsed1064 = defaults.LC(flagChannel1064);
        LCUsedTag1064 = 3;
        flagLCWarning1064 = false;
    end
end

% choose the most suitable lidar constants for 387 nm
if ~ isnan(LC_raman_387_mean)
    LCUsed387 = LC_raman_387_mean;
    LCUsedTag387 = 2;
    if (LC_raman_387_std / LC_raman_387_mean) >= 0.1
        flagLCWarning387 = true;
    end
else
    if (~ isempty(LC387History)) && config.flagUsePreviousLC
        LCUsed387 = LC387History;
        LCUsedTag387 = 4;
        flagLCWarning387 = false;
    else
        LCUsed387 = defaults.LC(flagChannel387);
        LCUsedTag387 = 3;
        flagLCWarning387 = false;
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