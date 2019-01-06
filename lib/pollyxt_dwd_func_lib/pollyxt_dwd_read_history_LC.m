function [LC355, LC532, LC1064, LCStd355, LCStd532, LCStd1064] = pollyxt_dwd_read_history_LC(thisTime, LCFile, config)
%pollyxt_dwd_read_history_LC read history Lidar constant from lidar constant file.
%   Example:
%       [LCOut] = pollyxt_dwd_read_history_LC(thisTime, LCFile)
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
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults

LC355 = [];
LCStd355 = [];
LC532 = [];
LCStd532 = [];
LC1064 = [];
LCStd1064 = [];

%% initialization
flagChannel355 = config.isFR & config.is355nm & config.isTot;
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel1064 = config.isFR & config.is1064nm & config.isTot;

if ~ exist(LCFile, 'file')
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end

%% read LCFile
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d %f %f %d %f %f %d', 'delimiter', ',', 'Headerlines', 1);

LCTime = NaN(1, length(data{1}));
LC355History = NaN(1, length(data{1}));
LCStd355History = NaN(1, length(data{1}));
LC355Status = NaN(1, length(data{1}));
LC532History = NaN(1, length(data{1}));
LCStd532History = NaN(1, length(data{1}));
LC532Status = NaN(1, length(data{1}));
LC1064History = NaN(1, length(data{1}));
LCStd1064History = NaN(1, length(data{1}));
LC1064Status = NaN(1, length(data{1}));
for iRow = 1:length(data{1})
    LCTime(iRow) = polly_parsetime(data{1}{iRow}, config.dataFileFormat);
end
LC355History = data{2};
LCStd355History = data{3};
LC355Status = data{4};
LC532History = data{5};
LCStd532History = data{6};
LC532Status = data{7};
LC1064History = data{8};
LCStd1064History = data{9};
LC1064Status = data{10};

fclose(fid);

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
else
end

end