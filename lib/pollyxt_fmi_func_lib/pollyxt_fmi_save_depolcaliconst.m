function [] = pollyxt_fmi_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, depol_cal_fac, depol_cal_fac_std, file)
%pollyxt_fmi_save_depolcaliconst save the depolarization calibration results.
%   Example:
%       [] = pollyxt_fmi_save_depolcaliconst(depolConst, depolConstStd, depolCaliTime, dataFilename, defaults, file)
%   Inputs:
%       depolConst: array
%           depolarization factor at each calibration period. 
%       depolConstStd: array
%           uncertainty of depolarization factor. 
%       depolCaliTime: array
%           time for depolarization calibration. [datenum] 
%       dataFilename: char
%           the polly netcdf data file.
%       depol_cal_fac: double
%           applied depolarization calibration factor.
%       depol_cal_fac_std: double
%           standard deviation of applied depolarization calibration factor.
%       file: char
%           file for saving depolarization calibration results.
%   Outputs:
%       
%   Note: 
%       The depolarization calibration results will be saved to "file". If there is no depolarization calibration results, defaults results will be used as replacement.
%   History:
%       2018-12-19. First Edition by Zhenping
%       2019-02-26. Replace the defaults calibration constant with applied depol calibration factor. The latter takes into account of previous calibration results.
%   Contact:
%       zhenping@tropos.de

if isempty(depolConst)
    depolConst = depol_cal_fac;
    depolConstStd = depol_cal_fac_std;
    depolCaliTimeStr = '-999';
    flagDepolCali = false;
else
    depolCaliTimeStr = datestr(depolCaliTime, 'yyyymmdd HH:MM:SS');
    flagDepolCali = true(size(depolConst));
end

if exist(file, 'file') ~= 2
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