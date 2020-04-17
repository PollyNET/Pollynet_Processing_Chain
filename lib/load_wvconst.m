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

addRequired(p, 'measTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addParameter(p, 'deltaTime', NaN, @isnumeric);
addParameter(p, 'flagClosest', false, @islogical);

parse(p, queryTime, dbFile, pollyType, varargin{:});

wvconst = [];
wvconstStd = [];
caliStartTime = [];
caliStopTime = [];
caliInstrument = cell(0);
instrumentMeasTime = [];

if exist(p.Results.dbFile, 'file') ~= 2
    warning('p.Results.dbFile does not exist!\n%s\n', p.Results.dbFile);
    return;
end

conn = database(p.Results.dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', p.Results.dbFile));

if isnan(p.Results.deltaTime) && p.Results.flagClosest
    % without constrain from deltaTime and return the closest calibration result
    curs = exec(conn, ...
        sprintf(['SELECT wv.cali_start_time wv.cali_stop_time ', ...
                'wv.standard_instrument wv.standard_instrument_meas_time ', ...
                'wv.wvconst wv.uncertainty_wvconst wv.nc_zip_file ', ...
                'wv.polly_type FROM wv_calibration_constant wv WHERE ', ...
                'WHERE (wv.polly_type = ''%s'') ORDER BY ABS((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2 - strftime(''%%s'', ''%s'')) ASC LIMIT 1;'], ...
        pollyType, datestr(queryTime, 'yyyy-mm-dd HH:MM:SS')));
elseif isnan(p.Results.deltaTime) && (~ p.Results.flagClosest)
    % without constrain from deltaTime and return all qualified results
    curs = exec(conn, ...
        sprintf(['SELECT wv.cali_start_time wv.cali_stop_time ', ...
                'wv.standard_instrument wv.standard_instrument_meas_time ', ...
                'wv.wvconst wv.uncertainty_wvconst wv.nc_zip_file ', ...
                'wv.polly_type FROM wv_calibration_constant wv WHERE ', ...
                'WHERE (wv.polly_type = ''%s'') ORDER BY (strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2 ASC;'], ...
        pollyType, datestr(queryTime, 'yyyy-mm-dd HH:MM:SS')));
elseif (~ isnan(p.Results.deltaTime)) && p.Results.flagClosest
    % with constrain from deltaTime and return the closest calibration result
    curs = exec(conn, ...
    sprintf(['SELECT wv.cali_start_time wv.cali_stop_time ', ...
            'wv.standard_instrument wv.standard_instrument_meas_time ', ...
            'wv.wvconst wv.uncertainty_wvconst wv.nc_zip_file ', ...
            'wv.polly_type FROM wv_calibration_constant wv WHERE ', ...
            'WHERE (wv.polly_type = ''%s'') AND (DATETIME((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'')', ...
            'ORDER BY ABS((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2 - strftime(''%%s'', ''%s'')) ASC LIMIT 1;'], ...
    pollyType, ...
    datestr(measTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(measTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(measTime, 'yyyy-mm-dd HH:MM:SS')));
else
    % with constrain from deltaTime and return all qualified calibration results
    curs = exec(conn, ...
    sprintf(['SELECT wv.cali_start_time wv.cali_stop_time ', ...
            'wv.standard_instrument wv.standard_instrument_meas_time ', ...
            'wv.wvconst wv.uncertainty_wvconst wv.nc_zip_file ', ...
            'wv.polly_type FROM wv_calibration_constant wv WHERE ', ...
            'WHERE (wv.polly_type = ''%s'') AND (DATETIME((strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2, ''unixepoch'') BETWEEN ''%s'' AND ''%s'')', ...
            'ORDER BY (strftime(''%%s'', wv.cali_start_time) + strftime(''%%s'', cali_stop_time))/2 ASC;'], ...
    pollyType, ...
    datestr(measTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(measTime - p.Results.deltaTime, 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(measTime, 'yyyy-mm-dd HH:MM:SS')));
end

res = fetch(curs);

%% close connection
close(conn);

if ~ isnumeric(res.Data)
    % when records were found
    for iRow = 1:size(res.Data, 1)
        caliStartTime = cat(2, caliStartTime, res.Data{iRow, 1});
        caliStopTime = cat(2, caliStopTime, res.Data{iRow, 2});
        caliInstrument = cat(2, caliInstrument, res.Data(iRow, 3));
        instrumentMeasTime = cat(2, instrumentMeasTime, res.Data{iRow, 4});
        wvconst = cat(2, wvconst, res.Data{iRow, 5});
        wvconstStd = cat(2, wvconstStd, res.Data{iRow, 6});
    end
end

end