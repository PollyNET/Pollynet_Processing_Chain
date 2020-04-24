function [flagSQLDriverValid] = testSQLiteJDBC()
%testSQLiteJDBC test whether SQLite JDBC is in MATLAB Java search path.
%Example:
%   [flagSQLDriverValid] = testSQLiteJDBC()
%Outputs:
%   flagSQLDriverValid: logical
%       flag to show whether SQLite JDBC is in the search path.
%History:
%   2020-04-23. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

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