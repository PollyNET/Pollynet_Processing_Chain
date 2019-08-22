function [LC532, LCStd532, LC607, LCStd607] = polly_1v2_read_history_LC(thisTime, LCFile, config)
%polly_1v2_read_history_LC read history Lidar constant from lidar constant file.
%   Example:
%       [LC532, LCStd532, LC607, LCStd607] = polly_1v2_read_history_LC(thisTime, LCFile, config)
%   Inputs:
%       thisTime: datenum
%           current time. 
%       LCFile: char
%           file for saving the history lidar constants. More information about this file can be found in /doc/pollynet_processing_program.md 
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       LC532: float
%           history lidar constant at 532 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd532: float
%           uncertainty of history lidar constant at 532 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LC607: float
%           history lidar constant at 607 nm. If no history results are found in the +- week lag, an empty array will be returned.
%       LCStd607: float
%           uncertainty of history lidar constant at 607 nm. If no history results are found in the +- week lag, an empty array will be returned.
%   History:
%       2018-12-31. First Edition by Zhenping
%       2019-08-04. Add the output of LC at 607 mn.
%       2019-08-19. If there are multi- close calibration results, choose the last one which is the newest one.
%   Contact:
%       zhenping@tropos.de

global defaults

LC532 = [];
LCStd532 = [];
LC607 = [];
LCStd607 = [];

%% initialization
flagChannel532 = config.isFR & config.is532nm & config.isTot;
flagChannel607 = config.isFR & config.is607nm;

if exist(LCFile, 'file') ~= 2
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end

%% read LCFile
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d %f %f %d', 'delimiter', ',', 'Headerlines', 1);

% read the LC at 532 nm
LCTime = NaN(1, length(data{1}));
LC532History = NaN(1, length(data{1}));
LCStd532History = NaN(1, length(data{1}));
LC532Status = NaN(1, length(data{1}));
for iRow = 1:length(data{1})
    LCTime(iRow) = polly_parsetime(data{1}{iRow}, config.dataFileFormat);
end
LC532History = transpose(data{2});
LCStd532History = transpose(data{3});
LC532Status = transpose(data{4});

% read the LC at 607 nm
LC607History = transpose(data{5});
LCStd607History = transpose(data{6});
LC607Status = transpose(data{7});

fclose(fid);

%% 532 nm
% find the most closest calibrated value in the +- 1 week with Raman method (status=2)
flagValid = (LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC532Status == 2);
if sum(flagValid) ~= 0

    LCTimeValid = LCTime(flagValid);
    LC532HistoryValid = LC532History(flagValid);
    LCStd532HistoryValid = LCStd532History(flagValid);

    % find closest calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTimeValid - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC532 = LC532HistoryValid(indx);
    LCStd532 = LCStd532HistoryValid(indx);
end

%% 607 nm
% find the most closest calibrated value in the +- 1 week with Raman method (status=2)
flagValid = (LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC607Status == 2);
if sum(flagValid) ~= 0

    LCTimeValid = LCTime(flagValid);
    LC607HistoryValid = LC607History(flagValid);
    LCStd607HistoryValid = LCStd607History(flagValid);

    % find closest calibration results. If there are multi-values, choose the last one which is the lastest calibrated results.
    thisLag = abs(LCTimeValid - thisTime);
    minLag = min(thisLag);
    indx = find(thisLag == minLag, 1, 'last');
    LC607 = LC607HistoryValid(indx);
    LCStd607 = LCStd607HistoryValid(indx);
end

end