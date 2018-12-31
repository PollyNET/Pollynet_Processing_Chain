function theResult = dim(self)

% ncatt/dim -- Dimensions associated with attributes of the same name.
%  dim(self) returns a list of the ncdim objects that are
%   associated with variables that have an attribute with the
%   same name as self, an ncatt object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:43:32.

if nargin < 1, help(mfilename), return, end

if nargout > 0, theResult = []; end

[ndims, nvars, ngatts, recdim, status] = ...
   ncmex('inquire', ncid(self));
if status < 0, return, end

result = cell(0, 0);
for i = 1:nvars
   varid = i - 1;
   [varname, vartype, varndims, vardims, varnatts, status] = ...
      ncmex('varinq', ncid(self), varid);
   if status >= 0
      nc = ncitem('', ncid(self));
      v = ncvar(varname, nc);
      a = att(v);
      for j = 1:length(a)
         if strcmp(name(a{j}), name(self))
            result = [result dim(v)];
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
