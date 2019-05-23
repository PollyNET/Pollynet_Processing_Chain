function [] = polly_1v2_save_LC_txt(data, taskInfo, config)
%arielle_save_LC_txt  save the lidar constants
%   Example:
%       [] = arielle_save_LC_txt(data, taskInfo, config)
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
LC532 = data.LCUsed.LCUsed532;
LCStd532 = -999;
LC532Status = data.LCUsed.LCUsedTag532;

fid = fopen(LCFile, 'a');
try
    fprintf(fid, '%s, %f, %f, %d\n', dataFile, LC532, LCStd532, LC532Status);
catch
    error('Error in %s: Failure in writing lidar calibration results to %s\n', mfilename, LCFile);
end

fclose(fid);

end