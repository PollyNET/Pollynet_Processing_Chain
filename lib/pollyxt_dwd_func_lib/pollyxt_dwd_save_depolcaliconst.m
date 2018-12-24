function [] = pollyxt_dwd_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, defaults, file)
%pollyxt_dwd_save_depolcaliconst save the depolarization calibration results.
%   Example:
%       [] = pollyxt_dwd_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, defaults, file)
%   Inputs:
%       depolConst, depolConstStd, depolCaliTime, defaults, file
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
    depolCaliTime = '-999';
    flagDepolCali = false;
else
    depolCaliTime = datestr(depolCaliTime, 'yyyymmdd HH:MM:SS');
    flagDepolCali = true(size(depolConst));
end

if ~ exist(file, 'file')
    fprintf('\n Create %s for saving calibration results.\n', file);
    fid = fopen(file, 'w');
    fprintf(fid, 'polly data, calibrated?, calibration time, depol calibration factor, std of depol calibration factor\n');
    fclose(fid);
end

fid = fopen(file, 'a');
try
    for iDepolCali = 1:length(depolConst)
        fprintf('%s,%d,%s,%f,%f\n', dataFilename, flagDepolCali(iDepolCali), depolCaliTime(iDepolCali, :), depolConst(iDepolCali), depolConstStd(iDepolCali));
    end
catch
    error('Error in %s: Failure in writing depolarization calibration results to %s\n', mfilename, file);
end

fclose(fid);

end