function [defaults] = polly_read_defaults(defaultFile)
%POLLY_READ_DEFAULTS read polly default settings.
%Example:
%   [defaults] = polly_read_defaults(defaultFile)
%Inputs:
%   defaultFile: char
%       absoluta path of the polly defaults file.
%Outputs:
%   defaults:
%       default settings for polly lidar system.
%       More detailed information can be found in doc/polly_defaults.md
%History:
%   2018-12-19. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

if exist(defaultFile, 'file') ~= 2
    error('Default file does not exist!\n%s\n', defaultFile);
end

defaults = loadjson(defaultFile);

end