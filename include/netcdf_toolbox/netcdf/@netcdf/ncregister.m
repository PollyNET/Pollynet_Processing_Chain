function theResult = ncregister(self, theValue)

% netcdf/ncregister -- Register a netcdf object.
%  theResult = ncregister(self) returns the current
%   registry entry for self, a "netcdf" object.
%  ncregister(self, theValue) registers self as theValue,
%   either self on "open" or [] on "close".
%  ncregister(self) calls "ncregister(self, self)" to
%   place self in the registry.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Aug-1997 10:22:21.

global NETCDF_REGISTRY
global NETCDF_INITIALIZED

theRegistryIndex = ncid(self) + 1;

if nargout > 0
   if theRegistryIndex > 0
      theResult = NETCDF_REGISTRY{theRegistryIndex};
   else
      theResult = [];
   end
else
   if nargin < 2, theValue = self; end
   if theRegistryIndex > 0
      NETCDF_REGISTRY{theRegistryIndex} = theValue;
   end
end

if isempty(NETCDF_INITIALIZED)
   NETCDF_INITIALIZED = 1;
   ncquiet
end
