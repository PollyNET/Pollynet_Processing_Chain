function [LC355, LC532, LC1064, LC387, LC607, LCStd355, LCStd532, LCStd1064, LCStd387, LCStd607] = pollyxt_tjk_read_history_LC(thisTime, LCFile, config)
%pollyxt_tjk_read_history_LC read history Lidar constant from lidar constant file.
%   Example:
%       [LC355, LC532, LC1064, LC387, LC607, LCStd355, LCStd532, LCStd1064, LCStd387, LCStd607] = pollyxt_tjk_read_history_LC(thisTime, LCFile, config)
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
%       2019-01-28. Add support for 387 and 607 channels
%       2019-08-06. If no history results, using the last Raman calibration results.
%       2019-08-19. If there are multi- close calibration results, choose the last one which is the newest one.
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

if exist(LCFile, 'file') ~= 2
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end

%% read LCFile
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d %f %f %d %f %f %d %f %f %d %f %f %d', 'delimiter', ',', 'Headerlines', 1);

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
LC387History = NaN(1, length(data{1}));
LCStd387History = NaN(1, length(data{1}));
LC387Status = NaN(1, length(data{1}));
LC607History = NaN(1, length(data{1}));
LCStd607History = NaN(1, length(data{1}));
LC607Status = NaN(1, length(data{1}));
for iRow = 1:length(data{1})
    LCTime(iRow) = polly_parsetime(data{1}{iRow}, config.dataFileFormat);
end
LC355History = transpose(data{2});
LCStd355History = transpose(data{3});
LC355Status = transpose(data{4});
LC532History = transpose(data{5});
LCStd532History = transpose(data{6});
LC532Status = transpose(data{7});
LC1064History = transpose(data{8});
LCStd1064History = transpose(data{9});
LC1064Status = transpose(data{10});
LC387History = transpose(data{11});
LCStd387History = transpose(data{12});
LC387Status = transpose(data{13});
LC607History = transpose(data{14});
LCStd607History = transpose(data{15});
LC607Status = transpose(data{16});

fclose(fid);

%% find the most closest calibrated value in the +- 1 week with Raman method (status=2)
% 355 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC355Status == 2), 1);
if ~ isempty(index)
    % find most close calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTime - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC355 = LC355History(indx);
    LCStd355 = LCStd355History(indx);
end

% 532 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC532Status == 2), 1);
if ~ isempty(index)
    % find most close calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTime - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC532 = LC532History(indx);
    LCStd532 = LCStd532History(indx);
end

% 1064 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC1064Status == 2), 1);
if ~ isempty(index)
    % find most close calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTime - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC1064 = LC1064History(indx);
    LCStd1064 = LCStd1064History(indx);
end

% 387 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC387Status == 2), 1);
if ~ isempty(index)
    % find most close calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTime - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC387 = LC387History(indx);
    LCStd387 = LCStd387History(indx);
end

% 607 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC607Status == 2), 1);
if ~ isempty(index)
    % find most close calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTime - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC607 = LC607History(indx);
    LCStd607 = LCStd607History(indx);
end

end