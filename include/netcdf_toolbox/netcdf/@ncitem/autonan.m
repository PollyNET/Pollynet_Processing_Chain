function theResult = autonan(self, theAutoNaNFlag)

% ncitem/autonan -- Set/get auto-NaN flag.
%  autonan(self) returns the auto-NaN flag of self.
%   When TRUE, ncvar objects will convert their fill-value
%   elements to NaNs on reading, and convert NaNs back to
%   the fill-value on writing to the file.
%  autonan(self, theAutoNaNFlag) sets the auto-NaN flag
%   and returns self.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Dec-1998 09:52:41.
% Updated    09-Aug-1999 16:18:10.

if nargin < 1, help(mfilename), return, end

if nargin == 1
	result = ~~self.itIsAutoNaNing;
else
	self.itIsAutoNaNing = ~~theAutoNaNFlag;
	result = self;
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
