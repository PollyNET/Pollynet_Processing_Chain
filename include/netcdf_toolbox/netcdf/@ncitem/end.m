function theResult = end(self, k, n)

% ncitem/end -- Evaluate "end" as an index.
%  end(self, k, n) returns the value of "end"
%   that has been used as the k-th index in
%   a list of n indices, on behalf of "self",
%   an "ncitem" object.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 24-Aug-1999 08:46:58.
% Updated    24-Aug-1999 08:46:58.

if nargin < 1, help(mfilename), return, end

s = size(self);

if k == 1 & n == 1
	result = prod(s);
elseif k <= length(s)
	result = s(k);
else
	result = 0;
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
