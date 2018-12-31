function theResult = subsindex(self)

% ncvar/subsindex -- Value of an ncvar object as an index.
%  subsindex(self) returns the set of zero-based indices
%   equivalent to the value of self, an "ncvar" object.
%   The result is [find(isfinite(self(:)) ~= 0) - 1],
%   corresponding to the one-dimensional indices of
%   all the finite, non-zero elements in the contents
%   of self.
%
% Also see: ncdim/subsindex.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

result = find(isfinite(self(:)) ~= 0) - 1;

if nargout > 0
   theResult = result;
  else
   disp(result)
end
