function theResult = attnum(self, theAttnum)

% ncitem/attnum -- Attribute number of an ncitem.
%  attnum(self) returns the attribute number of self,
%   an "ncitem" object.
%  attnum(self, theAttnum) sets the attnum of self
%   to theAttnum and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:34:31.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = self.itsAttnum;
else
   self.itsAttnum = theAttnum;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
