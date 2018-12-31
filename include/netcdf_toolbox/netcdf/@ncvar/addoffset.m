function theResult = addoffset(self, theNewAddoffset)

% ncvar/addoffset -- "add_offset" attribute value.
%  addoffset(self) returns the "add_offset" attribute
%   value of self, an "ncvar" object, or 0 if no such
%   attribute exists.
%  addoffset(self, theNewAddoffset) changes the add-offset
%   of self, an "ncvar" object, to theNewAddoffset.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 22-Dec-1998 10:04:05.

if nargin < 1, help(mfilename), return, end

if nargin < 2
   result = 0;
   theAtt = ncatt('add_offset', self);
   if ~isempty(theAtt), result = theAtt(:); end
  else
   theVartype = datatype(self);
   theAtttype = theVartype;
   theAtt = ncatt('add_offset', theAtttype, theNewAddoffset, self);
   result = theAtt;
end

if nargout > 0
   theResult = result;
  elseif nargin < 2
   disp(result)
end
