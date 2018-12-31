function theResult = unsigned(self, isUnsigned)

% ncitem/unsigned -- Set/get unsigned flag.
%  unsigned(self) returns TRUE if the "unsigned" flag
%   has been set to interpret NetCDF signed integer data
%   as unsigned.  This flag does not affect the contents
%   of the NetCDF file itself.  Only bytes, shorts, and
%   longs are allowed to be unsigned.
%  unsigned(self, isUnsigned) sets the "unsigned" flag
%   according to the "isUnsigned" argument: 1 or 0.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Nov-1998 12:51:36.

if nargin < 1, help(mfilename), return, end

if nargin < 2
	result = self.itIsUnsigned;
else
	if isa(self, 'ncvar') | isa(self, 'ncatt')
		switch datatype(self)
		case {'byte', 'short', 'long'}
			isUnsigned = ~~isUnsigned;
		otherwise
			isUnsigned = ~~0;
		end
		self.itIsUnsigned = isUnsigned;
	end
	result = self;
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
