function tmexcdf

% TMEXCDF Test of MEXCDF Mex-file routines.
 
% Copyright (C) 1992-4 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

% Version of 20-Jan-94.
% Version of 19-Dec-96.
% Version of 15-Jul-1997 08:11:51.

v = version;
if v(1) == '4'
   if exist('mexcdf4') ~= 3
      disp([' ## TMEXCDF -- Please install the "mexcdf4" Mex-file'])
      disp([' ##            or adjust Matlab path, then try again.'])
      return
   end
  elseif v(1) == '5'
   if exist('mexcdf53') ~= 3
      disp([' ## TMEXCDF -- Please install the "mexcdf53" Mex-file'])
      disp([' ##            or adjust Matlab path, then try again.'])
      return
   end
end

% Test of conventional functions.

tic

filename = 'foo.nc';
disp(['    TMEXCDF: Using file ' filename]);

mexcdf('setopts', 0);   % Quiet mode.

for i = 0:3
   status = mexcdf('close', i);
end

cdfid = mexcdf('create', filename, 'clobber');
begets('create', 0, cdfid)

if cdfid < 0, disp('Bad cdfid.'), return, end

dlat = mexcdf('dimdef', cdfid, 'lat', 10);
dlon = mexcdf('dimdef', cdfid, 'lon', 5);
dtime = mexcdf('dimdef', cdfid, 'time', 'unlimited');

vlat = mexcdf('vardef', cdfid, 'lat', 'long', -1, dlat);
vlon = mexcdf('vardef', cdfid, 'lon', 'long', -1, dlon);
vtime = mexcdf('vardef', cdfid, 'time', 'long', -1, dtime);

dims = [dtime dlat dlon];

vz = mexcdf('vardef', cdfid, 'z', 'long', -1, dims);
vt = mexcdf('vardef', cdfid, 't', 'long', -1, dims);
vp = mexcdf('vardef', cdfid, 'p', 'double', -1, dims);
vrh = mexcdf('vardef', cdfid, 'rh', 'long', -1, dims);

status = mexcdf('attput', cdfid, vlat, 'scale_factor', 'double', -1, 2);
begets('attput', 1, 'scale_factor', status)
status = mexcdf('attput', cdfid, vlat, 'add_offset', 'double', -1, 100);
begets('attput', 1, 'add_offset', status)

[value, status] = mexcdf('attget', cdfid, vlat, 'scale_factor');
begets('attget', 1, 'scale_factor', value, status)
[value, status] = mexcdf('attget', cdfid, vlat, 'add_offset');
begets('attget', 1, 'add_offset', value, status)

status = mexcdf('attput', cdfid, vlat, 'units', 'char', -1, 'degrees_north');
status = mexcdf('attput', cdfid, vlon, 'units', 'char', -1, 'degrees_east');
status = mexcdf('attput', cdfid, vtime, 'units', 'char', -1, 'seconds');

status = mexcdf('attput', cdfid, vz, 'units', 'char', -1, 'meters');
status = mexcdf('attput', cdfid, vz, 'valid_range', 'float', -1, [0 5000]);

status = mexcdf('attput', cdfid, vp, '_FillValue', 'double', -1, -9999);
status = mexcdf('attput', cdfid, vp, '_FillValue', 'double', -1, NaN);
status = mexcdf('attput', cdfid, vp, '_FillValue', 'double', -1, Inf);
status = mexcdf('attput', cdfid, vp, '_FillValue', 'double', -1, -Inf);

status = mexcdf('attput', cdfid, vrh, '_FillValue', 'long', -1, -1);

status = mexcdf('endef', cdfid);
begets('endef', 0, status);

[ndims, nvars, natts, recdim, status] = mexcdf('inquire', cdfid);
result = [ndims nvars natts recdim status];
begets('incquire', 1, cdfid, result)

for i = 0:ndims-1
   [name, len, status] = mexcdf('diminq', cdfid, i);
   begets('diminq', 2, cdfid, i, name, len, status)
end

