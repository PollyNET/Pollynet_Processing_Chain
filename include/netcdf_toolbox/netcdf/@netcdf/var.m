function theResult = var(self, theName, theType, theDims)

% netcdf/var -- Variables of a netcdf object.
%  var(self) returns the cell-list of ncvar objects
%   associated with self, a netcdf object.
%  var(self, 'theName') returns the ncvar object whose
%   name is theName, associated with self, a netcdf object.
%  var(self, 'theName', 'theType', {theDims}) defines a
%   new NetCDF variable in self, with theName, theType
%   (default  = 'double'), and theDims (a cell-list of
%   ncdim objects, possibly empty).  The new ncvar object
%   is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:33:06.

if nargin < 1, help(mfilename), return, end

result = [];

switch nargin
  case 1
   [ndims, nvars, ngatts, recdim, status] = ...
      ncmex('inquire', ncid(self));
   theVars = cell(1, nvars);
   for theVarindex = 1:nvars
      theVars{theVarindex} = ncvar(theVarindex, self);
   end
   result = theVars;
  case 2
   result = ncvar(theName, self);
  case 4
   result = ncvar(theName, theType, theDims, self);
  otherwise
   warning(' ## Illegal syntax.')
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
