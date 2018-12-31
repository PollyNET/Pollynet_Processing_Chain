function tnetcdf(nRecords)

% tnetcdf -- NetCDF Toolbox test.
%  tnetcdf(nRecords) tests the NetCDF Toolbox,
%   including an exercize with nRecords (default = 2).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 13-Mar-1997 00:00:00.
% Updated    05-Mar-2002 15:10:36.

% Check the Matlab path.

a = {'ncutility',
     'nctype',
     'netcdf/netcdf',
     'ncitem/ncitem',
     'ncdim/ncdim',
     'ncvar/ncvar',
     'ncatt/ncatt',
     'ncrec/ncrec',
     'ncbrowser/ncbrowser',
     'listpick/listpick'};
	 
okay = 1;
for i = 1:length(a)
   if isempty(which(a{i}))
      disp([' ## Unable to find: ' a{i}])
      okay = 0;
   end
end

if ~okay
   disp([' ## Please adjust your Matlab path,'])
   disp([' ##  then restart Matlab and'])
   disp([' ##  execute "tnetcdf" again.'])
   disp([' ##  See "ncstartup" for instructions.'])
   return
end

ncversion

if nargin < 1, nRecords = 2; end
if ischar(nRecords), nRecords = eval(nRecords); end

filename = 'foo.nc';

disp(' ')
disp([' ## TNETCDF: Using file "' filename '"']);

oldOptions = options(ncitem, 0);   % Quiet mode.
ncquiet

for i = 0:3
   status = ncmex('close', i);
end

f = netcdf(filename, 'clobber');

if isempty(f)
   disp(' ## NetCDF test file not created.')
   return
end

% Preamble.

f.Description = 'Test file.';
f.Author = 'Dr. Charles R. Denham, ZYDECO.';
f.Created = datestr(now);

f('time') = 0;
f('lat') = 10;
f('lon') = 5;
f('elapsed_time') = 100;
f('horse_number') = 5;

f{'time'} = nclong('time');
f{'lat'} = nclong('lat');
f{'lon'} = nclong('lon');
f{'elapsed_time'} = ncdouble('elapsed_time');
f{'horse_number'} = nclong('horse_number');
f{'speed'} = ncdouble('elapsed_time', 'horse_number');

dims = {'time'; 'lat'; 'lon'};

f{'z'} = nclong(dims);
f{'t'} = nclong(dims);
f{'p'} = nclong(dims);
f{'rh'} = nclong(dims);

f{'time'}.units = 'seconds';

f{'lat'}.FillValue_ = nclong(-999);
f{'lat'}.scale_factor = nclong(2);
f{'lat'}.add_offset = nclong(100);
f{'lat'}.units = 'degrees_north';

f{'lon'}.units = 'degrees_east';

f{'z'}.units = 'meters';
f{'z'}.valid_range = ncfloat([0 5000]);

f{'p'}.FillValue_ = NaN;
f{'p'}.FillValue_ = Inf;
f{'p'}.FillValue_ = -Inf;
f{'p'}.FillValue_ = -1;

f{'rh'}.FillValue_ = -1;

f{'elapsed_time'}.units = 'fortnights';
f{'speed'}.units = 'furlongs/fortnight';

if (1)   % Disabled = 0.

% Test dotted names: fails on some systems.

if (0)
   f('a.dotted.name') = length('a dotted variable name');
   f.a.dotted.name = 'a dotted global attribute name';
   f{'a.dotted.name'} = ncchar('a.dotted.name');
   f{'a.dotted.name'}.a.dotted.name = 'a dotted variable attribute name';
   f{'a.dotted.name'}(:) = 'a dotted variable name';
end

% Test dashed names: fails on some systems.

if (0)
   f('a-dashed-name') = length('a dashed variable name');
   ncatt('a-dashed-name', 'a dashed global attribute name', f)
   f('a-dashed-name') = length('a dashed variable name');
   f{'a-dashed-name'} = ncchar('a-dashed-name');
   v = f{'a-dashed-name'};
   ncatt('a-dashed-name', 'a dashed variable attribute name', v)
   f{'a-dashed-name'}(:) = 'a dashed variable name';
end

else
   disp(' ## After "tnetcdf", run "tncdotted" to check')
   disp(' ##  whether dotted and/or dashed NetCDF names')
   disp(' ##  can be created on this machine.')
end

f = close(f);

f = netcdf(filename, 'write')

if isempty(f)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

lat = [0 10 20 30 40 50 60 70 80 90].';   % Column-vectors.
lon = [-140 -118 -96 -84 -52].';

for i = 1:length(lat), f{'lat'}(i) = lat(i); end

value = f{'lat'}(:);

if ~isequal(value, lat)
	original_lat = lat, retrieved_lat = value
	warning(' ## Bad retrieval of lat data #1.')
end

f{'lat'}(1:2:10) = lat(1:2:10);

value = f{'lat'}(:);
if ~isequal(value, lat), warning(' ## Bad retrieval of lat data #2.'), end

value = f{'lat'}(1:2:10);
if ~isequal(value, lat(1:2:10)), warning(' ## Bad retrieval of lat data #3.'), end

