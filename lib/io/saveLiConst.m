function saveLiConst(dbFile, liconst, liconstStd, ...
                         lcStartTime, lcStopTime, ...
                         pollyDataFilename, pollyType, ...
                         wavelength, caliMethod, telescope)
% SAVELICONST save lidar calibration results.
%
% USAGE:
%    saveLiConst(dbFile, liconst, liconstStd, lcStartTime, lcStopTime, pollyDataFilename, pollyType, wavelength, caliMethod)
%
% INPUTS:
%    dbFile: char
%        absolute path of the database.
%    liconst: array
%        lidar calibration constants.
%    liconstStd: array
%        uncertainty of lidar calibration constants.
%    lcStartTime: array
%        start time of each calibration period.
%    lcStopTime: array
%        stop time of each calibration period.
%    pollyDataFilename: char
%        the polly netcdf data file.
%    pollyType: char
%        polly type. (case-sensitive)
%    wavelength: char
%        wavelength. ('355', '532', '1064', '387' or '607')
%    caliMethod: char
%        applied lidar calibration method.
%        ('Klett_Method', 'Raman_Method' or 'AOD_Constrained_Method')
%    telescope: char
%        detection range.
%        ('near_range', or 'far_range')
%
% HISTORY:
%    - 2021-06-08: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile),'AutoCommit', 'off');
%set(conn, 'AutoCommit', 'off');
commit(conn);

%% create table
exec(conn, ['CREATE TABLE IF NOT EXISTS lidar_calibration_constant ', ...
            '(id INTEGER PRIMARY KEY AUTOINCREMENT, ', ...
            'cali_start_time TEXT, cali_stop_time TEXT, ', ...
            'liconst REAL, uncertainty_liconst REAL, ', ...
            'wavelength TEXT, nc_zip_file TEXT, polly_type TEXT, ', ...
            'cali_method TEXT, telescope TEXT);'], 3);
exec(conn, ['CREATE UNIQUE INDEX IF NOT EXISTS uniq1_index ON ', ...
            'lidar_calibration_constant(cali_start_time, cali_stop_time, ', ...
            'wavelength, cali_method, polly_type, telescope);'], 3);
commit(conn);

%% insert data
for iLC = 1:length(liconst)

    if isnan(liconst(iLC))
        continue;
    end

    exec(conn, sprintf(['INSERT OR REPLACE INTO lidar_calibration_constant', ...
        '(cali_start_time, cali_stop_time,', ...
        'liconst, uncertainty_liconst, ', ...
        'wavelength, nc_zip_file, polly_type, ', ...
        'cali_method, telescope) VALUES(''%s'', ''%s'', ', ...
        '%f, %f, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')'], ...
    datestr(lcStartTime(iLC), 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(lcStopTime(iLC), 'yyyy-mm-dd HH:MM:SS'), ...
    double(liconst(iLC)), ...
    double(liconstStd(iLC)), ...
    wavelength, ...
    pollyDataFilename, ...
    pollyType, ...
    caliMethod, ...
    telescope), 3);
end
commit(conn);

%% close
close(conn);

end