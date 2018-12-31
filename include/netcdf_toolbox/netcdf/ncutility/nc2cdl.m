function nc2cdl(theNetCDFFile, theCDLFile, theDataFlag)

% nc2cdl -- Translate NetCDF file to CDL notation.
%  nc2cdl('theNetCDFFile', 'theCDLFile') translates
%   'theNetCDFFile' structure to CDL notation and
%   writes it to 'theCDLFile', a new file.
%  nc2cdl(..., ..., theDataFlag) includes the values
%   of the NetCDF variables, if the given flag evaluates
%   to TRUE.  Default = FALSE.  Scale-factors are not
%   applied to the data values before translation.
%   Single and double precision floating-point values
%   are expressed with 7 and 15 significant digits,
%   respectively.  Strings are written as individual
%   characters.
 
% Copyright (C) 2002 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Oct-2002 15:19:00.
% Updated    28-Oct-2002 09:52:32.

if nargin < 1, help(mfilename), return, end
if nargin < 3, theDataFlag = ~~0; end
if ischar(theDataFlag)
    theDataFlag = ~~eval(theDataFlag);
end

CHUNKSIZE = 10;   % Data chunk-size.

CR = char(13);
LF = char(10);
CRLF = [CR LF];

if any(findstr(computer, 'MAC'))
    NL = CR;
elseif ispc
    NL = CRLF;
elseif isunix
    NL = LF;
end

TAB = '    ';

% Open the NetCDF and CDL file.

if ischar(theNetCDFFile)
    nc = netcdf(theNetCDFFile, 'nowrite');
elseif isa(theNetCDFFile, 'netcdf')
    nc = theNetCDFFile;
end

if isempty(nc)
   disp(' ## Not a NetCDF File.')
   return
end

fout = fopen(theCDLFile, 'w');
if fout < 0
    disp([' ## Unable to open outputfile: ' theCDLFile])
    return
end

% CDL File Initialization.

fprintf(fout, ['netcdf %s {' NL], name(nc));

fprintf(fout, ['// NetCDF translated to CDL on %s' NL], datestr(now));

fprintf(fout, ['// By "%s"' NL], which(mfilename));

% Global Attributes.

fprintf(fout, ['// global attributes:' NL]);

g = att(nc);

for i = 1:length(g)
    fprintf(fout, [TAB ':' name(g{i}) ' = ']);
    x = g{i}(:);
    if ischar(x)
        fprintf(fout, ['"%s" ;' NL], x);
    else
        for k = 1:length(x)
            if i > 1, fprintf(fout, ', '); end
            fprintf(fout, num2str(x(k)));
        end
        fprintf(fout, [' ;' NL]);
    end
end

% Dimensions.

fprintf(fout, ['dimensions:' NL]);

d = dim(nc);
for i = 1:length(d)
    len = length(d{i});
    if isrecdim(d{i})
        fprintf(fout, [TAB name(d{i}) ' = UNLIMITED ; // (' ...
                    num2str(len) ' currently)' NL]);
    else
        fprintf(fout, [TAB name(d{i}) ' = ' ...
                    num2str(len) ' ;' NL]);
    end
end

% Variables and Attributes.

fprintf(fout, ['variables:' NL]);

v = var(nc);
for i = 1:length(v)
    fprintf(fout, [TAB datatype(v{i}) ' ' name(v{i}) '(']);
    d = dim(v{i});
    for j = 1:length(d)
        if j > 1, fprintf(fout, ', '); end
        fprintf(fout, [name(d{j})]);
    end
    fprintf(fout, [') ;' NL]);
    a = att(v{i});
    for j = 1:length(a)
        fprintf(fout, [TAB TAB name(v{i}) ':' name(a{j}) ' = ']);
        x = a{j}(:);
        if ischar(x)
            fprintf(fout, ['"%s" ;' NL], x);
        else
            for k = 1:length(x)
                if k > 1, fprintf(fout, ', '); end
                fprintf(fout, num2str(x(k)));
            end
            fprintf(fout, [' ;' NL]);
        end
    end
end

% Data.

if theDataFlag
    fprintf(fout, ['data:' NL]);
	for i = 1:length(v)
        fprintf(fout, [TAB name(v{i}) ' = ' NL]);
        x = v{i}(:);
        theDataType = datatype(v{i});
        switch theDataType
            case 'char'
                CHUNK = CHUNKSIZE;
            case 'float'
                CHUNK = CHUNKSIZE;
            case 'double'
                CHUNK = ceil(CHUNKSIZE/2);
            otherwise
                CHUNK = CHUNKSIZE;
        end
        len = prod(size(x));
        for j = 1:len
            if rem(j, CHUNK) == 1
                fprintf(fout, [TAB TAB]);
            end
            switch theDataType
                case 'char'
                    fprintf(fout, [' ''%c'''], x(j));
                case 'float'
                    fprintf(fout, [' ' num2str(x(j), 7)]);
                case 'double'
                    fprintf(fout, [' ' num2str(x(j), 15)]);
                otherwise
                    fprintf(fout, [' ' int2str(x(j))]);
            end
            if j < len
                fprintf(fout, ',');
            else
                fprintf(fout, ';');
            end
            if j < len & rem(j, CHUNK) == 0
                fprintf(fout, NL);
            end
        end
        fprintf(fout, NL);
	end
end

fprintf(fout, ['}' NL]);

fclose(fout);

if ischar(theNetCDFFile)
    close(nc);
end
