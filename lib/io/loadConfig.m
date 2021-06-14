function [config] = loadConfig(configFile, globalConfigFile)
% LOADCONFIG load configurations
% USAGE:
%    [config] = loadConfig(configFile, globalConfigFile)
% INPUTS:
%    configFile: char
%        absolute path of the configuration file.
%    globalConfigFile: char
%        absolute path of the global configuration file.
% OUTPUTS:
%    config: struct
%        configurations.
% EXAMPLE:
% HISTORY:
%    2021-04-07: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if exist(configFile, 'file') ~= 2
    error('PICASSO:NonexistFile', 'file does not exist.\n%s\n', configFile);
end

if exist(globalConfigFile, 'file') ~= 2
    error('PICASSO:NonexistFile', 'file does not exist.\n%s\n', globalConfigFile);
end

tmpConfig = loadjson(configFile);
globalConfig = loadjson(globalConfigFile);
config = globalConfig;

fields = fieldnames(globalConfig);

for iField = 1:length(fields)
    if isfield(tmpConfig, fields{iField})
        config.(fields{iField}) = tmpConfig.(fields{iField});
    end
end

end