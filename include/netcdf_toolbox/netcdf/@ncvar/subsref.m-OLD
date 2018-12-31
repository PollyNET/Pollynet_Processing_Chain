function theResult = subsref(self, theStruct)

% ncvar/subsref -- Overloaded "{}", ".", and "()" operators.
%  subsref(self, theStruct) processes the subscripting
%   operator () for self, an "ncvar" object referenced on
%   the righthand side of an assignment, such as in
%   result = self(i, j, ...), where the sole operator
%   is '()'.  If the syntax is result = self.theAttname
%   or result = self.theAttname(...), the named attribute
%   object of self is processed.  If fewer than the full
%   number of indices are provided, the silent ones
%   default to 1, unless the last one provided is ':',
%   in which case the remainder default to ':' as well.
%   Indices beyond the full number needed are ignored.
%   ## Only a constant stride is permitted at present.
%
%   If the "quick" flag is set, faster "vanilla-flavored"
%   processing is forced.  Except for autoscaling, no
%   special treatments are performed, such as virtual
%   indexing, implicit indexing (including ":"), unsigned
%   conversions, or auto-NaNing.

% Also see: ncvar/subsasgn.
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.
% Updated    11-May-2001 11:17:14.

if nargin < 1, help(mfilename), return, end

if length(theStruct) < 1
	result = self;
	if nargout > 0
		theResult = result;
	else
		disp(result)
	end
	return
end

% Quick processing.
%  The NetCDF file must already be in "data" mode.

isQuick = quick(self) & ...
			length(theStruct) == 1 & ...
			isequal(theStruct.type, '()');

if isQuick
	indices = theStruct.subs;
	if ~iscell(indices), indices = {indices}; end
	if (0)   % Slow, but proper.
		theNCid = ncid(self);
		theVarid = varid(self);
		theSize = ncsize(self);   % Slow.
		start = zeros(size(theSize));
		count = zeros(size(theSize));
		theAutoscaleflag = autoscale(self);
	else   % Fast, but very bad manners.
		s = struct(self);
		s = s.ncitem;
		s = struct(s);
		theNCid = s.itsNCid;
		theVarid = s.itsVarid;
		start = zeros(1, length(indices));
		count = zeros(1, length(indices));
		theAutoscaleflag = s.itIsAutoscaling;
	end
	for i = 1:length(indices)
		k = indices{i};
		start(i) = min(k) - 1;
		count(i) = length(k);
	end
	[result, status] = ncmex('varget', theNCid, theVarid, ...
								start, count, theAutoscaleflag);
	if status >= 0
		result = permute(result, length(size(result)):-1:1);
	end
	if nargout > 0
	   theResult = result;
	else
	   disp(result)
	end
	return
end

% Composite-variable processing.
%  We map the source-indices to the destination-indices
%  for each composite-variable participant.  The indices
%  are in cells of cells, arranged in the same order as
%  the variables, which themselves are in a cell.

theVars = var(self);   % A cell.
if ~isempty(theVars)
	[theSrcsubs, theDstsubs] = subs(self);  % The mappings.
	result = [];
	for i = length(theVars):-1:1
	  src = theSrcsubs{i};   % A cell.
	  dst = theDstsubs{i};   % A cell.
%     x = theVars{i}(src{:});
	  x = ncsubsref(theVars{i}, '()', src);
	  result(dst{:}) = x;
	end
	theSize = size(result);
	theSubs = theStruct(1).subs;
	if length(theSize) > length(theSubs)
		if isequal(theSubs{length(theSubs)}, ':')
			extra = ':';
		else
			extra = 1;
		end
		for i = length(theSubs)+1:length(theSize)
			theSubs{i} = extra;
		end
	end
	result = result(theSubs{:});  % Subset.
	if nargout > 0
		theResult = result;
	else
		disp(result)
	end
	return
end

% Regular processing.

result = [];
if nargout > 0, theResult = result; end
   
s = theStruct;
theType = s(1).type;
theSubs = s(1).subs;
s(1) = [];

nccheck(self)
theAutoscaleflag = (autoscale(self) == 1);
theDatatype = datatype(self);
theTypelen = ncmex('typelen', theDatatype);
isUnsigned = unsigned(self);
theFillvalue = fillval(self);
theAutonanflag = (autonan(self) == 1) & ~isempty(theFillvalue);
if theAutoscaleflag
	theScalefactor = scalefactor(self);
	theAddoffset = addoffset(self);
