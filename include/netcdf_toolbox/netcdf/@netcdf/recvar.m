function theResult = recvar(self)

% netcdf/recvar -- Record-variables of a netcdf object.
%  recvar(self) returns a cell-list of the ncvar objects
%   that correspond to the record-variables of self, a
%   "netcdf" object.  A record-variable is one whose leftmost
%   dimension is the recdim(self).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:29:39.

if nargin < 1, help(mfilename), return, end

result = [];
if nargout > 0, theResult = result; end

theRecdim = recdim(self);
if isempty(theRecdim), return, end

theRecdimid = dimid(theRecdim);

theVars = var(self);
for i = length(theVars):-1:1
   theDims = dim(theVars{i});
   if length(theDims) < 1 | ...
         dimid(theDims{1}) ~= theRecdimid
      theVars(i) = [];
   end
end

result = theVars;

if nargout > 0
   theResult = result;
  else
   disp(result)
end
