function theResult = dimid(self, theDimid)

% ncitem/dimid -- Dimid of an ncitem.
%  dimid(self) returns the dimension of of self,
%   an "ncitem" object.
% dimid(self, theDimid) sets the dimension id
%   of self to theDimid and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:44:27.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = self.itsDimid;
else
   self.itsDimid = theDimid;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
