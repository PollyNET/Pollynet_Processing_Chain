function status = ncrecput(ncid, recnum, data, ...
                              autoscale, recdim)

% ncrecget -- Emulator for broken mexcdf('recput', ...).
%  status = ncrecput(ncid, recnum, data, autoscale) writes
%   the record whose record number is recnum, to the netcdf
%   file whose id is ncid.  The data are expected to be
%   a single row-vector.  If autoscale is non-zero, then
%   the autoscale facility will be invoked.  if recdim is
%   provided, it substitutes for the actual recdim in the
%   file, if any.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1, help ncrecput; return, end
if nargin < 4, autoscale = 0; end
if nargin < 5, recdim = -1; end

if recdim == -1
   [ndims, nvars, ngatts, recdim] = ncmex('inquire', ncid);
  else
   [ndims, nvars, ngatts] = ncmex('inquire', ncid);
end

if recdim >= ndims, error(' ## Invalid recdim.'), end

status = 0;
[varids, varsizes, status] = ncmex('recinq', ncid);
if status == -1, return, end

k = 0;
for i = 1:length(varids)
   [varname, datatype, ndims, dimids, natts, status] = ...
      ncmex('varinq', ncid, varids(i));
   if status == -1, return, end
   dimsizes = zeros(1, ndims);
   for j = 1:ndims
      [dimname, dimsize, status] = ...
         ncmex('diminq', ncid, dimids(j));
      if dimsize == 0, dimsize = 1; end
      if status == -1, return, end
      dimsizes(j) = dimsize;
   end
   f = find(dimids == recdim);
   starts = dimsizes .* 0;
   starts(f) = recnum;
   counts = dimsizes;
   counts(f) = 1;
   x = data(k+1:k+prod(counts));
   status = ...
      ncmex('varput', ncid, varids(i), starts, counts, x, autoscale);
   if status == -1, return, end
   k = k + prod(counts);
end
