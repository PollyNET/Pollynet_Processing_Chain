function [data, depCalAttri] = polly_1v2_depolcali(data, config, taskInfo, defaults)
%polly_1v2_depolcali calibrate the polly depol channels both for 355 and 532 nm with +- 45\deg method.
%	Example:
%		[data] = polly_1v2_depolcali(data, config, taskInfo, defaults)
%	Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       taskInfo: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       defaults: struct
%           More detailed information can be found in doc/polly_defaults.md
%	Outputs:
%		data: struct
%           The depolarization calibration results will be inserted. And more information can be found in doc/pollynet_processing_program.md
%	History:
%		2018-12-17. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

depCalAttri = struct();
depol_cal_fac_532 = NaN;

if isempty(data.rawSignal)
    return;
end

%% depol calibration
% no depol calibration for polly_1v2

% if no successful calibration, set the calibration factor to be default
% values or other values as you like    
if sum(~ isnan(depol_cal_fac_532)) < 1
    data.depol_cal_fac_532 = defaults.depolCaliConst532;
    data.depol_cal_fac_std_532 = defaults.depolCaliConstStd532;
    data.depol_cal_time_532 = '-999';
else
    [~, indx] = min(depol_cal_fac_std_532);
    data.depol_cal_fac_532 = depol_cal_fac_532(indx);
    data.depol_cal_fac_std_532 = depol_cal_fac_std_532(indx);
    data.depol_cal_time_532 = depol_cal_time_532(indx);
end
    
end