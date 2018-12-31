function theResult = datatype(self)

% ncitem/datatype -- Numeric type of an ncitem object.
%  datatype(self) returns the numeric type of
%   self, an object derived from the ncitem class.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:42:59.

if nargin < 1, help(mfilename), return, end

result = '';

theTypes = {'byte', 'char', 'short', 'long', 'float', 'double'};

theNCid = ncid(self);

theClass = ncclass(self);
switch theClass
case 'ncdim'
   theType = 'long';
   status = 0;
case 'ncvar'
   if theNCid >= 0
      theVarid = varid(self);
      [theName, theType, theNdims, theDimids, theNatts, status] = ...
            ncmex('varinq', theNCid, theVarid);
  else
     s = struct(self);
     theType = s.itsVartype;
     status = 0;
  end
case 'ncatt'
   if theNCid >= 0
      theVarid = varid(self);
      theAttname = name(self);
      [theType, theLen, status] = ...
            ncmex('attinq', theNCid, theVarid, theAttname);
  else
     s = struct(self);
     theType = s.itsVartype;
     status = 0;
  end
otherwise
   theType = 'unknown';
   status = -1;
   warning(' ## Illegal syntax.')
end
   
if status >= 0 & ~isstr(theType)
   theType = theTypes{theType};
end

result = theType;

if nargout > 0
   theResult = result;
else
   disp(result)
end
