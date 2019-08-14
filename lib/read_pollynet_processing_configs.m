function [pollyConfigHistory] = read_pollynet_processing_configs(file)
%READ_POLLYNET_PROCESSING_CONFIGS read pollynet history configuration file.
%   Example:
%       [pollyConfigHistory] = read_pollynet_processing_configs(file)
%   Inputs:
%       file: char
%           pollynet processing configurature files. This file is used to guide 
%           the processing chain to search for the suitable config file and 
%           processing function to processing the polly data. More detailed 
%           information can be found in doc/pollynet.md
%   Outputs:
%       pollyConfigHistory: struct
%           pollyVersion: cell
%           startTime: array (datenum)
%           endTime: array (datenum)
%           pollyConfigFile: cell
%           pollyProcessFunc: cell
%           pollyUpdateInfo: cell
%           pollyLoadDefaultsFunc: cell
%   History:
%       2018-12-17. First edition by Zhenping
%       2018-12-18. Add pollyLoadDefaultsFunc category.
%   Contact:
%       zhenping@tropos.de

pollyConfigHistory = struct();
pollyConfigHistory.pollyVersion = {};
pollyConfigHistory.startTime = [];
pollyConfigHistory.endTime = [];
pollyConfigHistory.pollyConfigFile = {};
pollyConfigHistory.pollyProcessFunc = {};
pollyConfigHistory.pollyUpdateInfo = {};
pollyConfigHistory.pollyLoadDefaultsFunc = {};

if ~ exist(file, 'file')
    error(['Error in read_pollynet_processing_configs: ' ...
           'pollynet history configuration file does not exist. \n%s\n'], ...
           file);
end

try
    fid = fopen(file, 'r');
    data = textscan(fid, '%s %s %s %s %s %s %s', 'Delimiter', ',', ...
                    'Headerlines', 1);

    for iRow = 1:length(data{1})
        pollyConfigHistory.pollyVersion{iRow} = data{1}{iRow};
        pollyConfigHistory.startTime = [pollyConfigHistory.startTime, ...
            datenum(data{2}{iRow}, 'yyyy-mm-dd HH:MM:SS')];
        pollyConfigHistory.endTime = [pollyConfigHistory.endTime, ...
            datenum(data{3}{iRow}, 'yyyy-mm-dd HH:MM:SS')];
        pollyConfigHistory.pollyConfigFile{iRow} = data{4}{iRow};
        pollyConfigHistory.pollyProcessFunc{iRow} = data{5}{iRow};
        pollyConfigHistory.pollyUpdateInfo{iRow} = data{6}{iRow};
        pollyConfigHistory.pollyLoadDefaultsFunc{iRow} = data{7}{iRow};
    end
catch
    error('Failure in reading pollynet history configuration file.\n%s\n', file);
end

if isempty(pollyConfigHistory.startTime)
    fprintf('No pollynet history configuration.\n');
    return;
end

end