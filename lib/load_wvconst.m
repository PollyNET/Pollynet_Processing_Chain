function [wvconst, wvconstStd] = load_wvconst(measTime, dbFile, pollyType, varargin)
%load_wvconst load water vapor calibration constant from database.
%Example:
%   [wvconst, wvconstStd] = load_wvconst(measTime, dbFile, pollyType, varargin)
%Inputs:
%   measTime, dbFile, pollyType, varargin
%Outputs:
%   wvconst, wvconstStd
%History:
%   2020-04-17. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

%% parse arguments
p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'measTime', @isnumeric);
addRequired(p, 'dbFile', @ischar);
addRequired(p, 'pollyType', @ischar);
addParameter(p, 'deltaTime', NaN, @isnumeric);

parse(p, measTime, dbFile, pollyType, varargin{:});

wvconst = [];
wvconstStd = [];

if exist(p.Results.dbFile, 'file') ~= 2
    warning('p.Results.dbFile does not exist!\n%s\n', p.Results.dbFile);
    return;
end

conn = database(p.Results.dbFile, '', '', 'org:sqlite:JDBC', sprintf('jdbc:sqlite:%s', p.Results.dbFile));

if isnan(p.Results.deltaTime)
    % not constrain from deltaTime
    curs = exec(conn, ...
    sprintf('SELECT  FROM (lidar_constant WHERE time<=''%s'' AND time>=''%s'') ORDER BY ABS(STRFTIME(''%s'', ))', ...
        datestr(tRange(2), 'yyyy-mm-dd HH:MM:SS'), ...
        datestr(tRange(1), 'yyyy-mm-dd HH:MM:SS')));
else
end

res = fetch(curs);

%% close connection
close(conn);

end