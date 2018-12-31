function theResult = whos(self)

% netcdf/whos -- WHOS for a NetCDF file.
%  whos(self) returns a Matlab WHOS structure
%   for self, a "netcdf" object, containing
%   information about all of its items.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 08-Sep-1999 18:28:31.
% Updated    10-Sep-1999 11:25:37.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

items = [att(self) dim(self)];
v = var(self);
for k = 1:length(v)
	items = [items v(k) att(v{k})];
end

byteLen = ncmex('typelen', 'byte');
charLen = ncmex('typelen', 'char');
shortLen = ncmex('typelen', 'short');
longLen = ncmex('typelen', 'long');
floatLen = ncmex('typelen', 'float');
doubleLen = ncmex('typelen', 'double');

result = [];

for k = length(items):-1:1
	it = items{k};
	theName = name(it);
	theClass = class(it);
	theDatatype = class(it);
	theNCSize = ncsize(it);
	theSize = size(it);
	theDatatype = datatype(it);
	theParent = name(parent(it));
	switch theDatatype
	case 'byte'
		theBytes = prod(theSize)*byteLen;
	case 'char'
		theBytes = prod(theSize)*charLen;
	case 'short'
		theBytes = prod(theSize)*shortLen;
	case 'long'
		theBytes = prod(theSize)*longLen;
	case 'float'
		theBytes = prod(theSize)*floatLen;
	case 'double'
		theBytes = prod(theSize)*doubleLen;
	otherwise
		theBytes = 0;
	end
	result(k).name = theName;
	result(k).size = theSize;
	result(k).bytes = theBytes;
	result(k).class = theClass;
	result(k).datatype = theDatatype;
	result(k).ncsize = theNCSize;
	result(k).parent = theParent;
end

if nargout > 0
	theResult = result;
else
	disp(result)
	assignin('caller', 'ans', result)
end
