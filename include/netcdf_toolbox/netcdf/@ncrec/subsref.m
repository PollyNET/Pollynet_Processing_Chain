function theResult = subsref(self, theStruct)

% ncrec/subsref -- Overloaded subscriting for ncrec.
%  subsref(self, theStruct) processes subscript references to self,
%   an "ncrec" object.  The basic syntax is self(theRecindex), which
%   returns the record-data struct corresponding to theRecindex.  If
%   theRecindex == 0, the struct contains all zeros, for use as a
%   template.  The syntax can be extended with a valid field name
%   and indices, as in "self(10).field(1:20, 2:2:30)".

% Also see: ncatt/subsasgn.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 16:01:38.

if nargin < 1, help(mfilename), return, end

result = [];

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell'), theSubs = theSubs{1}; end

switch theType
case '()'
   theRecindex = theSubs;
   theVars = self.itsVars;
   theVarData = cell(1, length(theVars));
   theVarName = cell(1, length(theVars));
   for i = 1:length(theVars)
      theVarName{i} = name(theVars{i});
      if theRecindex > 0
         theVarData{i} = theVars{i}(theRecindex, :);
      else
         theSize = ncsize(theVars{i});
         if length(theSize) == 1, theSize = [theSize 1]; end
         if length(theSize) == 2, theSize = [theSize 1]; end
         theVarData{i} = zeros(theSize(2:length(theSize)));
      end
   end
   result = cell2struct(theVarData, theVarName, 2);
   for i = 1:length(s)
      if ~iscell(s(i).subs), s(i).subs = {s(i).subs}; end
   end
   switch length(s)
   case 0
   case 1
      result = getfield(result, s(1).subs)
   case 2
      result = getfield(result, {1}, s(1).subs, s(2).subs)
   otherwise
      warning([' ## Illegal syntax: Too many substripts.'])
   end
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
