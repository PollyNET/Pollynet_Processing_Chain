function theStatus = ncdumpd(theNetCDFFile, theOutputFile)

% ncdumpd -- List NetCDF file headers as NetCDF Language.
%  ncdumpd(theNetCDFFile, 'theOutputFile') displays the
%   definitions of items in theNetCDFFile, a filename
%   or a "netcdf" object.  Similar in behavior to the
%   Unidata "ncdump -h" program.  If theNetCDFFile looks
%   like a wild-card (contains '*'), the routine uses
%   the uigetfile() dialog to get the filename.  The
%   default is '*.*'.  The output file, which may be
%   a wild-card to invoke uiputfile(), defaults to
%   'stdout', equivalent to the Matlab command window.
%   (NOTE: if theOutputFile is provided as an integer
%   > 2, it is assumed to be the file-id of an already
%   open file.)
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Oct-1996 13:10:35.53.   For ncmex4.
% Version of 19-Dec-1996 11:30:00.00.   For ncmex5.
% Version of 09-Jan-1997 11:26:00.00.   For netcdf objects.
% Version of 14-Jan-1997 11:34:00.00.   Use nc4ml notation.
% Version of 21-Jan-1997 10:48:00.00.   Names with embedded-quotes.
% Version of 11-Feb-1998 10:41:08.00.   Accepts "netcdf" object.
% Version of 16-Jun-1998 10:41:08.00.   Accepts id of open file.
% Updated    29-Sep-1998 09:10:49.      Cleaned up the "help".
% Updated    31-May-2001 10:07:14.      Write the data.

if nargin < 1, help ncdumpd, theNetCDFFile = '*.*'; end
if nargin < 2, theOutputFile = 'stdout'; end   % stdout.

if isa(theNetCDFFile, 'ncitem')
    theNetCDFFile = name(parent(parent(theNetCDFFile)));
end

if any(theNetCDFFile == '*')
   theFilterSpec = theNetCDFFile;
   thePrompt = 'Select a NetCDF Input File:';
   [theFile, thePath] = uigetfile(theFilterSpec, thePrompt);
   if ~any(theFile), return, end
   theNetCDFFile = [thePath theFile];
end

if any(theOutputFile == '*')
   theFilterSpec = theOutputFile;
   thePrompt = 'Select a Text Output File:';
   [theFile, thePath] = uiputfile(theFilterSpec, thePrompt);
   if ~any(theFile), return, end
   theOutputFile = [thePath theFile];
end

nctypes = ['byte   '; 'char   '; 'short  '; ...
           'long   '; 'float  '; 'double '; ...;
           'unknown'; 'unknown'; 'unknown'];

nc = netcdf(theNetCDFFile, 'nowrite');
theNCid = ncid(nc);

if isempty(nc)
   disp([' ## Unable to open: ' theNetCDFFile])
   return
end

if strcmp(theOutputFile, 'stdout')
   fp = 1;
  elseif strcmp(theOutputFile, 'stderr')
   fp = 2;
  elseif isstr(theOutputFile)
   fp = fopen(theOutputFile, 'w');
  else
   fp = theOutputFile;
end

if fp < 0, close(f), return, end

[ndims, nvars, ngatts, recdim] = size(nc);

dims = dim(nc); ndims = length(dims);
vars = var(nc); nvar = length(vars);
gatts = att(nc); ngatts = length(gatts);

