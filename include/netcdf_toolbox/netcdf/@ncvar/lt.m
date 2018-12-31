function theResult = lt(self, other)

% ncvar/lt -- Redirection operator.
%  lt(self, other) redirects other, an ncvar, ncatt,
%   double, or char object, into self, an ncvar object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

result = [];

switch ncclass(other)
case 'cell'
   result = cell(size(other));
   for i = 1:length(other)
      result{i} = (self < other{i});
   end
case 'ncdim'
case 'ncvar'
   result = copy(other, self, 1, 1);
case {'ncatt'}
   result = copy(other, self);
case {'double', 'char'}
   result = copy(other, self, 1, 0);
otherwise
   warning(' ## Incompatible arguments.')
end

if nargout > 0, theResult = result; end
