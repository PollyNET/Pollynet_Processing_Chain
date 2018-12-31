function theResult = permission(self)

% netcdf/permission -- Create/open permission of a netcdf file.
%  permission(self) returns the "create/open" permission
%   of self, a "netcdf" object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Aug-1997 10:43:29.

if nargin < 1, help(mfilename), return, end

self = ncregister(self);

result = self.itsPermission;

if nargout > 0
   theResult = result;
else
   disp(result)
end
