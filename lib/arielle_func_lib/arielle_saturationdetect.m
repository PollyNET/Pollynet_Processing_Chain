function [flag] = arielle_saturationdetect(data, config)
%ARIELLE_SATURATIONDETECT detect the bins which is fully saturated by the
%clouds.
%Example:
%   [flag] = arielle_saturationdetect(data, height, config)
%Inputs:
%   data: struct
%       More detailed information can be found in
%       doc\pollynet_processing_program.md
%   config: struct
%       processing configurations. Deatiled information can be found in
%       doc\polly_config.md
%Outputs:
%   flag: logical matrix
%       if it is true, it means the current range bin should be saturated
%       by clouds. Vice versa.
%History:
%   2018-12-21. First Edition by Zhenping
%   2019-07-08. Fix the bug of converting signal to PCR.
%Contact:
%   zhenping@tropos.de

nChannels = size(data.signal, 1);
nProfiles = size(data.signal, 3);

flag = false(size(data.signal));

if isempty(data.rawSignal)
    return;
end

signalPCR = squeeze(data.signal + data.bg) ./ ...
            repmat(...
                    reshape(data.mShots, ...
                            size(data.mShots, 1), ...
                            1, size(data.mShots, 2)), ...
                    [1, size(data.signal, 2), 1]) * 150.0 ./ data.hRes;

for iChannel = 1:nChannels
    for iProfile = 1:nProfiles
        flagSaturation = polly_saturationdetect(...
                            signalPCR(iChannel, :, iProfile), ...
                            data.height, ...
                            config.heightFullOverlap(iChannel), ...
                            10000, config.saturate_thresh, 500);
        flag(iChannel, :, iProfile) = flagSaturation;
    end
end

end