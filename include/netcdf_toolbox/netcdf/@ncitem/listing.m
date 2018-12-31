function theResult = listing(self)

% ncitem/listing -- Listing of value.
%  listing(self) lists the value of self,
%   an object derived from "ncitem".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:51:07.

if nargin < 1, help(mfilename), return, end

theNameOfSelf = name(self);
if strcmp(theNameOfSelf, '_FillValue')
   theNameOfSelf = 'FillValue_';
end
x = self(:);

disp(' '), disp(' ')
disp([theNameOfSelf ' =']), disp(' ')
disp(x)

if nargout > 0
   theResult = x;
end
