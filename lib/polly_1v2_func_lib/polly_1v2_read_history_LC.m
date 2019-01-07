function [LC532, LCStd532] = polly_1v2_read_history_LC(thisTime, LCFile, config)
%polly_1v2_read_history_LC read history Lidar constant from lidar constant file.
%   Example:
%       [LCOut] = polly_1v2_read_history_LC(thisTime, LCFile)
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
%   History:
%       2018-12-31. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults

LC532 = [];
LCStd532 = [];

%% initialization
flagChannel532 = config.isFR & config.is532nm & config.isTot;

if ~ exist(LCFile, 'file')
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end

%% read LCFile
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d', 'delimiter', ',', 'Headerlines', 1);

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

fclose(fid);

%% find the most closest calibrated value in the +- week.
index = find((LCTime > (thisTime - datenum(0,1,7))) & (LCTime < (thisTime + datenum(0,1,7))));
if ~ isempty(index)
    % find the most closest calibrated Lidar constant
    [~, indx] = min(abs(LCTime - thisTime));
    LC532 = LC532History(indx);
    LCStd532 = LCStd532History(indx);
else
end

end