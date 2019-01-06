function [LCUsed355, LCUsedTag355, flagLCWarning355, LCUsed532, LCUsedTag532, flagLCWarning532, LCUsed1064, LCUsedTag1064, flagLCWarning1064] = pollyxt_noa_save_LC(data, config, taskInfo, folder)
%pollyxt_noa_save_LC calculate and save the lidar calibration constant based on the optional constants and defaults.
%   Example:
%       [LCUsed] = pollyxt_noa_save_LC(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       LCUsed355: float
%           applied lidar constant at 355 nm. 
%       LCUsedTag355: integer
%           source of the applied lidar constant at 355 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults) %      flagLCWarning355: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed532: float
%           applied lidar constant at 532 nm. 
%       LCUsedTag532: integer
%           source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults) %      flagLCWarning532: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed1064: float
%           applied lidar constant at 1064 nm. 
%       LCUsedTag1064: integer
%           source of the applied lidar constant at 1064 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults) %      flagLCWarning1064: integer
%           flag to show whether the calibration constant is unstable. 
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults campaignInfo processInfo

LCUsed355 = [];
LCUsed532 = [];
LCUsed1064 = [];
LCUsedTag355 = 0;   % 0: no calibration; 1: klett; 2: raman; 3: defaults
LCUsedTag532 = 0;
LCUsedTag1064 = 0;
flagLCWarning355 = false;   % if there is large uncertainty of lidar constants, throw a warning.
flagLCWarning532 = false;
flagLCWarning1064 = false;

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

LC_raman_355_std = nanstd(data.LC.LC_raman_355);
LC_raman_532_std = nanstd(data.LC.LC_raman_532);
LC_raman_1064_std = nanstd(data.LC.LC_raman_1064);
LC_klett_355_std = nanstd(data.LC.LC_klett_355);
LC_klett_532_std = nanstd(data.LC.LC_klett_532);
LC_klett_1064_std = nanstd(data.LC.LC_klett_1064);

flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

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
    LCUsed355 = defaults.LC(flagChannel355);
    LCUsedTag355 = 3;
    flagLCWarning355 = false;
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
    LCUsed532 = defaults.LC(flagChannel532);
    LCUsedTag532 = 3;
    flagLCWarning532 = false;
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
    LCUsed1064 = defaults.LC(flagChannel1064);
    LCUsedTag1064 = 3;
    flagLCWarning1064 = false;
end

end