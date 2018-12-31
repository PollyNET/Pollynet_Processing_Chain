function theResult = sync(self)

% netcdf/sync -- Synchronize the NetCDF file.
%  sync(self) synchronizes the NetCDF file
%   represented by self, a netcdf object.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

status = ncmex('sync', ncid(self));

result = self;

if nargout > 0, theResult = result; end
