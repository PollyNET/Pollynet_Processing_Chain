function theResult = copy(self, theDestination)

% netcdf/copy -- Copy one NetCDF into another.
%  copy(self, theDestination) copies the contents
%   of self, a netcdf or cell, into theDestination,
%   a netcdf.  If self is a cell, the enclosed
%   items are processed in the order given, with
%   variable data copying reserved for last.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 20-May-1997 09:09:49.

if nargin < 1, help(mfilename), return, end

result = [];

switch ncclass(theDestination)
case 'netcdf'
   switch ncclass(self)
   case 'cell'
      theItems = self;
   case 'netcdf'
      theItems = [att(self), dim(self), var(self)];
   otherwise
      disp(' ## Incompatible arguments.')
   end
   for i = 1:length(theItems)
      it = theItems{i};
      switch ncclass(it)
      case {'netcdf', 'ncdim', 'ncatt', 'ncrec'}
         result{i} = copy(it, theDestination);
      case 'ncvar'
         result{i} = copy(it, theDestination, 0, 1);
      otherwise
         disp(' ## Incompatible arguments.')
      end
   end
   for i = 1:length(theItems)
      it = theItems{i};
      switch ncclass(it)
      case 'ncvar'
         result{i} = copy(it, theDestination, 1, 0);
      otherwise
      end
   end
otherwise
end

if nargout > 0, theResult = result; end
