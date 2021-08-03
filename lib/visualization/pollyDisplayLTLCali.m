function pollyDisplayLTLCali(data, dbFile)
% POLLYDISPLAYLTLCALI display long-term calibration results.
% USAGE:
%    pollyDisplayLTLCali(data)
% INPUTS:
%    data: struct
%    dbFile: char
% EXAMPLE:
% HISTORY:
%    2021-06-09: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

global CampaignConfig

switch lower(CampaignConfig.name)
case {'arielle', 'pollyxt_fmi', 'pollyxt_tropos', 'pollyxt_noa', 'pollyxt_tjk', 'pollyxt_tau', 'pollyxt_uw', 'pollyxt_cyp', 'pollyxt_lacros'}
    pollyxt_displayLTLCali(data, dbFile);
case {'pollyxt_cge'}
    pollyxt_cge_displayLTLCali(data, dbFile);
case {'pollyxt_dwd'}
    pollyxt_dwd_displayLTLCali(data, dbFile);
case {'pollyxt_ift'}
    pollyxt_ift_displayLTLCali(data, dbFile);
case {'polly_1v2'}
    polly_1v2_displayLTLCali(data, dbFile);
case {'polly_1st'}
    polly_1st_displayLTLCali(data, dbFile);
otherwise
    error('Unknown polly: %s', CampaignConfig.name);
end

end