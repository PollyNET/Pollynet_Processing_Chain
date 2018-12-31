function theResult = mat2nc(theMatFile, theNetCDFFile, uniqueDims, noSqueeze)

% mat2nc -- Convert Matlab Mat-file to NetCDF file.
%  mat2nc('theMatFile', 'theNetCDFFile') converts the
%   "double", "single", "char", and "uint8" components of 'theMatFile'
%   to dimensioned variables in 'theNetCDFFile'.  Items embedded
%   in "struct" and "cell" objects are named with the appropriate
%   Matlab subscripting operators.  Empty entities are stored as
%   NetCDF scalars.  Each item can be reconstituted by assigning
%   its contents to its "original_name", an attribute.
%   Filenames are entered via dialog if not provided as input
%   arguments, or if provided as empty strings.  The mat-file
%   name can be wild-carded with '*'.
%   If an output argument is given, the "netcdf" object is
%   returned and the NetCDF file itself remains open.  The
%   "uniqueDims" argument defaults to 0 (FALSE), which means
%   that only enough NetCDF dimensions to meet the minimal needs
%   of the data will be generated.  If non-zero (TRUE), then
%   each variable will be given unique NetCDF dimensions.
%   (Note: the typical NetCDF file allows up to 100 dimensions.)
%  mat2nc(theMatFile, theNetCDFFile, uniqueDims, noSqueeze)
%   defines unique dimensions to each variable if uniqueDims is
%   logically TRUE; otherwise, dimensions of the same size are
%   recycled.  If noSqueeze is logically TRUE, all singleton
%   dimensions are left intact; otherwise, they are squeezed
%   out before storage, except that scalar values are given
%   a single dimension of 1.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-May-1998 20:44:58.   % Original.
% Updated    02-Jun-1998 14:33:02.   % Dimensions recycled.
% Updated    16-Jul-1998 06:25:54.   % Singletons squeezed.
% Updated    09-Apr-2003 10:47:45.

TESTING = 0;

if nargout > 0, theResult = []; end

% Get the file names if not provided.

if nargin < 1, theMatFile = ''; end
if nargin < 2, theNetCDFFile = ''; end
if nargin < 3, uniqueDims = 0; end
if nargin < 4, noSqueeze = 0; end

if ischar(uniqueDims), uniqueDims = eval(uniqueDims); end
if ischar(noSqueeze), noSqueeze = eval(noSqueeze); end

uniqueDims = any(uniqueDims);
noSqueeze = any(noSqueeze);

if isempty(theMatFile), theMatFile = '*'; end

if any(theMatFile == '*')
	help(mfilename)
	[theFile, thePath] = uigetfile(theMatFile, 'Select A Mat-File:');
	if ~any(theFile)
		disp(' ## No Mat-file selected.')
		return
	end
	theMatFile = [thePath theFile];
end

theSuggested = theMatFile;
f = find(theSuggested == '.');
if any(f)
	theSuggested(f(1):length(theSuggested)) = '';
end
f = find(theSuggested == filesep);
if any(f)
	theSuggested(1:f(length(f))) = '';
end
theSuggested = [theSuggested '.nc'];

if isempty(theNetCDFFile)
	[theFile, thePath] = uiputfile(theSuggested, 'Save As NetCDF File:');
	if ~any(theFile)
		disp(' ## No NetCDF file selected.')
		return
	end
	theNetCDFFile = [thePath theFile];
end

% Save the "base" workspace, then load the Mat-file
%  into it, in order to avoid name collisions with
%  the present routine.  We do this first to make
%  sure that enough memory is available, before
%  proceeding with the NetCDF allocations.  The
%  "base" workspace is restored at the end.

theTempFile = 'mat2nc_temp.mat';
evalin('base', ['save ' theTempFile])
evalin('base', 'clear variables')
evalin('base', ['load ' theMatFile])

% Create the output NetCDF file.

nc = netcdf(theNetCDFFile, 'clobber');
if isempty(nc)
	disp([' ## Unable to create NetCDF file: ' theNetCDFFile])
	return
end

nc.CreationDate = datestr(now);
nc.CreatedBy = which(mfilename);
nc.CreatedFrom = which(theMatFile);

% Get the Mat-file directory.

w = whos('-file', theMatFile);

% Expand the directory for "struct" and "cell" data.

