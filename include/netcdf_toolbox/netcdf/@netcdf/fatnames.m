function theResult = fatnames(self, theMaxNameLen)

% netcdf/fatnames -- Enable fat-names.
%  fatnames(f, theMaxNameLen) makes provision in self,
%   a "netcdf" object, for the storage of names up to the
%   given maximum length (not to exceed the MAX_NC_NAME
%   parameter).  The purpose is to allow for the later
%   renaming of NetCDF items without forcing the rewriting
%   of the NetCDF file itself whenever a new name exceeds
%   the length of the original.  Set theMaxNameLen to 0
%   (zero) to disable the feature (the default behavior).
%   The "netcdf" object is returned.
%  fatnames(f) returns the present "fatnames" length.
%
% N.B. This routine is experimental at present.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-May-1999 08:46:20.

if nargin < 1, help(mfilename), return, end

self = ncregister(self);

if nargin < 2
	result = self.itsMaxNameLen;
else
	result = self;
	max_nc_name = ncmex('parameter', 'MAX_NC_NAME');
	result.itsMaxNameLen = min(max(theMaxNameLen, 0), max_nc_name);
	ncregister(result)
end

if nargout > 0
	theResult = result;
else
	disp(result);
end
