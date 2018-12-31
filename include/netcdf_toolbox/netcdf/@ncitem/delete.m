function theResult = delete(varargin)

% ncitem/delete -- Delete one or more NetCDF items.
%  delete(item1, item2, ...) deletes the items, all "ncitem"
%   objects that must be associated with the same NetCDF file.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Aug-1997 16:50:10.

if nargin < 1, help(mfilename), return, end

theParent = parent(parent(varargin{1}));

result = delete(theParent, varargin{:});

if nargout > 0
   theResult = result;
else
   ncans(result)
end
