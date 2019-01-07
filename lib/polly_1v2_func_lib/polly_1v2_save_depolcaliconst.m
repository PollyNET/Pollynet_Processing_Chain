function [] = polly_1v2_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, defaults, file)
%polly_1v2_save_depolcaliconst save the depolarization calibration results.
%   Example:
%       [] = polly_1v2_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, defaults, file)
%   Inputs:
%       depolConst: array
%           depolarization factor at each calibration period. 
%       depolConstStd: array
%           uncertainty of depolarization factor. 
%       depolCaliTime: array
%           time for depolarization calibration. [datenum] 
%       dataFilename: char
%           the polly netcdf data file.
%       defaults: struct
%           defaults configuration. Detailed information can be found in doc/polly_defaults.md 
%       file: char
%           file for saving depolarization calibration results.
%   Outputs:
%       
%   Note: 
%       The depolarization calibration results will be saved to "file". If there is no depolarization calibration results, defaults results will be used as replacement.
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if isempty(depolConst)
    depolConst = defaults.depolCaliConst532;
    depolConstStd = defaults.depolCaliConstStd532;
    depolCaliTimeStr = '-999';
    flagDepolCali = false;
else
    depolCaliTimeStr = datestr(depolCaliTime, 'yyyymmdd HH:MM:SS');
    flagDepolCali = true(size(depolConst));
end

if ~ exist(file, 'file')
    fprintf('\n Create %s for saving depolarization calibration results.\n', file);
    fid = fopen(file, 'w');
    fprintf(fid, 'polly data, calibrated?, calibration time, depol calibration factor, std of depol calibration factor\n');
    fclose(fid);
end

fid = fopen(file, 'a');
try
    for iDepolCali = 1:length(depolConst)
        fprintf(fid, '%s, %d, %s, %f, %f\n', dataFilename, flagDepolCali(iDepolCali), depolCaliTimeStr(iDepolCali, :), depolConst(iDepolCali), depolConstStd(iDepolCali));
    end
catch
    error('Error in %s: Failure in writing depolarization calibration results to %s\n', mfilename, file);
end

fclose(fid);

end