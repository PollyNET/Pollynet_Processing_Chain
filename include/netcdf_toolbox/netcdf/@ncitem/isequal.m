function theResult = isequal(self, other)

% ncitem/isequal -- Are two ncitems the same?
%  isequal(self, other) returns TRUE (1) if self
%   and other represent the same NetCDF entity.
%   Otherwise, it returns FALSE (0).
%
% Also see: ncitem/eq, ncitem/ne.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:50:19.

if nargin < 2, help(mfilename), return, end

result = 0;

if isequal(class(self), class(other)) & ...
   isequal(name(self), name(other)) & ...
   isequal(ncid(self), ncid(other)) & ...
   isequal(dimid(self), dimid(other)) & ...
   isequal(varid(self), varid(other)) & ...
   isequal(attnum(self), attnum(other))
   result = 1;
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
