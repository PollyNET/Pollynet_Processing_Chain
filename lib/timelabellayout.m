function [tOutTick, tOutTickStr] = timelabellayout(tIn, outFormat)
%TIMELABELLAYOUT tight layout of time label.
%Example:
%   [tOutTick, tOutTickStr] = timelabellayout(tIn, outFormat)
%Inputs:
%   tIn: array
%       measurement time. [datenum]
%   outFormat: char
%       output format for the date string.
%Outputs:
%   tOutTick: array
%       datenum for each tick label. 
%   tOutTickStr: cell
%       tick label.
%History:
%   2018-12-29. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

tOutTick = [];
tOutTickStr = cell(0);

if numel(tIn) <= 1
    return;
end

if ~ exist('outFormat', 'var')
    outFormat = 'HH:MM';
end

tSpan = tIn(end) - tIn(1);

if tSpan <= datenum(0, 1, 0, 0, 30, 0)
    tInterval = datenum(0, 1, 0, 0, 5, 0);
    firstIntegerTime = floor(tIn(1) / tInterval + 1) * tInterval;
    lastIntegerTime = ceil(tIn(end) / tInterval - 1) * tInterval;

    if firstIntegerTime > lastIntegerTime
        tOutTick = [tIn(1), tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
        tOutTickStr{end - 1} = '';
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) > tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
    elseif ((firstIntegerTime - tIn(1)) > tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{end - 1} = '';
    else
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    end
elseif tSpan <= datenum(0, 1, 0, 0, 180, 0)
    tInterval = datenum(0, 1, 0, 0, 30, 0);
    firstIntegerTime = floor(tIn(1) / tInterval + 1) * tInterval;
    lastIntegerTime = ceil(tIn(end) / tInterval - 1) * tInterval;

    if firstIntegerTime > lastIntegerTime
        tOutTick = [tIn(1), tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
        tOutTickStr{end - 1} = '';
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) > tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
    elseif ((firstIntegerTime - tIn(1)) > tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{end - 1} = '';
    else
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    end
elseif tSpan <= datenum(0, 1, 0, 0, 360, 0)
    tInterval = datenum(0, 1, 0, 0, 60, 0);
    firstIntegerTime = floor(tIn(1) / tInterval + 1) * tInterval;
    lastIntegerTime = ceil(tIn(end) / tInterval - 1) * tInterval;

    if firstIntegerTime > lastIntegerTime
        tOutTick = [tIn(1), tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
        tOutTickStr{end - 1} = '';
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) > tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
    elseif ((firstIntegerTime - tIn(1)) > tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{end - 1} = '';
    else
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    end
elseif tSpan <= datenum(0, 1, 0, 0, 1440, 0)
    tInterval = datenum(0, 1, 0, 0, 240, 0);
    firstIntegerTime = ceil(tIn(1) / tInterval) * tInterval;
    lastIntegerTime = floor(tIn(end) / tInterval) * tInterval;

    if firstIntegerTime > lastIntegerTime
        tOutTick = [tIn(1), tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
        tOutTickStr{end - 1} = '';
    elseif ((firstIntegerTime - tIn(1)) <= tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) > tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{2} = '';
    elseif ((firstIntegerTime - tIn(1)) > tInterval/3) && ...
           ((tIn(end) - lastIntegerTime) <= tInterval/3)
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
        tOutTickStr{end - 1} = '';
    else
        tOutTick = [tIn(1), ...
            firstIntegerTime:tInterval:lastIntegerTime, tIn(end)];
        tOutTickStr = cellstr(datestr(tOutTick, outFormat));
    end
else
    error('The span is too large.')
end

end