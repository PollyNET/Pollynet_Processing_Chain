function theResult = ncid(self, theNCid)

% ncitem/ncid -- Id of the owner of an ncitem object.
%  ncid(self) returns the ncid of the "netcdf"
%   object that owns self, an "ncitem" object.
%  ncid(self, theNCid) sets the ncid of self to theNCid
%   and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:53:00.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = self.itsNCid;
elseif nargin == 2
   self.itsNCid = theNCid;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
