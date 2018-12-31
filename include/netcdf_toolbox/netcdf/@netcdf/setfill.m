function theResult = setfill(self, theFillMode)

% netcdf/setfill -- Set the NetCDF fill-mode.
%  setfill(self, theFillMode) sets the fill-mode of the
%   NetCDF file represented by self, a "netcdf" object.
%   The modes are 'fill' [default] or 'nofill'.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 02-Sep-1997 11:08:44.

if nargin < 1, help(mfilename), return, end

self = ncregister(self);

if nargout > 0 & nargin < 2
   theResult = self.itsFillMode;
   return
end

if nargin < 2, theFillMode = 'fill'; end

result = [];

switch theFillMode
case 0
   theFillMode = 'nofill';
case 1
   theFillMode = 'fill';
end

result = ncmex('setfill', ncid(self), theFillMode);
if result >= 0, self.itsFillMode = theFillMode; end

ncregister(self)

if nargout > 0, theResult = result; end
