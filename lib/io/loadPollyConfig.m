function [pollyConfig] = loadPollyConfig(pollyConfigFile, pollyGlobalConfigFile)
% LOADPOLLYCONFIG load polly configurations from polly config file.
% USAGE:
%    [pollyConfig] = loadPollyConfig(pollyConfigFile, pollyGlobalConfigFile)
% INPUTS:
%    pollyConfigFile: char
%        absolute path of polly config file.
%    pollyGlobalConfigFile: char
%        absolute path of polly global config file.
% OUTPUTS:
%    pollyConfig: struct
%        polly configurations. Details can be found in doc/polly_config.md
% EXAMPLE:
% HISTORY:
%    2018-12-16: First edition by Zhenping
%    2019-08-01: Remove the conversion of depol cali time. 
%                (Don't need to set the depol cali time any more)
%    2019-08-03: Add global polly config for unify the defaults polly 
%                settings.
% .. Authors: - zhenping@tropos.de

if exist(pollyConfigFile, 'file') ~= 2
    error(['Error in loadPollyConfig: ' ...
           'config file does not exist.\n%s\n'], pollyConfigFile);
end

if exist(pollyGlobalConfigFile, 'file') ~= 2
    error(['Error in loadPollyConfig: ' ...
           'polly global config file does not exist.\n%s\n'], ...
           pollyGlobalConfigFile);
end

%% load polly global config
pollyGlobalConfig = loadjson(pollyGlobalConfigFile);

%% load specified polly config
pollyConfig = loadjson(pollyConfigFile);
if ~ isstruct(pollyConfig)
    fprintf('Warning in loadPollyConfig: no polly configs were loaded.\n');
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
pollyGlobalConfig.isRR = logical(pollyGlobalConfig.isRR);
pollyGlobalConfig.isParallel = logical(pollyGlobalConfig.isParallel);
pollyGlobalConfig.flagRamanChannelTempCor = logical(pollyGlobalConfig.flagRamanChannelTempCor);

if isfield(pollyConfig, 'isFR')
    pollyConfig.isFR = logical(pollyConfig.isFR);
else
    pollyConfig.isFR = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'isNR')
    pollyConfig.isNR = logical(pollyConfig.isNR);
else
    pollyConfig.isNR = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is532nm')
    pollyConfig.is532nm = logical(pollyConfig.is532nm);
else
    pollyConfig.is532nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is355nm')
    pollyConfig.is355nm = logical(pollyConfig.is355nm);
else
    pollyConfig.is355nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is1064nm')
    pollyConfig.is1064nm = logical(pollyConfig.is1064nm);
else
    pollyConfig.is1064nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'isTot')
    pollyConfig.isTot = logical(pollyConfig.isTot);
else
    pollyConfig.isTot = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'isCross')
    pollyConfig.isCross = logical(pollyConfig.isCross);
else
    pollyConfig.isCross = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is387nm')
    pollyConfig.is387nm = logical(pollyConfig.is387nm);
else
    pollyConfig.is387nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is407nm')
    pollyConfig.is407nm = logical(pollyConfig.is407nm);
else
    pollyConfig.is407nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'is607nm')
    pollyConfig.is607nm = logical(pollyConfig.is607nm);
else
    pollyConfig.is607nm = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'isRR')
    pollyConfig.isRR = logical(pollyConfig.isRR);
else
    pollyConfig.isRR = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'isParallel')
    pollyConfig.isParallel = logical(pollyConfig.isParallel);
else
    pollyConfig.isParallel = false(1, length(pollyConfig.is532nm));
end
if isfield(pollyConfig, 'flagRamanChannelTempCor')
    pollyConfig.flagRamanChannelTempCor = logical(pollyConfig.flagRamanChannelTempCor);
else
    pollyConfig.flagRamanChannelTempCor = false(1, length(pollyConfig.is532nm));
end

%% overwrite polly global configs
for fn = fieldnames(pollyConfig)'
    if isfield(pollyGlobalConfig, fn{1})
        pollyGlobalConfig.(fn{1}) = pollyConfig.(fn{1});
    elseif strcmp(fn{1}, 'minSNR_4_sigNorm')
        warning('''minSNR_4_sigNorm'' was deprecated');
    elseif strcmp(fn{1}, 'zLim_FR_RCS_355')
        warning('''zLim_FR_RCS_355'' was deprecated');
    elseif strcmp(fn{1}, 'zLim_FR_RCS_532')
        warning('''zLim_FR_RCS_532'' was deprecated');
    elseif strcmp(fn{1}, 'zLim_FR_RCS_1064')
        warning('''zLim_FR_RCS_1064'' was deprecated');
    elseif strcmp(fn{1}, 'zLim_NR_RCS_355')
        warning('''zLim_NR_RCS_355'' was deprecated');
    elseif strcmp(fn{1}, 'zLim_NR_RCS_532')
        warning('''zLim_NR_RCS_532'' was deprecated');
    elseif strcmp(fn{1}, 'channelTag')
        warning('''channelTag'' was deprecated');
    else
        error('Unknown polly settings: %s', fn{1});
    end
end

pollyConfig = pollyGlobalConfig;

end