s = ' ';
fprintf(fp, '%s\n', s);
s = ['%% ncdump(''' theNetCDFFile ''')'];
s = [s '   %% Generated ' datestr(now)];
fprintf(fp, '%s\n', s);
s = ' ';
fprintf(fp, '%s\n', s);
s = ['nc = netcdf(''' theNetCDFFile ''', ''noclobber'');'];
fprintf(fp, '%s\n', s);
s = ['if isempty(nc), return, end'];
fprintf(fp, '%s\n', s);

s = ' ';
fprintf(fp, '%s\n', s);
s = '%% Global attributes:';
fprintf(fp, '%s\n', s);
s = ' ';
fprintf(fp, '%s\n', s);
s = '%% (none)';
if ngatts < 1,fprintf(fp, '%s\n', s); end

for i = 1:ngatts
   varid = -1;
   attnum = i-1;
   attname = name(gatts{i});
   if any(attname ~= '_')
      while attname(1) == '_'
         attname = [attname(2:length(attname)) attname(1)];
      end
   end
   attname = strrep(attname, '''', '''''');
   theDatatype = datatype(gatts{i});
   attlen = ncsize(gatts{i});
   attvalue = gatts{i}(:);
   theDatatype = ['nc' theDatatype];
   s = ['nc.' attname ' = ' theDatatype '('];
   t = mat2str(attvalue);
   if length(t) > 0 & 0
      if t(1) == '[' & t(length(t)) == ']'
         t = [ '{' t(2:length(t)-1) '}'];
      end
   end
   if ~isstr(attvalue)
      if (0)
         f = [];
         k = 1:length(t)-1;
         if any(k), f = find(t(k) == t(k+1)); end
         if any(f), t(f) = []; end
         f = find(t == ' ');
         if any(f), t(f) = setstr(t(f) .* 0 + ','); end
         t = strrep(t, ',', ', ');
      end
     else
      t = ['''' t ''''];
   end
   s = [s t ');'];
   fprintf(fp, '%s\n', s);
end

s = ' ';
fprintf(fp, '%s\n', s);
s = '%% Dimensions:';
fprintf(fp, '%s\n', s);
s = ' ';
fprintf(fp, '%s\n', s);

if ndims < 1, disp('%% (none)'), end

for i = 1:ndims
   dimid = i-1;
   dimname = name(dims{i});
   dimname = strrep(dimname, '''', '''''');
   dimlen = ncsize(dims{i});
   s = ['nc(''' dimname ''') = ' int2str(dimlen) ';'];
   if dimid == recdim, s = [s ' %% (record dimension)']; end
   fprintf(fp, '%s\n', s);
end

s = ' ';
fprintf(fp, '%s\n', s);
s = '%% Variables and attributes:';
fprintf(fp, '%s\n', s);
s = ' ';
fprintf(fp, '%s\n', s);

s = '%% (none)';
if nvars < 1, fprintf(fp, '%s\n', s), end

for j = 1:nvars;
   varid = j-1;
   varname = name(vars{j});
   varname = strrep(varname, '''', '''''');
   theDatatype = datatype(vars{j});
   theDatatype = ['nc' theDatatype];
   dims = dim(vars{j});
   ndims = length(dims);
   atts = att(vars{j});
   natts = length(atts);
   s = ['nc{''' varname '''} = ' theDatatype];
   for i = 1:ndims
      dimname = name(dims{i});
      dimname = strrep(dimname, '''', '''''');
      dimlen = ncsize(dims{i});
      if i == 1, s = [s '(']; end
      if i > 1, s = [s, ', ']; end
      s = [s '''' dimname ''''];
      if i == ndims, s = [s ')']; end
  end
  s = [s ';'];
   elements = prod(ncsize(vars{j}));
   s = [s ' %% ' int2str(elements) ' element'];
   if elements ~= 1, s = [s 's']; end
   s = [s '.'];
   fprintf(fp, '%s\n', s);
   for i = 1:natts
      attnum = i-1;
      theDatatype = datatype(atts{i});
      theDatatype = ['nc' theDatatype];
      attname = name(atts{i});
      if strcmp(attname, '_FillValue')
         attname = 'FillValue_';
      end
      if any(attname ~= '_')
         while attname(1) == '_'
            attname = [attname(2:length(attname)) attname(1)];
         end
      end
      attname = strrep(attname, '''', '''''');
      attlen = ncsize(atts{i});
      attvalue = atts{i}(:);
      s = ['nc{''' varname '''}.' attname ' = ' theDatatype];
      t = mat2str(attvalue);
      if ~isstr(attvalue)   % Patch in commas.
         if (0)   % Doesn't work correctly.
            f = [];
            k = 1:length(t)-1;
            if any(k), f = find(t(k) == t(k+1)); end
            if any(f), t(f) = []; end
            f = find(t == ' ');
            if any(f), t(f) = setstr(t(f) .* 0 + ','); end
            t = strrep(t, ',', ', ');
         end
        else
         t = ['''' t ''''];
      end
      t = ['(' t ')'];
      s = [s t ';'];
      fprintf(fp, '%s\n', s);
   end
   s = ' ';
   fprintf(fp, '%s\n', s);
end

s = 'endef(nc)';
fprintf(fp, '%s\n', s);

for j = 1:nvars
	varname = name(vars{j});
	s = [varname '('];
	d = ncsize(vars{j});
	for i = 1:length(d)
		ind = ['1:' int2str(d(i))];
		s = [s ind];
		if i < length(d)
			s = [s ', '];
		end
	end
	s = [s ') = ...'];
	fprintf(fp, '\n%s\n', s);
	x = vars{j}(:);
	s = mat2str(x);
	if ischar(x)
		fprintf(fp, '%s', '[''')
	end
	fprintf(fp, '%s', s);
	if ischar(x)
		fprintf(fp, '%s', ''']')
	end
	fprintf(fp, '%s\n', ';')
end

s = 'close(nc)';
fprintf(fp, '\n%s\n', s);

if ischar(theOutputFile) & fp > 2, fclose(fp); end

close(nc)

if nargout > 0, theStatus = status; end
