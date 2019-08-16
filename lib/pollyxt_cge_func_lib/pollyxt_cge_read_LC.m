function [LC] = pollyxt_cge_read_LC(LCFile, dataFileFormat)
%pollyxt_cge_read_LC read the lidar constants from the lidar constant file. Detailed information about the file can be found in /doc/pollynet_processing_program.md
%   Example:
%       [LC] = pollyxt_cge_read_LC(LCFile)
%   Inputs:
%       LCFile: char
%           lidar calibration file which saving all the historical calibration results.
%       dataFileFormat: char
%           data file format to extract the date and time from polly data filename.
%   Outputs:
%       LC: struct
%           LCTime: array
%               datetime for each calibration. [datenum]
%           LC355History: array
%               lidar constant at 355 nm.
%           LCStd355History: array
%               standard deviation of lidar constant at 355 nm;
%           LC355Status: array
%                source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
%           LC532History: array
%               lidar constant at 532 nm.
%           LCStd532History: array
%               standard deviation of lidar constant at 532 nm;
%           LC532Status: array
%                source of the applied lidar constant at 532 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
%           LC1064History: array
%               lidar constant at 1064 nm.
%           LCStd1064History: array
%               standard deviation of lidar constant at 1064 nm;
%           LC1064Status: array
%                source of the applied lidar constant at 1064 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
%           LC387History: array
%               lidar constant at 387 nm.
%           LCStd387History: array
%               standard deviation of lidar constant at 387 nm;
%           LC387Status: array
%                source of the applied lidar constant at 387 nm. (0: no calibration; 1: klett; 2: raman; 3: defaults; 4: history)
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
LC.LC355History = [];
LC.LCStd355History = [];
LC.LC355Status = [];
LC.LC532History = [];
LC.LCStd532History = [];
LC.LC532Status = [];
LC.LC1064History = [];
LC.LCStd1064History = [];
LC.LC1064Status = [];
LC.LC387History = [];
LC.LCStd387History = [];
LC.LC387Status = [];
LC.LC607History = [];
LC.LCStd607History = [];
LC.LC607Status = [];

if exist(LCFile, 'file') ~= 2
    warning('Lidar constant results file does not exist!\n%s\n', LCFile);
    return;
end
fid = fopen(LCFile, 'r');
data = textscan(fid, '%s %f %f %d %f %f %d %f %f %d %f %f %d %f %f %d', 'delimiter', ',', 'Headerlines', 1);
fclose(fid);

for iRow = 1:length(data{1})
    LC.LCTime = [LC.LCTime, polly_parsetime(data{1}{iRow}, dataFileFormat)];
end
LC.LC355History = data{2};
LC.LCStd355History = data{3};
LC.LC355Status = data{4};
LC.LC532History = data{5};
LC.LCStd532History = data{6};
LC.LC532Status = data{7};
LC.LC1064History = data{8};
LC.LCStd1064History = data{9};
LC.LC1064Status = data{10};
LC.LC387History = data{11};
LC.LCStd387History = data{12};
LC.LC387Status = data{13};
LC.LC607History = data{14};
LC.LCStd607History = data{15};
LC.LC607Status = data{16};

end