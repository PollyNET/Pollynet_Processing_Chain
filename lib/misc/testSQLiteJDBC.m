function [flagSQLDriverValid] = testSQLiteJDBC()
% TESTSQLITEJDBC test whether SQLite JDBC is in MATLAB Java search path.
% USAGE:
%    [flagSQLDriverValid] = testSQLiteJDBC()
% OUTPUTS:
%    flagSQLDriverValid: logical
%        flag to show whether SQLite JDBC is in the search path.
% HISTORY:
%    2021-06-13: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

dbFile = sprintf('%s.db', tempname);

% try to use the SQLite JDBC
conn = database(dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', dbFile));

if strcmpi(conn.Message, 'Unable to find JDBC driver.') || ...
   ~ isempty(regexp(char(conn.Message), 'No suitable \w*', 'once'))
    flagSQLDriverValid = false;
else
    flagSQLDriverValid = true;
end

end