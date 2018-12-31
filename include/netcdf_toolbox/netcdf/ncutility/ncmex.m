function [varargout] = ncmex(varargin)

% ncmex -- Driver for NetCDF C-Language interface.
%  ncmex('action', ...) performs the specified NetCDF action.
%   Variables are returned as multi-dimensional arrays whose
%   dimensions are arranged in the left-to-right order defined
%   in 'vardef' or retrieved by 'varinq'.  No pre-put or post-get
%   permutation of dimensions is required.  The base-index for
%   slabs is zero (0), and -1 can be used to specify the remaining
%   count along any variable direction from the starting point.
%
% ncmex('USAGE')
% [cdfid, rcode] = ncmex('CREATE', 'path', cmode)
% cdfid = ncmex('OPEN', 'path', mode)
% status = ncmex('REDEF', cdfid)
% status = ncmex('ENDEF', cdfid)
% [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid)
% status = ncmex('SYNC', cdfid)
% status = ncmex('ABORT', cdfid)
% status = ncmex('CLOSE', cdfid)
%
% status = ncmex('DIMDEF', cdfid, 'name', length)
% [dimid, rcode] = ncmex('DIMID', cdfid, 'name')
% ['name', length, status] = ncmex('DIMINQ', cdfid, dimid)
% status = ncmex('DIMRENAME', cdfid, 'name')
%
% status = ncmex('VARDEF', cdfid, 'name', datatype, ndims, [dim])
% [varid, rcode] = ncmex('VARID', cdfid, 'name')
% ['name', datatype, ndims, [dim], natts, status] = ncmex('VARINQ', cdfid, varid)
% status = ncmex('VARPUT1', cdfid, varid, coords, value, autoscale)
% [value, status] = ncmex('VARGET1', cdfid, varid, coords, autoscale)
% status = ncmex('VARPUT', cdfid, varid, start, count, value, autoscale)
% [value, status] = ncmex('VARGET', cdfid, varid, start, count, autoscale)
% status = ncmex('VARPUTG', cdfid, varid, start, count, stride, [], value, autoscale)
% [value, status] = ncmex('VARGETG', cdfid, varid, start, count, stride, [], autoscale)
% status = ncmex('VARRENAME', cdfid, varid, 'name')
%
% status = ncmex('ATTPUT', cdfid, varid, 'name', datatype, len, value) 
% [datatype, len, status] = ncmex('ATTINQ', cdfid, varid, 'name')
% [value, status] = ncmex('ATTGET', cdfid, varid, 'name')
% status = ncmex('ATTCOPY', incdf, invar, 'name', outcdf, outvar)
% ['name', status] = ncmex('ATTNAME', cdfid, varid, attnum)
% status = ncmex('ATTRENAME', cdfid, varid, 'name', 'newname')
% status = ncmex('ATTDEL', cdfid, varid, 'name')
%
% status = ncmex('RECPUT', cdfid, recnum, [data], autoscale, recdim)
% [[data], status] = ncmex('RECGET', cdfid, recnum, autoscale, recdim)
% [[recvarids], [recsizes], status] = ncmex('RECINQ', cdfid, recdim)
%
% len = ncmex('TYPELEN', datatype)
% old_fillmode = ncmex('SETFILL', cdfid, fillmode)
%
% old_ncopts = ncmex('SETOPTS', ncopts)
% ncerr = ncmex('ERR')
% code = ncmex('PARAMETER', 'NC_...')
%
% Notes:
%  1. The rcode is always zero.
%  2. The dimid can be number or name.
%  3. The varid can be number or name.
%  4. The attname can be name or number.
%  5. The operation and parameter names are not case-sensitive.
%  6. The cmode defaults to 'NC_NOCLOBBER'.
%  7. The mode defaults to 'NC_NOWRITE'.
%  8. The value -1 determines length automatically.
%  9. The operation names can prepend 'nc'.
% 10. The parameter names can drop 'NC_' prefix.
% 11. Dimensions: Matlab (i, j, ...) <==> [..., j, i] NetCDF.
% 12. Indices and identifiers are zero-based.
% 13. One-dimensional arrays are returned as column-vectors.

% 14. Scaling can be automated via 'scale_factor' and 'add_offset'.
 
% Copyright (C) 1992-1997 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

% Version of 16-May-96 at 10:17:47.75.
% Version of 06-Jan-97 at 14:04:00.
% Version of 12-Feb-97 at 14:08:00.
% Updated    08-Dec-2000 14:09:48.
% Updated    27-Apr-2001 09:19:06.   % Added WetCDF trap.

persistent WETCDF_IS_ACTIVE

if nargin < 1, help ncmex, return, end

% WetCDF gateway.

if isempty(WETCDF_IS_ACTIVE)
	WETCDF_IS_ACTIVE = ~~0;
end

if isequal(varargin{1}, 'wetcdf')
	if nargin > 1
		WETCDF_IS_ACTIVE = isequal(varargin{2}, 'on') | ...
							isequal(varargin{2}, '1') | ...
							isequal(varargin{2}, logical(1));
	end
	if nargout > 0, varargout{1} = WETCDF_IS_ACTIVE; end
	return
end

if WETCDF_IS_ACTIVE
	if nargout < 1
		wcmex(varargin{:});
	else
		varargout = cell(1, nargout);
		[varargout{:}] = wcmex(varargin{:});
	end
	return
end

% Mex-file gateway.

v = version;
if eval(v(1)) > 4
	fcn = 'mexcdf53';   % Matlab-5 or 6.
elseif eval(v(1)) == 4
	fcn = 'mexcdf4';    % Matlab-4 only.
else
	error(' ## Unrecognized Matlab version.')
end

% The "record" routines are emulated.

op = lower(varargin{1});
if any(findstr(op, 'rec'))
	fcn = op;
	if ~strcmp(fcn(1:2), 'nc')
		fcn = ['nc' fcn];
	end
	varargin{1} = [];
end

% Matlab-5 comma-list syntax.

if nargout > 0
	varargout = cell(1, nargout);
	[varargout{:}] = feval(fcn, varargin{:});
else
	feval(fcn, varargin{:});
end
