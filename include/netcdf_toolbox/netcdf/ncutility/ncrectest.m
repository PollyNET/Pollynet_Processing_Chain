function ncrectest(nrecords)

% ncrectest -- Test of ncrecput/ncrecget.
%  ncrectest(nrecords) exercises the netcdf test-file
%   'foo.cdf' by writing/reading nrecords, using
%   ncrecinq(), ncrecput() and ncrecget().
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.
 
% Version of 17-Apr-96 at 16:45:57.08.
% Updated    08-Dec-2000 13:58:07.

if nargin < 1, nrecords = 1; end

x = 1:201;

ncid = ncmex('open', 'foo.cdf', 'write');

[varids, varsizes, status] = ncrecinq(ncid);

disp(' ## Variable ids and sizes:')
disp([varids; varsizes])

varid = 2;
for recnum = 0:nrecords-1
   status = ncmex('varput', ncid, varid, recnum, 1, 9999);
   [d, status] = ncmex('varget', ncid, varid, recnum, 1);
end

okay = 1;

d = [];
for recnum = 0:nrecords-1
   status = ncrecput(ncid, recnum, x);
   [d, status] = ncrecget(ncid, recnum);
   if any(d(:) ~= x(:))
      disp([' ## Bad round trip: record ' int2str(recnum)])
      okay = 0;
   end
end

status = ncmex('close', ncid);

if okay, disp(' ## Successful test.'), end
