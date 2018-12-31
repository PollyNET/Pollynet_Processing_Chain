function theResult = copy(self, theDestination, ...
                                copyData, copyAttributes, copyDimensions)

% ncvar/copy -- Copy a NetCDF variable, including data and attributes.
%  copy(self, theDestination, copyData, copyAttributes) copies the NetCDF
%   variable associated with self, an "ncvar" object, to the location
%   associated with theDestination, a "netcdf" or "ncvar" object.  If
%   successful, the new "ncvar" object is returned; otherwise, the empty-
%   matrix [] is returned.  The default behavior is NOT to copy data and
%   attributes, unless otherwise directed with non-zero "copyData" and/or
%   "copyAttributes".
%
%   To copy several variables without rewriting theDestination file
%   unnecessarily, call this routine once for each variable, using
%   copyData = 0 and copyAttributes = 1.  Then call it again for the
%   same variables, using copyData = 1 and copyAttributes = 0.
%
%   Small computers may require limits on memory usage during copying.
%   If copyData > 1, it specifies the maximum number of data elements to
%   transfer per NetCDF call.  For copyData = 1, the number is 16*1024
%   elements.  Use "inf" to transfer all the data in one call.
%
%  copy(self, theDestination, copyData, copyAttributes, copyDimensions)
%   for copyDimensions = 0 fulfills the copying request only if the
%   corresponding dimensions already exist in theDestination NetCDF
%   file.  The default is copyDimensions = 1, which copies the
%   corresponding dimensions automatically as needed.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-May-1997 10:56:35.
% Revised    05-Sep-1997 22:42:02.
% Revised    24-Mar-1998 17:38:36.   For Matlab 5.2.

% Arguments.

if nargin < 2, help(mfilename), return, end
if nargin < 3, copyData = 0; end
if nargin < 4, copyAttributes = 0; end
if nargin < 5, copyDimensions = 1; end
if nargout > 0, theResult = []; end

% Dimensions.

switch ncclass(theDestination)
case 'netcdf'
   switch ncclass(self)
   case 'ncvar'
      if isempty(theDestination{name(self)})
         d = dim(self);
         for i = 1:length(d)
            if ~copyDimensions
               status = theDestination(name(d{i}));
            else
               status = (theDestination < d{i});
            end
            if isempty(status), return, end
         end
      end
   otherwise
   end
case 'ncvar'
otherwise
   warning(' ## Incompatible arguments.')
end

% Variable definition.

switch ncclass(theDestination)
case 'netcdf'
   switch ncclass(self)
   case 'ncvar'
      v = theDestination{name(self)};
      if isempty(v)
         v = ncvar(name(self), datatype(self), ncnames(dim(self)), theDestination);
         if isempty(v), return, end
      end
   otherwise
   end
case 'ncvar'
   v = theDestination;
otherwise
   warning(' ## Incompatible arguments.')
end

% Copy attributes.

if copyAttributes
   switch ncclass(self)
   case 'ncvar'
      a = att(self);
      for i = 1:length(a)
         status = (v < a{i});
         if isempty(status), return, end
      end
   otherwise
   end
end

% Copy data.

MAX_CHUNK = 16 * 1024;   % 16 K values = 128 K bytes.

if copyData > 1, MAX_CHUNK = copyData; end

if copyData
   theClass = ncclass(self);
   switch theClass
   case {'ncvar', 'double', 'char', 'uint8'}
      d = dim(v);
      theSize = size(v);
		if isempty(d)
			kmax = 1;
		elseif isrecdim(d{1})
			mver = version;
			switch ( str2double(mver(1) ) )
			case 7
				% theSize = ncsize(self); % this does not work in MATLAB 7.0
				% it returns a scalar length when ncind2sub below needs a [row, col] shape
				theSize = size(self);
			otherwise
				theSize = ncsize(self);
			end
         kmax = prod(theSize);
		else
         kmax = min(prod(theSize), prod(size(self)));
      end
      [s, c] = ncind2sub(theSize, 1, min(MAX_CHUNK, kmax));
      if length(c) > 0, MAX_CHUNK = c(1); end
      k = 0;;
      while k < kmax;
         kstep = min(MAX_CHUNK, kmax-k);
         [s, c] = ncind2sub(theSize, k+1, kstep);
         [m, n] = size(s);
         switch theClass
         case 'ncvar'
            for i = 1:m
               t = s(i, :);
%              v(t{:}) = self(t{:});  % "()" out-of-context here.
               theSubs.type = '()';
               theSubs.subs = t;
               temp = subsref(self, theSubs);
               v = subsasgn(v, theSubs, temp);
            end
         otherwise
            for i = 1:m
               t = s(i, :);
%              v(t{:}) = self(k+1:k+kstep);   % Here too.
               theSubs.type = '()';
               theSubs.subs = t;
               temp = self(k+1:k+kstep);
               v = subsasgn(v, theSubs, temp);
            end
         end
         k = k + kstep;
      end
   otherwise
      warning(' ## Incompatible arguments.')
   end
end

% Return.

if nargout > 0, theResult = v; end
