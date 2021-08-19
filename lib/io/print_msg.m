function print_msg(inStr, varargin)
% PRINT_MSG Print message. 
%
% USAGE:
%    % Usercase 1: print message
%    print_msg('Hello world!');
%    % Usercase 2: print message with timestamp
%    print_msg('Hello world!', 'flagTimestamp', true);
%
% INPUTS:
%    inStr: char
%       input char array
%
% KEYWORDS:
%    mode: digit
%       0: normal mode
%       1: log mode (default)
%    flagSimpleMsg: logical
%       simple message flag. (default: true)
%    flagTimestamp: logical
%       flag to control whether add timestamp for the message. (default: false)
%
% HISTORY:
%    - 2021-04-06: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

global LogConfig

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'inStr', @ischar);
addParameter(p, 'mode', 1, @isnumeric);
addParameter(p, 'flagSimpleMsg', true, @islogical);
addParameter(p, 'flagTimestamp', false, @islogical);

parse(p, inStr, varargin{:});

if abs(p.Results.mode - 0) < 1e-5
    % normal mode
    fprintf(inStr);
elseif abs(p.Results.mode - 1) < 1e-5
    % log mode

    % write to matlab command line
    if (LogConfig.printLevel == 0) || (LogConfig.printLevel == 2)
        % full message
        if p.Results.flagTimestamp
            fprintf(['[%s] ', inStr], datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        else
            fprintf(inStr);
        end
    elseif (LogConfig.printLevel == 3) || (LogConfig.printLevel == 5)
        % simple message
        if ~ p.Results.flagSimpleMsg
            % Enalbe simple message output
            if p.Results.flagTimestamp
                fprintf(['[%s] ', inStr], datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            else
                fprintf(inStr);
            end
        end
    else
        error('PICASSO:InvalidInput', 'Unknown printLevel: %d\n', ...
              LogConfig.printLevel);
    end

    % determine the existence of log file
    if exist(LogConfig.logFile, 'file') ~= 2
        error('PICASSO:NonexistFile', 'log file does not exist.\n%s\n', ...
              LogConfig.logFile);
    end

    % write to log file
    if (LogConfig.printLevel == 0) || (LogConfig.printLevel == 1)
        % full message
        if p.Results.flagTimestamp
            fprintf(LogConfig.logFid, ['[%s] ', inStr], ...
                    datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        else
            fprintf(LogConfig.logFid, inStr);
        end
    elseif (LogConfig.printLevel == 3) || (LogConfig.printLevel == 4)
        % simple message
        if ~ p.Results.flagSimpleMsg
            % Enalbe simple message output
            if p.Results.flagTimestamp
                fprintf(LogConfig.logFid, ['[%s] ', inStr], ...
                        datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            else
                fprintf(LogConfig.logFid, inStr);
            end
        end
    else
        fclose(LogConfig.logFid);
        error('PICASSO:InvalidInput', 'Unknown printLevel: %d\n', ...
              LogConfig.printLevel);
    end
else
    error('PICASSO:InvalidInput', 'Unknown print mode: %d\n', p.Results.mode);
end

end