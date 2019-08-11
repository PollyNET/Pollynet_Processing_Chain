function [data, overlapAttri] = pollyxt_cge_overlap(data, config)
%pollyxt_cge_overlap description
%   Example:
%       [data] = pollyxt_cge_overlap(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       overlapAttri: struct
%           All information about overlap.
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global processInfo campaignInfo defaults

overlapAttri = struct();
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = [];
overlapAttri.overlap355 = [];
overlapAttri.overlap532 = [];
overlapAttri.overlap355_std = [];
overlapAttri.overlap532_std = [];
overlapAttri.overlap355DefaultInterp = [];
overlapAttri.overlap532DefaultInterp = [];
overlapAttri.sig355FR = [];   % Photon count rate [MHz]
overlapAttri.sig355NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio355 = [];
overlapAttri.normRange355 = [];
overlapAttri.sig532FR = [];   % Photon count rate [MHz]
overlapAttri.sig532NR = [];   % Photon count rate [MHz]
overlapAttri.sigRatio532 = [];
overlapAttri.normRange532 = [];

if isempty(data.rawSignal)
    return;
end

%% calculate the overlap
overlap532 = [];   
overlap532_std = [];
overlap355 = [];
overlap355_std = [];
% no suitable overlap correction method for pollyxt_cge

%% read default overlap function to compare with the estimated ones.
[height532, overlap532Default] = read_default_overlap(fullfile(processInfo.defaultsFile_folder, defaults.overlapFile532));
[height355, overlap355Default] = read_default_overlap(fullfile(processInfo.defaultsFile_folder, defaults.overlapFile355));

%% interpolate the default overlap
if ~ isempty(overlap355Default)
    overlap355DefaultInterp = interp1(height355, overlap355Default, data.height, 'linear');
end
if ~ isempty(overlap532Default)
    overlap532DefaultInterp = interp1(height532, overlap532Default, data.height, 'linear');
end

%% saving the results
overlapAttri.location = campaignInfo.location;
overlapAttri.institute = processInfo.institute;
overlapAttri.contact = processInfo.contact;
overlapAttri.version = processInfo.programVersion;
overlapAttri.height = data.height;
overlapAttri.overlap355 = overlap355;
overlapAttri.overlap532 = overlap532;
overlapAttri.overlap355_std = overlap355_std;
overlapAttri.overlap532_std = overlap532_std;
overlapAttri.overlap355DefaultInterp = overlap355DefaultInterp;
overlapAttri.overlap532DefaultInterp = overlap532DefaultInterp;

%% append the overlap to data
if isempty(overlap532)
    data.overlap532 = interp1(height532, overlap532Default, data.height, 'linear');
    data.flagOverlapUseDefault532 = true;
else
    data.overlap532 = overlap532;
    data.flagOverlapUseDefault532 = false;
end

if isempty(overlap355)
    data.overlap355 = interp1(height355, overlap355Default, data.height, 'linear');
    data.flagOverlapUseDefault355 = true;
else
    data.overlap355 = overlap355;
    data.flagOverlapUseDefault355 = false;
end

end