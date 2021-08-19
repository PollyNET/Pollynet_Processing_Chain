function [depolconst, depolconstStd, caliStartTime, caliStopTime] = loadDepolConst(queryTime, dbFile, pollyType, wavelength, varargin)
% LOADDEPOLCONST load depolarization calibration constant from database.
%
% USAGE:
%    [depolconst, depolconstStd, caliStartTime, caliStopTime] = loadDepolConst(queryTime, dbFile, pollyType, wavelength)
%
% INPUTS:
%    queryTime: datenum
%        query time.
%    dbFile: char
%        absolute path of the SQLite database.
%    pollyType: char
%        polly name. (case-sensitive)
%    wavelength: char
%        wavelength ('355' or '532').
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
%    depolconst: array
%        depolarization calibration constant.
%    depolconstStd: array
%        uncertainty of depolarization calibration constant.
%    caliStartTime: array
%        calibration start time for each record.
%    caliStopTime: array
%        calibration stop time for each record.
%
% HISTORY:
%    - 2021-06-08: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

%% parse arguments
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'queryTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addRequired(p, 'wavelength', @ischar);
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'flagClosest', false, @islogical);
addParameter(p, 'flagBeforeQuery', false, @islogical);

parse(p, queryTime, dbFile, pollyType, wavelength, varargin{:});

depolconst = [];
depolconstStd = [];
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
    condWithinDT = sprintf(' AND (DATETIME((strftime(''%%s'', dc.cali_start_time) + strftime(''%%s'', dc.cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'') ', ...
    datestr(queryTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condWithinDT = '';
end

% subcommand for filtering records within deltaTime
if p.Results.flagBeforeQuery
    condBeforeQuery = sprintf(' AND (DATETIME((strftime(''%%s'', dc.cali_start_time) + strftime(''%%s'', dc.cali_stop_time))/2, ''unixepoch'') < ''%s'') ', ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condBeforeQuery = '';
end

if p.Results.flagClosest
    % without constrain from deltaTime and return the closest calibration result
    try
        data = fetch(conn, ...
            [sprintf(['SELECT dc.cali_start_time, dc.cali_stop_time, ', ...
                    'dc.depol_const, dc.uncertainty_depol_const, dc.nc_zip_file, ', ...
                    'dc.polly_type, dc.wavelength FROM depol_calibration_constant dc ', ...
                    'WHERE (dc.polly_type = ''%s'') AND (dc.wavelength = ''%s'') '], ...
                    pollyType, wavelength), ...
            condWithinDT, condBeforeQuery, ...
            sprintf('ORDER BY ABS((strftime(''%%s'', dc.cali_start_time) + strftime(''%%s'', dc.cali_stop_time))/2 - strftime(''%%s'', ''%s'')) ASC LIMIT 1;', datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'))]);
    catch ME
        warning(ME.message);
        data = [];
    end
else
    % without constrain from deltaTime and return all qualified results
    try
        data = fetch(conn, ...
            [sprintf(['SELECT dc.cali_start_time, dc.cali_stop_time, ', ...
                    'dc.depol_const, dc.uncertainty_depol_const, dc.nc_zip_file, ', ...
                    'dc.polly_type, dc.wavelength FROM depol_calibration_constant dc ', ...
                    'WHERE (dc.polly_type = ''%s'') AND (dc.wavelength = ''%s'') '], ...
                    pollyType, wavelength), ...
            condWithinDT, condBeforeQuery, ...
            sprintf('ORDER BY (strftime(''%%s'', dc.cali_start_time) + strftime(''%%s'', dc.cali_stop_time))/2 ASC;' )]);
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
        depolconst = cat(2, depolconst, data{iRow, 3});
        depolconstStd = cat(2, depolconstStd, data{iRow, 4});
    end
end

end