function [defaults] = pollyxt_dwd_read_defaults(file)
%pollyxt_dwd_read_defaults read default settings for pollyxt_dwd
%   Example:
%       [defaults] = pollyxt_dwd_read_defaults(file)
%   Inputs:
%       file: char
%   Outputs:
%       defaults:
%           default settings for polly lidar system. More detailed information can be found in doc/polly_defaults.md
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist(file, 'file')
    error('Default file for pollyxt_dwd does not exist!\n%s\n', file);
end

defaults = loadjson(file);

end