end

switch theType
case '()'   % Variable data by index: self(..., ...).
	indices = theSubs;
	theSize = ncsize(self);
	for i = 1:length(indices)
		if isa(indices{i}, 'double')
			if any(diff(diff(indices{i})))
				disp(' ## Indexing strides must be positive and constant.')
				return
			end
		end
	end
   
% Flip and permute indices before proceeding,
%  since we are using virtual indexing.
   
	theOrientation = orient(self);
	if any(theOrientation < 0) | any(diff(theOrientation) ~= 1)
		for i = 1:length(theOrientation)
			if theOrientation(i) < 0
				if isa(indices{i}, 'double')   % Slide the indices.
					indices{i} = fliplr(theSize(i) + 1 - indices{i});
				end
			end
		end
		indices(abs(theOrientation)) = indices;
		theSize(abs(theOrientation)) = theSize;
	end

	if prod(theSize) > 0
		start = zeros(1, length(theSize));
		count = ones(1, length(theSize));
		stride = ones(1, length(theSize));
		for i = 1:min(length(indices), length(theSize))
				k = indices{i};
				if ~isstr(k) & ~strcmp(k, ':') & ~strcmp(k, '-')
				start(i) = k(1)-1;
				count(i) =  length(k);
				d = 0;
				if length(k) > 1, d = diff(k); end
				stride(i) = max(d(1), 1);
			else
				count(i) = -1;
				if i == length(indices) & i < length(theSize)
					j = i+1:length(theSize);
					count(j) = -ones(1, length(j));
				end
			end
		end
		start(start < 0) = 0;
		stride(stride < 0) = 1;
		for i = 1:length(count)
			if count(i) == -1
				maxcount = fix((theSize(i)-start(i)+stride(i)-1) ./ stride(i));
				count(i) = maxcount;
			end
		end
		theNetCDF = parent(self);
		theNetCDF = endef(theNetCDF);
		count(count < 0) = 0;
		if any(count == 0), error(' ## Bad count.'), end
		if all(count == 1)
			[result, status] = ncmex('varget1', ncid(self), varid(self), ...
										start, 0);

elseif all(stride == 1)

			[result, status] = ncmex('varget', ncid(self), varid(self), ...
										start, count, 0);
		else
			imap = [];
			[result, status] = ncmex('vargetg', ncid(self), varid(self), ...
										start, count, stride, imap, ...
										0);
		end
		if theAutonanflag & status >= 0
			f = find(result == theFillvalue);
			if any(f), result(f) = NaN; end
		end
		if theAutoscaleflag & status >= 0
			result = result .* theScalefactor + theAddoffset;
		end
		if isUnsigned & prod(size(result)) > 0
			result(result < 0) = 2^(8*theTypelen) + result(result < 0);
		end
	 else
		result = [];
		status = 0;
	end
	if status >= 0 & prod(size(result)) > 0
		result = permute(result, length(size(result)):-1:1);
		theOrientation = orient(self);
		if any(theOrientation < 0) | any(diff(theOrientation) ~= 1)
			for i = 1:length(theOrientation)
				if theOrientation(i) < 0
					result = flipdim(result, abs(theOrientation(i)));
				end
		 	end
			if length(theOrientation) < 2
				theOrientation = [theOrientation 2];
			end
			result = permute(result, abs(theOrientation));
		end
	elseif status >= 0 & prod(size(result)) == 0
		result = [];
	else
		status, prod_size_result = prod(size(result))   % ***
		warning(' ## ncvar/subsref failure.')
	end
case '.'   % Attribute: self.theAttname(...)
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

if nargout > 0   % Always true.
	theResult = result;
else   % Is there any way to force this?
	c = ncatt('C_format', self);
	if ~isempty(c)
		c = c(:);
		s = size(result)
		result = result.';
		result = result(:);
		step = prod(s)/s(1);
		k = 1:step;
		for i = 1:s(1)
			fprintf(c, result(k));
			fprintf('\n');
			k = k + step;
		end
	else
		disp(result)
	end
end
