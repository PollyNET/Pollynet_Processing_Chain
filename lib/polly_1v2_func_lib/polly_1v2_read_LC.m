function [LC] = polly_1v2_read_LC(LCFile, dataFileFormat)
%polly_1v2_read_LC read the lidar constants from the lidar constant file. Detailed information about the file can be found in /doc/pollynet_processing_program.md
%   Example:
%       [LC] = polly_1v2_read_LC(LCFile)
%   Inputs:
%       LCFile: char
%           lidar calibration file which saving all the historical calibration results.
%       dataFileFormat: char
%           data file format to extract the date and time from polly data filename.
%   Outputs:
%       LC: struct
%           LCTime: array
%               datetime for each calibration. [datenum]
%           LC532History: array
%               lidar constant at 532 nm.
%           LCStd532History: array
%               standard deviation of lidar constant at 532 nm;
%           LC532Status: array
%                source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
%           LC607History: array
%               lidar constant at 607 nm.
%           LCStd607History: array
%               standard deviation of lidar constant at 607 nm;
%           LC607Status: array
%                source of the applied lidar constant at 607 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
%   History:
%       2019-02-07. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

LC.LCTime = [];
LC.LC532History = [];
LC.LCStd532History = [];
LC.LC532Status = [];
LC.LC607History = [];
LC.LCStd607History = [];
LC.LC607Status = [];

if exist(LCFile, 'file') ~= 2
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d %f %f %d', 'delimiter', ',', 'Headerlines', 1);
fclose(fid);

for iRow = 1:length(data{1})
    LC.LCTime = [LC.LCTime, polly_parsetime(data{1}{iRow}, dataFileFormat)];
end
LC.LC532History = data{2};
LC.LCStd532History = data{3};
LC.LC532Status = data{4};
LC.LC607History = data{5};
LC.LCStd607History = data{6};
LC.LC607Status = data{7};

end