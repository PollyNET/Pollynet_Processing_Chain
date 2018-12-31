function theResult = isepic(self)

% ncvar/isepic -- Is this an epic variable?
%  isepic(self) returns TRUE (1) if self, an "ncvar"
%   object, appears to represent a NOAA epic variable.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-May-1997 10:43:30.

if nargin < 1, help(mfilename), return, end

result = 0;

d = dim(self);
if ~isempty(d)
   if strcmp(lower(name(d{1})), 'time') & ~isempty(self.epic_code)
      result = 1;
   end
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