f{'lon'}(:) = lon;

theSize = [prod(size(f{'elapsed_time'})) 1];
theDistance = sort(rand(theSize));
f{'elapsed_time'}(:) = theDistance;
f{'horse_number'}(:) = [2; 5; 27; 100; 125];
theSpeed = rand(size(f{'speed'}));
for j = 1:size(theSpeed, 2)
   theSpeed(:, j) = filter(theSpeed(:, j), ones(1, 5), 1) + ...
                       sin(2*pi*theDistance) + 1;
end
f{'speed'}(:) = theSpeed;

f = close(f);

ncdump(filename)

f = netcdf(filename, 'write');

if isempty(f)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

% Re-write the scale_factor and add_offset
%  two different ways.

if (1)
	f{'lat'}.scale_factor = nclong(999);
	f{'lat'}.add_offset = nclong(999);
	f{'lat'}.scale_factor(:) = 1;
	f{'lat'}.add_offset(:) = 0;
end

f = close(f);

% Test of functions dealing with copying.

if (1)
	disp(' ')
	disp(' ## TNETCDF: Copy-testing...')
	theOriginal = netcdf(filename, 'nowrite')
	if isempty(theOriginal)
	   disp(' ## NetCDF test file not opened for "read".')
	   return
	end
	theCopy = netcdf([filename '.copy'], 'clobber');
	if isempty(theCopy)
	   disp(' ## NetCDF destination file not created.')
	   return
	end
	theCopy < theOriginal;
	theCopy
	theCopy = close(theCopy);
	theOriginal = close(theOriginal);
	disp(' ## TNETCDF: Copy-testing done.')
end

% Test of functions dealing with records.

disp(' ')
disp(' ## TNETCDF: Record-testing...')

f = netcdf(filename, 'write');

if isempty(f)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

record = f(0);
recdata = record(0);
goodRecords = 0;
iRec = nRecords:-1:1;
for i = iRec
   disp([' ## Record: ' int2str(i)])
   recdata = record(0);
   recdata.time = i;
   recdata.z = fix(rand(size(recdata.z))*100);
   recdata.t = fix(rand(size(recdata.t))*100);
   recdata.p = fix(rand(size(recdata.p))*100);
   recdata.rh = fix(rand(size(recdata.rh))*100);
   record(i) = recdata;
   recdata1 = record(i);
   record(i) = recdata1;   % Round-trip.
   recdata2 = record(i);
   goodRecords = goodRecords + isequal(recdata1, recdata2);
end
f = close(f);

theOptions = options(ncitem, oldOptions);

if goodRecords == nRecords
   disp(' ## TNETCDF: Record-testing successful.')
  else
   disp(' ## TNETCDF: Record-testing not successful.')
   disp([' ## Good Records: ' int2str(goodRecords) ' of ' int2str(nRecords) '.'])
end

% Test of virtual variables.
	
disp(' ')
disp(' ## TNETCDF: Virtual-variable test...')
f = netcdf(filename, 'write');
rh = f{'rh'};
a = rh;
b = orient(rh, [3 1 2]);
aa = permute(a(:), [3 1 2]);   % WetCDF gets "ncvar/subsref" warning here. ***
b(:) = aa;   % Put-back.
aa = a(:);   % Get again.
bb = ipermute(b(:), [3 1 2]);   % But not here. ***
f = close(f);

if isequal(aa, bb)
   disp(' ## TNETCDF: Virtual-variable test successful.')
else
	aa, bb
   disp(' ## TNETCDF: Virtual-variable test NOT successful.')
end

% Test of composite variables.

% Note: our use of "orient" here malfunctions
%  when we attempt to use [-1], rather than [+1].

disp(' ')
disp(' ## TNETCDF: Composite-variable test...')
f = netcdf(filename, 'write');
lat = f{'lat'};
m = ncsize(lat, 1);
v = var(lat, {':'}, {1:m, 1}, ...
        orient(lat, [+1]), {':'}, {1:m, 2});   % Was orient(lat, [-1]).
		
x1 = v(:);
v(:) = flipud(x1);
x2 = v(:);
v(:) = flipud(x2);
x3 = v(:);
f = close(f);

if isequal(x1, x3)
   disp(' ## TNETCDF: Composite-variable test successful.')
else
   disp(' ## TNETCDF: Composite-variable test NOT successful.')
end

% Test of "quick" input/output.

disp(' ')
disp(' ## TNETCDF: Input/output in "quick-mode"...')
f = netcdf(filename, 'write');
v = f{'speed'};
theSize = size(v);
v = quick(v, 0);
ntimes = 20;
for k = 1:2
	tic
	for i = 1:ntimes
		x = v(1:theSize(1), 1:theSize(2));
	end
	elapsed(k) = toc;
	v = quick(v, 1);
end
close(f)
theSpeedFactor = elapsed(1) ./ elapsed(2)

% Browser.

if (1)
   disp(' ')
   disp(' ## TNETCDF: Browse test-file...')
   disp(' ')
   ncbrowser ('foo.nc','nowrite')
end

disp(' ')
disp(' ## TNETCDF: Done.')
