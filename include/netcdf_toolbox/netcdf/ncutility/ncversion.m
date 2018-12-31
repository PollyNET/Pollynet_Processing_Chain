function theNCVersion = NCVersion

% NCVersion (no argument) returns or displays the modification
%  date of the current "NetCDF Toolbox For Matlab-5".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Sep-1997 08:58:30.

theVersion = help('ncitem/version');
f = find(theVersion >= '0' & theVersion <= '9');
if any(f), theVersion = theVersion(f(1):f(length(f))); end

if nargout < 1
	disp([' ## http://crusty.er.usgs.gov/~cdenham'])
   disp([' ## NetCDF Toolbox For Matlab-5.'])
   disp([' ## Version of ' theVersion])
else
   theNCVersion = theVersion;
end
