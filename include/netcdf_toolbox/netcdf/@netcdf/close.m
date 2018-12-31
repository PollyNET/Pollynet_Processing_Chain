function theResult = close(self)

% netcdf/close -- Close the file of a "netcdf" object.
%  close(self) closes the NetCDF file associated
%   with self, a "netcdf" object.  The empty matrix
%   [] is returned if successful; otherwise self
%   is returned.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

result = [];

if (ncmex('close', ncid(self)) < 0)
   result = self;
   warning([' ## ' mfilename ' failed: ' name(self)])
end

ncregister(self, result)
result = ncregister(self);

if nargout > 0, theResult = result; end
