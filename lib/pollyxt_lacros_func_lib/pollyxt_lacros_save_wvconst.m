function [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = pollyxt_lacros_save_wvconst(wvconst, wvconstStd, WVCaliInfo, IWVAttri, dataFilename, defaults, file)
%pollyxt_lacros_save_wvconst  save the water vapor calibration results. And select the most appropriate water vapor calibration constant to calculate the WVMR and RH.
%   Example:
%       [wvconstUsed, wvconstUsedStd, wvconstUsedInfo] = pollyxt_lacros_save_wvconst(wvconst, wvconstStd, WVCaliInfo, IWVAttri, dataFilename, defaults, file)
%   Inputs:
%       wvconst: array
%           water vapor calibration constants. [g*kg^{-1}] 
%       wvconstStd: array
%           uncertainty of water vapor calibration constants. [g*kg^{-1}] 
%       WVCaliInfo: struct
%           source: char
%               data source. ('AERONET', 'MWR' or else)
%           site: char
%               measurement site.
%           datetime: array
%               datetime of applied IWV.
%           PI: char
%           contact: char
%       IWVAttri: struct
%           datetime: array
%               water vapor calibration time. [datenum]
%           WVCaliInfo: cell
%               calibration information for each calibration period.
%           IntRange: matrix
%               index of integration range for calculate the raw IWV from lidar. 
%       dataFilename: char
%           the polly netcdf data file.
%       defaults: struct
%           defaults configuration. Detailed information can be found in doc/polly_defaults.md 
%       file: char
%           file for saving water vapor calibration results.
%   Outputs:
%       wvconstUsed: float
%           applied water vapor calibration constants.[g*kg^{-1}]  
%       wvconstUsedStd: float
%           uncertainty of applied water vapor calibration constants. [g*kg^{-1}]  
%       wvconstUsedInfo: struct
%           flagCalibrated: logical
%               flag to show whether the applied constant comes from a successful calibration. If not, the result comes from the defaults.
%           IWVInstrument: char
%               the instrument for external standard IWV measurement 
%           nIWVCali: integer
%               number of successful water vapor calibration.
%   Note: 
%       The depolarization calibration results will be saved to "file". If there is no depolarization calibration results, defaults results will be used as replacement.
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

wvconstUsedInfo = struct();
wvconstUsed = NaN;
wvconstUsedStd = NaN;

if isempty(wvconst)
    wvconst = defaults.wvconst;
    thisWVconst = defaults.wvconst;
    thisWVconstStd = defaults.wvconstStd;
    wvconstUsed = defaults.wvconst;
    wvconstUsedStd = defaults.wvconstStd;
    wvCaliTimeStr = '-999';
    flagWVCali = false;
    IWVInstrument = 'none';
    IWVMeasTimeStr = '-999';
    wvconstUsedInfo.flagCalibrated = false;
    wvconstUsedInfo.IWVInstrument = 'none';
    wvconstUsedInfo.nIWVCali = 0;
elseif sum(~ isnan(wvconst)) == 0
    wvconstUsed = defaults.wvconst;
    wvconstUsedStd = defaults.wvconstStd;
    wvconstUsedInfo.flagCalibrated = false;
    wvconstUsedInfo.IWVInstrument = IWVAttri.source;
    wvconstUsedInfo.nIWVCali = 0;
else
    flagCalibrated = ~ isnan(wvconst);
    wvconstUsed = nanmean(wvconst);
    wvconstUsedStd = sqrt(sum(wvconstStd(flagCalibrated).^2)) ./ sum(flagCalibrated);
    wvconstUsedInfo.flagCalibrated = true;
    wvconstUsedInfo.IWVInstrument = IWVAttri.source;
    wvconstUsedInfo.nIWVCali = sum(flagCalibrated);
end

if ~ exist(file, 'file')
    fprintf('\n Create %s for saving water vapor calibration results.\n', file);
    fid = fopen(file, 'w');
    fprintf(fid, 'polly data, calibrated?, calibration time, Standard IWV Instrument, IWV measurement time, wv const(g*kg{-1}), wv const std(g*kg{-1})\n');
    fclose(fid);
end

fid = fopen(file, 'a');
try
    for iWVCali = 1:length(wvconst)

        if isnan(IWVAttri.datetime(iWVCali))
            IWVMeasTimeStr = '-999';
        else 
            IWVMeasTimeStr = datestr(IWVAttri.datetime(iWVCali), 'yyyymmdd HH:MM');
        end

        if isnan(WVCaliInfo.datetime(iWVCali))
            wvCaliTimeStr = '-999';
        else
            wvCaliTimeStr = datestr(WVCaliInfo.datetime(iWVCali), 'yyyymmdd HH:MM');
        end

        if isnan(wvconst(iWVCali))
            thisWVconst = -999;
            thisWVconstStd = -999;
        end

        fprintf(fid, '%s, %d, %s, %s, %s, %f, %f\n', dataFilename, (~ isnan(wvconst(iWVCali))), wvCaliTimeStr, IWVAttri.source, IWVMeasTimeStr, thisWVconst, thisWVconstStd);
    end
catch
    error('Error in %s: Failure in writing water vapor calibration results to %s\n', mfilename, file);
end

fclose(fid);



end