function theResult = fillval(self, theNewFillValue)

% ncvar/fillval -- Get or set _FillValue of a netcdf variable.
%  fillval(self) returns the value of the _FillValue
%   attribute of self, an ncvar object.
%  fillval(self, theNewFillValue) sets the _FillValue
%   attribute of self, an ncvar object, to theNewFillValue.
%   The type of the fill value is set to the type of the
%   netcdf variable.  The resulting ncatt object is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

if nargin < 2
   theAtt = ncatt('_FillValue', self);
   result = theAtt(:);
  else
   theVartype = datatype(self);
   theAtttype = theVartype;
   theAtt = ncatt('_FillValue', theAtttype, theNewFillValue, self);
   result = theAtt;
end

if nargout > 0
   theResult = result;
  elseif nargin < 2
   disp(result)
end
