function tncbig(nBytes)

% tncbig -- Test allowed size of file.
%  tncbig(nBytes) creates a NetCDF file, then
%   an array of nBytes.  On Macintosh and PCWIN,
%   we have long had difficulty getting beyond
%   about 16K bytes, far too small for real work.
%   This has forced us to create larger files
%   on Unix machines.  Once created, such files
%   work on the smaller machines just fine.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 23-Feb-2000 08:43:12.
% Updated    23-Feb-2000 09:00:51.

if nargin < 1, nBytes = 2^16; help(mfilename), end
if ischar(nBytes), nBytes = eval(nBytes); end

theFilename = [mfilename '.nc'];

n = 0;

while n < nBytes
	n = n + 1000;
	disp([' ## n: ' int2str(n)])
	nc = netcdf(theFilename, 'clobber');
	nc('index') = n;
	nc{'x'} = ncbyte('index');
	x = nc{'x'};
	x(:) = zeros(1, n);
	status = close(nc);
	delete(theFilename)
	if ~isequal(status, [])
		disp(' ')
		disp([' ## Unable to close file on ' computer '.'])
		break
	end
end
