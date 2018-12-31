function theResult = subsasgn(self, theStruct, other)

% ncatt/subsasgn -- Overloaded "()" operator.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncatt" object referenced on
%   the lefthand side of an assignment, as in self(i:j)
%   = other, self(i:j:k) = other, or self(:) = other.

% See also: ncatt/subsref.
 
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

if isa(other, 'ncitem'), other = other(:); end

theNetCDF = parent(parent(self));
theNCid = ncid(self);
theVarid = varid(self);
theAttname = name(self);
if strcmp(theAttname, 'FillValue')
   theAttname = '_Fillvalue';
   theAtttype = datatype(ncvar('', theNCid, -1, theVarid));
	[ignore, theAttlen, status] = ...
      	ncmex('attinq', theNCid, theVarid, theAttname);
else
	[theAtttype, theAttlen, status] = ...
      	ncmex('attinq', theNCid, theVarid, theAttname);
end
if status < 0, theAtttype = class(other); end

theAttvalue = self(:);
if isstr(theAttvalue)   % Undo escaped-zeros, if any.
   theAttvalue = strrep(theAttvalue, '\0', setstr(0));
end

theDatatype = datatype(self);
theTypelen = ncmex('typelen', theDatatype);
isUnsigned = unsigned(self);

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell'), theSubs = theSubs{1}; end

switch theType
case '()'
   if isempty(other) & length(theSubs) == 1 & strcmp(theSubs{1}, ':')
      result = delete(self);   % Delete.
      if nargout >  0
         theResult = result;
      else
         disp(result)
      end
      return
   end
otherwise
end

switch theType
case '()'   % Attribute data: self(...)
   switch theSubs
   case ':'
      if isstr(other), other = strrep(other, '\0', setstr(0)); end
      theAttvalue = other;
   otherwise
      if isstr(other), other = strrep(other, '\0', setstr(0)); end
      theAttvalue(theSubs) = other;
   end
   if isstr(theAttvalue)
      theAttvalue = strrep(theAttvalue, '\0', setstr(0));
   end
	if isUnsigned & prod(ncsize(self)) > 0
		nBits = 8*theTypelen;
		i = (theAttvalue >= 2^(nBits-1));
		theAttvalue(i) = theAttvalue(i) - 2^nBits;
	end
   status = ...
      ncmex('attput', theNCid, theVarid, theAttname, ...
                       theAtttype, -1, theAttvalue);
   if status < 0
      theNetCDF = redef(theNetCDF);
      status = ...
         ncmex('attput', theNCid, theVarid, theAttname, ...
                          theAtttype, -1, theAttvalue);
   end
   result = self;
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(theResult)
end
