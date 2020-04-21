function [wvconst, wvconstStd, caliStartTime, caliStopTime, caliInstrument, ...
    instrumentMeasTime] = load_wvconst(queryTime, dbFile, pollyType, varargin)
%load_wvconst load water vapor calibration constant from database.
%Example:
%   [wvconst, wvconstStd, caliStartTime, caliStopTime, caliInstrument,
%    instrumentMeasTime] = load_wvconst(queryTime, dbFile, pollyType)
%Inputs:
%   queryTime: datenum
%       query time.
%   dbFile: char
%       absolute path of the SQLite database.
%   pollyType: char
%       polly name. (case-sensitive)
%Keywords:
%   deltaTime: datenum
%       search range for the query time. (default: NaN)
%   flagClosest: logical
%       flag to control whether to return the closest value only.
%       (default: false)
%   flagBeforeQuery: logical
%       flag to control whether to return records with calibration time before
%       queryTime. (default: false)
%Outputs:
%   wvconst: array
%       water vapor calibration constant. (g*kg^{-1})
%   wvconstStd: array
%       uncertainty of water vapor calibration constant. (g*kg^{-1})
%   caliStartTime: array
%       calibration start time for each record.
%   caliStopTime: array
%       calibration stop time for each record.
%   caliInstrument: cell
%       intrument used in the water vapor calibration for each record.
%   instrumentMeasTime: array
%       timestamp for the data measured by the standard instrument.
%History:
%   2020-04-17. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

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

conn = database(p.Results.dbFile, '', '', 'org:sqlite:JDBC', ...
                sprintf('jdbc:sqlite:%s', p.Results.dbFile));

%% setup SQL query command

% subcommand for filtering results
if ~ isnan(p.Results.deltaTime)
    condWithinDeltaT = sprintf('AND (DATETIME((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', wv.cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'') ', ...
    datestr(queryTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(queryTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'));
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

    % return the closest calibration result
    try
        data = fetch(conn, ...
            [sprintf(['SELECT wv.cali_start_time, wv.cali_stop_time, ', ...
                'wv.standard_instrument, wv.standard_instrument_meas_time, ', ...
                'wv.wv_const, wv.uncertainty_wv_const, wv.nc_zip_file, ', ...
                'wv.polly_type FROM wv_calibration_constant wv ', ...
                'WHERE (wv.polly_type = ''%s'') '], pollyType), ...
                condWithinDeltaT, ...
                condBeforeQuery, ...
            sprintf(['ORDER BY ABS((strftime(''%%s'', wv.cali_start_time) + ', ...
                'strftime(''%%s'', wv.cali_stop_time))/2 - ', ...
                'strftime(''%%s'', ''%s'')) ASC LIMIT 1;'], ...
            datestr(queryTime, 'yyyy-mm-dd HH:MM:SS'))]);
    catch ME
        warning(ME.message);
        data = [];
    end
else
    % return all qualified results
    try
        data = fetch(conn, ...
            [sprintf(['SELECT wv.cali_start_time, wv.cali_stop_time, ', ...
                    'wv.standard_instrument, wv.standard_instrument_meas_time, ', ...
                    'wv.wv_const, wv.uncertainty_wv_const, wv.nc_zip_file, ', ...
                    'wv.polly_type FROM wv_calibration_constant wv ', ...
                    'WHERE (wv.polly_type = ''%s'') '], pollyType), ...
                    condWithinDeltaT, ...
                    condBeforeQuery, ...
                    sprintf('ORDER BY (strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', wv.cali_stop_time))/2 ASC;')]);
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
        caliInstrument = cat(2, caliInstrument, data(iRow, 3));
        instrumentMeasTime = cat(2, instrumentMeasTime, datenum(data{iRow, 4}, 'yyyy-mm-dd HH:MM:SS'));
        wvconst = cat(2, wvconst, data{iRow, 5});
        wvconstStd = cat(2, wvconstStd, data{iRow, 6});
    end
end

end