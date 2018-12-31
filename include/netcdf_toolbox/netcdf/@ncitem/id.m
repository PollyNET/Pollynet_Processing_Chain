function theResult = id(self)

% ncitem/id -- The access id of a NetCDF object.
%  id(self) returns the access id for self,
%   a netcdf, ncdim, ncvar, or ncatt object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:48:59.

if nargin < 1, help(mfilename), return, end

switch class(self)
case 'netcdf'
   result = ncid(self);
case 'ncdim'
   result = dimid(self);
case 'ncvar'
   result = varid(self);
case 'ncatt'
   result = attnum(self);
otherwise
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
