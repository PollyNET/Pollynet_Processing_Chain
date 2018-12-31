function theResult = iscoord(self)

% ncvar/iscoord -- Is self a coordinate-variable?
%  iscoord(self) returns TRUE (non-zero) if self has the
%   same name as a dimension; else, it returns FALSE (0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

theName = name(self);
result = (ncmex('dimid', ncid(self), name(self)) >= 0);

if nargout > 0
   theResult = result;
  else
   disp(result)
end
