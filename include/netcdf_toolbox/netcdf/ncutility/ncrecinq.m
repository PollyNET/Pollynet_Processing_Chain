function [varids, varsizes, status] = ncrecinq(ncid, recdim)

% ncrecinq -- emulator for mexcdf4('ncrecinq', ...).
%  [narids, varsizes, status] = ncrecinq(ncid, recdim)
%   inquires about records stored in the NetCDF file whose
%   id is ncid.  If recdim is provided, it substitutes for
%   the actual recdim in the file, if any.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

% Updated    08-Dec-2000 13:48:14.

if nargin < 1, help ncrecinq, return, end
if nargin < 2, recdim = -1; end

if recdim == -1
   [ndims, nvars, ngatts, recdim] = ncmex('inquire', ncid);
  else
   [ndims, nvars, ngatts] = ncmex('inquire', ncid);
end

if recdim >= ndims, error(' ## Invalid recdim.'), end

status = 0;

varids = [];
varsizes = [];
for i = 1:nvars
   varid = i-1;
   [varname, datatype, ndims, dimids] = ...
         ncmex('varinq', ncid, varid);
   if any(dimids == recdim)
      varids = [varids; varid];
      varsize = 1;
      for j = 1:length(dimids)
         dimid = dimids(j);
         if dimid ~= recdim
            [dimname, dimsize] = ncmex('diminq', ncid, dimid);
            varsize = varsize .* dimsize;
         end
      end
      varsizes = [varsizes; varsize];
   end
end
