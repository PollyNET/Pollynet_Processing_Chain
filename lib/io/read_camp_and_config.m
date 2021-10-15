function [PicassoCampLinks] = read_camp_and_config(PicassoLinkFile)
% READ_CAMP_AND_CONFIG read pollynet campaign link file.
%
% USAGE:
%    [PicassoCampLinks] = read_camp_and_config(PicassoLinkFile)
%
% INPUTS:
%    PicassoLinkFile: char
%        absolute path of the pollynet config link file.
%
% OUTPUTS:
%    PicassoCampLinks: struct
%        instrument: cell
%        location: cell
%        camp_starttime: array
%        camp_stoptime: array
%        latitude: array
%        longitude: array
%        asl: array
%        config_starttime: array
%        config_stoptime: array
%        config_file: cell
%        process_func: cell
%        default_file: cell
%        caption: cell
%        comment: cell
%
% HISTORY:
%    - 2021-04-07: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if exist(PicassoLinkFile, 'file') ~= 2
    error('PICASSO:NonexistFile', ...
          'Picasso config link file does not exist.\n%s\n', PicassoLinkFile);
end

%% initialization
PicassoCampLinks = struct();
PicassoCampLinks.instrument = {};
PicassoCampLinks.location = {};
PicassoCampLinks.camp_starttime = [];
PicassoCampLinks.camp_stoptime = [];
PicassoCampLinks.latitude = [];
PicassoCampLinks.longitude = [];
PicassoCampLinks.asl = [];
PicassoCampLinks.config_starttime = [];
PicassoCampLinks.config_stoptime = [];
PicassoCampLinks.config_file = {};
PicassoCampLinks.process_func = {};
PicassoCampLinks.default_file = {};
PicassoCampLinks.caption = {};
PicassoCampLinks.comment = {};

%% read PicassoLinkFile
try
    [~, ~, fileExt] = fileparts(PicassoLinkFile);

    if strcmpi(fileExt, '.xlsx')
        T = readtable(PicassoLinkFile, 'ReadRowNames', false, ...
                      'ReadVariableNames', false);

        for iRow = 2:size(T, 1)
            PicassoCampLinks.instrument{iRow - 1} = T.Var1{iRow};
            PicassoCampLinks.location{iRow - 1} = T.Var2{iRow};

            if ~ isempty(T.Var3{iRow})
                PicassoCampLinks.camp_starttime = cat(2, ...
                    PicassoCampLinks.camp_starttime, ...
                    datenum(T.Var3{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                PicassoCampLinks.camp_starttime = cat(2, ...
                    PicassoCampLinks.camp_starttime, NaN);
            end

            if ~ isempty(T.Var4{iRow})
                PicassoCampLinks.camp_stoptime = cat(2, ...
                    PicassoCampLinks.camp_stoptime, ...
                    datenum(T.Var4{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                PicassoCampLinks.camp_stoptime = cat(2, ...
                    PicassoCampLinks.camp_stoptime, NaN);
            end

            PicassoCampLinks.latitude = cat(2, ...
                PicassoCampLinks.latitude, str2double(T.Var5{iRow}));
            PicassoCampLinks.longitude = cat(2, ...
                PicassoCampLinks.longitude, str2double(T.Var6{iRow}));
            PicassoCampLinks.asl = cat(2, ...
                PicassoCampLinks.asl, str2double(T.Var7{iRow}));

            if ~ isempty(T.Var8{iRow})
                PicassoCampLinks.config_starttime = cat(2, ...
                    PicassoCampLinks.config_starttime, ...
                    datenum(T.Var8{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                PicassoCampLinks.config_starttime = cat(2, ...
                    PicassoCampLinks.config_starttime, NaN);
            end

            if ~ isempty(T.Var9{iRow})
                PicassoCampLinks.config_stoptime = cat(2, ...
                    PicassoCampLinks.config_stoptime, ...
                    datenum(T.Var9{iRow}, 'yyyymmdd HH:MM:SS'));
            else
                PicassoCampLinks.config_stoptime = cat(2, ...
                    PicassoCampLinks.config_stoptime, NaN);
            end

            PicassoCampLinks.config_file{iRow - 1} = T.Var10{iRow};
            PicassoCampLinks.process_func{iRow - 1} = T.Var11{iRow};
            PicassoCampLinks.default_file{iRow - 1} = T.Var12{iRow};
            PicassoCampLinks.caption{iRow - 1} = T.Var13{iRow};
            PicassoCampLinks.comment{iRow - 1} = T.Var14{iRow};
        end
    else
        error('PICASSO:InvalidInput', ...
               'Invalid Picasso campaign link file.\n%s\n', PicassoLinkFile);
    end
catch
    error('PICASSO:IOError', ...
           'Failure in reading pollynet config link file.\n%s\n', ...
        PicassoLinkFile);
end

end