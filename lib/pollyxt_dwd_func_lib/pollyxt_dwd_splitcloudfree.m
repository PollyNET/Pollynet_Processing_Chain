function [cloudFreeSubContGroup] = pollyxt_dwd_splitcloudfree(data, config)
%pollyxt_dwd_splitcloudfree split the continous cloud free profiles into several small groups.
%   Example:
%       [cloudFreeSubContGroup] = pollyxt_dwd_splitcloudfree(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       cloudFreeSubContGroup: matrix
%           [[iGroupStartIndx, iGroupEndIndx], ...].
%   History:
%       2018-12-22. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

cloudFreeSubContGroup = [];

if isempty(data.rawSignal)
    return;
end

% mark the continues cloud-free, nonfog, no depol calibration profile
validProfile = double(data.flagCloudFree8km & (~ data.fogMask) & (~ data.depCalMask));
validProfile(validProfile == 0) = NaN;
[cloudFreeContGroup, nCloudFreeContGroup] = label(validProfile);   % label continuous cloud-free profiles

cloudFreeSubContGroup = [];
nCloudFreeSubContGroup = 0;

if nCloudFreeContGroup == 0
    fprintf('No qualified cloud-free profiles were found.\n');
else
    for iCloudFreeContGroup = 1:nCloudFreeContGroup
        iCloudFreeContGroupIndx = find(cloudFreeContGroup == iCloudFreeContGroup);

        % check whether the number of continuous profiles in ith group is larger than what we need
        if (length(iCloudFreeContGroupIndx) <= config.intNProfiles) && (length(iCloudFreeContGroupIndx) >= config.minIntNProfiles)
            nCloudFreeSubContGroup = nCloudFreeSubContGroup + 1;
            cloudFreeSubContGroup = [cloudFreeSubContGroup; [iCloudFreeContGroupIndx(1), iCloudFreeContGroupIndx(end)]];
        elseif length(iCloudFreeContGroupIndx) > config.intNProfiles
            % if the profiles of ith cloud free group it too many, more than what we need, split it into small groups
            if rem(length(iCloudFreeContGroupIndx), config.intNProfiles) >= config.minIntNProfiles
                nCloudFreeSubContGroup = nCloudFreeContGroup + ceil(length(iCloudFreeContGroupIndx) / config.intNProfiles);
                splitCloudFreeGroup = [(0:ceil(length(iCloudFreeContGroupIndx) / config.intNProfiles) - 1) * config.intNProfiles + iCloudFreeContGroupIndx(1); [(1:ceil(length(iCloudFreeContGroupIndx) / config.intNProfiles) - 1) * config.intNProfiles - 1 + iCloudFreeContGroupIndx(1), iCloudFreeContGroupIndx(end)]];
                cloudFreeSubContGroup = [cloudFreeSubContGroup; transpose(splitCloudFreeGroup)];
            else
                nCloudFreeSubContGroup = nCloudFreeSubContGroup + floor(length(iCloudFreeContGroupIndx) / config.intNProfiles);
                splitCloudFreeGroup = [(0:floor(length(iCloudFreeContGroupIndx) / config.intNProfiles) - 1) * config.intNProfiles + iCloudFreeContGroupIndx(1); [(1:floor(length(iCloudFreeContGroupIndx) / config.intNProfiles) - 1) * config.intNProfiles - 1 + iCloudFreeContGroupIndx(1), iCloudFreeContGroupIndx(end)]];
                cloudFreeSubContGroup = [cloudFreeSubContGroup; transpose(splitCloudFreeGroup)];
            end
        end
    end
end

end