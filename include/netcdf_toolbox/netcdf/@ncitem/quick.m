function theResult = quick(self, theQuickFlag)

% ncitem/quick -- Set/Get "quick" flag.
%  quick(self) returns the "quick" flag of self,
%   an "ncitem" object.  When TRUE, the flag forces
%   faster, vanilla-flavored I/O for variables.
%   See help on "ncvar/subsref" and "ncvar/subsasgn".
%  quick(self, theQuickFlag) sets the "quick" flag
%   to theQuickFlag.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jul-1999 15:10:58.
% Updated    19-Jul-1999 16:34:07.

if nargin < 1, help(mfilename), return, end

if nargin < 2
	result = self.itIsQuick;
else
	result = self;
	result.itIsQuick = ~~theQuickFlag;
end

if nargout > 0
	theResult = result;
else
	ncans(result)
end
