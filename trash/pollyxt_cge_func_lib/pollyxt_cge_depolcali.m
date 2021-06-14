function [data, depCalAttri] = pollyxt_cge_depolcali(data, config, taskInfo)
%POLLYXT_CGE_DEPOLCALI calibrate the polly depol channels both for 355 and 532 nm with +- 45\deg method.
%Example:
%   [data] = pollyxt_cge_depolcali(data, config)
%Inputs:
%   data.struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   config: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%   taskInfo: struct
%       More detailed information can be found in doc/pollynet_processing_program.md
%Outputs:
%   data.struct
%       The depolarization calibration results will be inserted. And more information can be found in doc/pollynet_processing_program.md
%   depCalAttri: struct
%       depolarization calibration information for each calibration period.
%History:
%   2019-08-10. First edition by Zhenping
%Contact:
%   zhenping@tropos.de

global processInfo campaignInfo defaults

depCalAttri = struct();

if isempty(data.rawSignal)
    return;
end

% 532 nm
% No automatic depol calibration for pollyxt_cge
% Apply default settings
data.depol_cal_fac_532 = defaults.depolCaliConst532;
data.depol_cal_fac_std_532 = defaults.depolCaliConstStd532;
data.depol_cal_time_532 = 0;

end