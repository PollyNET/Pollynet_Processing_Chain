function theResult = options(self, theOptions)

% ncitem/options -- Set netcdf options.
%  options(self, theOptions) sets theOptions in the
%   current netcdf interface and returns the original
%   option settings.
%  options(self) returns the current netcdf options.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:54:12.

if nargin < 1, help(mfilename), return, end

if nargin < 2
   result = ncmex('setopts');
  else
   result = ncmex('setopts', theOptions);
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
