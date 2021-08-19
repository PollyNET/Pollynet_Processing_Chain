function pollyDisplayTCV1(data)
% POLLYDISPLAYTCV1 display aerosol/cloud target classification mask (V1).
%
% USAGE:
%    pollyDisplayTCV1(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-11: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

flag532T = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532C = data.flagFarRangeChannel & data.flag532nmChannel & data.flagCrossChannel;
flag1064 = data.flagFarRangeChannel & data.flag1064nmChannel & data.flagTotalChannel;

if (sum(flag532T) == 1) && (sum(flag532C) == 1) && (sum(flag1064) == 1)
    %% read data
    TC_mask = data.tcMaskV1;
    height = data.height;
    time = data.mTime;
    figDPI = PicassoConfig.figDPI;
    partnerLabel = PollyConfig.partnerLabel;
    flagWatermarkOn = PicassoConfig.flagWatermarkOn;
    yLim_Quasi_Params = PollyConfig.yLim_Quasi_Params;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    imgFormat = PollyConfig.imgFormat;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    %% display rcs 
    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'TC_mask', 'height', 'time', 'yLim_Quasi_Params', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayTCV1.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayTCV1.py');
    end
    delete(tmpFile);
end

end