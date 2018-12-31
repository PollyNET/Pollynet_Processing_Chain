function theResult = ncmemory(theNetCDF)

% ncmemory -- Estimate Matlab memory for NetCDF file.
%  ncmemory(theNetCDF) estimates the amount of Matlab
%   memory that would be required to load all the variables
%   and attributes from theNetCDF ('filename' or "netcdf"
%   object).  The size of the Matlab header is not included
%   in the estimate.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 08-Sep-1999 09:12:20.
% Updated    08-Sep-1999 10:07:00.

if nargout > 0, theResult = []; end

if nargin < 1
	help(mfilename)
	theNetCDF = '*';
end

% Compute byte-sizes for "char" and "double".

charBytes = 2;
doubleBytes = 8;

aChar = '0';
aDouble = 0;

w = whos('aChar', 'aDouble');
for i = 1:length(w)
	switch w(i).class
	case 'char'
		charBytes = w(i).bytes;
	case 'double'
		doubleBytes = w(i).bytes;
	end
end

theClass = class(theNetCDF);

wasOpened = 0;
if isa(theClass, 'char')
	nc = netcdf(theNetCDF, 'nowrite');
	wasOpened = ~isempty(nc);
elseif isa(theClass, 'netcdf')
	nc = theNetCDF;
	theNetCDF = name(nc);
else
	disp(' ## Requires filename or "netcdf" object.')
	return
end

if isempty(nc), return, end

% List of items.

x = att(nc);
v = var(nc);
for k = 1:length(v)
	x{end+1} = v{k};
	a = att(v{k});
	for i = 1:length(a)
		x{end+1} = a{i};
	end
end

% Compute Matlab memory requirements.
	
result = 0;

for i = 1:length(x)
	s = prod(size(x{i}));
	switch class(x{i});
	case 'char'
		s = s*charBytes;
	otherwise
		s = s*doubleBytes;
	end
	result = result + s;
end

% Done.

if wasOpened, close(nc), end

if nargout > 0
	theResult = result
else
	disp([' ## "' theNetCDF '" requires approximately ' int2str(result) ' bytes.'])
	assignin('caller', 'ans', result)
end
