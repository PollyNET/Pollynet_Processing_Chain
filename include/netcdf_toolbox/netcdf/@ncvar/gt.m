function theResult = gt(self, other)

% ncvar/gt -- Redirection operator.
%  gt(self, theNetcdf) redirects self, an ncvar object,
%   into theNetcdf, a netcdf object.  This copies the
%   variable definition, but not its data or attributes.
%  gt(self, theNCVar) redirects the contents of self, an
%   ncvar object, into theNCVar, an ncvar object.  This
%   copies variable data, but not the attributes.
%  gt(self, theNCVar) redirects the contents of self, a
%   double or char object, into theNCVar, an ncvar object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = [];

switch class(other)
  case 'netcdf'  % No data or attributes copied.
   result = copy(self, other, 0, 0);
  case 'ncvar'
   switch class(self)
   case 'ncvar'   % Copy the data.
      result = (other < self(:));
   case 'ncatt'   % Copy the attribute.
      result = ncatt(name(other), datatype(other), other(:), self);
   case {'double', 'char'}   % Copy the data brute-force.
   if isequal(prod(size(self)), prod(size(other))) | ...
         prod(size(self)) == 1
      other(:) = self(:);
      result = other;
   end
   otherwise
   end
  otherwise
   warning(' ## Incompatible arguments.')
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
