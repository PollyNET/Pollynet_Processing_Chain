function theResult = nclong(varargin)

% nclong -- Courier for constructing NetCDF 'long' entities.
%  nclong('dim1', 'dim2', ...) prepends 'long' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'long', varargin);
   theResult = [{'long'} varargin];
  else
   help nclong
end
