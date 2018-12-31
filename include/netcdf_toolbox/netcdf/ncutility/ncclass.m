function theResult = ncclass(theItem)

% NCClass -- Class of an item.
%  NCClass(theItem) returns the class of theItem.
%   This function provides continuity with the
%   ncitem/ncclass method.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 20-May-1997 07:23:32.

result = class(theItem);

if nargout > 0
   theResult = result;
  else
   disp(result)
end
