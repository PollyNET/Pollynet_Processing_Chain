function theResult = var(self)

% ncdim/var -- Variables associated with a NetCDF dimension.
%  var(self) returns a list of the ncvar objects that use
%   the dimension associated with self, an ncdim object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

if nargout > 0, theResult = []; end

[ndims, nvars, ngatts, recdim, status] = ...
   ncmex('inquire', ncid(self));
if status < 0, return, end

count = 0;
result = cell(0, 0);
for i = 1:nvars
   varid = i - 1;
   [varname, vartype, varndims, vardims, varnatts, status] = ...
      ncmex('varinq', ncid(self), varid);
   if status >= 0
      for j = 1:length(vardims)
         if vardims(j) == dimid(self)
            nc = ncitem('', ncid(self));
            v = ncvar(varname, nc);
            count = count + 1;
            result{count} = v;
            break
         end
      end
   end
end

if nargout > 0
   theResult = result;
  else
   for i = 1:length(result)
      disp(name(result{i}))
   end
end
