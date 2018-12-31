function theResult = endef(self)

% netcdf/endef -- Disable the NetCDF "define" mode.
%  endef(self) disables the "define" mode of the netCDF
%   file associated with self, a netcdf object.  Use
%   redef(self) to enable the "define" mode.  Self is
%   returned with 'itsDefineMode' field set to 'define'
%   or 'data'.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end

result = redef(self, 'data');

if nargout > 0, theResult = result; end
