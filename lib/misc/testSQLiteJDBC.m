function [flagSQLDriverValid] = testSQLiteJDBC()
% TESTSQLITEJDBC test whether SQLite JDBC is in MATLAB Java search path.
%
% USAGE:
%    [flagSQLDriverValid] = testSQLiteJDBC()
%
% OUTPUTS:
%    flagSQLDriverValid: logical
%        flag to show whether SQLite JDBC is in the search path.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

flagSQLDriverValid = true;

try
    org.sqlite.JDBC;
catch ME
    flagSQLDriverValid = false;
end

end