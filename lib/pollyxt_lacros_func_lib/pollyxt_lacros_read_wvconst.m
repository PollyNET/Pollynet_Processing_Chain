function [datetime, wvconst, wvconstStd] = pollyxt_lacros_read_wvconst(wvFile)
%pollyxt_lacros_read_wvconst read the water vapor calibration results from the file.
%   Example:
%       [datetime, wvconst, wvconstStd] = pollyxt_lacros_read_wvconst(wvFile)
%   Inputs:
%       wvFile: char
%           water vapor calibration file. Detailed information about this file can be found in /doc/pollynet_processing_program.md
%   Outputs:
%       datetime: array
%           calibration time for each calibration period. 
%       wvconst: array
%           water vapor calibration constant. [g*kg^{-1}] 
%       wvconstStd: array
%           standard deviation of water vapor calibration constant. [g*kg^{-1}]
%   History:
%       2019-02-12. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

datetime = [];
wvconst = [];
wvconstStd = [];

if ~ exist(wvFile, 'file')
    warning('Lidar water vapor calibration results file does not exist!\n%s\n', wvFile);
    return;
end
fid = fopen(wvFile, 'r');
data = textscan(fid, '%s %f %s %s %s %f %f', 'delimiter', ',', 'Headerlines', 1);
fclose(fid);

for iRow = 1:length(data{1})
    if data{2}(iRow) == 1 && (~ strcmp(data{3}{iRow}, '-999'))
        datetime = [datetime, datenum(data{3}{iRow}, 'yyyymmdd HH:MM')];
        wvconst = [wvconst, data{6}(iRow)];
        wvconstStd = [wvconstStd, data{7}(iRow)];
    end
end

end