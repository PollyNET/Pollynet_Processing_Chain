function theResult = recdimid(self, theRecdimid)

% ncitem/recdimid -- Recdimid of an ncitem.
%  recdimid(self) returns the record-dimension id
%   of self, an "ncitem" object.
%  recdimid(self, theRecdimid) sets the record-dimension
%   id of self to theRecdimid and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:44:27.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin < 2
   result = self.itsRecdimid;
else
   self.itsRecdimid = theRecdimid;
   result = self;
   if isa(result, 'netcdf')
      ncregister(result)
      result = ncregister(result);
   end
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
