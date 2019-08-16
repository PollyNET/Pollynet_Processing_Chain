function polly_1v2_save_wvconst(wvconst, wvconstStd, WVCaliInfo, ...
       IWVAttri, dataFilename, wvconstUsed, wvconstStdUsed, file)
%polly_1v2_save_wvconst  save the water vapor calibration results. 
%   Example:
%       polly_1v2_save_wvconst(wvconst, wvconstStd, WVCaliInfo, IWVAttri, 
%                                   dataFilename, defaults, file)
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
%       wvconstUsed: float
%           the water vapor calibration constant applied for water vapor 
%           retrieving. [g*kg^{-1}]
%       wvconstUsedStd: float
%           the std of water vapor calibration constant applied for water vapor 
%           retrieving. [g*kg^{-1}]
%       file: char
%           file for saving water vapor calibration results.
%   Outputs:
%
%   History:
%       2018-12-19. First Edition by Zhenping
%       2019-02-12. Remove the bug for saving flagCalibration at some time with 
%                   no calibration constants.
%       2019-08-09. Saving the real applied water vapor constant instead of the 
%                   defaults. And remove the outputs of the function.
%   Contact:
%       zhenping@tropos.de

%% Clean the water vapor calibration results
% in case there is empty array
if isempty(wvconst)
    % if there is not cloud free period
    wvconst = wvconstUsed;
    wvconstStd = wvconstStdUsed;
    flagCalibrated = false;
elseif sum(~ isnan(wvconst)) == 0
    % if there is no successful calibration
    wvconst = ones(size(wvconst)) * wvconstUsed;
    wvconstStd = ones(size(wvconst)) * wvconstStdUsed;
    flagCalibrated = false(size(wvconst));
else
    flagCalibrated = ~ isnan(wvconst);
end

if exist(file, 'file') ~= 2
    % if the water vapor calibration file does not exist, create it forcefully.
    fprintf('\n Create %s for saving water vapor calibration results.\n', file);
    fid = fopen(file, 'w');
    fprintf(fid, ['polly data, calibrated?, calibration time, Standard IWV ' ...
                  'Instrument, IWV measurement time, ' ...
                  'wv const(g*kg{-1}), wv const std(g*kg{-1})\n']);
    fclose(fid);
end

fid = fopen(file, 'a');
try
    for iWVCali = 1:length(wvconst)

        if isempty(IWVAttri.datetime)
            IWVMeasTimeStr = '-999';
        elseif isnan(IWVAttri.datetime(iWVCali))
            IWVMeasTimeStr = '-999';
        else 
            IWVMeasTimeStr = datestr(IWVAttri.datetime(iWVCali), ...
                                     'yyyymmdd HH:MM');
        end

        if isempty(WVCaliInfo.datetime)
            wvCaliTimeStr = '-999';
        elseif isnan(WVCaliInfo.datetime(iWVCali))
            wvCaliTimeStr = '-999';
        else
            wvCaliTimeStr = datestr(WVCaliInfo.datetime(iWVCali), ...
                                    'yyyymmdd HH:MM');
        end

        if isnan(wvconst(iWVCali))
            thisWVconst = wvconstUsed;
            thisWVconstStd = wvconstStdUsed;
        else
            thisWVconst = wvconst(iWVCali);
            thisWVconstStd = wvconstStd(iWVCali);
        end

        fprintf(fid, '%s, %d, %s, %s, %s, %f, %f\n', dataFilename, ...
                int32(flagCalibrated(iWVCali)), wvCaliTimeStr, ...
                IWVAttri.source, IWVMeasTimeStr, thisWVconst, thisWVconstStd);
    end
catch
    error(['Error in %s: Failure in writing water vapor ' ...
           'calibration results to %s\n'], mfilename, file);
end

fclose(fid);

end