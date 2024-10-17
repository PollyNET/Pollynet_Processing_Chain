function saveDepolConst(dbFile, depolconst, depolconstStd, ...
                         dcStartTime, dcStopTime, ...
                         pollyDataFilename, pollyType, wavelength)
% SAVEDEPOLCONST save polarization calibration results.
%
% USAGE:
%    saveDepolConst(dbFile, depolconst, depolconstStd, dcStartTime, 
%                   dcStopTime, pollyDataFilename, pollyType, wavelength)
%
% INPUTS:
%    dbFile: char
%        absolute path of the database.
%    depolconst: array
%        polarization calibration constants.
%    depolconstStd: array
%        uncertainty of polarization calibration constants.
%    dcStartTime: array
%        start time of each calibration period.
%    dcStopTime: array
%        stop time of each calibration period.
%    pollyDataFilename: char
%        the polly netcdf data file.
%    pollyType: char
%        polly type. (case-sensitive)
%    wavelength: char
%        wavelength. ('355', '532' or '1064')
%
% HISTORY:
%    - 2021-06-08: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

jdbc = org.sqlite.JDBC;
props = java.util.Properties;
conn = jdbc.createConnection(['jdbc:sqlite:', dbFile], props);
stmt = conn.createStatement;

%% create table
stmt.executeUpdate(['CREATE TABLE IF NOT EXISTS depol_calibration_constant ', ...
            '(id INTEGER PRIMARY KEY AUTOINCREMENT, ', ...
            'cali_start_time TEXT, cali_stop_time TEXT, ', ...
            'depol_const REAL, uncertainty_depol_const REAL, ', ...
            'wavelength TEXT, nc_zip_file TEXT, polly_type TEXT);']);
stmt.executeUpdate(['CREATE UNIQUE INDEX IF NOT EXISTS uniq_index ON ', ...
            'depol_calibration_constant(cali_start_time, cali_stop_time, ', ...
            'wavelength, polly_type);']);

%% insert data
for iDC = 1:length(depolconst)

    if (~isnan(depolconst(iDC)) && ~isnan(depolconstStd(iDC)) && ~isempty(dcStartTime) && ~isempty(dcStopTime))
    stmt.executeUpdate(sprintf(['INSERT OR REPLACE INTO depol_calibration_constant', ...
        '(cali_start_time, cali_stop_time,', ...
        'depol_const, uncertainty_depol_const, ', ...
        'wavelength, nc_zip_file, polly_type) VALUES(''%s'', ''%s'', ', ...
        '%f, %f, ''%s'', ''%s'', ''%s'')'], ...
    datestr(dcStartTime(iDC), 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(dcStopTime(iDC), 'yyyy-mm-dd HH:MM:SS'), ...
    double(depolconst(iDC)), ...
    double(depolconstStd(iDC)), ...
    wavelength, ...
    pollyDataFilename, ...
    pollyType));
    end
end

%% close connection
stmt.close;
conn.close;

end