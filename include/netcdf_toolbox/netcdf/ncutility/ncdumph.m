function theStatus = ncdumph(theNetCDFFile, theOutputFile)

% ncdumph -- List NetCDF file structure as NC4ML.
%  ncdumph(theNetCDFFile, theOutputFile) displays the
%   definitions of items in theNetCDFFile, a filename.
%   Similar in behavior to the "ncdump -h" program.
%   If theNetCDFFile looks like a wild-card (contains '*'),
%   the routine uses uigetfile() dialog to obtain the filename.
%   The default is '*.*'.  The output file, which may be
%   a wild-card to invoke uiputfile, defaults to 'stdout',
%   equivalent to the Matlab command window.
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Oct-96 at 13:10:35.53.   For ncmex4.
% Version of 19-Dec-96 at 11:30:00:00.   For ncmex5.
% Version of 09-Jan-97 at 11:26:00:00.   For netcdf objects.
% Version of 14-Jan-97 at 11:34:00:00.   Use nc4ml notation.
% Version of 21-Jan-97 at 10:48:00:00.   Names with embedded-quotes.
% Version of 28-Jan-97 at 09:00:00:00.   List structure only.

if nargin < 1, help ncdumph, theNetCDFFile = '*.*'; end
if nargin < 2, theOutputFile = 'stdout'; end

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
  else
   fp = fopen(theOutputFile, 'w');
end

if fp < 0, close(f), return, end

[ndims, nvars, ngatts, recdim] = size(nc);

dims = dim(nc); ndims = length(dims);
vars = var(nc); nvar = length(vars);
gatts = att(nc); ngatts = length(gatts);

s = ' ';
fprintf(fp, '%s\n', s);
s = ['%% ncdumph(''' theNetCDFFile ''')'];
s = [s '   %% Generated ' datestr(now)];
fprintf(fp, '%s\n', s);
s = ' ';
fprintf(fp, '%s\n', s);
s = ['nc = netcdf(''' theNetCDFFile ''', ''noclobber'');'];
fprintf(fp, '%s\n', s);
s = ['if isempty(nc), return, end'];
fprintf(fp, '%s\n', s);

s = ' '; fprintf(fp, '%s\n', s);
s = '%% Global attributes:'; fprintf(fp, '%s\n', s);
s = ' '; fprintf(fp, '%s\n', s);

if nvars < 1, s = '%% (none)'; fprintf(fp, '%s\n', s); end

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
   attlen = size(gatts{i});
   attvalue = gatts{i}(:);
   theDatatype = ['nc' theDatatype];
   s = ['nc.' attname ' = ' theDatatype '(...)'];
   fprintf(fp, '%s\n', s);
end

s = ' '; fprintf(fp, '%s\n', s);
s = '%% Dimensions:'; fprintf(fp, '%s\n', s);
s = ' '; fprintf(fp, '%s\n', s);

if ndims < 1, s = '%% (none)'; fprintf(fp, '%s\n', s); end

for i = 1:ndims
   dimid = i-1;
   dimname = name(dims{i});
   dimname = strrep(dimname, '''', '''''');
   dimlen = size(dims{i});
   s = ['nc(''' dimname ''') = ' int2str(dimlen) ';'];
   if dimid == recdim, s = [s ' %% (record dimension)']; end
   fprintf(fp, '%s\n', s);
end

s = ' '; fprintf(fp, '%s\n', s);
s = '%% Variables:'; fprintf(fp, '%s\n', s);
s = ' '; fprintf(fp, '%s\n', s);

s = '%% (none)'; if nvars < 1, disp(s), end

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
      dimlen = size(dims{i});
      if i == 1, s = [s '(']; end
      if i > 1, s = [s, ', ']; end
      s = [s '''' dimname ''''];
      if i == ndims, s = [s ')']; end
   end
   elements = prod(size(vars{j}));
   s = [s ' %% ' int2str(elements) ' element'];
   if elements ~= 1, s = [s 's']; end
   s = [s '.']; fprintf(fp, '%s\n', s);
end

s = ' '; fprintf(fp, '%s\n', s);
s = '%% Attributes:'; fprintf(fp, '%s\n', s);

for j = 1:nvars;
   varid = j-1;
   varname = name(vars{j});
   varname = strrep(varname, '''', '''''');
   atts = att(vars{j});
   natts = length(atts);
   if natts > 0, s = ' '; fprintf(fp, '%s\n', s); end
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
      attlen = size(atts{i});
      attvalue = atts{i}(:);
      s = ['nc{''' varname '''}.' attname ' = ' theDatatype '(...)'];
      fprintf(fp, '%s\n', s);
   end
end

s = ' '; fprintf(fp, '%s\n', s);
s = 'endef(nc)'; fprintf(fp, '%s\n', s);
s = 'close(nc)'; fprintf(fp, '%s\n', s);

if fp ~= 1, fclose(fp); end

close(nc)

if nargout > 0, theStatus = status; end
