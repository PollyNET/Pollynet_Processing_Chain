function theResult = ncsetstr(x)

% ncsetstr -- SETSTR for NetCDF character data.
%  ncsetstr(x) converts values x to unsigned-characters
%   in the range 0:255, for use by Matlab.  Beginning
%   with Version-6, Matlab characters must be non-negative,
%   whereas the sign of NetCDF "char" is undefined.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Mar-2001 11:23:06.
% Updated    01-Mar-2001 11:45:03.

if nargout > 0
	theResult = [];
end

if nargin < 1
	help(mfilename)
	return
end

result = rem(x, 256);
result(result < 0) = result(result < 0) + 256;
result = char(result);

if nargout > 0
	theResult = result;
else
	disp(result)
end
