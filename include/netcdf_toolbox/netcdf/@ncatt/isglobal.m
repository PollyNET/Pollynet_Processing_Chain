function theResult = isglobal(self)

% ncatt/isglobal -- Is this a global atttribute?
%  isglobal(self) returns TRUE (1) if self, an
%   ncatt object, represents a global attribute.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-May-1997 11:57:05.

if nargin < 1, help(mfilename), return, end

result = (varid(self) < 0);

if nargout > 0
   theResult = result;
  else
   disp(result)
end
