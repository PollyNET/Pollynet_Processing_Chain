function theResult = dim(self, theDimname)

% ncvar/dim -- Dimensions of an ncvar object.
%  dim(self, 'theDimname') returns the ncdim object
%   whose name is theDimname, associated with self,
%   an ncvar object.
%  dim(self) returns the cell-list of ncdim objects
%   associated with self, an "ncvar" object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin < 2 & ncid(self) >= 0
   [theVarname, theVartype, theVarndims, theVardimids, theVarnatts, status] = ...
         ncmex('varinq', ncid(self), varid(self));
   result = cell(1, theVarndims);
   for i = 1:theVarndims
      theDimid = theVardimids(i);
      [theDimname, theDimsize, status] = ...
            ncmex('diminq', ncid(self), theDimid);
      result{i} = ncdim(theDimname, self);
   end
elseif nargin > 1
   result = ncdim(theDimname, self);
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
