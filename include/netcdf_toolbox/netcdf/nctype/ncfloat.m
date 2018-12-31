function theResult = ncfloat(varargin)

% ncfloat -- Courier for constructing NetCDF 'float' entities.
%  ncfloat('dim1', 'dim2', ...) prepends 'float' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'float', varargin);
   theResult = [{'float'} varargin];
  else
   help ncfloat
end
