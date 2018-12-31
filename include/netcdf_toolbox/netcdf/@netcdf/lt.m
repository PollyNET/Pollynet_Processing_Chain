function theResult = lt(self, theItem)

% netcdf/lt -- Redirect an item into self.
%  lt(self, theItem) redirects theItem, derived from
%   the ncitem class, into self, a netcdf object.
%   If theItem is a cell-array, its elements are
%   processed one at a time in the order given.
%   When intending to copy more than one variable,
%   use a cell-array of variables for efficiency.
%   The returned value is the destination object
%   or list of objects, depending on context.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-May-1997 13:25:31.

if nargin < 1, help(mfilename), return, end

result = [];

switch ncclass(self)
case 'netcdf'
   switch ncclass(theItem)
   case {'cell', 'netcdf', 'ncdim', 'ncvar', 'ncatt', 'ncrec'}
      result = copy(theItem, self);
   otherwise
      warning(' ## Incompatible arguments.')
   end
otherwise
   warning(' ## Incompatible arguments.')
end

if nargout > 0, theResult = result; end
