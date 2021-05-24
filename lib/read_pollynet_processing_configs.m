function [pollyConfigHistory] = read_pollynet_processing_configs(file)
%READ_POLLYNET_PROCESSING_CONFIGS read pollynet history configuration file.
%Example:
%   [pollyConfigHistory] = read_pollynet_processing_configs(file)
%Inputs:
%   file: char
%       pollynet processing configurature files. This file is used to guide 
%       the processing chain to search for the suitable config file and 
%       processing function to processing the polly data. More detailed 
%       information can be found in doc/pollynet.md
%Outputs:
%   pollyConfigHistory: struct
%       pollyVersion: cell
%       startTime: array (datenum)
%       endTime: array (datenum)
%       pollyConfigFile: cell
%       pollyProcessFunc: cell
%       pollyUpdateInfo: cell
%       pollyDefaultsFile: cell
%History:
%   2018-12-17: First edition by Zhenping
%   2018-12-18: Add pollyDefaultsFile category.
%Contact:
%   zhenping@tropos.de

pollyConfigHistory = struct();
pollyConfigHistory.pollyVersion = {};
pollyConfigHistory.startTime = [];
pollyConfigHistory.endTime = [];
pollyConfigHistory.pollyConfigFile = {};
pollyConfigHistory.pollyProcessFunc = {};
pollyConfigHistory.pollyUpdateInfo = {};
pollyConfigHistory.pollyDefaultsFile = {};

if exist(file, 'file') ~= 2
    error(['Error in read_pollynet_processing_configs: ' ...
           'pollynet history configuration file does not exist. \n%s\n'], ...
           file);
end

try
    [~, ~, fileExt] = fileparts(file);

    if strcmpi(fileExt, '.txt')
        % ASCII file
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
            pollyConfigHistory.pollyDefaultsFile{iRow} = data{7}{iRow};
        end
    elseif strcmp(fileExt, '.xlsx')
        % Excel file
        T = readtable(file, 'ReadRowNames', false, 'ReadVariableNames', false);

        for iRow = 2:size(T, 1)
            pollyConfigHistory.pollyVersion{iRow - 1} = T.Var1{iRow};
            pollyConfigHistory.startTime = [pollyConfigHistory.startTime, ...
                datenum(T.Var2{iRow}, 'yyyy-mm-dd HH:MM:SS')];
            pollyConfigHistory.endTime = [pollyConfigHistory.endTime, ...
                datenum(T.Var3{iRow}, 'yyyy-mm-dd HH:MM:SS')];
            pollyConfigHistory.pollyConfigFile{iRow - 1} = T.Var4{iRow};
            pollyConfigHistory.pollyProcessFunc{iRow - 1} = T.Var5{iRow};
            pollyConfigHistory.pollyUpdateInfo{iRow - 1} = T.Var6{iRow};
            pollyConfigHistory.pollyDefaultsFile{iRow - 1} = T.Var7{iRow};
        end
    else
        error('Wrong file format for %s', file);
    end
catch
    error('Failure in reading pollynet history configuration file.\n%s\n', file);
end

if isempty(pollyConfigHistory.startTime)
    fprintf('No pollynet history configuration.\n');
    return;
end

end