function theResult = gt(self, theDestination)

% ncdim/gt -- Pipe self into a netcdf item.
%  gt(self, theDestination) pipes self, an ncdim
%   object, into theDestination, an netcdf object.
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = [];

switch class(theDestination)
  case 'netcdf'
   result = [];
   [ndims, nvars, ngatts, recdim, status] = ncmex('inquire', ncid(self));
   if dimid(self) == recdim
   end
   if isempty(result)
      result = copy(self, theDestination);
   end
  otherwise
   warning(' ## Illegal operation.')
end

if nargout > 0, theResult = result; end
