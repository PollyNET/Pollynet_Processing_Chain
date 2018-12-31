function theResult = subsasgn(self, theStruct, other)

% ncrec/subsasgn -- Overloaded assignment for ncrec.
%  subsasgn(self, theStruct, other) processes the
%   subscripted assignment for self, an "ncrec" object.
%   The self is returned.  The only allowed syntax
%   is self(theRecindices) = theRecs, for an array
%   of record-structures.

% Also see: ncrec/subsref.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 16:01:38.

if nargin < 3, help(mfilename), return, end

result = [];

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell'), theSubs = theSubs{1}; end

% N.B. Should be expanded to "self(...).field(...)" syntax.
%  The ncrec/subsref method already complies.

switch theType
case '()'
   theRecindices = theSubs;
   theVars = self.itsVars;
   if isa(other, 'cell'), other = other{1}; end
   theRecs = other;
   theFields = fieldnames(theRecs);
   for k = 1:length(theVars)
      for j = 1:length(theRecindices)
         if theRecindices(j) > 0
            for i = 1:length(theFields)
               if strcmp(name(theVars{k}), theFields{i})
                  a = ['theVars{k}(' int2str(theRecindices(j)) ', :)' ...
                       ' = theRecs(' int2str(j) ').' theFields{i} ';'];
                  eval(a);
               end
            end
         end
      end
   end
   result = self;
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
