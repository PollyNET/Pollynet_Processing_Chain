function [flag] = pollyxt_dwd_saturationdetect(data, config)
%pollyxt_dwd_saturationdetect detect the bins which is fully saturated by the clouds. The description about the detection algorithm can be found in doc/polly_defaults.md
%   Example:
%       [flag] = pollyxt_dwd_saturationdetect(data, height, config)
%   Inputs:
%       data: struct
%           More detailed information can be found in doc\pollynet_processing_program.md
%       config: struct
%           processing configurations. Deatiled information can be found in doc\polly_config.md
%   Outputs:
%       flag: logical matrix
%           if it is true, it means the current range bin should be saturated by clouds. Vice versa.
%   History:
%       2018-12-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

nChannels = size(data.signal, 1);
nProfiles = size(data.signal, 3);

flag = false(size(data.signal));

if isempty(data.rawSignal)
    return;
end

for iChannel = 1:nChannels
    for iProfile = 1:nProfiles
        flagSaturation = polly_saturationdetect(squeeze(data.signal(iChannel, :, iProfile)), data.height, config.heightFullOverlap(iChannel), 10000, config.saturate_thresh, 500);
        flag(iChannel, :, iProfile) = flagSaturation;
    end
end

end