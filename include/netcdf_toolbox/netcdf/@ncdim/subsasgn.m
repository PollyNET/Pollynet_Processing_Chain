function theResult = subsasgn(self, theStruct, other)

% ncdim/subsasgn -- Overloaded "()" operator.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncdim" object referenced
%   on the left-hand side of an assignment, as in
%   "self(:) = other".  If "other" is [] (empty-matrix),
%   the dimension and all its associated variables are
%   deleted.  If "other" is a scalar, the dimension is
%   resized to that value.

% Also see: ncdim/subsref.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1, help(mfilename), return, end

if length(theStruct) < 1   % Never happens.
   result = other;
   if nargout > 1
      theResult = result;
   else
      disp(result)
   end
   return
end
   
result = [];

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];
if ~isa(theSubs, 'cell'), theSubs = {theSubs}; end

switch theType
case '()'
   if length(theSubs) == 1 & strcmp(theSubs{1}, ':')
		if isempty(other)
      	result = delete(self);   % Delete.
		elseif isa(other, 'double') & length(other) == 1
			result = resize(self, other);   % Resize.
		end
   end
otherwise
end

if nargout >  0
   theResult = result;
else
   disp(result)
end
