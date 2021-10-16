function pollyDisplayHousekeeping(data)
% POLLYDISPLAYHOUSEKEEPING display housekeeping data.
%
% USAGE:
%    pollyDisplayHousekeeping(data)
%
% INPUTS:
%    data: struct
%
% HISTORY:
%    - 2021-06-09: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global CampaignConfig

switch lower(CampaignConfig.name)
case {'arielle', 'pollyxt_fmi', 'pollyxt_tropos', 'pollyxt_noa', 'pollyxt_tjk', 'pollyxt_tau', 'pollyxt_uw', 'pollyxt_cyp', 'pollyxt_lacros', 'pollyxt_cpv'}
    pollyxt_displayHousekeeping(data);
case {'pollyxt_cge'}
    pollyxt_cge_displayHousekeeping(data);
case {'pollyxt_dwd'}
    pollyxt_dwd_displayHousekeeping(data);
case {'pollyxt_ift'}
    pollyxt_ift_displayHousekeeping(data);
case {'polly_1v2'}
    polly_1v2_displayHousekeeping(data);
case {'polly_1st'}
    polly_1st_displayHousekeeping(data);
otherwise
    error('Unknown polly: %s', CampaignConfig.name);
end

end