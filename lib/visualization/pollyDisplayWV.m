function pollyDisplayWV(data)
% POLLYDISPLAYWV display water vapor products.
%
% USAGE:
%    pollyDisplayWV(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-10: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

flag407 = data.flag407nmChannel & data.flagFarRangeChannel;
flag387 = data.flag387nmChannel & data.flagFarRangeChannel;

if (sum(flag407) == 1) && (sum(flag387) == 1)

    WVMR = data.WVMR;
    RH = data.RH;
    wvconstUsed = data.wvconstUsed;
    lowSNRMask = (squeeze(data.lowSNRMask(flag387, :, :)) | squeeze(data.lowSNRMask(flag407, :, :)));
    flagCalibrated = logical2str(data.wvconstUsedInfo.flagCalibrated, 'yes');
    flagCalibrated = flagCalibrated{1};
    height = data.height;
    time = data.mTime;
    yLim_WV_RH = PollyConfig.yLim_WV_RH;
    figDPI = PicassoConfig.figDPI;
    partnerLabel = PollyConfig.partnerLabel;
    flagWatermarkOn = PicassoConfig.flagWatermarkOn;
    xLim_Profi_WV_RH = PollyConfig.xLim_Profi_WV_RH;
    meteorSource = data.quasiAttri.meteorSource;
    [xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
    imgFormat = PollyConfig.imgFormat;
    colormap_basic = PollyConfig.colormap_basic;

    pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
    tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
    saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

    % create tmp folder by force, if it does not exist.
    if ~ exist(tmpFolder, 'dir')
        fprintf('Create the tmp folder to save the temporary results.\n');
        mkdir(tmpFolder);
    end

    tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
    save(tmpFile, 'figDPI', 'WVMR', 'RH', 'lowSNRMask', 'flagCalibrated', 'wvconstUsed', 'meteorSource', 'height', 'time', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'xLim_Profi_WV_RH', 'yLim_WV_RH', 'imgFormat', 'colormap_basic', 'flagWatermarkOn', 'partnerLabel', '-v6');
    flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayWV.py'), tmpFile, saveFolder));
    if flag ~= 0
        warning('Error in executing %s', 'pollyDisplayWV.py');
    end
    delete(tmpFile);
end

end