function theResult = name(self, theNewName)

% ncitem/name -- Name of the NetCDF item.
%  name(self) returns the name of self, an ncitem object.
%  name(self, theNewName) renames self to theNewName and
%   returns self.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:51:50.

if nargin < 1, help(mfilename), return, end

result = '';

if nargin > 1
   if ncid(self) >= 0
      switch ncclass(self)
      case {'ncdim', 'ncvar', 'ncatt'}
         self = rename(self, theNewName);
         if isa(self, 'ncatt'), self.itsName = theNewName; end
      otherwise
         warning(' ## Illegal syntax.')
      end
     else
      self.itsName = theNewName;
   end
end

result = self.itsName;

if ~isempty(self) & ncid(self) >= 0
   switch ncclass(self)
   case 'netcdf'
      self = ncregister(self);
      result = self.itsName;
      status = 0;
   case 'ncdim'
      if dimid(self) >= 0
         [theDimname, theDimsize, status] = ...
            ncmex('diminq', ncid(self), dimid(self));
         if status >= 0, result = theDimname; end
      end
   case 'ncvar'
      if varid(self) >= 0
         [theVarname, theVartype, theVarndims, theVardims, ...
            theVarnatts, status] = ...
            ncmex('varinq', ncid(self), varid(self));
         if status >= 0, result = theVarname; end
      end
   case 'ncatt'
      if attnum(self) >= 0
         theAttname = self.itsName;
         [theAtttype, theAttlen, status] = ...
            ncmex('attinq', ncid(self), varid(self), theAttname);
         if status >= 0, result = theAttname; end
      end
   case 'ncitem'
      result = '';
      if ncid(self) >= 0
         if dimid(self) >= 0
            [theDimname, theDimsize, status] = ...
               ncmex('diminq', ncid(self), dimid(self));
            if status >= 0, result = theDimname; end
           elseif varid(self) >= 0 & attnum(self) < 0
            [theVarname, theVartype, theVarndims, theVardims, ...
               theVarnatts, status] = ...
               ncmex('varinq', ncid(self), varid(self));
            if status >= 0, result = theVarname; end
           elseif attnum(self) >= 0
            theAttname = self.itsName;
            [theAtttype, theAttlen, status] = ...
               ncmex('attinq', ncid(self), varid(self), theAttname);
            if status >= 0, result = theAttname; end
           else
            result = self.itsName;
         end
      end
   otherwise
      warning([' ## Illegal operation.'])
   end
end

self.itsName = result;

if nargin > 1, result = self; end

if nargout > 0
   theResult = result;
  elseif nargin < 2
   disp(result)
end
