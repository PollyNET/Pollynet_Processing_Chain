function save_wvconst(dbFile, wvconst, wvconstStd, WVCaliInfo, IWVAttri, ...
                      pollyDataFilename, pollyType)
%save_wvconst  save water vapor calibration results. 
%Example:
%   save_wvconst(dbFile, wvconst, wvconstStd, WVCaliInfo, IWVAttri, 
%                pollyDataFilename, pollyType)
%Inputs:
%   dbFile: char
%       absolute path of the database.
%   wvconst: array
%       water vapor calibration constants. [g*kg^{-1}] 
%   wvconstStd: array
%       uncertainty of water vapor calibration constants. [g*kg^{-1}] 
%   WVCaliInfo: struct
%       source: char
%           data source. ('AERONET', 'MWR' or else)
%       site: char
%           measurement site.
%       datetime: array
%           datetime of applied IWV.
%       PI: char
%       contact: char
%   IWVAttri: struct
%       cali_start_time: array
%           water vapor calibration start time. [datenum]
%       cali_stop_time: array
%           water vapor calibration stop time. [datenum]
%       WVCaliInfo: cell
%           calibration information for each calibration period.
%       IntRange: matrix
%           index of integration range for calculate the raw IWV from lidar. 
%   pollyDataFilename: char
%       the polly netcdf data file.
%   pollyType: char
%       polly type. (case-sensitive)
%History:
%   2018-12-19. First Edition by Zhenping
%   2019-02-12. Remove the bug for saving flagCalibration at some time with 
%               no calibration constants.
%   2019-08-09. Saving the real applied water vapor constant instead of the 
%               defaults. And remove the outputs of the function.
%Contact:
%   zhenping@tropos.de

conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
set(conn, 'AutoCommit', 'off');
commit(conn);

%% create table
exec(conn, ['CREATE TABLE IF NOT EXISTS wv_calibration_constant ', ...
            '(id INTEGER PRIMARY KEY AUTOINCREMENT, cali_start_time TEXT, ', ...
            'cali_stop_time TEXT, standard_instrument TEXT, ', ...
            'standard_instrument_meas_time TEXT, wv_const REAL, ', ...
            'uncertainty_wv_const REAL, nc_zip_file TEXT, polly_type TEXT);'], 3);
exec(conn, ['CREATE UNIQUE INDEX IF NOT EXISTS uniq2_index ON ', ...
            'wv_calibration_constant(cali_start_time, cali_stop_time, ', ...
            'standard_instrument, polly_type);'], 3);
commit(conn);

%% insert data
for iWVCali = 1:length(wvconst)

    if isnan(wvconst(iWVCali))
        continue;
    end

    exec(conn, sprintf(['INSERT OR REPLACE INTO wv_calibration_constant', ...
        '(cali_start_time, cali_stop_time, standard_instrument, ', ...
        'standard_instrument_meas_time, wv_const, uncertainty_wv_const, ', ...
        'nc_zip_file, polly_type) VALUES(''%s'', ''%s'', ''%s'', ', ...
        '''%s'', %f, %f, ''%s'', ''%s'')'], ...
    datestr(WVCaliInfo.cali_start_time(iWVCali), 'yyyy-mm-dd HH:MM:SS'), ...
    datestr(WVCaliInfo.cali_stop_time(iWVCali), 'yyyy-mm-dd HH:MM:SS'), ...
    IWVAttri.source, ...
    datestr(IWVAttri.datetime(iWVCali), 'yyyy-mm-dd HH:MM:SS'), ...
    double(wvconst(iWVCali)), ...
    double(wvconstStd(iWVCali)), ...
    pollyDataFilename, ...
    pollyType), 3);
end
commit(conn);

%% close
close(conn);

end