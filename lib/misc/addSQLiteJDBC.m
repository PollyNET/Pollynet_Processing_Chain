function addSQLiteJDBC(SQLiteJDBCPath, varargin)
% ADDSQLITEJDBC add SQLite Java database connector (JDBC) to MATLAB search path.
% USAGE:
%    addSQLiteJDBC(SQLiteJDBCPath)
% INPUTS:
%    SQLiteJDBCPath: char
%        absolute path of the SQLite JDBC.
% KEYWORDS:
%    flagDownloadSQLiteJDBC: logical
%        flag to control whether to download the SQLite JDBC. (default: false)
% HISTORY:
%    2021-06-15: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'SQLiteJDBCPath', @ischar);
addParameter(p, 'flagDownloadSQLiteJDBC', false, @islogical);

parse(p, SQLiteJDBCPath, varargin{:});

%% prepare SQLite JDBC
pathJDBC = '';
if (exist(p.Results.SQLiteJDBCPath, 'file') == 2)
    pathJDBC = p.Results.SQLiteJDBCPath;
elseif p.Results.flagDownloadSQLiteJDBC
    SQLJDBCURL = 'https://bitbucket.org/xerial/sqlite-jdbc/downloads/sqlite-jdbc-3.30.1.jar';

    system(sprintf('wget -O %s %s', p.Results.SQLiteJDBCPath, SQLJDBCURL));
    pathJDBC = p.Results.SQLiteJDBCPath;
end

if (exist(pathJDBC, 'file') == 2)

    %% add the SQLite JDBC JDBC to the search path
    % details can be found under
    % https://ww2.mathworks.cn/help/database/ug/sqlite-jdbc-linux.html

    disp('Add SQLite JDBC to your search path.');
    javaclasspathFilepath = fullfile(prefdir, 'javaclasspath.txt');

    fid = fopen(javaclasspathFilepath, 'a');
    fprintf(fid, '%s\n', pathJDBC);

    fclose(fid);

    disp('MATLAB needs to be **RESTARTED** to activate the settings');
    res = input('Close MATLAB now? (y/n): ', 's');

    if strcmpi(res, 'y')
        exit;
    else
        pause(3);
    end

else

    fprintf('No SQLite JDBC was found.\nFind intructions from %s\n', ...
            'https://ww2.mathworks.cn/help/database/ug/sqlite.html');
    pause(3);

end

end