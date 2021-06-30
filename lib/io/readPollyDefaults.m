function [defts] = readPollyDefaults(deftFile, globalDeftFile)
% readPollyDefaults Read polly default settings.
% USAGE:
%    [defts] = readPollyDefaults(deftFile)
% INPUTS:
%    deftFile: char
%        absoluta path of the polly defaults file.
% OUTPUTS:
%    defts:
%        default settings for polly lidar system.
%        More detailed information can be found in doc/polly_defaults.md
% EXAMPLE:
% HISTORY:
%    2021-04-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if exist(deftFile, 'file') ~= 2
    error('Default file does not exist!\n%s\n', deftFile);
end

if exist(globalDeftFile, 'file') ~= 2
    error('Global default file does not exist!\n%s\n', globalDeftFile);
end

defts = loadjson(deftFile);
globalDefts = loadjson(globalDeftFile);

for fn = fieldnames(defts)'
    if isfield(globalDefts, fn{1})
        globalDefts.(fn{1}) = defts.(fn{1});
    else
        error('Unknown polly default: %s', fn{1});
    end
end

defts = globalDefts;

end