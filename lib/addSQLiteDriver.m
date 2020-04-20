function [flag] = addSQLiteDriver(SQLiteDriverPath, varargin)
%addSQLiteDriver add SQLite driver to search path.
%Example:
%   [flag] = addSQLiteDriver(SQLiteDriverPath)
%Inputs:
%   SQLiteDriverPath: char
%       absolute path of the SQLite driver.
%Keywords:
%   flagDownloadSQLiteDriver: logical
%       flag to control whether to download the SQLite driver. (default: false)
%Outputs:
%   flag: logical
%       flag to demonstrate whether the process is successful.
%History:
%   2020-04-20. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'SQLiteDriverPath', @ischar);
addParameter(p, 'flagDownloadSQLiteDriver', false, @islogical);

parse(p, SQLiteDriverPath, varargin{:});

%% test whether SQLite driver exists in the search path
flagSQLDriverValid = true;
dbFile = sprintf('%s.db', tempname);
conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));
if exist(dbFile, 'file') == 2
    delete(dbFile);
end

if strcmpi(conn.Message, 'Unable to find JDBC driver.')
    flagSQLDriverValid = false;
end

%% prepare SQLite driver
if (~ flagSQLDriverValid) && (exist(p.Results.SQLiteDriverPath, 'file') == 2)
    pathJDBC = p.Results.SQLiteDriverPath;
elseif (~ flagSQLDriverValid) && p.Results.flagDownloadSQLiteDriver
    SQLDriverURL = 'https://bitbucket.org/xerial/sqlite-jdbc/downloads/sqlite-jdbc-3.30.1.jar';
    system(sprintf('wget -O %s %s', p.Results.SQLiteDriverPath, SQLDriverURL));
    pathJDBC = p.Results.SQLiteDriverPath;
else
    warning('SQLite Driver was not found!');
end

%% add the SQLite JDBC driver to the search path
% details can be found under
% https://ww2.mathworks.cn/help/database/ug/sqlite-jdbc-linux.html
if exist(pathJDBC, 'file') == 2
    disp('Add SQLite JDBC to your search path.');
    javaclasspathFilepath = fullfile(prefdir, 'javaclasspath.txt');

    fid = fopen(javaclasspathFilepath, 'a');
    fprintf(fid, '%s\n', pathJDBC);

    fclose(fid);

    disp('MATLAB needs to be **RESTARTED** to activate the settings');
    pause(5);

    flag = true;
else
    flag = false;
end

end