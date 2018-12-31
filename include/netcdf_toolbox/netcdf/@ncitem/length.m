function theResult = length(self)

% ncitem/length -- Length of an "ncitem" object.
%  length(self) returns max(size(self)).
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Dec-1998 10:04:23.

result = max(size(self));

if nargout > 0
	theResult = result;
else
	disp(result)
end
