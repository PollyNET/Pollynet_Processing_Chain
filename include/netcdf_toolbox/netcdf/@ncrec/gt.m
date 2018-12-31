function theResult = gt(self, theNetcdf)

% ncrec/gt -- Pipe self into a netcdf object.
%  gt(self, theItem) pipes self, an ncrec object,
%   into theNetcdf, a netcdf object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

result = [];

switch class(theNetcdf)
  case 'netcdf'
   result = rec(theNetcdf, recnum(self), self(:));
  otherwise
   warning(' ## Illegal operation.')
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
