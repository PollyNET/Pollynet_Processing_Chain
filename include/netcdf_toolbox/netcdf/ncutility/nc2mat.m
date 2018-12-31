function nc2mat(theNetCDF, theMat)

% nc2mat -- Convert NetCDF file to mat-file.
%  nc2mat('theNetCDF', 'theMat') creates 'theMat' file
%   from the contents of 'theNetCDF' file.  Dimensions,
%   variables, and attributes are named with prefixes
%   of 'D_', 'V_', and 'A_', respectively.
%   Global-attributes are prefixed by 'G'.  Names
%   that are not legal Matlab names are repaired with
%   '_' (underscore) for each invalid character, then
%   truncated to 31 characters.  Repaired names are not
%   checked for uniqueness.
%
%   See "help whos" and "help load" for information
%   about reading the contents of the mat-file.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 31-May-2001 14:07:35.
% Updated    31-May-2001 15:17:43.

if nargin < 1, help(mfilename), theNetCDF = '*'; end
if nargin < 2, theMat = '*'; end

if any(theNetCDF == '*')
	[f, p] = uigetfile(theNetCDF, 'Select a NetCDF File');
	if ~any(f), return, end
	if p(end) ~= filesep, p(end+1) = filesep; end
	theNetCDF = [p f];
end

if any(theMat == '*')
	[f, p] = uiputfile(theMat, 'Save As Mat File');
	if ~any(f), return, end
	if p(end) ~= filesep, p(end+1) = filesep; end
	theMat = [p f];
end

nc = netcdf(theNetCDF, 'nowrite');
if isempty(nc), return, end

Created_By = [mfilename '(''' theNetCDF ''', ''' theMat ''')   % ' datestr(now)];
save(theMat, 'Created_By')

% Global attributes.

gatts = att(nc);
for i = 1:length(gatts)
	gattname = ['G_' name(gatts{i})];
	gattname = repair_matlab_name(gattname);
	gattvalue = gatts{i}(:);
	eval([gattname ' = gattvalue;'])
	save(theMat, gattname, '-append')
end

% Dimensions.

dims = dim(nc);
for i = 1:length(dims)
	dimname = name(dims{i});
	dimname = ['D_' dimname];
	dimname = repair_matlab_name(dimname);
	dimlen = ncsize(dims{i});
	eval([dimname ' = dimlen;'])
	save(theMat, dimname, '-append')
	clear(dimname)
end

% Variables and attributes.

vars = var(nc);
for i = 1:length(vars)
	varname = ['V_' name(vars{i})];
	varname = repair_matlab_name(varname);
	atts = att(vars{i});
	for j = 1:length(atts)
		attname = [varname '_A_' name(atts{j})];
		attname = repair_matlab_name(attname);
		attvalue = atts{j}(:);
		eval([attname ' = attvalue;'])
		save(theMat, attname, '-append')
	end
	varvalue = vars{i}(:);
	eval([varname ' = varvalue;'])
	save(theMat, varname, '-append')
end

nc = close(nc);

disp(' ')
disp([' ## Contents of "' theMat '":'])
disp(' ')

whos('-file', theMat)

function y = repair_matlab_name(x, replacement)

% repair_matlab_name -- Convert to valid Matlab name.
%  repair_matlab_name('theName') converts 'theName' to
%   a valid Matlab name by replacing invalid
%   characters with '_' (underscore).  Names
%   are then truncated to 31 characters.
%  repair_name('theName', 'c') uses 'c' as the
%   replacement character.

if nargin < 2, replacement = '_'; end

f = (x == '_') | ...
		(x >= 'A' & x <= 'Z') | ...
		(x >= 'a' & x <= 'z') | ...
		(x >= '0' & x <= '9');

if any(x(1) == ['_0123456789'])
	f(1) = ~~0;
end

y = x;

if any(~f)
	y(~f) = replacement;
	if ~f(1), y = ['x' y]; end
end

if length(y) > 31, y = y(1:31); end
