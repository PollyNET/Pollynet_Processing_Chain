function [datetime, depolconst, depolconstStd] = pollyxt_ift_read_depolconst(depolconstFile)
%pollyxt_ift_read_depolconst read the depolarization calibration results from the file.
%   Example:
%       [datetime, depolconst, depolconstStd] = pollyxt_ift_read_depolconst(depolconstFile)
%   Inputs:
%       depolconstFile: char
%           depolarization calibration file. Detailed information about this file can be found in /doc/pollynet_processing_program.md
%   Outputs:
%       datetime: array
%           calibration time for each calibration period. 
%       depolconst: array
%           depolarization calibration constant (the same to V*)
%       depolconstStd: array
%           standard deviation of depolarization calibration constant. 
%   History:
%       2019-02-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

datetime = [];
depolconst = [];
depolconstStd = [];

if exist(depolconstFile, 'file') ~= 2
    warning('Lidar depolarization calibration results file does not exist!\n%s\n', depolconstFile);
    return;
end

fid = fopen(depolconstFile, 'r');
data = textscan(fid, '%s %f %s %f %f', 'delimiter', ',', 'Headerlines', 1);
fclose(fid);

for iRow = 1:length(data{1})
    if data{2}(iRow) == 1 && (~ strcmp(data{3}{iRow}, '-999'))
        datetime = [datetime, datenum(data{3}{iRow}, 'yyyymmdd HH:MM')];
        depolconst = [depolconst, data{4}(iRow)];
        depolconstStd = [depolconstStd, data{5}(iRow)];
    end
end

end