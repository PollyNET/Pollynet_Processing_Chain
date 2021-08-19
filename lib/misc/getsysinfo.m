function [username, userpath, platform] = getsysinfo()
% GETSYSINFO get system information.
%
% USAGE:
%    [username, userpath, platform] = getsysinfo()
%
% OUTPUTS:
%    username: char
%        current user of the OS.
%    userpath: char
%        home directory of the current user.
%    platform: char
%        current running OS.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if ispc
    platform = 'win';
    username = getenv('USERNAME');
    userpath = getenv('USERPROFILE');
elseif isunix
    platform = 'linux';
    username = getenv('USER');
    userpath = getenv('HOME');
elseif ismac
    platform = 'mac';
    username = getenv('USER');
    userpath = getenv('HOME');
else
    error('Error in getsysinfo(): Unrecognizable platform');
end

end