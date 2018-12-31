function tscalar

% tscalar -- Test NetCDF scalar values.
%  tscalar (no arguments) writes the value 99 into
%   several variables for each NetCDF datatype, then
%   reads and tests the data after reopening the
%   file.  The tested variables have lengths of 0
%   (scalar), 1, and 2.  Errors are noted, if any.
%   Note: ascii(99) = "c".
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 23-Sep-1999 08:22:11.
% Updated    27-Jan-2000 13:38:12.

help(mfilename)

nc = netcdf('scalar.nc', 'clobber');
theNetCDFFile = name(nc);
disp([' ## NetCDF File: ' theNetCDFFile])

theTypes = {'byte', 'char', 'short', 'long', 'float', 'double'};
theDimNames = {'', 'one', 'two'};

for k = 1:length(theDimNames)
	thePrefix = char('a' + k - 1);
	for i = 1:length(theTypes)
		t = theTypes{i};
		t(1) = upper(t(1));
		theNames{i} = [thePrefix t];
		theKinds{i} = ['nc' theTypes{i}];
		if k < 2
			nc{theNames{i}} = feval(theKinds{i});
		else
			nc(theDimNames{k}) = k-1;
			nc{theNames{i}} = feval(theKinds{i}, theDimNames{k});
		end
		nc{theNames{i}}.value = 99;
	end
end

theNames = ncnames(var(nc));

for i = 1:length(theNames)
	nc{theNames{i}}(:) = 99;
end

close(nc)

% Re-open the file.

nc = netcdf(theNetCDFFile, 'write');

% Read the data.

for i = 1:length(theNames)
	theValues{i} = nc{theNames{i}}(1);
end

disp(' ## Testing variables using  "(1)" notation:')

okay = [];

okay(end+1) = ~~1;
for i = 1:length(theValues)
	if ~all(double(theValues{i}) == 99)
		disp([' ## Some values are not 99: ' theNames{i}])
		okay(end+1) = ~~0;
	end
end

% Read attributes with (1) notation.

for i = 1:length(theNames)
	theValues{i} = nc{theNames{i}}.value(1);
end

disp(' ## Testing attributes using "(1)" notation:')

okay(end+1) = ~~1;
for i = 1:length(theValues)
	if ~all(double(theValues{i}) == 99)
		disp([' ## Some values are not 99: ' theNames{i}])
		okay(end+1) = ~~0;
	end
end

% Rewrite the data.

for i = 1:length(theNames)
	nc{theNames{i}}(:) = 99;
	nc{theNames{i}}.value(:) = 99;
end

% Reread with (:) notation.

for i = 1:length(theNames)
	theValues{i} = nc{theNames{i}}(:);
end

disp(' ## Testing variables using  "(:)" notation:')

okay(end+1) = ~~1;
for i = 1:length(theValues)
	if ~all(double(theValues{i}) == 99)
		disp([' ## Some values are not 99: ' theNames{i}])
		okay(end+1) = ~~0;
	end
end

% Read attributes with (:) notation.

for i = 1:length(theNames)
	theValues{i} = nc{theNames{i}}.value(:);
end

disp(' ## Testing attributes using "(:)" notation:')

okay(end+1) = ~~1;
for i = 1:length(theValues)
	if ~all(double(theValues{i}) == 99)
		disp([' ## Some values are not 99: ' theNames{i}])
		okay(end+1) = ~~0;
	end
end

close(nc)

if all(okay)
	disp(' ## Scalar test successful.')
else
	disp(' ## Scalar test NOT successful.')
end
