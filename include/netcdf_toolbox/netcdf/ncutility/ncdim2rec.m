function ncdim2rec(theNetCDF, theDim)

% ncdim2rec -- Convert static dimension to record dimension.
%  ncdim2rec(theNetCDF, theDim) converts one of the dimensions
%   of theNetCDF, given as theDim, to a record-dimension.
%   The arguments may be strings or NetCDF entities.
%   The chosen dimension must be left-most in all the
%   variables that use it.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Nov-2001 09:25:59.
% Updated    03-Mar-2003 16:25:27.

if nargin < 1, help(mfilename), return, end

if ischar(theNetCDF)
	theFilename = theNetCDF;
	theNetCDF = netcdf(theFilename, 'nowrite');
	if isempty(theNetCDF)
		disp([' ## Unable to open as NetCDF: "' theFilename '"'])
		return
	end
elseif ~isa(theNetCDF, 'netcdf')
	disp([' ## Not a "netcdf" object.'])
	return
end

if ischar(theDim)
	theDimname = theDim;
	theDim = theNetCDF(theDimname);
	if isempty(theDim)
		disp([' ## Not a NetCDF dimension: "' theDimname '"'])
		return
	end
elseif ~isa(theDim, 'ncdim')
	disp([' ## Not a NetCDF dimension.'])
end

if isrecdim(theDim)
	close(theNetCDF)
	disp([' ## Already is a NetCDF record-dimension: "' theDimname '"'])
	return
end

% Open a randomly-named temporary file.

for i = 1:100
	tmpname = ['temp' int2str(rand(1, 1)*10^9) '.nc'];
	f = netcdf(tmpname, 'noclobber');
	if ~isempty(f), break, end
end

if isempty(f)
	close(theNetCDF)
	disp([' ## Unable to open temporary NetCDF file.'])
	return
end

% Define the record-dimension.

theDimname = name(theDim);
f(theDimname) = 0;

% Pour everything into the new file.

f < theNetCDF;

% Get full filenames.

theNetCDFname = name(theNetCDF)
theTmpname = name(f)

% Close both files.

close(theNetCDF)
close(f)

% Copy temporary file to original name.

fcopy(theTmpname, theNetCDFname)

% Delete temporary file.

delete(theTmpname)
