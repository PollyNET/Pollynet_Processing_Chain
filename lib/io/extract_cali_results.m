function [csvFilenames, csvFileID] = extract_cali_results(dbFile, csvFilepath, varargin)
% EXTRACT_CALI_RESULTS extract calibration results from SQLite database to ASCII files.
% USAGE:
%    % Usecase 1: convert single table
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile', ...
%        'tablename', 'lidar_calibration_constant');
%
%    % Usecase 2: convert all tables
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile');
%
%    % Usecase 3: add prefix for csv files
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile', ...
%        'prefix', 'arielle_');
% INPUTS:
%    dbFile: char
%        absolute path of database file.
%    csvFilepath: char
%        output folder for the csv file.
% KEYWORDS:
%    tablename: char
%        table name that needs to be extracted (regular expression is supported).
%        (defaults: '.*')
%    prefix: char
%        prefix for the ASCII filename.
% OUTPUTS:
%    csvFilenames: cell
%        absolute path for extracted ASCII files.
%    csvFileID: cell
%        identifier (table name) for respective csv file.
% EXAMPLE:
% HISTORY:
%    2021-06-13: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = false;

addRequired(p, 'dbFile', @ischar);
addRequired(p, 'csvFilepath', @ischar);
addParameter(p, 'tablename', '.*', @ischar);
addParameter(p, 'prefix', '', @ischar);

parse(p, dbFile, csvFilepath, varargin{:});

if (exist(dbFile, 'file') ~= 2)
    warning('dbFile does not exist.\n%s\n', dbFile);
    return;
end

conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
set(conn, 'AutoCommit', 'off');
commit(conn);

%% get table names
tableNames = fetch(conn, 'SELECT name FROM sqlite_master where (type=''table'') and (name != ''sqlite_sequence'') order by name');

csvFilenames = cell(0);
csvFileID = cell(0);

for iTable = 1:length(tableNames)
    if ~ isempty(regexp(tableNames{iTable}, p.Results.tablename, 'once'))
        %% get column names
        tableColNames = fetch(conn, sprintf('PRAGMA table_info(%s);', tableNames{iTable}));
        
        %% load data
        data = fetch(conn, sprintf('SELECT * from %s;', tableNames{iTable}));
        if isempty(data)
            data = cell(0, length(tableColNames(:, 2)));
        end

        tableData = cell2table(data, 'variablenames', tableColNames(:, 2));

        %% save data to csv file
        csvFilename = sprintf('%s%s.csv', p.Results.prefix, tableNames{iTable});
        writetable(tableData, fullfile(csvFilepath, csvFilename));

        csvFilenames = cat(2, csvFilenames, fullfile(csvFilepath, csvFilename));
        csvFileID = cat(2, csvFileID, tableNames{iTable});
    end
end

%% close connection
close(conn);

end