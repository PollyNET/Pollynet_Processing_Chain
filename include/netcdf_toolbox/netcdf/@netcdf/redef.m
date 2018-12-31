function theResult = redef(self, theDefineMode)

% netcdf/redef -- Set the NetCDF "define mode".
%  redef(self) enables the "define" mode of the NetCDF
%   file associated with self, a netcdf object.  Use
%   endef(self) to revert to 'data' mode.  Self is
%   returned, with 'itsDefineMode' set to 'define'.
%  redef(self, theDefineMode) sets the "define" mode of
%   the file to theDefineMode ('define' or 'data') and
%   returns self.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:30:58.

if nargin < 1, help(mfilename), return, end

if nargin < 2, theDefineMode = 'define'; end

self = ncregister(self);

switch theDefineMode
case 'define'
   status = ncmex('redef', ncid(self));
   self.itsDefineMode = theDefineMode;
case 'data'
   status = ncmex('endef', ncid(self));
   self.itsDefineMode = theDefineMode;
otherwise
end

ncregister(self)
result = ncregister(self);

if nargout > 0, theResult = result; end
