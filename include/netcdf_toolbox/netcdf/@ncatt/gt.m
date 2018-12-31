function theResult = gt(self, other)

% gt -- Greater-than operator; redirection operator.
%  gt(self, other) returns the arithmetic greater-than
%   comparison of self with other, for self, an ncatt
%   object, and other, an ncatt, double, or char.
%  gt(self, other) redirects self, an ncatt object,
%   into other, a netcdf or ncvar object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

result = [];

switch class(other)
  case {'netcdf', 'ncvar'}
   result = copy(self, other);
  case 'ncatt'
   a = self(:);
   b = other(:);
   if isequal(size(a), size(b)) | length(b) == 1
      result = (a > b);
   end
  case {'double', 'char'}
   a = self(:);
   b = other;
   if isequal(size(a), size(b)) | length(b) == 1
      result = (a > b);
   end
  otherwise
   warning(' ## Incompatible arguments.')
end

if nargout > 0, theResult = result; end
