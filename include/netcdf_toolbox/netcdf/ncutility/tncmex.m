function tncmex

% TNCMEX -- Test of NCMEX routine, similar to TMEXCDF.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 13-Mar-97.
% Version of 15-Jul-1997 08:11:51.
% Updated    08-Dec-2000 13:46:14.

% Test of conventional functions.

tic

filename = 'foo.nc';
disp(['    TNCMEX: Using file ' filename]);

ncmex('setopts', 0);   % Quiet mode.

for i = 0:3
   status = ncmex('close', i);
end

cdfid = ncmex('create', filename, 'clobber');
begets('create', 0, cdfid)

if cdfid < 0, disp('Bad cdfid.'), return, end

dlat = ncmex('dimdef', cdfid, 'lat', 10);
dlon = ncmex('dimdef', cdfid, 'lon', 5);
dtime = ncmex('dimdef', cdfid, 'time', 'unlimited');

vlat = ncmex('vardef', cdfid, 'lat', 'long', -1, dlat);
vlon = ncmex('vardef', cdfid, 'lon', 'long', -1, dlon);
vtime = ncmex('vardef', cdfid, 'time', 'long', -1, dtime);

dims = [dtime dlat dlon];

vz = ncmex('vardef', cdfid, 'z', 'long', -1, dims);
vt = ncmex('vardef', cdfid, 't', 'long', -1, dims);
vp = ncmex('vardef', cdfid, 'p', 'double', -1, dims);
vrh = ncmex('vardef', cdfid, 'rh', 'long', -1, dims);

status = ncmex('attput', cdfid, vlat, 'scale_factor', 'double', -1, 2);
begets('attput', 1, 'scale_factor', status)
status = ncmex('attput', cdfid, vlat, 'add_offset', 'double', -1, 100);
begets('attput', 1, 'add_offset', status)

[value, status] = ncmex('attget', cdfid, vlat, 'scale_factor');
begets('attget', 1, 'scale_factor', value, status)
[value, status] = ncmex('attget', cdfid, vlat, 'add_offset');
begets('attget', 1, 'add_offset', value, status)

if (1)

status = ncmex('attput', cdfid, vlat, 'units', 'char', -1, 'degrees_north');
status = ncmex('attput', cdfid, vlon, 'units', 'char', -1, 'degrees_east');
status = ncmex('attput', cdfid, vtime, 'units', 'char', -1, 'seconds');

status = ncmex('attput', cdfid, vz, 'units', 'char', -1, 'meters');
status = ncmex('attput', cdfid, vz, 'valid_range', 'float', -1, [0 5000]);

end

status = ncmex('attput', cdfid, vp, '_FillValue', 'double', -1, -9999);
status = ncmex('attput', cdfid, vp, '_FillValue', 'double', -1, NaN);
status = ncmex('attput', cdfid, vp, '_FillValue', 'double', -1, Inf);
status = ncmex('attput', cdfid, vp, '_FillValue', 'double', -1, -Inf);

status = ncmex('attput', cdfid, vrh, '_FillValue', 'long', -1, -1);

status = ncmex('endef', cdfid);
begets('endef', 0, status);

[ndims, nvars, natts, recdim, status] = ncmex('inquire', cdfid);
result = [ndims nvars natts recdim status];
begets('incquire', 1, cdfid, result)

for i = 0:ndims-1
   [name, len, status] = ncmex('diminq', cdfid, i);
   begets('diminq', 2, cdfid, i, name, len, status)
end

for i = 0:nvars-1
   [name, datatype, ndims, dim, natts, status] = ncmex('varinq', cdfid, i);
   begets('varinq', 2, cdfid, i, name, datatype, ndims, dim, natts, status)
   for j = 0:natts-1
      [name, status] = ncmex('attname', cdfid, i, j);
      begets('attname', 3, cdfid, i, j, name, status)
      [value, status] = ncmex('attget', cdfid, i, name);
      begets('attget', 3, cdfid, i, name, value, status)
   end
