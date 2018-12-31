function theResult = lt(self, other)

% ncatt/lt -- Redirection operator.
%  lt(self, other) redirects the contents of other,
%   an ncatt, double, or char object, into self,
%   an ncatt object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:43:32.

if nargin < 1, help(mfilename), return, end

result = [];

switch class(other)
  case 'ncatt'
   result = copy(other, self);
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
