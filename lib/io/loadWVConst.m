function [wvconst, wvconstStd, caliStartTime, caliStopTime, caliInstrument, instrumentMeasTime] = loadWVConst(queryTime, dbFile, pollyType, varargin)
% LOADWVCONST load water vapor calibration constant from database.
%
% USAGE:
%    [wvconst, wvconstStd, caliStartTime, caliStopTime, caliInstrument, instrumentMeasTime] = loadWVConst(queryTime, dbFile, pollyType)
%
% INPUTS:
%    queryTime: datenum
%        query time.
%    dbFile: char
%        absolute path of the SQLite database.
%    pollyType: char
%        polly name. (case-sensitive)
%
% KEYWORDS:
%    deltaTime: datenum
%        search range for the query time. (default: NaN)
%    flagClosest: logical
%        flag to control whether to return the closest value only.
%        (default: false)
%    flagBeforeQuery: logical
%        flag to control whether to return records with calibration time before
%        queryTime. (default: false)
%
% OUTPUTS:
%    wvconst: array
%        water vapor calibration constant. (g*kg^{-1})
%    wvconstStd: array
%        uncertainty of water vapor calibration constant. (g*kg^{-1})
%    caliStartTime: array
%        calibration start time for each record.
%    caliStopTime: array
%        calibration stop time for each record.
%    caliInstrument: cell
%        intrument used in the water vapor calibration for each record.
%    instrumentMeasTime: array
%        timestamp for the data measured by the standard instrument.
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
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'flagClosest', false, @islogical);
addParameter(p, 'flagBeforeQuery', false, @islogical);

parse(p, queryTime, dbFile, pollyType, varargin{:});

wvconst = [];
wvconstStd = [];
caliStartTime = [];
caliStopTime = [];
caliInstrument = cell(0);
instrumentMeasTime = [];

if exist(p.Results.dbFile, 'file') ~= 2
    warning('dbFile does not exist!\n%s\n', p.Results.dbFile);
    return;
end

jdbc = org.sqlite.JDBC;
props = java.util.Properties;
conn = jdbc.createConnection(['jdbc:sqlite:', dbFile], props);
stmt = conn.createStatement;

%% setup SQL query command

% subcommand for filtering results
if ~ isnan(p.Results.deltaTime)
    condWithinDeltaT = sprintf('AND (DATETIME((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', wv.cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'') ', ...
    datestr(queryTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condWithinDeltaT = '';
end

% subcommand for filtering results
if p.Results.flagBeforeQuery
    condBeforeQuery = sprintf('AND (DATETIME((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', wv.cali_stop_time))/2, ''unixepoch'') < ''%s'') ', ...
    datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'));
else
    condBeforeQuery = '';
end

% main command
if p.Results.flagClosest

     sqlStr = [sprintf(['SELECT wv.cali_start_time, wv.cali_stop_time, ', ...
                'wv.standard_instrument, wv.standard_instrument_meas_time, ', ...
                'wv.wv_const, wv.uncertainty_wv_const, wv.nc_zip_file, ', ...
                'wv.polly_type FROM wv_calibration_constant wv ', ...
                'WHERE (wv.polly_type = ''%s'') '], pollyType), ...
                condWithinDeltaT, ...
                condBeforeQuery, ...
            sprintf(['ORDER BY ABS((strftime(''%%s'', wv.cali_start_time) + ', ...
                'strftime(''%%s'', wv.cali_stop_time))/2 - ', ...
                'strftime(''%%s'', ''%s'')) ASC LIMIT 1;'], ...
            datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'))];
else
    sqlStr = [sprintf(['SELECT wv.cali_start_time, wv.cali_stop_time, ', ...
                    'wv.standard_instrument, wv.standard_instrument_meas_time, ', ...
                    'wv.wv_const, wv.uncertainty_wv_const, wv.nc_zip_file, ', ...
                    'wv.polly_type FROM wv_calibration_constant wv ', ...
                    'WHERE (wv.polly_type = ''%s'') '], pollyType), ...
                    condWithinDeltaT, ...
                    condBeforeQuery, ...
                    sprintf('ORDER BY (strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', wv.cali_stop_time))/2 ASC;')];
end

try
    rs = stmt.executeQuery(sqlStr);

    while rs.next
        thisStartTime = char(rs.getString('cali_start_time'));
        thisStopTime = char(rs.getString('cali_stop_time'));
        thisCaliInstrument = char(rs.getString('standard_instrument'));
        thisInstrumentMeasTime = char(rs.getString('standard_instrument_meas_time'));
        thisWvconst = double(rs.getDouble('wv_const'));
        thisWvconstStd = double(rs.getDouble('uncertainty_wv_const'));

        caliStartTime = cat(2, caliStartTime, datenum(thisStartTime, 'yyyy-mm-dd HH:MM:SS'));
        caliStopTime = cat(2, caliStopTime, datenum(thisStopTime, 'yyyy-mm-dd HH:MM:SS'));
        caliInstrument = cat(2, caliInstrument, thisCaliInstrument);
        instrumentMeasTime = cat(2, instrumentMeasTime, datenum(thisInstrumentMeasTime, 'yyyy-mm-dd HH:MM:SS'));
        wvconst = cat(2, wvconst, thisWvconst);
        wvconstStd = cat(2, wvconstStd, thisWvconstStd);
    end
catch ME
    warning(ME.message);
end

%% close connection
rs.close;
stmt.close;
conn.close;

end