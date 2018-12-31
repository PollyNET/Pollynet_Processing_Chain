function ncdimadd(theSrcFile, theDstFile, theDimName, theDimLength)

% ncdimadd -- Add a dimension to a NetCDF file.
%  ncdimadd(theSrcFile, theDstFile, 'theDimName', theDimLength)
%   copies the components of theSrcFile to theDstFile (either
%   filenames or "netcdf" objects), and adds the given dimension.
%   If originally open, the files remain open.  NOTE: theDstFile
%   must be new or never have been closed or placed in "data" mode
%   previously.  If to be created, "clobber" permission is used.
%   To add more than one dimension, use cell-arrays for the names
%   and lengths.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Oct-1999 10:48:23.
% Updated    06-Oct-1999 11:41:43.

if nargin < 4, help(mfilename), return, end

if ischar(theDimLength)
	theDimLength = eval(theDimLength);
end

% Open source file.

if isa('netcdf', theSrcFile)
	f = theSrcFile;
else
	f = netcdf(theSrcFile, 'nowrite');
end

% Open destination file.

if isempty(f), return, end

if isa('netcdf', theDstFile)
	g = theDstFile;
else
	g = netcdf(theDstFile, 'clobber');
end

if isempty(g), close(f), return, end

% Check destination for "data" mode.

theMode = mode(g);
switch theMode
case 'data'
	disp(' ## Output file requires "define" mode initially.')
	close(g), close(f), return
end

% Copy.

disp([' ## Source file:      ' name(f)])
disp([' ## Destination file: ' name(f)])

g < att(f);   % Copy existing global attributes.
g < dim(f);   % Copy existing dimensions.

if ~iscell(theDimName)
	theDimName = {theDimName};
end

if ~iscell(theDimLength)
	theDimLength = {theDimLength};
end

% Too few dimension lengths provided; adjust.

while length(theDimLength) < length(theDimName)
	theDimLength{end+1} = theDimLength{end};
end

% Add new dimensions.

nDims = length(theDimName);

for i = 1:nDims
	disp([' ## ' int2str(nDims-i+1) ' Defining dimension: ' theDimName{i}])
	g(theDimName{i}) = theDimLength{i};
end

% Define existing variables and attributes.

v = var(f);
nVars = length(v);

for i = 1:nVars
	disp([' ## ' int2str(nVars-i+1) ' Defining variable: ' name(v{i})])
	copy(v{i}, g, 0, 1, 1);
end

% Fill existing variables.

for i = 1:nVars
	disp([' ## ' int2str(nVars-i+1) ' Filling variable: ' name(v{i})])
	copy(v{i}, g, 1, 0, 0);
end

% Close files.

if ischar(theDstFile)
	g = close(g);
	if ~isempty(g)
		disp(' ## Unable to close destination file.')
	end
end

if ischar(theSrcFile)
	f = close(f);
	if ~isempty(f)
		disp(' ## Unable to close source file.')
	end
end
