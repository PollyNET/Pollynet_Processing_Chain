function theResult = rename(self, theNewName)

% ncitem/rename -- Rename a NetCDF entity.
%  rename(self, theNewName) renames the NetCDF entity
%   associated with self, an object derived from the
%   ncitem class,  to theNewName.  The updated self is
%   returned.
%
% Also see: ncitem/name.
%
%  THIS IS A PRIVATE FUNCTION: Do not call this function
%   directly; use name(self, theNewName) instead.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 10:00:41.

if nargin < 2, help(mfilename), return, end

result = [];

theNCid = ncid(self);

switch class(self)
case {'ncdim'}
   theDimid = dimid(self);
   status = ncmex('dimrename', theNCid, theDimid, theNewName);
   if status < 0
      status = ncmex('redef', theNCid);
      if status >= 0
         status = ncmex('dimrename', theNCid, theDimid, theNewName);
         status = ncmex('endef', theNCid);
      end
   end
case {'ncvar'}
   theVarid = varid(self);
   status = ncmex('varrename', theNCid, theVarid, theNewName);
   if status < 0
      status = ncmex('redef', theNCid);
      if status >= 0
         status = ncmex('varrename', theNCid, theVarid, theNewName);
         status = ncmex('endef', theNCid);
      end
   end
case {'ncatt'}
   theVarid = varid(self);
   theAttname = name(self);
   status = ncmex('attrename', theNCid, theVarid, theAttname, theNewName);
   if status < 0
      status = ncmex('redef', theNCid);
      if status >= 0
         status = ncmex('attrename', theNCid, theVarid, theAttname, theNewName);
         status = ncmex('endef', theNCid);
      end
   end
otherwise
   status = -1;
   warning(' ## Illegal syntax.')
end

if status >= 0, self.itsName = theNewName; end

result = self;

if nargout > 0, theResult = result; end
