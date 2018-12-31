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
% Updated    25-Mar-2003 11:35:17.

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

%  Can we consolidate some of this mess?

theVars = var(self);   % A cell.
if ~isempty(theVars)
	[theSrcsubs, theDstsubs] = subs(self);  % The mappings.
	for j = 1:length(theSrcsubs)
		siz = size(theVars{j});
		src = theSrcsubs{j};
		for i = 1:length(src)
			if isequal(src{i}, ':')   % Convert to numbers.
				src{i} = 1:siz(i);
			end
		end
		theSrcsubs{j} = src;
	end
	theSize = zeros(size(theDstsubs));
	for j = 1:length(theDstsubs)
		dst = theDstsubs{j};
		for i = 1:length(dst)
			theSize(i) = max(theSize(i), max(dst{i}));
		end
	end
	theSubs = theStruct(1).subs;
	if ~iscell(theSubs), theSubs = {theSubs}; end
	isColon = isequal(theSubs{end}, ':');
	if isColon, s = ':'; else, s = 1; end
	while length(theSubs) < length(theSize)
		theSubs{end+1} = s;
	end
	
% Note: We compute a base-1 surrogate of theSubs,
%  in order to keep the pre-allocated "result" matrix
%  as small as possible.

	subsx = cell(size(theSubs));   % "subs" is a function.
	siz = zeros(size(subsx));
	for i = 1:length(theSubs)
		if isequal(theSubs{i}, ':')
			theSubs{i} = 1:theSize(i);
		end
		subsx{i} = theSubs{i} - min(theSubs{i}) + 1;   % Base-1.
		siz(i) = max(subsx{i});
	end
	
	result = zeros(siz);   % Pre-allocate.
	
	for j = 1:length(theVars)
% [from, to] = mapsubs(theSrcsubs{j}, theDstsubs{j}, theSubs);
		[from, to] = mapsubs(theSrcsubs{j}, theDstsubs{j}, subsx);
		if ~isempty(from) & ~isempty(to)
	  		x = ncsubsref(theVars{j}, '()', from);
	  		result(to{:}) = x;
		end
	end

% result = result(theSubs{:});  % Subset.

	result = result(subsx{:});  % Subset.

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
theDatatype = datatype(self);
theFillvalue = fillval(self);
if strcmp ( theDatatype, 'char' )
	theAutonanflag = 0;
	theAutoscaleflag = 0;
else
	theAutonanflag = (autonan(self) == 1) & ~isempty(theFillvalue);
	theAutoscaleflag = (autoscale(self) == 1);
end
theTypelen = ncmex('typelen', theDatatype);
isUnsigned = unsigned(self);
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

		%
		% Singleton variables end up with an empty "theSize".  But,
		% prod(theSize) still results in 1.  Yeah, that makes sense.
		% This results in [] being passed into the mex file for the
		% index.  Yeah, ***THAT*** makes sense.  It actually works for 
		% a singleton, but causes a segmentation fault otherwise.
		% Bad state of affairs.  So we need to watch for this.
		% The way out is to make sure that singletons get a start
		% index of 0.
		%
		% JGE
		if isempty(theSize)
			start = 0;
		else
			start = zeros(1, length(theSize));
		end

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
	if status >= 0 & prod(size(result)) > 0 & (ndims(result)==2) & (strcmp(class(result),'char')) & any(find(size(result)==1))
        
		%
		% If the read operation was successful
		% and if something was actually returned
		% and if that something has exactly two dimensions
		% and if that something was character
		% and if that character string is actually 1D (ndims never returns 1)
		% then do not permute.
		%
		% This way 1D character arrays are loaded as column vectors.
		%
		% Now if you'll excuse me, after writing this code fragment, I have to go
		% wash my hands vigorously for a few hours (get it off, get it off, get it off, unclean..)
		;
        
	elseif status >= 0 & prod(size(result)) > 0
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
