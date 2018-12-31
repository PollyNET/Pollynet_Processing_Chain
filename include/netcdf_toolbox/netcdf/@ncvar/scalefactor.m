function theResult = scalefactor(self, theNewScalefactor)

% ncvar/scalefactor -- "scale-factor" attribute value.
%  scalefactor(self) returns the "scale_factor" attribute
%   value of self, an "ncvar" object, or 1 if no such
%   attribute exists.
%  scalefactor(self, theNewScalefactor) changes the scale-factor
%   of self, an "ncvar" object, to theNewScalefactor.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 22-Dec-1998 10:04:05.

if nargin < 1, help(mfilename), return, end

if nargin < 2
   result = 1;
   theAtt = ncatt('scale_factor', self);
   if ~isempty(theAtt), result = theAtt(:); end
  else
   theVartype = datatype(self);
   theAtttype = theVartype;
   theAtt = ncatt('scale_factor', theAtttype, theNewScalefactor, self);
   result = theAtt;
end

if nargout > 0
   theResult = result;
  elseif nargin < 2
   disp(result)
end
