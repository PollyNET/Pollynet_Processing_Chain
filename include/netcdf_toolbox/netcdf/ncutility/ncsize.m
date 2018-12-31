function theResult = ncsize(x)

% ncsize -- NCSIZE() for non-NetCDF objects.
%  ncsize(x) returns the size of x.  This routine
%   also posts a warning whenever called.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Dec-1998 09:43:20.

warning(' ## Please use SIZE for non-NetCDF entities.')

result = size(x);

if nargout > 0
	theResult = result;
else
	disp(result)
end
