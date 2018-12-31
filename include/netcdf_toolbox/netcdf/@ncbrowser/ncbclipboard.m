function theResult = NCBClipboard(self)

% NCBrowser/NCBClipboard -- NetCDF Browser clipboard file name.
%  NCBClipboard(self) returns the full-path name of
%   the NetCDF Browser clipboard file.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 08-May-1997 10:54:11.

if nargin < 1, help(mfilename), return, end

if nargout > 0, theResult = ''; end

w = which(mfilename);
if any(w)
   w(length(w)) = '';
   w = [w 'nc'];
end

if nargout > 0
   theResult = w;
  else
   disp(w)
end
