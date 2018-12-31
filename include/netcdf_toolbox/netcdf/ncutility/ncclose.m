function theResult = ncclose(theNCid)

% ncclose(theNCid) closes the netcdf files whose
%  identifiers are the given theNCid.  The default
%  is 'all', which uses theNCid = [0:15].
%
% Note: for "netcdf" objects, use "close", not
%  "ncclose".
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Feb-2000 09:29:46.
% Updated    08-Dec-2000 13:55:18.

if nargin < 1, theNCid = 'all'; end

if isa(theNCid, 'ncitem')
	warning(' ## Use "close" for "netcdf" objects.')
	if nargout > 0, theResult = []; end
	return
end

if isequal(theNCid, 'all')
	theNCid = 0:15;
end

theNCid = -sort(-theNCid);

for i = 1:length(theNCid)
   status(i) = ncmex('close', theNCid(i));
end

if nargout > 0
   theResult = status;
  else
   for i = 1:length(theNCid)
      if status(i) >= 0
         disp([' ## closed: ncid = ' int2str(theNCid(i)) '.'])
      end
   end
end
