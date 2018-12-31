function theSuperObject = Super(theObject)

% Super -- Super-object of an object.
%  Super(theObject) returns the super-object
%   of theObject, or [] if none exists.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Apr-1997 16:51:36.

if nargin < 1, help(mfilename), return, end

if isobject(theObject)
   theStruct = struct(theObject);
  else
   theStruct = theObject;
end

f = fieldnames(theStruct);
if ~isempty(f)
   s = getfield(theStruct, f{length(f)});
   if ~isobject(s), s = []; end
end

if nargout > 0
   theSuperObject = s;
  else
   disp(s)
end
