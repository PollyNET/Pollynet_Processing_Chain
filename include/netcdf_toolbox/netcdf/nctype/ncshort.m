function theResult = ncshort(varargin)

% ncshort -- Courier for constructing NetCDF 'short' entities.
%  ncshort('dim1', 'dim2', ...) prepends 'short' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'short', varargin);
   theResult = [{'short'} varargin];
  else
   help ncshort
end
