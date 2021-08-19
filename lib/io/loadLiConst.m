function [liconst, liconstStd, caliStartTime, caliStopTime] = loadLiConst(queryTime, dbFile, pollyType, wavelength, caliMethod, telescope, varargin)
% LOADLICONST load lidar calibration constant from database.
%
% USAGE:
%    [liconst, liconstStd, caliStartTime, caliStopTime] = loadLiConst(queryTime, dbFile, pollyType, wavelength, caliMethod)
%
% INPUTS:
%    queryTime: datenum
%        query time.
%    dbFile: char
%        absolute path of the SQLite database.
%    pollyType: char
%        polly name. (case-sensitive)
%    wavelength: char
%        wavelength ('355', '532', '1064', '387' or '607').
%    caliMethod: char
%        calibration method ('Klett_Method', 'Raman_Method', 'AOD_Constrained_Method')
%    telescope: char
%        detection range. ('far_range', or 'near_range')
%
% KEYWORDS:
%    deltaTime: datenum
%        search range for the query time. (default: NaN)
%    flagClosest: logical
%        flag to control whether to return the closest value only.
%        (default: false)
%        (default: false)
%    flagBeforeQuery: logical
%        flag to control whether to return records with calibration time before
%        queryTime. (default: false)
%
% OUTPUTS:
%    liconst: array
%        lidar calibration constant.
%    liconstStd: array
%        uncertainty of lidar calibration constant.
%    caliStartTime: array
%        calibration start time for each record.
%    caliStopTime: array
%        calibration stop time for each record.
%
% HISTORY:
%    - 2021-06-11: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

%% parse arguments
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'queryTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addRequired(p, 'wavelength', @ischar);
addRequired(p, 'caliMethod', @ischar);
addRequired(p, 'telescope', @ischar);
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'flagClosest', false, @islogical);
addParameter(p, 'flagBeforeQuery', false, @islogical);

parse(p, queryTime, dbFile, pollyType, wavelength, caliMethod, telescope, varargin{:});

liconst = [];
liconstStd = [];
caliStartTime = [];
caliStopTime = [];

if exist(dbFile, 'file') ~= 2
    warning('dbFile does not exist!\n%s\n', dbFile);
    return;
end

conn = database(dbFile, '', '', 'org:sqlite:JDBC', ...
                sprintf('jdbc:sqlite:%s', dbFile));

%% setup SQL query command

% subcommand for filtering records within deltaTime
if ~ isnan(p.Results.deltaTime)
    condWithinDT = sprintf(' AND (DATETIME((strftime(''%%s'', lc.cali_start_time) + strftime(''%%s'', lc.cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'') ', ...
    datestr(queryTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condWithinDT = '';
end

% subcommand for filtering records within deltaTime
if p.Results.flagBeforeQuery
    condBeforeQuery = sprintf(' AND (DATETIME((strftime(''%%s'', lc.cali_start_time) + strftime(''%%s'', lc.cali_stop_time))/2, ''unixepoch'') < ''%s'') ', ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condBeforeQuery = '';
end

% main command
if p.Results.flagClosest
    % without constrain from deltaTime and return the closest calibration result
    try
        data = fetch(conn, ...
            [sprintf(['SELECT lc.cali_start_time, lc.cali_stop_time, ', ...
                'lc.liconst, lc.uncertainty_liconst, lc.nc_zip_file, ', ...
                'lc.polly_type, lc.wavelength FROM lidar_calibration_constant lc ', ...
                'WHERE (lc.polly_type = ''%s'') AND (lc.wavelength = ''%s'') ', ...
                'AND (lc.cali_method = ''%s'') AND (lc.telescope = ''%s'')'], ...
                pollyType, wavelength, caliMethod, telescope), ...
            condWithinDT, condBeforeQuery, ...
            sprintf(['ORDER BY ', ...
                'ABS((strftime(''%%s'', lc.cali_start_time) + ', ...
                'strftime(''%%s'', lc.cali_stop_time))/2 - strftime(''%%s'', ''%s'')) ASC LIMIT 1;'], ...
                datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'))]);
    catch ME
        warning(ME.message);
        data = [];
    end
else
    % without constrain from deltaTime and return all qualified results
    try
        data = fetch(conn, ...
            [sprintf(['SELECT lc.cali_start_time, lc.cali_stop_time, ', ...
                    'lc.liconst, lc.uncertainty_liconst, lc.nc_zip_file, ', ...
                    'lc.polly_type, lc.wavelength FROM lidar_calibration_constant lc ', ...
                    'WHERE (lc.polly_type = ''%s'') AND (lc.wavelength = ''%s'') AND ', ...
                    '(lc.cali_method = ''%s'') AND (lc.telescope = ''%s'')'], ...
                    pollyType, wavelength, caliMethod, telescope), ...
            condWithinDT, condBeforeQuery, ...
            sprintf('ORDER BY (strftime(''%%s'', lc.cali_start_time) + strftime(''%%s'', lc.cali_stop_time))/2 ASC;')]);
    catch ME
        warning(ME.message);
        data = [];
    end
end

%% close connection
close(conn);

if ~ isempty(data)
    % when records were found
    for iRow = 1:size(data, 1)
        caliStartTime = cat(2, caliStartTime, datenum(data{iRow, 1}, 'yyyy-mm-dd HH:MM:SS'));
        caliStopTime = cat(2, caliStopTime, datenum(data{iRow, 2}, 'yyyy-mm-dd HH:MM:SS'));
        liconst = cat(2, liconst, data{iRow, 3});
        liconstStd = cat(2, liconstStd, data{iRow, 4});
    end
end

end