function [LC355, LC532, LC1064, LC387, LC607, LCStd355, LCStd532, LCStd1064, LCStd387, LCStd607] = pollyxt_tjk_read_history_LC(thisTime, LCFile, config)
%pollyxt_tjk_read_history_LC read history Lidar constant from lidar constant file.
%   Example:
%       [LCOut] = pollyxt_tjk_read_history_LC(thisTime, LCFile)
%   Inputs:
%       thisTime: datenum
%           current time. 
%       LCFile: char
%           file for saving the history lidar constants. More information about this file can be found in /doc/pollynet_processing_program.md 
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       LC355: float
%           history lidar constant at 355 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd355: float
%           uncertainty of history lidar constant at 355 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LC532: float
%           history lidar constant at 532 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd532: float
%           uncertainty of history lidar constant at 532 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LC1064: float
%           history lidar constant at 1064 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd1064: float
%           uncertainty of history lidar constant at 1064 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LC387: float
%           history lidar constant at 387 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd387: float
%           uncertainty of history lidar constant at 387 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LC607: float
%           history lidar constant at 607 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd607: float
%           uncertainty of history lidar constant at 607 nm. If no history results are found in the +- week lag, an empty array will be returned.
%   History:
%       2018-12-31. First Edition by Zhenping
%       2018-01-28. Add support for 387 and 607 channels
%   Contact:
%       zhenping@tropos.de

global defaults

LC355 = [];
LCStd355 = [];
LC532 = [];
LCStd532 = [];
LC1064 = [];
LCStd1064 = [];
LC387 = [];
LCStd387 = [];
LC607 = [];
LCStd607 = [];

%% initialization
flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;
flagChannel387 = config.isFR & config.is387nm;
flagChannel607 = config.isFR & config.is607nm;

%% read LCFile
LC = pollyxt_tjk_read_LC(LCFile, config.dataFileFormat);
LCTime = LC.LCTime;
LC355History = LC.LC355History;
LCStd355History = LC.LCStd355History;
LC355Status = LC.LC355Status;
LC532History = LC.LC532History;
LCStd532History = LC.LCStd532History;
LC532Status = LC.LC532Status;
LC1064History = LC.LC1064History;
LCStd1064History = LC.LCStd1064History;
LC1064Status = LC.LC1064Status;
LC387History = LC.LC387History;
LCStd387History = LC.LCStd387History;
LC387Status = LC.LC387Status;
LC607History = LC.LC607History;
LCStd607History = LC.LCStd607History;
LC607Status = LC.LC607Status;

%% find the most closest calibrated value in the +- week.
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))));
if ~ isempty(index)
    % find the most closest calibrated Lidar constant
    [~, indx] = min(abs(LCTime - thisTime));
    LC355 = LC355History(indx);
    LCStd355 = LCStd355History(indx);
    LC532 = LC532History(indx);
    LCStd532 = LCStd532History(indx);
    LC1064 = LC1064History(indx);
    LCStd1064 = LCStd1064History(indx);
    LC387 = LC387History(indx);
    LCStd387 = LCStd387History(indx);
    LC607 = LC607History(indx);
    LCStd607 = LCStd607History(indx);
else
end

end