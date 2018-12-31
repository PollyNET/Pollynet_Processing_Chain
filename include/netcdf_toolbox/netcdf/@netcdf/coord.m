function theResult = coord(self)

% netcdf/coord -- Coordinate variables
%  coord(self) returns the coordinate variables
%   of self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

vars = var(self);

for i = length(vars):-1:1
   if ~iscoord(vars{i}), vars(i) = []; end
end

if nargout > 0
   theResult = vars;
  else
   for i = 1:length(vars)
      disp(name(vars{i}))
   end
end
