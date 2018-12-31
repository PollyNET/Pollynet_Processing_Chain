function theResult = subsref(self, theStruct)

% ncdim/subsref -- Overloaded "{}", ".", and "()" operators.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncdim" object referenced on
%   the righthand side of an assignment, specifically
%   the single case of result = self(:), which returns
%   the value of the dimension.

% Also see: ncdim/subsasgn.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

if length(theStruct) < 1
   result = self;
   if nargout > 0
      theResult = result;
   else
      disp(theResult)
   end
   return
end

result = [];

theNCid = ncid(self);
theDimid = dimid(self);
[ignore, theSize] = ncmex('diminq', theNCid, theDimid);
   
s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell'), theSubs = theSubs{1}; end

switch theType
case '()'   % Attribute data: self(...)
   switch theSubs
   case ':'
      result = theSize;
   otherwise
   warning([' ## Illegal syntax: "' theSubs '"'])
   end
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(theResult)
end
