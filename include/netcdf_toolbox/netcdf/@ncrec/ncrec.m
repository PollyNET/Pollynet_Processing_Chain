function self = ncrec(theNetcdf, theAutoscaleflag)

% ncrec/ncrec -- Constructor for ncrec class.
%  ncrec(theNetcdf, theAutoscaleflag) allocates a new ncrec
%   object for the current record-variables associated with
%   theNetcdf, a netcdf object.  The result is assigned
%   silently to "ans" if no output argument is given.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

if nargout > 0, self = []; end

if nargin < 2, theAutoscaleflag = 0; end

theRecdim = recdim(theNetcdf);
if ~isempty(theRecdim)
   theRecdimid = dimid(theRecdim);
else
   if nargout < 1, ncans(self), end
   return
end

theVars = var(theNetcdf);
for i = length(theVars):-1:1
   theDims = dim(theVars{i});
   if length(theDims) < 1 | ...
         dimid(theDims{1}) ~= theRecdimid
      theVars(i) = [];
     else
      theVars{i} = autoscale(theVars{i}, theAutoscaleflag);
   end
end

theStruct.itsVars = theVars;

theNCid = ncid(theNetcdf);

result = class(theStruct, 'ncrec', ncitem('', theNCid));

if nargout > 0
   self = result;
else
   ncans(result)
end
