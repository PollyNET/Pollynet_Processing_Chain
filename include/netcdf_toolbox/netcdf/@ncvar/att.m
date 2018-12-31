function theResult = att(self, theAttname)

% ncvar/att -- Attributes of an ncvar object.
%  att(self, 'theAttname') returns the ncatt object
%   whose name is theAttname, associated with self,
%   an ncvar object.
%  att(self) returns the cell-list of ncatt objects
%   associated with self, an ncvar object.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1 & ncid(self) >= 0
   [theVarname, theVartype, theVarndims, theVardims, theVarnatts] = ...
         ncmex('varinq', ncid(self), varid(self));
   result = cell(1, theVarnatts);
   for i = 1:theVarnatts
      theAttnum = i-1;
      theAttname = ncmex('attname', ncid(self), varid(self), theAttnum);
      result{i} = ncatt(theAttname, self);
   end
  elseif ncid(self) >= 0
   result = ncatt(theAttname, self);
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
