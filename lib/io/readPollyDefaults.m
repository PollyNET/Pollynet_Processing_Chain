function [defaults] = readPollyDefaults(defaultFile)
% readPollyDefaults Read polly default settings.
% USAGE:
%    [defaults] = readPollyDefaults(defaultFile)
% INPUTS:
%    defaultFile: char
%        absoluta path of the polly defaults file.
% OUTPUTS:
%    defaults:
%        default settings for polly lidar system.
%        More detailed information can be found in doc/polly_defaults.md
% EXAMPLE:
% HISTORY:
%    2021-04-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if exist(defaultFile, 'file') ~= 2
    error('Default file does not exist!\n%s\n', defaultFile);
end

defaults = loadjson(defaultFile);

end