end

if (0), ncmex('close', cdfid), return, end

lat = [0 10 20 30 40 50 60 70 80 90];
lon = [-140 -118 -96 -84 -52];

for i = 1:length(lat)
   status = ncmex('varput1', cdfid, vlat, i-1, lat(i));
   begets('varput1', 0, status)
   [value, status] = ncmex('varget1', cdfid, vlat, i-1);
   begets('varget1', 0, value, status)
end

if (1)

[value, status] = ncmex('vargetg', cdfid, vlat, 0, 10, 1, []);
if value ~= lat(1:10), error('vargetg'), end

status = ncmex('varputg', cdfid, vlat, 0, 5, 2, [], lat(1:5));
[value, status] = ncmex('vargetg', cdfid, vlat, 0, 10, 1, []);
if value ~= lat(1:10), error('varputg/getg'), end

[value, status] = ncmex('vargetg', cdfid, vlat, 0, 5, 2, []);
if value ~= lat(1:5), error('varputg/getg'), end

end

status = ncmex('close', cdfid);
begets('close', 0, status)

cdfid = ncmex('open', filename, 'write');
begets('open', 0, cdfid)

if cdfid < 0, disp('Bad cdfid.'), return, end

vlat = ncmex('varid', cdfid, 'lat');
begets('varid', 0, vlat);

status = ncmex('attput', cdfid, vlat, 'scale_factor', 'double', -1, 1);
begets('attput', 1, 'scale_factor', status)
status = ncmex('attput', cdfid, vlat, 'add_offset', 'double', -1, 0);
begets('attput', 1, 'add_offset', status)

[value, status] = ncmex('attget', cdfid, vlat, 'scale_factor');
begets('attget', 1, 'scale_factor', value, status)
[value, status] = ncmex('attget', cdfid, vlat, 'add_offset');
begets('attget', 1, 'add_offset', value, status)

if (1)

[value, status] = ncmex('varget', cdfid, vlat, 0, length(lat));
begets('varget', 0, value, status)

status = ncmex('varput', cdfid, vlat, 0, length(lat), lat);
status = ncmex('varput', cdfid, vlat, 0, -1, lat);
begets('varput', 0, status)

[value, status] = ncmex('varget', cdfid, vlat, 0, length(lat));
[value, status] = ncmex('varget', cdfid, vlat, 0, -1);
begets('varget', 0, value, status)

end

status = ncmex('close', cdfid);
begets('close', 0, status)

toc

% Test of functions dealing with records.

if (1)

disp(' ## TNCMEX: Record-testing using ncmex...')
ncid = ncmex('open', filename, 'write');
[ndims, nvars, natts, recid, status] = ncmex('inquire', ncid);
[dimname, dimlen, status] = ncmex('diminq', ncid, recid);
[recvars, recsizes, status] = ncmex('recinq', ncid);
oldopts = ncmex('setopts', 0);
nrecords = dimlen;
good = 0;
recdata = 1:sum(recsizes);
nrecords = 2;
for i = 0:nrecords-1
   if (0)
      status = ncmex('recput', ncid, i, recdata);
      recdata1 = ncmex('recget', ncid, i);
      status = ncmex('recput', ncid, i, recdata1);
      recdata2 = ncmex('recget', ncid, i);
     else
      status = ncrecput(ncid, i, recdata);
      recdata1 = ncrecget(ncid, i);
      status = ncrecput(ncid, i, recdata1);
      recdata2 = ncrecget(ncid, i);
   end
   if any(recdata2 ~= recdata)
      disp([' ## Bad round-trip: record #' int2str(i)])
     else
      good = good + 1;
   end
end
ncmex('setopts', oldopts);
status = ncmex('close', ncid);

if good == nrecords
   disp(' ## TNCMEX: Record-testing successful.')
  else
   disp(' ## TNCMEX: Record-testing not successful.')
end

end
