function [pollynetConfigLinks] = read_camp_and_config(pollynetConfigFile)
%READ_CAMP_AND_CONFIG read pollynet config link file.
%Example:
%   [pollynetConfigLinks] = read_camp_and_config(pollynetConfigFile)
%Inputs:
%   pollynetConfigFile: char
%       absolute path of the pollynet config link file.
%Outputs:
%   pollynetConfigLinks: struct
%       instrument: cell
%       location: cell
%       camp_starttime: array
%       camp_stoptime: array
%       latitude: array
%       longitude: array
%       asl: array
%       config_starttime: array
%       config_stoptime: array
%       config_file: cell
%       process_func: cell
%       default_file: cell
%       caption: cell
%       comment: cell
%History:
%   2021-02-03. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

if exist(pollynetConfigFile, 'file') ~= 2
    error(['Error in search_campaigninfo: ', ...
           'pollynet config link file does not exist.\n%s\n'], pollynetConfigFile);
end

%% initialization
pollynetConfigLinks = struct();
pollynetConfigLinks.instrument = {};
pollynetConfigLinks.location = {};
pollynetConfigLinks.camp_starttime = [];
pollynetConfigLinks.camp_stoptime = [];
pollynetConfigLinks.latitude = [];
pollynetConfigLinks.longitude = [];
pollynetConfigLinks.asl = [];
pollynetConfigLinks.config_starttime = [];
pollynetConfigLinks.config_stoptime = [];
pollynetConfigLinks.config_file = {};
pollynetConfigLinks.process_func = {};
pollynetConfigLinks.default_file = {};
pollynetConfigLinks.caption = {};
pollynetConfigLinks.comment = {};

%% read pollynetConfigFile
try
    [~, ~, fileExt] = fileparts(pollynetConfigFile);

    if strcmpi(fileExt, '.xlsx')
        T = readtable(pollynetConfigFile, 'ReadRowNames', false, ...
                      'ReadVariableNames', false);

        for iRow = 2:size(T, 1)
            pollynetConfigLinks.instrument{iRow - 1} = T.Var1{iRow};
            pollynetConfigLinks.location{iRow - 1} = T.Var2{iRow};

            if ~ isempty(T.Var3{iRow})
                pollynetConfigLinks.camp_starttime = cat(2, ...
                    pollynetConfigLinks.camp_starttime, ...
                    datenum(T.Var3{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                pollynetConfigLinks.camp_starttime = cat(2, ...
                    pollynetConfigLinks.camp_starttime, NaN);
            end

            if ~ isempty(T.Var4{iRow})
                pollynetConfigLinks.camp_stoptime = cat(2, ...
                    pollynetConfigLinks.camp_stoptime, ...
                    datenum(T.Var4{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                pollynetConfigLinks.camp_stoptime = cat(2, ...
                    pollynetConfigLinks.camp_stoptime, NaN);
            end

            pollynetConfigLinks.latitude = cat(2, ...
                pollynetConfigLinks.latitude, str2double(T.Var5{iRow}));
            pollynetConfigLinks.longitude = cat(2, ...
                pollynetConfigLinks.longitude, str2double(T.Var6{iRow}));
            pollynetConfigLinks.asl = cat(2, ...
                pollynetConfigLinks.asl, str2double(T.Var7{iRow}));

            if ~ isempty(T.Var8{iRow})
                pollynetConfigLinks.config_starttime = cat(2, ...
                    pollynetConfigLinks.config_starttime, ...
                    datenum(T.Var8{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                pollynetConfigLinks.config_starttime = cat(2, ...
                    pollynetConfigLinks.config_starttime, NaN);
            end

            if ~ isempty(T.Var9{iRow})
                pollynetConfigLinks.config_stoptime = cat(2, ...
                    pollynetConfigLinks.config_stoptime, ...
                    datenum(T.Var9{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                pollynetConfigLinks.config_stoptime = cat(2, ...
                    pollynetConfigLinks.config_stoptime, NaN);
            end

            pollynetConfigLinks.config_file{iRow - 1} = T.Var10{iRow};
            pollynetConfigLinks.process_func{iRow - 1} = T.Var11{iRow};
            pollynetConfigLinks.default_file{iRow - 1} = T.Var12{iRow};
            pollynetConfigLinks.caption{iRow - 1} = T.Var13{iRow};
            pollynetConfigLinks.comment{iRow - 1} = T.Var14{iRow};
        end
    else
        error(['Error in search_campaigninfo: ', ...
               'invalid pollynet config link file.\n%s\n'], pollynetConfigFile);
    end
catch
    error(['Error in search_campaigninfo: ', ...
           'failure in reading pollynet config link file.\n%s\n'], ...
        pollynetConfigFile);
end

end