for i = 0:nvars-1
   [name, datatype, ndims, dim, natts, status] = mexcdf('varinq', cdfid, i);
   begets('varinq', 2, cdfid, i, name, datatype, ndims, dim, natts, status)
   for j = 0:natts-1
      [name, status] = mexcdf('attname', cdfid, i, j);
      begets('attname', 3, cdfid, i, j, name, status)
      [value, status] = mexcdf('attget', cdfid, i, name);
      begets('attget', 3, cdfid, i, name, value, status)
   end
end

lat = [0 10 20 30 40 50 60 70 80 90].';
lon = [-140 -118 -96 -84 -52].';

for i = 1:length(lat)
   status = mexcdf('varput1', cdfid, vlat, i-1, lat(i));
   begets('varput1', 0, status)
   [value, status] = mexcdf('varget1', cdfid, vlat, i-1);
   begets('varget1', 0, value, status)
end

[value, status] = mexcdf('vargetg', cdfid, vlat, 0, 10, 1, []);
if value ~= lat(1:10), error('vargetg'), end

status = mexcdf('varputg', cdfid, vlat, 0, 5, 2, [], lat(1:5));
[value, status] = mexcdf('vargetg', cdfid, vlat, 0, 10, 1, []);
if value ~= lat(1:10), error('varputg/getg'), end

[value, status] = mexcdf('vargetg', cdfid, vlat, 0, 5, 2, []);
if value ~= lat(1:5), error('varputg/getg'), end

status = mexcdf('close', cdfid);
begets('close', 0, status)

cdfid = mexcdf('open', filename, 'write');
begets('open', 0, cdfid)

if cdfid < 0, disp('Bad cdfid.'), return, end

vlat = mexcdf('varid', cdfid, 'lat');
begets('varid', 0, vlat);

status = mexcdf('attput', cdfid, vlat, 'scale_factor', 'double', -1, 1);
begets('attput', 1, 'scale_factor', status)
status = mexcdf('attput', cdfid, vlat, 'add_offset', 'double', -1, 0);
begets('attput', 1, 'add_offset', status)

[value, status] = mexcdf('attget', cdfid, vlat, 'scale_factor');
begets('attget', 1, 'scale_factor', value, status)
[value, status] = mexcdf('attget', cdfid, vlat, 'add_offset');
begets('attget', 1, 'add_offset', value, status)

[value, status] = mexcdf('varget', cdfid, vlat, 0, length(lat));
begets('varget', 0, value, status)

status = mexcdf('varput', cdfid, vlat, 0, length(lat), lat);
status = mexcdf('varput', cdfid, vlat, 0, -1, lat);
begets('varput', 0, status)

[value, status] = mexcdf('varget', cdfid, vlat, 0, length(lat));
[value, status] = mexcdf('varget', cdfid, vlat, 0, -1);
begets('varget', 0, value, status)

status = mexcdf('close', cdfid);
begets('close', 0, status)

toc

% Test of functions dealing with records.

if (1)

disp(' ## TMEXCDF: Record-testing...')
ncid = mexcdf('open', filename, 'write');
[ndims, nvars, natts, recid, status] = mexcdf('inquire', ncid);
[dimname, dimlen, status] = mexcdf('diminq', ncid, recid);
[recvars, recsizes, status] = mexcdf('recinq', ncid);
oldopts = mexcdf('setopts', 0);
nrecords = dimlen;
good = 0;
recdata = 1:sum(recsizes);
nrecords = 2;
for i = 0:nrecords-1
   if (1)
      status = mexcdf('recput', ncid, i, recdata);
      recdata1 = mexcdf('recget', ncid, i);
      status = mexcdf('recput', ncid, i, recdata1);
      recdata2 = mexcdf('recget', ncid, i);
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
mexcdf('setopts', oldopts);
status = mexcdf('close', ncid);

if good == nrecords
   disp(' ## TMEXCDF: Record-testing successful.')
  else
   disp(' ## TMEXCDF: Record-testing not successful.')
end

end
