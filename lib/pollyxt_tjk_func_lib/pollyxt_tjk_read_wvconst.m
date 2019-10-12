function [datetime, wvCaliFlag, wvconst, wvconstStd] = pollyxt_tjk_read_wvconst(wvconstFile)
%pollyxt_tjk_read_wvconst read the depolarization calibration results from the file.
%   Example:
%       [datetime, wvconst, wvconstStd] = pollyxt_tjk_read_wvconst(wvconstFile)
%   Inputs:
%       wvconstFile: char
%           depolarization calibration file. Detailed information about this file can be found in /doc/pollynet_processing_program.md
%   Outputs:
%       datetime: array
%           calibration time for each calibration period. 
%       wvCaliFlag: array
%           water vapor calibration status. (0: no calibration; 1: with calibration)
%       wvconst: array
%           water vapor calibration constant. (the same to V*)
%       wvconstStd: array
%           standard deviation of water vapor calibration constant. 
%   History:
%       2019-02-26. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

datetime = [];
wvCaliFlag = [];
wvconst = [];
wvconstStd = [];

if exist(wvconstFile, 'file') ~= 2
    warning('Water vapor calibration results file does not exist!\n%s\n', wvconstFile);
    return;
end
fid = fopen(wvconstFile, 'r');
data = textscan(fid, '%s %d %s %s %s %f %f', 'delimiter', ',', 'Headerlines', 1);
fclose(fid);

for iRow = 1:length(data{1})
    if (~ strcmp(data{3}{iRow}, '-999'))
        datetime = [datetime, datenum(data{3}{iRow}, 'yyyymmdd HH:MM')];
        wvCaliFlag = [wvCaliFlag, data{2}(iRow)];
        wvconst = [wvconst, data{6}(iRow)];
        wvconstStd = [wvconstStd, data{7}(iRow)];
    end
end

end