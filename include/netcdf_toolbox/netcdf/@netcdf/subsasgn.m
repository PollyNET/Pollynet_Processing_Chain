function theResult = subsasgn(self, theStruct, other)

% netcdf/subsasgn -- Assignment with "{}", "()", and ".".
%  subsasgn(self, theStruct, other) is called whenever
%   self is used with subindexing on the left-side of
%   an assignment, as in self{...} = other, for
%   self, a "netcdf" object.

% Also see: netcdf/subsref.

if nargin < 1, help(mfilename), return, end

if length(theStruct) < 1
   result = other;
   if nargout > 1
      theResult = result;
   else
      disp(result)
   end
   return
end

result = [];

self = ncregister(self);

if length(theStruct) < 1
   result = other;
   if nargout >  0, theResult = result; end
   return
end

s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

theAutoscaleflag = 0;
if isa(theSubs, 'cell')
   if length(theSubs) > 1
      theAutoscaleflag = isequal(theSubs{2}, 1);
   end
   theSubs = theSubs{1};
end

switch theType
case '{}'   % Variable by name or index: self(theVarindex)...(...).
   theVarname = theSubs;
   if length(s) < 1 & ...
         (isa(other, 'cell') | isa(other, 'char') | isa(other, 'double'))
      if ~isempty(other)
         if isa(other, 'char'), other = {other}; end
         switch other{1}
         case {'byte', 'char', 'short', 'int', 'long', 'float', 'double'}
            % Okay as is.
         otherwise
            other = [{'double'} other(:).'];
         end
         theVartype = other{1};
         theVardims = other;
         theVardims(1) = [];
         result = ncvar(theVarname, theVartype, theVardims, self);
			if ~isempty(result)
         	result = autoscale(result, theAutoscaleflag);
			end
         result = self;
      else
         theVar = ncvar(theVarname, self);
         if ~isempty(theVar)
            result = delete(theVar);   % Delete.
         end
      end
         result = self;
   elseif isa(other, 'ncvar') & ncid(other) < 0
      other = name(other, theVarname);
      result = (self < other);
      result = self;
   else
      v = var(self, theVarname);
		if ~isempty(v)
      	v = autoscale(v, theAutoscaleflag);
		end
      result = subsasgn(v, s, other);
      result = self;
   end
case '()'   % Record by index 1..nrecs: self(theRecindex).
   switch ncclass(theSubs)
   case 'char'   % Dimension by name: self('theDimname').
      theDimname = theSubs;
      if ~isempty(other)
         result = ncdim(theDimname, other, self);
      else
         theDim = ncdim(theDimname, self);
         result = delete(theDim);
      end
      result = self;
   case 'double'   % Record by index 1..nrecs: self(theRecindex).
      theRecindices = theSubs;
      result = rec(self, theRecindices, other, theAutoscaleflag);
      result = self;
   otherwise
      warning(' ## Illegal syntax.')
   end
case '.'   % Global attribute by index: self.theAttname(...).
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
   if length(s) < 1 & isa(other, 'cell') & length(other) == 2
      theAtttype = other{1};
      theAttvalue = other{2};
      result = ncatt(theAttname, theAtttype, theAttvalue, self);
   elseif length(s) < 1
      if ~isempty(other)
         result = ncatt(theAttname, ncclass(other), other, self);
      else
         theAtt = ncatt(theAttname, self);
         if ~isempty(theAtt)
            result = delete(theAtt);   % Delete.
         end
      end
   else
      result = subsasgn(att(self, theAttname), s, other);
   end
   result = self;
otherwise
   warning([' ## Illegal syntax: "' theType '"'])
end

if nargout >  0
   theResult = result;
else
   ncans(result)
end
