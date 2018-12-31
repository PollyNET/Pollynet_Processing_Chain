function theResult = ncclass(self)

% ncitem/ncclass -- NetCDF class of a derived object.
%  ncclass(self) returns the NetCDF class of self,
%   an object derived from ncitem.  Unrecognized
%   classes are returned as they are.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-May-1997 11:27:21.

if nargin < 1, help(mfilename), return, end

theNCClass = class(self);
theNCClasses = {'netcdf', 'ncdim', 'ncvar', 'ncatt', 'ncrec', 'ncitem'};
for i = 1:length(theNCClasses)
   if isa(self, theNCClasses{i})
      theNCClass = theNCClasses{i};
      break;
   end
end

if nargout > 0
   theResult = theNCClass;
  else
   disp(theNCClass)
end
