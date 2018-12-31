function theResult = subsindex(self)

% ncdim/subsindex -- Value of an ncdim object as an index.
%  subsindex(self) returns the set of zero-based indices
%   equivalent to the value of self, an "ncdim" object.
%   The result is [(1:self(:)) - 1], corresponding
%   to the full span of the dimensional length.
%
% Also see: ncvar/subsindex.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

result = (1:self(:)) - 1;

if nargout > 0
   theResult = result;
  else
   disp(result)
end
