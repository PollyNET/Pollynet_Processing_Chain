function pollyDisplayPolCali(data)
% POLLYDISPLAYPOLCALI display polarization calibration results.
% USAGE:
%    pollyDisplayPolCali(data)
% INPUTS:
%    data
% EXAMPLE:
% HISTORY:
%    2021-06-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

imgFormat = PollyConfig.imgFormat;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;

pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));

% create tmp folder by force, if it does not exist.
if ~ exist(tmpFolder, 'dir')
    fprintf('Create the tmp folder to save the temporary results.\n');
    mkdir(tmpFolder);
end

% 532 nm
flag532C = data.flagCrossChannel & data.flag532nmChannel & data.flagFarRangeChannel;
flag532T = data.flagTotalChannel & data.flag532nmChannel & data.flagFarRangeChannel;

if (sum(flag532C) == 1) && (sum(flag532T) == 1) && (~ PollyConfig.flagMolDepolCali)
    for iCali = 1:length(data.polCali532Attri.caliTime)  
        wavelength = 532; 
        time = data.mTime;
        height = data.height;
        figDPI = PicassoConfig.figDPI;
        sig_t_p = data.polCali532Attri.sig_t_p{iCali};
        sig_t_m = data.polCali532Attri.sig_t_m{iCali};
        sig_x_p = data.polCali532Attri.sig_x_p{iCali};
        sig_x_m = data.polCali532Attri.sig_x_m{iCali};
        caliHIndxRange = data.polCali532Attri.caliHIndxRange{iCali};
        indx_45m = data.polCali532Attri.indx_45m{iCali};
        indx_45p = data.polCali532Attri.indx_45p{iCali};
        dplus = data.polCali532Attri.dplus{iCali};
        dminus = data.polCali532Attri.dminus{iCali};
        segmentLen = data.polCali532Attri.segmentLen{iCali};
        indx = data.polCali532Attri.indx{iCali};
        mean_dplus_tmp = data.polCali532Attri.mean_dplus_tmp{iCali};
        std_dplus_tmp = data.polCali532Attri.std_dplus_tmp{iCali};
        mean_dminus_tmp = data.polCali532Attri.mean_dminus_tmp{iCali};
        std_dminus_tmp = data.polCali532Attri.std_dminus_tmp{iCali};
        TR_t = data.polCali532Attri.TR_t{iCali};
        TR_x = data.polCali532Attri.TR_x{iCali};
        segIndx = data.polCali532Attri.segIndx{iCali};
        caliTime = data.polCali532Attri.caliTime{iCali};

        %% display depol-cali results
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'wavelength', 'time', 'height', 'sig_t_p', 'sig_t_m', 'sig_x_p', 'sig_x_m', 'caliHIndxRange', 'indx_45m', 'indx_45p', 'dplus', 'dminus', 'segmentLen', 'indx', 'mean_dplus_tmp', 'std_dplus_tmp', 'mean_dminus_tmp', 'std_dminus_tmp', 'TR_t', 'TR_x', 'segIndx', 'caliTime', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayPolCali.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayPolCali.py');
        end
        delete(tmpFile);
    end
end

% 355 nm
flag355C = data.flagCrossChannel & data.flag355nmChannel & data.flagFarRangeChannel;
flag355T = data.flagTotalChannel & data.flag355nmChannel & data.flagFarRangeChannel;

if (sum(flag355C) == 1) && (sum(flag355T) == 1) && (~ PollyConfig.flagMolDepolCali)
    for iCali = 1:length(data.polCali355Attri.caliTime)  
        wavelength = 355; 
        time = data.mTime;
        height = data.height;
        figDPI = PicassoConfig.figDPI;
        sig_t_p = data.polCali355Attri.sig_t_p{iCali};
        sig_t_m = data.polCali355Attri.sig_t_m{iCali};
        sig_x_p = data.polCali355Attri.sig_x_p{iCali};
        sig_x_m = data.polCali355Attri.sig_x_m{iCali};
        caliHIndxRange = data.polCali355Attri.caliHIndxRange{iCali};
        indx_45m = data.polCali355Attri.indx_45m{iCali};
        indx_45p = data.polCali355Attri.indx_45p{iCali};
        dplus = data.polCali355Attri.dplus{iCali};
        dminus = data.polCali355Attri.dminus{iCali};
        segmentLen = data.polCali355Attri.segmentLen{iCali};
        indx = data.polCali355Attri.indx{iCali};
        mean_dplus_tmp = data.polCali355Attri.mean_dplus_tmp{iCali};
        std_dplus_tmp = data.polCali355Attri.std_dplus_tmp{iCali};
        mean_dminus_tmp = data.polCali355Attri.mean_dminus_tmp{iCali};
        std_dminus_tmp = data.polCali355Attri.std_dminus_tmp{iCali};
        TR_t = data.polCali355Attri.TR_t{iCali};
        TR_x = data.polCali355Attri.TR_x{iCali};
        segIndx = data.polCali355Attri.segIndx{iCali};
        caliTime = data.polCali355Attri.caliTime{iCali};

        %% display depol-cali results
        tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
        save(tmpFile, 'figDPI', 'wavelength', 'time', 'height', 'sig_t_p', 'sig_t_m', 'sig_x_p', 'sig_x_m', 'caliHIndxRange', 'indx_45m', 'indx_45p', 'dplus', 'dminus', 'segmentLen', 'indx', 'mean_dplus_tmp', 'std_dplus_tmp', 'mean_dminus_tmp', 'std_dminus_tmp', 'TR_t', 'TR_x', 'segIndx', 'caliTime', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
        flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayPolCali.py'), tmpFile, saveFolder));
        if flag ~= 0
            warning('Error in executing %s', 'pollyDisplayPolCali.py');
        end
        delete(tmpFile);
    end
end

end