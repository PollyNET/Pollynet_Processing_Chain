function theResult = switchsafe(x)

% switchsafe -- Make an empty item safe for "switch" command.
%  switchsafe(x) returns a version of x, where x is empty,
%   that is safe to use in a "switch" statement.
 
% Copyright (C) 2002 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Mar-2002 14:58:56.
% Updated    08-Apr-2002 10:46:04.

if nargin < 1, help(mfilename), return, end

if isempty(x), x = ''; end

if nargout > 0
	theResult = x;
else
	assignin('caller', 'ans', x)
end
