function theResult = open(self, thePermission)

% netcdf/open -- Open the file of a netcdf object.
%  open(self, 'thePermission') opens the NetCDF file
%   associated with self, a netcdf object, using
%   thePermission, either 'write' or 'nowrite' (default).
%   The object (self) is returned.  This routine can
%   be used to re-open a NetCDF file, using the
%   permission already established in self from a
%   previous invocation.

if nargin < 1, help(mfilename), return, end
if nargin < 2
   thePermission = self.itsPermission;
   if isempty(thePermission)
      thePermission = 'nowrite';
   end
end

[theNCid, status] = ncmex('open', name(self), thePermission);

if status >= 0
   w = which(name(self));
   if ~isempty(w), self = name(self, w); end
   self = ncid(self, theNCid);
   self.itsPermission = thePermission;
   self.itsDefineMode = 'data';
   [ndims, nvars, ngatts, theRecdimid, status] = ...
         ncmex('inquire', ncid(self));
   if status >= 0, self = recdimid(self, theRecdimid); end
   ncregister(self)
   self = ncregister(self);
end

result = self;

if nargout > 0, theResult = result; end
