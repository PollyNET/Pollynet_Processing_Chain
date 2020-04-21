function LCUsed = polly_1v2_select_liconst(data, config, dbFile)
%POLLY_1v2_SELECT_LICONST select the most suitable lidar calibration constants.
%Example:
%   LCUsed = polly_1v2_select_liconst(data, config, dbFile)
%Inputs:
%   data.struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in
%       doc/pollynet_processing_program.md
%   dbFile: char
%       absolute path of the database.
%Outputs:
%   LCUsed: struct
%       LCUsed532: float
%           applied lidar constant at 532 nm. 
%       LCUsedTag532: integer
%           source of the applied lidar constant at 532 nm.
%           (1: klett; 2: raman; 3: defaults; 4: history) 
%       flagLCWarning532: integer
%           flag to show whether the calibration constant is unstable. 
%       LCUsed607: float
%           applied lidar constant at 607 nm. 
%       LCUsedTag607: integer
%           source of the applied lidar constant at 607 nm.
%           (1: klett; 2: raman; 3: defaults; 4: history) 
%       flagLCWarning607: integer
%           flag to show whether the calibration constant is unstable.
%History:
%   2020-04-18. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

global defaults campaignInfo

LC = data.LC;

LCUsed = struct();
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel607 = config.isFR & config.is607nm;

[LCUsed.LCUsed532, ~, LCUsed.LCUsedTag532, LCUsed.flagLCWarning532] = ...
    select_liconst(LC.LC_raman_532, zeros(size(LC.LC_raman_532)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, campaignInfo.name, '532', ...
        'flagUsePrevLC', config.flagUsePreviousLC, ...
        'flagLCCalibration', config.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', defaults.LC(flagChannel532), ...
        'default_liconstStd', defaults.LCStd(flagChannel532));
[LCUsed.LCUsed607, ~, LCUsed.LCUsedTag607, LCUsed.flagLCWarning607] = ...
    select_liconst(LC.LC_raman_607, zeros(size(LC.LC_raman_607)), ...
        LC.LC_start_time, ...
        LC.LC_stop_time, ...
        mean(data.mTime), dbFile, campaignInfo.name, '607', ...
        'flagUsePrevLC', config.flagUsePreviousLC, ...
        'flagLCCalibration', config.flagLCCalibration, ...
        'deltaTime', datenum(0, 1, 7), ...
        'default_liconst', defaults.LC(flagChannel607), ...
        'default_liconstStd', defaults.LCStd(flagChannel607));

end