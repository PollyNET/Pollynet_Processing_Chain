function [logbook] = readLogBook(logbookFile, nChannel)
% READLOGBOOK read logbook information from logbookFile.
%
% USAGE:
%    [logbook] = readLogBook(logbookFile, nChannel)
%
% INPUTS:
%    logbookFile: char
%        filename of the logbook file.
%    nChannel: int32
%        number of all the channels.
%
% OUTPUTS:
%    logbook: struct
%        datetime: array
%            datetime for applying the changes.
%        changes: struct
%            flagOverlap: logical
%            flagWindowwipe: logical
%            flagFlashlamps: logical
%            flagPulsepower: logical
%            flagRestart: logical
%        flag_CH_NDChange: logical matrix (IDs * nChannel)
%            logical to show whether there is ND filter changes in certain 
%            channels.
%
% HISTORY:
%    - 2021-06-11: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

logbook = struct();
logbook.datetime = [];
logbook.changes.flagOverlap = [];
logbook.changes.flagWindowwipe = [];
logbook.changes.flagFlashlamps = [];
logbook.changes.flagPulsepower = [];
logbook.changes.flagRestart = [];
logbook.flag_CH_NDChange = [];
if exist(logbookFile, 'file') ~= 2
    warning('logbook does not exist! Please check %s', logbookFile);
    return;
end

fid = fopen(logbookFile, 'r');

fgetl(fid);

while ~ feof(fid)

    lineStr = fgetl(fid);
    thisLogInfo = regexp(lineStr, ...
    '(?<id>\d+);"(?<time>.{13})";\[(?<operators>.*)\];\[(?<changes>.*)\];\{(?<ND>.*)\};(?<comment>.*)', 'names');
    logbook.datetime = [logbook.datetime, ...
                        datenum(thisLogInfo.time, 'yyyymmdd-HHMM')];
    % extract the operation information
    [flagOverlap, flagWindowwipe, flagFlashlamps, flagPulsepower, flagRestart] = regexpChanges(thisLogInfo.changes);
    logbook.changes.flagOverlap = [logbook.changes.flagOverlap, flagOverlap];
    logbook.changes.flagWindowwipe = [logbook.changes.flagWindowwipe, flagWindowwipe];
    logbook.changes.flagFlashlamps = [logbook.changes.flagFlashlamps, flagFlashlamps];
    logbook.changes.flagPulsepower = [logbook.changes.flagPulsepower, flagPulsepower];
    logbook.changes.flagRestart = [logbook.changes.flagRestart, flagRestart];
    % extract the ND change information
    [CH_NDChange] = regexpND(thisLogInfo.ND);
    thisFlag_CH_NDChange = zeros(1, nChannel);
    thisFlag_CH_NDChange(CH_NDChange) = true;

    % fill 0 at the end for those old Polly systems with less channels.
    if size(logbook.flag_CH_NDChange, 2) ~= size(thisFlag_CH_NDChange, 2)
        maxCh = max([size(logbook.flag_CH_NDChange, 2), ...
                     size(thisFlag_CH_NDChange, 2)]);
        tmp = zeros(size(logbook.flag_CH_NDChange, 1), maxCh);
        tmp(:, 1:size(logbook.flag_CH_NDChange, 2)) = logbook.flag_CH_NDChange;
        logbook.flag_CH_NDChange = tmp;

        tmp = zeros(1, maxCh);
        tmp(1:size(thisFlag_CH_NDChange, 2)) = thisFlag_CH_NDChange;
        thisFlag_CH_NDChange = tmp;
    end

    logbook.flag_CH_NDChange = [logbook.flag_CH_NDChange; thisFlag_CH_NDChange];

end

fclose(fid);

end

function [flagOverlap, flagWindowwipe, flagFlashlamps, flagPulsepower, flagRestart] = regexpChanges(changesStr)
% REGEXPCHANGES extract operation information from the changes string with 
% regular expression.
% USAGE:
%    [flagOverlap, flagWindowwipe, flagFlaslamps, flagPulsepower, 
%     flagRestart] = regexpChanges(changesStr)
% INPUTS:
%    changesStr: char
%        the extracted string from `changes` category in logbook.
% OUTPUTS:
%    flagOverlap: logical
%        if it is true, the correponding operation is applied in the 
%        adjustment.
%    flagWindowwipe: logical
%        if it is true, the correponding operation is applied in the 
%        adjustment.
%    flagFlaslamps: logical
%        if it is true, the correponding operation is applied in the 
%        adjustment.
%    flagPulsepower: logical
%        if it is true, the correponding operation is applied in the 
%        adjustment.
%    flagRestart: logical
%        if it is true, the correponding operation is applied in the 
%        adjustment.
% HISTORY:
%    2019-02-08: First Edition by Zhenping
% .. Authors: - zhenping@tropos.de

flagOverlap = ~ isempty(strfind(changesStr, 'overlap'));
flagWindowwipe = ~ isempty(strfind(changesStr, 'windowwipe'));
flagFlashlamps = ~ isempty(strfind(changesStr, 'flashlamps'));
flagPulsepower = ~ isempty(strfind(changesStr, 'pulsepower'));
flagRestart = ~ isempty(strfind(changesStr, 'restarted'));

end

function [channel] = regexpND(ndFilterStr)
% REGEXPND extract channel nubmers with ND filter changes.
% USAGE:
%    [channel] = regexpND(ndFilterStr)
% INPUTS:
%    ndFilterStr: char
%        ND filter change string.
% OUTPUTS:
%    channel: array
%        channel number with ND filter chagnes.
% HISTORY:
%    2019-02-08. First Edition by Zhenping
% .. Authors: - zhenping@tropos.de

channel = [];

if isempty(ndFilterStr)
    return;
else
    data = textscan(ndFilterStr, '%d %f', 'delimiter', ',');
    channel = data{1};
end

end