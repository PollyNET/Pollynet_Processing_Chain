function theResult = recnum(self, theRecnum)

% ncitem/recnum -- Record number of an ncitem.
%  recnum(self) returns the current record number
%   of self, an ncitem object.
%  recnum(self, theRecnum) sets the recnum to theRecnum
%   and returns self.
 
% Version of 07-Aug-1997 09:59:52.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = self.itsRecnum;
else
   self.itsRecnum = theRecnum;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
