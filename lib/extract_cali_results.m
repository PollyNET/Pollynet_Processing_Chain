function extract_cali_results(dbFile, csvFilepath, varargin)
%extract_cali_results extract calibration results from SQLite database.
%Example:
%   extract_cali_results('/path/to/dbFile', '/path/for/csvFile', ...
%       'tablename', 'lidar_calibration_constant');
%Inputs:
%   dbFile: char
%       absolute path of database file.
%   csvFilepath: char
%       csv file for the output results.
%Keywords:
%   tablename: char
%       table name that needs to be extracted.
%       (defaults: lidar_calibration_constant)
%History:
%   2020-04-20. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = false;

addRequired(p, 'dbFile', @ischar);
addRequired(p, 'csvFilepath', @ischar);
addParameter(p, 'tablename', 'lidar_calibration_constant', @ischar);

parse(p, dbFile, csvFilepath, varargin{:});

if (exist(dbFile, 'file') ~= 2)
    warning('dbFile does not exist.\n%s\n', dbFile);
    return;
end

conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
set(conn, 'AutoCommit', 'off');
commit(conn);

%% get column names
tableColNames = fetch(conn, sprintf('PRAGMA table_info(%s);', p.Results.tablename));

%% load data
data = fetch(conn, sprintf('SELECT * from %s;', p.Results.tablename));

%% close connection
close(conn);

%% save data to csv file
tableData = cell2table(data, 'variablenames', tableColNames(:, 2));
writetable(tableData, csvFilepath);

end