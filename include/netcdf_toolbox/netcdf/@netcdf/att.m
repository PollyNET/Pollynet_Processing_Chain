function theResult = att(self, theAttname)

% netcdf/att -- Attributes of a netcdf object.
%  att(self, 'theAttname') returns the ncatt object
%   whose name is theAttname, associated with self,
%   a netcdf object.
%  att(self) returns the cell-list of ncatt objects
%   associated with self, a netcdf object.

if nargin < 1, help netcdf/att, return, end

result = [];

if nargin == 1
   [ndims, nvars, ngatts, recdim, status] = ...
         ncmex('inquire', ncid(self));
   result = cell(1, ngatts);
   for i = 1:ngatts
      theAttnum = i-1;
      [theAttname, status] = ...
            ncmex('attname', ncid(self), varid(self), theAttnum);
      result{i} = ncatt(theAttname, self);
   end
  else
   result = ncatt(theAttname, self);
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
