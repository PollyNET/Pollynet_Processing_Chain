function [theSrc, theDst] = subs(self, theSrcsubs, theDstsubs)

% ncvar/subs -- Manipulate origin.
%  [{theSrcsubs}, {theDstsubs}] = subs(self) returns the "src"
%   and "dst" subscripts of self, a composite "ncvar" object.
%  subs(self, {theSrcsubs}, {theDstsubs}) sets the "src" and
%   "dst" subscripts of self to the given structs.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 29-Sep-1997 09:33:06.

if nargin < 1, help(mfilename), return, end

if nargin == 1
	src = self.itsSrcsubs;
	dst = self.itsDstsubs;
    if isempty(src), src = {}; end
    if isempty(dst), dst = {}; end
elseif nargin > 1
	self.itsSrcsubs = theSrcsubs;
    if nargin > 2
	    self.itsDstsubs = theDstsubs;
    end
    result = self;
end

if nargout > 0
    if nargin > 1
        theSrc = result;
    else
        theSrc = src;
        theDst = dst;
    end
else
	ncans([src dst]);
end
