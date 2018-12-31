function theResult = att(self)

% ncdim/att -- Attributes of variables associated with a NetCDF dimension.
%  att(self) returns a list of the ncvar objects that use the dimension
%   associated with self, an ncdim object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = cell(0, 0);

v = var(self);
for i = 1:length(v)
   result = [result att(v{i})];
end

if nargout > 0
   theResult = result;
  else
   for i = 1:length(result)
      disp(name(result{i}))
   end
end
