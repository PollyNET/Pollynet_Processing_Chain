function ncwhatsnew

% ncwhatsnew -- What's new in the NetCDF Toolbox.
%  ncwhatsnew emits a "what's new" message the first time
%   it is called.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 09-Dec-1998 10:47:04.
% Updated    19-Jul-1999 11:07:43.

global NC_WHATS_NEW_DISPLAYED

if isempty(NC_WHATS_NEW_DISPLAYED) & 0
	disp(' ')
	disp(' ## WHAT''S NEW in the NetCDF Toolbox')
	disp(' ')
	disp(' ##  Starting January 1, 1999, the "size" function for')
	disp(' ##  netcdf items will return at least two elements,')
	disp(' ##  following the Matlab convention.  To get the old')
	disp(' ##  style of size-vector, use "ncsize".')
	disp(' ')
	v = version;
	if isequal(v(1:3), '5.3')
		disp(' ##  Matlab v5.3 (Release 11) Alert -- Changes to the')
		disp(' ##  Matlab object-oriented scheme required that we patch')
		disp(' ##  the NetCDF Toolbox.  The present toolbox seems to be')
		disp(' ##  compatible with v5.3.  Please let us know if you notice')
		disp(' ##  otherwise: <cdenham@usgs.gov> (14Apr1999).')
		disp(' ')
	end
	NC_WHATS_NEW_DISPLAYED = 1;
end
