function pollyxt_displayHousekeeping(data)
% POLLYXT_DISPLAYHOUSEKEEPING display housekeeping data.
% USAGE:
%    pollyxt_displayHousekeeping(data)
% INPUTS:
%    data: struct
% EXAMPLE:
% HISTORY:
%    2021-06-09: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

if isempty(data.rawSignal)
    return;
end

[xtick, xtickstr] = timelabellayout(data.mTime, 'HH:MM');
monitorStatus = data.monitorStatus;
figDPI = PicassoConfig.figDPI;
mTime = data.mTime;
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

%% display monitor status
tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
save(tmpFile, 'figDPI', 'monitorStatus', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'xtick', 'xtickstr', 'mTime', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyxt_displayHousekeeping.py'), tmpFile, saveFolder));
if flag ~= 0
    warning('Error in executing %s', 'pollyxt_displayHousekeeping.py');
end
delete(tmpFile);

end