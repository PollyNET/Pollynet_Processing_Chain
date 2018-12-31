function theResult = mode(self)

% ncitem/mode -- Define/data mode.
%  mode(self) returns the "define/data" mode of
%   the "netcdf" object associated with self,
%   an object derived from "ncitem".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Aug-1997 10:43:29.

if nargin < 1, help(mfilename), return, end

theParent = mode(parent(parent(self)));

if nargout > 0
   theResult = result;
else
   disp(result)
end
