function theResult = copy(self, theDestination)

% ncdim/copy -- Copy a NetCDF dimension.
%  copy(self, theDestination) copys the NetCDF dimension
%   associated with self, an ncdim object, to theDestination,
%   a netcdf object.  If successful, the new ncdim object is
%   returned; otherwise, the empty-matrix [] is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.
% Updated    30-Apr-2001 09:27:03.

if nargin < 2, help(mfilename), return, end

switch ncclass(theDestination)
case 'netcdf'
   theSize = ncsize(self);
   if isrecdim(self), theSize = 0; end
   result = ncdim(name(self), theSize, theDestination);
otherwise
   result = [];
end

if nargout > 0, theResult = result; end