k = 0;
while k < length(w)
	k = k + 1;
	switch w(k).class
	case {'struct', 'cell'}
		x = evalin('base', w(k).name);
		f = partnames(x, w(k).name);
		j = length(w);
		len = length(f);
		w(j+len) = w(j);   % Lengthen.
		for i = 1:length(f)
			a = evalin('base', f{i});
			j = j + 1;
			w(j).name = f{i};
			w(j).size = size(a);
			w(j).class = class(a);
		end
	end
end

% Cull the "struct" and "cell" entries.

for k = length(w):-1:1
	switch lower(w(k).class)
	case {'struct', 'cell'}
		w(k) = [];
	end
end

% Define the NetCDF dimensions.
%  If "uniqueDims" is TRUE, we provide unique
%  dimensions for each variable.  If "noSqueeze"
%  is TRUE, we leave all singleton dimensions
%  intact.

theVars = [];
theDimCount = 0;
for j = 1:length(w)
	theVars(j).name = w(j).name;
	theVars(j).class = w(j).class;
	theDims = {};
	theSize = w(j).size;
	f = find(theSize == 1);
	if ~noSqueeze   % Squeeze.
		if any(f), theSize(f)  = []; end
		if isempty(theSize), theSize = 1; end
	end
	if prod(theSize) > 0
		for i = 1:length(theSize)
			theDimCount = theDimCount+1;
			if uniqueDims   % Unique dimensions.
				theDimName = ['dim_' int2str(theDimCount)];
			else
				theDimName = ['dim_' int2str(theSize(i))];
			end
			if isempty(nc(theDimName))
				nc(theDimName) = theSize(i);
			end
			theDim = nc(theDimName);
			if isempty(theDim)
				disp([' ## Dimension not defined: ' theDimName])
			end
			theDims{i} = theDim;
		end
	end
	theVars(j).size = theSize;
	theVars(j).dims = theDims;
	theVars(j).var = [];
end

if (TESTING), nc = redef(sync(endef(nc))); end

% Define the NetCDF variables.

if (TESTING), theVars = theVars(1:min(length(theVars),24)); end

for j = 1:length(theVars)
	theDims = theVars(j).dims;
	if ~isempty(theDims) | 1
		theDimNames = ncnames(theDims);
		theVar = [];
		theVarName = ncnamesafe(theVars(j).name);
		switch theVars(j).class
		case 'char'
			nc{theVarName} = ncchar(theDimNames{:});
			theVar = nc{theVarName};
		case 'double'
			nc{theVarName} = ncdouble(theDimNames{:});
			theVar = nc{theVarName};
		case 'single'
			nc{theVarName} = ncfloat(theDimNames{:});
			theVar = nc{theVarName};
		case 'uint8'
			nc{theVarName} = ncbyte(theDimNames{:});
			theVar = nc{theVarName};
		otherwise
		end
		if isempty(theVar)
			disp([' ## Variable not defined: ' theVarName])
		end
		theVars(j).var = theVar;
		if ~isempty(theVar)
			theVar.original_name = theVars(j).name;
			if isempty(size(theVar))
				theVar.isEmpty = 'item-is-empty';
			end
			a = evalin('base', theVars(j).name, 'no-value-assigned');
			if isequal(a, 'no-value-assigned')
				theVar.noValue = 'no-value-assigned';
			end
		end
	end
end

if (TESTING), nc = sync(endef(nc)); end

% Populate the NetCDF variables, checking for
%  empty items and those with no assigned value.

for j = 1:length(theVars)
	theVar = theVars(j).var;
	if ~isempty(theVar)
		if isempty(size(theVar))
			theVar(:) = 0;  % NetCDF requires a value.
		else
			a = evalin('base', theVars(j).name, 'no-value-assigned');
			if ~isequal(a, 'no-value-assigned')
                try
				    theVar(:) = a;
                catch
                    disp([' ## Unable to write data to: ' name(theVar)])
                    disp([' ## ' lasterr])
                    disp(' ')
                end
			end
		end
	end
end

% Restore the "base" workspace.

evalin('base', 'clear variables')
evalin('base', ['load ' theTempFile])
delete(theTempFile)

% Done.

if nargout > 0
	theResult = nc;
else
	close(nc)
end

function theResult = ncnamesafe(theName)

% ncnamesafe -- Name cleanup for NetCDF 3.
%  ncnamesafe('theName') makes 'theName'
%   safe for use as a NetCDF name.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Aug-1998 10:51:31.

TESTING = 0;

c = '()[]{}';   % No longer allowed.

if (TESTING), c = [c '.-']; end

result = theName;
for i = 1:length(c)
	result = strrep(result, c(i), '_');
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
