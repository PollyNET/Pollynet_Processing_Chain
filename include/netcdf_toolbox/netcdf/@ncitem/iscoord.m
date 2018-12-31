function theResult = iscoord(self)

% ncitem/iscoord -- Is self related to a coordinate-variable?
%  iscoord(self) returns TRUE (non-zero) if self has the
%   same name as a dimension; else, it returns FALSE (0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:49:26.

if nargin < 1, help(mfilename), return, end

theName = name(self);

theClass = ncclass(self);
switch theClass
case 'ncdim'
   result = (ncmex('varid', ncid(self), name(self)) >= 0);
case 'ncvar'
   result = (ncmex('dimid', ncid(self), name(self)) >= 0);
case 'ncatt'
   result = (ncmex('varid', ncid(self), name(self)) >= 0) & ...
            (ncmex('dimid', ncid(self), name(self)) >= 0);
otherwise
   result = 0;
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
