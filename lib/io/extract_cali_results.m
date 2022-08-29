function [csvFilenames, csvFileID] = extract_cali_results(dbFile, csvFilepath, varargin)
% EXTRACT_CALI_RESULTS extract calibration results from SQLite database to ASCII files.
%
% USAGE:
%    % Usecase 1: convert single table
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile', 'tablename', 'lidar_calibration_constant');
%
%    % Usecase 2: convert all tables
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile');
%
%    % Usecase 3: add prefix for csv files
%    extract_cali_results('/path/to/dbFile', '/path/to/csvFile', 'prefix', 'arielle-');
%
% INPUTS:
%    dbFile: char
%        absolute path of database file.
%    csvFilepath: char
%        output folder for the csv file.
%
% KEYWORDS:
%    tablename: char
%        table name that needs to be extracted (regular expression is supported). (defaults: '.*')
%    prefix: char
%        prefix for the ASCII filename.
%    SQLiteReadMode: char
%        'database_toolbox' (default) or 'jdbc'
%
% OUTPUTS:
%    csvFilenames: cell
%        absolute path for extracted ASCII files.
%    csvFileID: cell
%        identifier (table name) for respective csv file.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = false;

addRequired(p, 'dbFile', @ischar);
addRequired(p, 'csvFilepath', @ischar);
addParameter(p, 'tablename', '.*', @ischar);
addParameter(p, 'prefix', '', @ischar);
addParameter(p, 'SQLiteReadMode', 'database_toolbox', @ischar);

parse(p, dbFile, csvFilepath, varargin{:});

if (exist(dbFile, 'file') ~= 2)
    warning('dbFile does not exist.\n%s\n', dbFile);
    return;
end

switch lower(p.Results.SQLiteReadMode)
case 'jdbc'
    jdbc = org.sqlite.JDBC;
    props = java.util.Properties;
    conn = jdbc.createConnection(['jdbc:sqlite:', dbFile], props);
    stmt = conn.createStatement;

    %% get table names
    tableNames = cell(0);
    rs1 = stmt.executeQuery('SELECT name FROM sqlite_master where (type = ''table'') and (name != ''sqlite_sequence'') order by name');
    while rs1.next
        tableNames = cat(2, tableNames, char(rs1.getString('name')));
    end
    rs1.close;

    csvFilenames = cell(0);
    csvFileID = cell(0);

    for iTable = 1:length(tableNames)
        if ~ isempty(regexp(tableNames{iTable}, p.Results.tablename, 'once'))
            tableColNames = cell(0);
            tableColTypes = cell(0);
            %% get column names
            rs2 = stmt.executeQuery(sprintf('PRAGMA table_info(%s);', tableNames{iTable}));
            while rs2.next
                tableColNames = cat(2, tableColNames, char(rs2.getString('name')));
                tableColTypes = cat(2, tableColTypes, char(rs2.getString('type')));
            end
            rs2.close;

            rs4 = stmt.executeQuery(sprintf('SELECT COUNT(*) FROM %s', tableNames{iTable}));
            nCounts = int32(rs4.getLong('COUNT(*)'));
            rs4.close;

            %% load data
            rs3 = stmt.executeQuery(sprintf('SELECT * from %s;', tableNames{iTable}));
            data = cell(nCounts, length(tableColNames));
            iCount = 1;
            while rs3.next
                record = cell(1, length(tableColNames));

                for iCol = 1:length(tableColNames)
                    switch lower(tableColTypes{iCol})
                    case 'text'
                        record{iCol} = char(rs3.getString(tableColNames{iCol}));
                    case 'integer'
                        record{iCol} = int32(rs3.getLong(tableColNames{iCol}));
                    case 'real'
                        record{iCol} = double(rs3.getDouble(tableColNames{iCol}));
                    case 'null'
                    case 'blob'
                    otherwise
                        error('Unknown SQLite data type.');
                    end
                end

                data(iCount, :) = record;
                iCount = iCount + 1;
            end
            rs3.close;

            tableData = cell2table(data, 'variablenames', tableColNames);

            %% save data to csv file
            csvFilename = sprintf('%s%s.csv', p.Results.prefix, tableNames{iTable});
            writetable(tableData, fullfile(csvFilepath, csvFilename));

            csvFilenames = cat(2, csvFilenames, fullfile(csvFilepath, csvFilename));
            csvFileID = cat(2, csvFileID, tableNames{iTable});
        end
    end

    %% close connection
    stmt.close;
    conn.close;

case 'database_toolbox'
    %% check matlab version to set correct database connection parameters
    release = strsplit(version, '(');
    release = regexp(release{2},'[0-9]{4}','match');
    release = release{1};
    release = uint16(str2num(release));

    if release < 2018
        conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
        set(conn, 'AutoCommit', 'off');
    else
        conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile),'AutoCommit', 'off');
    end

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

end