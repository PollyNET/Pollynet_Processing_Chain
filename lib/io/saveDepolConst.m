function saveDepolConst(dbFile, depolconst, depolconstStd, ...
                         dcStartTime, dcStopTime, ...
                         pollyDataFilename, pollyType, wavelength)
% SAVEDEPOLCONST save depolarization calibration results.
% USAGE:
%    saveDepolConst(dbFile, depolconst, depolconstStd, dcStartTime, 
%                   dcStopTime, pollyDataFilename, pollyType, wavelength)
% INPUTS:
%    dbFile: char
%        absolute path of the database.
%    depolconst: array
%        depolarization calibration constants.
%    depolconstStd: array
%        uncertainty of depolarization calibration constants.
%    dcStartTime: array
%        start time of each calibration period.
%    dcStopTime: array
%        stop time of each calibration period.
%    pollyDataFilename: char
%        the polly netcdf data file.
%    pollyType: char
%        polly type. (case-sensitive)
%    wavelength: char
%        wavelength. ('355' or '532')
% EXAMPLE:
% HISTORY:
%    2021-06-08: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
set(conn, 'AutoCommit', 'off');
commit(conn);

%% create table
exec(conn, ['CREATE TABLE IF NOT EXISTS depol_calibration_constant ', ...
            '(id INTEGER PRIMARY KEY AUTOINCREMENT, ', ...
            'cali_start_time TEXT, cali_stop_time TEXT, ', ...
            'depol_const REAL, uncertainty_depol_const REAL, ', ...
            'wavelength TEXT, nc_zip_file TEXT, polly_type TEXT);'], 3);
exec(conn, ['CREATE UNIQUE INDEX IF NOT EXISTS uniq_index ON ', ...
            'depol_calibration_constant(cali_start_time, cali_stop_time, ', ...
            'wavelength, polly_type);'], 3);
commit(conn);

%% insert data
for iDC = 1:length(depolconst)

    if isnan(depolconst(iDC))
        continue;
    end

    exec(conn, sprintf(['INSERT OR REPLACE INTO depol_calibration_constant', ...
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
    pollyType), 3);
end
commit(conn);

%% close
close(conn);

end