function pollyDisplayOL(data)
% pollyDisplayOL display overlap function.
%
% USAGE:
%    pollyDisplayOL(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-10: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global PicassoConfig CampaignConfig PollyConfig PollyDataInfo

height = data.height;
imgFormat = PollyConfig.imgFormat;
partnerLabel = PollyConfig.partnerLabel;
flagWatermarkOn = PicassoConfig.flagWatermarkOn;

flag355FR = data.flagFarRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag355NR = data.flagNearRangeChannel & data.flag355nmChannel & data.flagTotalChannel;
flag532FR = data.flagFarRangeChannel & data.flag532nmChannel & data.flagTotalChannel;
flag532NR = data.flagNearRangeChannel & data.flag532nmChannel & data.flagTotalChannel;

overlap355 = data.olFunc355;
overlap355Raman = data.olFunc355Raman;

if isempty(overlap355)
    overlap355 = NaN(size(height));
end



if isfield(data.olAttri355, 'sigFR')
    sig355FR = data.olAttri355.sigFR;
    sig355NR = data.olAttri355.sigNR;
    sigRatio355 = data.olAttri355.sigRatio;
    normRange355 = data.olAttri355.normRange;
end

overlap532 = data.olFunc532;
overlap532Raman = data.olFunc532Raman;

if isempty(overlap532)
    overlap532 = NaN(size(height));
end

if isempty(overlap355Raman)
    overlap355Raman = NaN(size(height));
end
if isempty(overlap532Raman)
    overlap532Raman = NaN(size(height));
end

if isfield(data.olAttri532, 'sigFR')
    sig532FR = data.olAttri532.sigFR;
    sig532NR = data.olAttri532.sigNR;
    sigRatio532 = data.olAttri532.sigRatio;
    normRange532 = data.olAttri532.normRange;
end

overlap355Defaults = data.olFuncDeft355;
if isempty(overlap355Defaults)
    overlap355Defaults = NaN(size(height));
end
if isempty(sig355FR)
    sig355FR = NaN(size(height));
end
if isempty(sig355NR)
    sig355NR = NaN(size(height));
end
if isempty(sigRatio355)
    sig355Gl = NaN(size(height));
else
    sig355Gl = sig355FR ./ overlap355;
end

overlap532Defaults = data.olFuncDeft532;
if isempty(overlap532Defaults)
    overlap532Defaults = NaN(size(height));
end
if isempty(sig532FR)
    sig532FR = NaN(size(height));
end
if isempty(sig532NR)
    sig532NR = NaN(size(height));
end
if isempty(sigRatio532)
    sig532Gl = NaN(size(height));
else
    sig532Gl = sig532FR ./ overlap532;
end

pyFolder = fileparts(mfilename('fullpath'));   % folder of the python scripts for data visualization
tmpFolder = fullfile(parentFolder(mfilename('fullpath'), 3), 'tmp');
saveFolder = fullfile(PicassoConfig.pic_folder, CampaignConfig.name, datestr(data.mTime(1), 'yyyy'), datestr(data.mTime(1), 'mm'), datestr(data.mTime(1), 'dd'));
figDPI = PicassoConfig.figDPI;

% create tmp folder by force, if it does not exist.
if ~ exist(tmpFolder, 'dir')
    fprintf('Create the tmp folder to save the temporary results.\n');
    mkdir(tmpFolder);
end

tmpFile = fullfile(tmpFolder, [basename(tempname), '.mat']);
save(tmpFile, 'figDPI', 'overlap355', 'overlap532','overlap355Raman', 'overlap532Raman', 'overlap355Defaults', 'overlap532Defaults', 'sig355FR', 'sig355NR', 'sig532FR', 'sig532NR', 'sig355Gl', 'sig532Gl', 'sigRatio355', 'sigRatio532', 'normRange355', 'normRange532', 'height', 'PicassoConfig', 'CampaignConfig', 'PollyDataInfo', 'imgFormat', 'flagWatermarkOn', 'partnerLabel', '-v6');
flag = system(sprintf('%s %s %s %s', fullfile(PicassoConfig.pyBinDir, 'python'), fullfile(pyFolder, 'pollyDisplayOL.py'), tmpFile, saveFolder));
if flag ~= 0
    warning('Error in executing %s', 'pollyDisplayOL.py');
end
delete(tmpFile);

end