function theResult = dim(self, theDimname)

% netcdf/dim -- Dimensions of a netcdf object.
%  dim(self, 'theDimname') returns the ncdim object
%   whose name is theDimname, associated with self,
%   a netcdf object.
%  dim(self) returns the cell-list of ncdim objects
%   associated with self, a netcdf object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin < 2
   [ndims, nvars, ngatts, recdim, status] = ...
         ncmex('inquire', ncid(self));
   result = cell(1, ndims);
   for i = 1:ndims
      theDimid = i-1;
      [theDimname, theDimsize, status] = ...
            ncmex('diminq', ncid(self), theDimid);
      result{i} = ncdim(theDimname, self);
   end
else
   result = ncdim(theDimname, self);
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
