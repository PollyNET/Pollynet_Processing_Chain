function [] = pollyxt_tau_save_LC_txt(data, taskInfo, config)
%pollyxt_tau_save_LC_txt  save the lidar constants
%   Example:
%       [] = pollyxt_tau_save_LC_txt(data, taskInfo, config)
%   Inputs:
%   Outputs:
%
%   History:
%       2018-12-19. First Edition by Zhenping
%       2019-01-28. Add support for 387 and 607 channels.
%   Contact:
%       zhenping@tropos.de

global processInfo defaults campaignInfo

LCFile = fullfile(processInfo.results_folder, campaignInfo.name, config.lcCaliFile);

%% fill missing values
dataFile = taskInfo.dataFilename;
LC355 = data.LCUsed.LCUsed355;
LCStd355 = -999;
LC355Status = data.LCUsed.LCUsedTag355;
LC532 = data.LCUsed.LCUsed532;
LCStd532 = -999;
LC532Status = data.LCUsed.LCUsedTag532;
LC1064 = data.LCUsed.LCUsed1064;
LCStd1064 = -999;
LC1064Status = data.LCUsed.LCUsedTag1064;
LC387 = data.LCUsed.LCUsed387;
LCStd387 = -999;
LC387Status = data.LCUsed.LCUsedTag387;
LC607 = data.LCUsed.LCUsed607;
LCStd607 = -999;
LC607Status = data.LCUsed.LCUsedTag607;

fid = fopen(LCFile, 'a');
try
    fprintf(fid, '%s, %f, %f, %d, %f, %f, %d, %f, %f, %d, %f, %f, %d, %f, %f, %d\n', dataFile, LC355, LCStd355, LC355Status, LC532, LCStd532, LC532Status, LC1064, LCStd1064, LC1064Status, LC387, LCStd387, LC387Status, LC607, LCStd607, LC607Status);
catch
    error('Error in %s: Failure in writing lidar calibration results to %s\n', mfilename, LCFile);
end

fclose(fid);

end