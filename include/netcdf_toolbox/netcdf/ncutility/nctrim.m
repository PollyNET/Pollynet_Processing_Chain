function theResult = nctrim(theSrc, theDst, theIndices, theRecdim, isVerbose)

% nctrim -- Trim records in a NetCDF file.
%  nctrim('theSrc', 'theDst', theIndices, 'theRecdim')
%   copies 'theSrc' NetCDF file to 'theDst', trimming
%   all record-variables to just theIndices.  The
%   "apparent" record-dimension name can be specified
%   in 'theRecdim' -- it must be the left-most dimension
%   in variables that are to be treated as record-variables.
%   Defaults: '', '', [], ''.
%  nctrim('', ...) invokes the "uigetfile" dialog.
%  nctrim(..., isVerbose) displays progress information
%   if isVerbose is logically TRUE.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Jan-1998 14:27:57.
% Updated    10-Aug-1999 16:30:19.

if nargin < 1, help(mfilename), return, end

if nargin < 2, theDst = ''; end
if nargin < 3, theIndices = []; end
if nargin < 5, isVerbose = 0; end

if nargout > 0, theResult = []; end

% Open the source file.

if isempty(theSrc)
    src = netcdf('nowrite')
elseif ischar(theSrc)
    src = netcdf(theSrc, 'nowrite')
elseif isa(theSrc, 'ncitem')
    src = parent(parent(theSrc));
else
    disp(' ## Unknown source argument.')
    return
end
if isempty(src)
    disp(' ## No source file.')
    return
end

% Get the record-dimension.

if nargin < 4, theRecdim = recdim(src); end

if isempty(theRecdim)
    disp(' ## No record-dimension found.')
    close(src)
    return
end

% Open the destination file.

if isempty(theDst)
    dst = netcdf('clobber')
elseif ischar(theDst)
    dst = netcdf(theDst, 'clobber')
elseif isa(theSrc, 'ncitem')
    dst = parent(parent(theDst));
    theDst = name(dst);
    close(dst)
    dst = netcdf(theDst, 'clobber')
else
    close(src)
    disp(' ## Unknown destination argument.')
    return
end
if isempty(dst)
    close(src)
    disp(' ## No destination file.')
    return
end

% Copy the global attributes.

dst < att(src);

if ~isempty(theRecdim) & ischar(theRecdim)
    theRecdim = src(theRecdim)
else
    theRecdim = recdim(src)
end

% Define the destination dimensions.

theDims = dim(src);
for i = 1:length(theDims)
    theSize = size(theDims{i});
    if isequal(name(theDims{i}), name(theRecdim))
        theSize = 0;
    end
    dst(name(theDims{i})) = theSize;
end

% Define the destination variables and attributes.

theVars = var(src);
for i = 1:length(theVars)
    copyData = 0;
    copyAtts = 1;
    copy(theVars{i}, dst, copyData, copyAtts);
end

% Copy the fixed-variable data.

for i = 1:length(theVars)
    theDims = dim(theVars{i});
    if length(theDims) > 0
        if ~isequal(name(theDims{1}), name(theRecdim))
			if isVerbose
				disp([' ## ' mfilename ': copying "' name(theVars{i}) '"'])
			end
            dst{name(theVars{i})}(:) = theVars{i}(:);
        end
    else
        dst{name(theVars{i})}(:) = theVars{i}(:);
    end
end

% Copy the trimmed record-variable data.

if length(theIndices) > 0
    theIndices = sort(theIndices);       % Indices sorted.
    f = find(diff(theIndices) == 0);
    if any(f), theIndices(f) = []; end   % Unique indices only.
    k = 1:length(theIndices);
    for i = 1:length(theVars)
        theDims = dim(theVars{i});
        if length(theDims) > 0
            if isequal(name(theDims{1}), name(theRecdim))
				if isVerbose
					disp([' ## ' mfilename ': trimming "' name(theVars{i}) '"'])
				end
                dst{name(theVars{i})}(k, :) = theVars{i}(theIndices, :);
            end
        end
    end
end

% Done.

close(src)             % Close src.
if nargout > 0
    theResult = dst;   % Keep dst open.
else
    close(dst)         % Close dst.
end
