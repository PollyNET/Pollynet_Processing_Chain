function [pollyConfig] = load_polly_config(configFile, configDir)
%LOAD_POLLY_CONFIG load the polly configurations for processing the polly data.
%   Example:
%       [pollyConfig] = load_polly_config(configFile, configDir)
%   Inputs:
%       configFile: char
%       configDir: char
%           the directory for saving the polly configuration files.
%   Outputs:
%       pollyConfig: struct
%           polly configurations. Details can be found in doc/polly_config.md
%   History:
%       2018-12-16. First edition by Zhenping
%       2019-08-01. Remove the conversion of depol cali time. 
%                   (Don't need to set the depol cali time any more)
%       2019-08-03. Add global polly config for unify the defaults polly 
%                   settings.
%   Contact:
%       zhenping@tropos.de

%TODO: add the switch part to read the configurature individually for 
%      different polly system.

pollyConfig = '';
pollyConfigDir = fullfile(configDir, 'pollyConfigs');

if ~ exist(pollyConfigDir, 'dir')
    error(['Error in load_polly_config: ' ...
           'folder does not exist.\n%s\n'], pollyConfigDir);
end

configFile = fullfile(pollyConfigDir, configFile);

if exist(configFile, 'file') ~= 2
    error(['Error in load_polly_config: ' ...
           'config file does not exist.\n%s\n'], configFile);
end

if exist(fullfile(pollyConfigDir, 'polly_global_config.json'), 'file') ~= 2
    error(['Error in load_polly_config: ' ...
           'polly global config file does not exist.\n%s\n'], ...
           fullfile(pollyConfigDir, 'polly_global_config.json'));
end

%% load polly global config
pollyGlobalConfig = loadjson(fullfile(pollyConfigDir, 'polly_global_config.json'));

%% load specified polly config
pollyConfig = loadjson(configFile);
if ~ isstruct(pollyConfig)
    fprintf('Warning in load_polly_config: no polly configs were loaded.\n');
    return;
end

%% convert logical 
pollyGlobalConfig.isFR = logical(pollyGlobalConfig.isFR);
pollyGlobalConfig.isNR = logical(pollyGlobalConfig.isNR);
pollyGlobalConfig.is532nm = logical(pollyGlobalConfig.is532nm);
pollyGlobalConfig.is355nm = logical(pollyGlobalConfig.is355nm);
pollyGlobalConfig.is1064nm = logical(pollyGlobalConfig.is1064nm);
pollyGlobalConfig.isTot = logical(pollyGlobalConfig.isTot);
pollyGlobalConfig.isCross = logical(pollyGlobalConfig.isCross);
pollyGlobalConfig.is387nm = logical(pollyGlobalConfig.is387nm);
pollyGlobalConfig.is407nm = logical(pollyGlobalConfig.is407nm);
pollyGlobalConfig.is607nm = logical(pollyGlobalConfig.is607nm);
pollyConfig.isFR = logical(pollyConfig.isFR);
pollyConfig.isNR = logical(pollyConfig.isNR);
pollyConfig.is532nm = logical(pollyConfig.is532nm);
pollyConfig.is355nm = logical(pollyConfig.is355nm);
pollyConfig.is1064nm = logical(pollyConfig.is1064nm);
pollyConfig.isTot = logical(pollyConfig.isTot);
pollyConfig.isCross = logical(pollyConfig.isCross);
pollyConfig.is387nm = logical(pollyConfig.is387nm);
pollyConfig.is407nm = logical(pollyConfig.is407nm);
pollyConfig.is607nm = logical(pollyConfig.is607nm);

%% overwrite polly global configs
for fn = fieldnames(pollyConfig)'
    if isfield(pollyGlobalConfig, fn{1})
        pollyGlobalConfig.(fn{1}) = pollyConfig.(fn{1});
    else
        error('Unknow polly settings: %s', fn{1});
    end
end

pollyConfig = pollyGlobalConfig;

end