function theResult = autoscale(self, theAutoscale)

% ncitem/autoscale -- Auto-scale flag of an ncitem.
%  autoscale(self) returns the auto-scale flag of self,
%   an ncitem object.
% autoscale(self, theAutoscale) sets the auto-scale flag
%   to theAutoscale and returns self.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:42:01.
% Updated    09-Aug-1999 16:18:59.

if nargin < 1, help(mfilename), return, end

result = [];

if nargin == 1
   result = ~~self.itIsAutoscaling;
else
   self.itIsAutoscaling = ~~theAutoscale;
   result = self;
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
