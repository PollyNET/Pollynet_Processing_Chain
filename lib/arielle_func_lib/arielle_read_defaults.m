function [defaults] = arielle_read_defaults()
%arielle_read_defaults read default settings for pollyxt_dwd
%   Example:
%       [defaults] = arielle_read_defaults(file)
%   Inputs:
%       file: char
%   Outputs:
%       defaults:
%           default settings for polly lidar system. More detailed information can be found in doc/polly_defaults.md
%   History:
%       2018-12-19. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

defaultFile = 'arielle_defaults.json';

if ~ exist(defaultFile, 'file')
    error('Default file for arielle does not exist!\n%s\n', defaultFile);
end

defaults = loadjson(defaultFile);

end