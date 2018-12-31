function tncorder(m, n)

% tncorder -- Test of NetCDF row vs. column dominance.
%  tncorder(m, n) shows how a Matlab array of size [m n]
%   is actually stored in a NetCDF file.
 
% Copyright (C) 2002 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Oct-2002 16:59:50.
% Updated    18-Oct-2002 16:59:50.

if nargin < 1, help(mfilename), m = 3; end
if nargin < 2, n = m; end

if ischar(m), m = eval(m); end
if ischar(n), n = eval(n); end

fclose('all');

ncfile = [mfilename '.nc'];

nc = netcdf(ncfile, 'clobber');

nc('i') = m;
nc('j') = n;

nc{'x'} = ncdouble('i', 'j');

matlab_array = zeros(m, n);
matlab_array(:) = 1:prod(size(matlab_array));

nc{'x'}(:) = matlab_array;

close(nc)

ptr = wcvarptr(ncfile, 'x');

fid = fopen(ncfile, 'r');
fseek(fid, ptr, 'bof');
in_netcdf_file = fread(fid, [1, 9], 'double');
fclose(fid);

delete(ncfile)

matlab_array
in_netcdf_file

a = matlab_array;
b = in_netcdf_file;

if min(m, n) > 1
	if a(:) == b(:)
        disp(' ## Matlab array is stored by columns in NetCDF.')
	else
        disp(' ## Matlab array is stored by rows in NetCDF.')
	end
end
