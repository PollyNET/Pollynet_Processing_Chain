function theResult = abort(self)

% netcdf/abort -- Abort recent definitions in the NetCDF file.
%  abort(self) aborts recent definitions in the NetCDF
%   file represented by self, a netcdf object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 29-Jul-1997 09:36:10.

if nargin < 1, help(mfilename), return, end

status = ncmex('abort', ncid(self));

result = self;

if nargout > 0, theResult = result; end
