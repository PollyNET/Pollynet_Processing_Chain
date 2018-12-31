function theResult = copy(self, theDestination)

% ncatt/copy -- Copy a NetCDF attribute.
% copy(self, theDestination) copys the NetCDF attribute
%  associated with self, an ncatt object, to the location
%  associated with theDestination, a netcdf or ncvar object.
%  If successful, the new ncatt object is returned; otherwise,
%  the empty-matrix [] is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:43:32.

if nargin < 2, help(mfilename), return, end

result = [];

switch ncclass(theDestination)
case 'netcdf'
   result = ncatt(name(self), datatype(self), self(:), theDestination);
case 'ncvar'
   result = ncatt(name(self), datatype(self), self(:), theDestination);
case 'ncatt'
   switch ncclass(self)
   case 'ncatt'
      theDestination(:) = self(:);
      result = theDestination;
   case {'double', 'char'}
      theDestination(:) = self;
      result = theDestination;
   otherwise
   end
otherwise
end

if nargout > 0, theResult = result; end
