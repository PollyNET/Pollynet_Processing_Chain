function theResult = varid(self, theVarid)

% ncitem/varid -- Variable id of an ncitem.
%  varid(self) returns the variable id of self,
%   an "ncitem" object.
%  varid(self, theVarid) sets the varid of self
%   to theVarid and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 11:17:56.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = self.itsVarid;
else
   self.itsVarid = theVarid;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
