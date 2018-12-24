function [username, userpath, platform] = getsysinfo()
%GETSYSINFO get the system information.
%	Example:
%		[username, userpath, platform] = getsysinfo()
%	Inputs:
%	Outputs:
%		username: char
%			current user of the OS.
%		userpath: char
%			home directory of the current user.
%		platform: char
%			current running OS.
%	History:
%		2018-12-16. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

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