function theResult = parent(self)

% ncitem/parent -- Parent of a NetCDF item.
%  parent(self) returns the parent-object
%   of self, an "ncitem" object.  Non-global
%   attributes return an "ncvar"; all others
%   return a "netcdf".  The parent of a "netcdf"
%   is itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Apr-1997 09:17:30.

if nargin < 1, help(mfilename), return, end

if nargout > 0
    theResult = [];
end

theNCid = ncid(self);
if theNCid < 0, return, end

theNetCDF = netcdf(theNCid);

switch ncclass(self)
case 'ncatt'
   if varid(self) >= 0
      theParent = ncvar(ncitem('', ncid(self), -1, varid(self)));
   else
      theParent = ncregister(theNetCDF);
   end
otherwise
   theParent = ncregister(theNetCDF);
end

if nargout > 0
   theResult = theParent;
else
   theParent
end
