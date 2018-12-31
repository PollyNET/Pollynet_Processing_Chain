function theResult = subsref(self, theStruct)

% ncatt/subsref -- Overloaded "{}", ".", and "()" operators.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncatt" object referenced on
%   the righthand side of an assignment, such as in
%   result = self(...).

% Also see: ncatt/subsasgn.
 
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
theVarid = varid(self);
theAttname = name(self);
theDatatype = datatype(self);
theTypelen = ncmex('typelen', theDatatype);
isUnsigned = unsigned(self);

if length(theStruct) == 1
   s = theStruct;
   theType = s(1).type;
   theSubs = s(1).subs;
   s(1) = [];
   if theNCid >= 0
       switch ( theDatatype )
        case 'char'
            [result, status] = mexnc('get_att_text', theNCid, theVarid, theAttname);
       otherwise
            [result, status] = mexnc('get_att_double', theNCid, theVarid, theAttname);
       end

      %[result, status] = ncmex('attget', theNCid, theVarid, theAttname);
      if status >= 0 & isstr(result)
         result = strrep(result, setstr(0), '\0');
      end
   else
      result = self.itsAttvalue;
   end
   switch theType
   case '()'   % Attribute data: self(...)
      if isa(theSubs, 'cell'), theSubs = theSubs{1}; end
      switch class(theSubs)
      case 'char'
         switch theSubs
         case ':'
         otherwise
            warning(' ## Illegal syntax.')
         end
      case 'double'
         result = result(theSubs);
      otherwise
         warning([' ## Illegal syntax: "' theSubs '"'])
      end
		if isUnsigned & prod(size(result)) > 0
			result(result < 0) = 2^(8*theTypelen) + result(result < 0);
		end
   otherwise
      warning(' ## Illegal syntax.')
   end
else
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(theResult)
end
