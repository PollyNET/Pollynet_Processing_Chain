function theResult = subsref(self, theStruct)

% netcdf/subsref -- Overloaded "{}", "()", and "." operators.
%  subsref(self, theStruct) processes subscripting references
%   of self, a "netcdf" object, as follows:
%   If the first operator, contained in theStruct(1).type,
%   is '{}', as in {'theVarname'} or {theVarindex}, the rest
%   of theStruct is passed to the subsref function of the
%   corresponding ncvar object managed by self.
%   If the first operator is '()', as in ('theDimname'), the
%   corresponding named ncdim object of self is processed.
%   If the first operator is '.', as in .theAttname, the
%   corresponding named global attribute object of self is
%   processed.

% Also see: netcdf/subsasgn.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 

global nctbx_options;

%
% Check to see if we already set the autoscale flag.  Isn't this
% just terrific code?
if isempty ( nctbx_options )

	%
	% Just use a default of zero (no autoscale).
	theAutoscaleflag = 0;

else
	if isfield ( nctbx_options, 'theAutoScale' )
		theAutoScaleflag = nctbx_options.theAutoScale;
	else

		%
		% Just use a default of zero (no autoscale).
		theAutoScaleflag = 0;
	end
end


if nargin < 1, help(mfilename), return, end

result = [];

self = ncregister(self);

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

if isa(theSubs, 'cell')
   if length(theSubs) > 1
      theAutoscaleflag = isequal(theSubs{2}, 1);
   end
   theSubs = theSubs{1};
end

switch theType
case '{}'   % Variable by name or index.
   switch class(theSubs)
   case 'char'   % Variable by name: self{'theVarname'}.
      theVarname = theSubs;
      result = var(self, theVarname);
      if ~isempty(result)
         %result = autoscale(result, theAutoscaleflag);
         result = subsref(result, s);
      end
   case 'double'   % Variable by index 1..nvars: self{theVarindex}.
      theVarindex = theSubs;
      result = var(self, theVarindex);
      if ~isempty(result)
         result = autoscale(result, theAutoscaleflag);
         result = subsref(result, s);
      end
   otherwise
      warning(' ## Illegal syntax.')
   end
case '()'   % Dimension by name; record by index.
   switch class(theSubs)
   case 'char'   % Dimension by name: self('theDimname').
      theDimname = theSubs;
      result = dim(self, theDimname);
      if ~isempty(result), result = subsref(result, s); end
   case 'double'   % Record by index 1..nrecs: self(theRecindex).
      theRecindex = theSubs;
      result = rec(self, theRecindex);
   otherwise
      warning(' ## Illegal syntax.')
   end
case '.'   % Global attribute by name: self.theAttname(...)
   theAttname = theSubs;
   while length(s) > 0   % Dotted name.
      switch s(1).type
      case '.'
         theAttname = [theAttname '.' s(1).subs];
         s(1) = [];
      otherwise
         break
      end
   end
   result = att(self, theAttname);
   if ~isempty(result), result = subsref(result, s); end
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
