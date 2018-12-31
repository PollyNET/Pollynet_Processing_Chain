function theResult = isrecdim(self)

% ncdim/isrecdim -- Is self a coordinate-dimension?
%  isrecdim(self) returns TRUE (non-zero) if self is
%   the record-dimension; else, it returns FALSE (0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = 0;
theRecdim = recdim(parent(self));
if ~isempty(theRecdim)
   if dimid(self) == dimid(theRecdim)
      result = 1;
   end
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
