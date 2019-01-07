function [LCUsed532, LCUsedTag532, flagLCWarning532] = polly_1v2_mean_LC(data, config, taskInfo, folder)
%polly_1v2_mean_LC calculate and save the lidar calibration constant based on the optional constants and defaults.
%   Example:
%       [LCUsed] = polly_1v2_mean_LC(data, config)
%   Inputs:
%		data: struct
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
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

%% TODO: if no lidar calibration or too much uncertainty read history lidar constants.

global defaults campaignInfo processInfo

LCUsed532 = [];
LCUsedTag532 = 0;
flagLCWarning532 = false;
LCCaliFile = fullfile(processInfo.results_folder, taskInfo.pollyVersion, config.lcCaliFile);

%% create the LC file if not exist
if ~ exist(LCCaliFile, 'file')
    fprintf('Create the file to save the lidar constants.\n%s\n', LCCaliFile);
    fid = fopen(LCCaliFile, 'w');
    fprintf(fid, 'polly data, LC532, LC532Std, Calibration status 532\n');
    fclose(fid);
end

if isempty(data.rawSignal)
    return;
end

% mean and std values of lidar constants
LC_raman_532_mean = nanmean(data.LC.LC_raman_532);
LC_klett_532_mean = nanmean(data.LC.LC_klett_532);

LC_raman_532_std = nanstd(data.LC.LC_raman_532);
LC_klett_532_std = nanstd(data.LC.LC_klett_532);

flagChannel532 = config.isFR & config.is532nm & config.isTot;

%% read history lidar constants
[LC532History, LCStd532History] = polly_1v2_read_history_LC(taskInfo.dataTime, LCCaliFile, config);

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
    if ~ isempty(LC532History)
        LCUsed532 = LC532History;
        LCUsedTag532 = 4;
        flagLCWarning532 = false;
    else
        LCUsed532 = defaults.LC(flagChannel532);
        LCUsedTag532 = 3;
        flagLCWarning532 = false;
    end
end

end