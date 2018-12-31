function theResult = datatype(self)

% ncatt/datatype -- Numeric type of an ncatt object.
%  datatype(self) returns the numeric type of self,
%   an "ncatt" object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:42:59.

if nargin < 1, help(mfilename), return, end

result = '';

theTypes = {'byte', 'char', 'short', 'long', 'float', 'double'};

theNCid = ncid(self);

if theNCid >= 0
   theVarid = varid(self);
   theAttname = name(self);
   [theType, theLen, status] = ncmex('attinq', theNCid, theVarid, theAttname);
   if status >= 0 & ~isstr(theType)
      theType = theTypes{theType};
   end
else
    theType = self.itsAtttype;
end

result = theType;

if nargout > 0
   theResult = result;
else
   disp(result)
end
