function theResult = isscalar(self)

% ncvar/isscalar -- Is this a scalar variable?
%  isscalar(self) returns 1 (TRUE) if self, an "ncvar"
%   object, represents a NetCDF "scalar" variable, i.e.
%   one with no dimensions.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Sep-1997 10:12:33.

if nargin < 1, help(mfilename), return, end

result = isempty(dim(self));

if nargout > 0
   theResult = result;
else
   disp(result)
end
