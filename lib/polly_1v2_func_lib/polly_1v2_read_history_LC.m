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

if ~ exist(LCFile, 'file')
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
LC532History = data{2};
LCStd532History = data{3};
LC532Status = data{4};

% read the LC at 607 nm
LCTime = NaN(1, length(data{1}));
LC607History = NaN(1, length(data{1}));
LCStd607History = NaN(1, length(data{1}));
LC607Status = NaN(1, length(data{1}));
LC607History = data{5};
LCStd607History = data{6};
LC607Status = data{7};

fclose(fid);

%% find the most closest calibrated value in the +- 1 week with Raman method (status=2)
% 532 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC532Status == 2));
if ~ isempty(index)
    [~, indx] = min(abs(LCTime - thisTime));
    LC532 = LC532History(indx);
    LCStd532 = LCStd532History(indx);
end

% 607 nm
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))) & (LC607Status == 2));
if ~ isempty(index)
    [~, indx] = min(abs(LCTime - thisTime));
    LC607 = LC607History(indx);
    LCStd607 = LCStd607History(indx);
end

end