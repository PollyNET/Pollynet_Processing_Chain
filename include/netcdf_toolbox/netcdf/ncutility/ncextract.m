function theResult = ncextract(theNCObject, theOutputName)

% ncextract -- GUI for NetCDF data extraction.
%  ncextract(theNCObject, 'theOutputName') presents a dialog
%   for guiding the extraction of the values associated with
%   theNCObject, a NetCDF variable or attribute object.  The
%   optional output-name defaults to "ans" in the "base"
%   workspace, unless an actual output argument is provided.
%  Matlab 5.1 -- This routine uses a "try/catch" test below.
%   Comment-out the lines designated below.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 27-Jul-2000 09:28:06.
% Updated    19-Aug-2002 14:09:55.

v = version;
f = find(v == '.');
v(f(2):end) = '';
if eval(v) < 5.2
	error(' ## Requires Matlab v5.2+')
end

if nargin < 1, help(mfilename), return, end
if nargin < 2, theOutputName = 'ans'; end

result = [];

if ~isa(theNCObject, 'ncvar') & ~isa(theNCObject, 'ncatt')
	disp([' ## ' mfilename ' -- The item must be a NetCDF variable or attribute.'])
	if nargout > 0, theResult = result; end
	return
end

theName = name(theNCObject);
theSize = ncsize(theNCObject);

Extract.Output = theOutputName;
for i = 1:length(theSize)
	label = ['Dim_' int2str(i)];
	indices = ['1:1:' int2str(theSize(i))];
	Extract = setfield(Extract, label, indices);
end

theTitle = ['NCExtract -- ' theName];
x = guido(Extract, theTitle);

% Matlab 5.1 -- Comment out the try/catch/disp/end statements.

try   % Comment if Matlab 5.1.
	if ~isempty(x)
		theOutputName = getinfo(x, 'Output');
		s = 'theNCObject(';
		for i = 1:length(theSize)
			label = ['Dim_' int2str(i)];
			indices = getinfo(x, label);
			if i > 1, s = [s ', ']; end
			s = [s indices];
		end
		s = [s ')'];
		result = eval(s);
		if nargout < 1
			assignin('base', theOutputName, result)
		end
	end
catch   % Comment if Matlab 5.1.
	disp([' ## ' mfilename ' -- error; try again.'])   % Comment if Matlab 5.1.
end   % Comment if Matlab 5.1.

if nargout > 0, theResult = result, end
