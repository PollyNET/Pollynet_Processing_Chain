function theResult = ncint(varargin)

% ncint -- Courier for constructing NetCDF 'int' entities.
%  ncint('dim1', 'dim2', ...) prepends 'int' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'int', varargin);
   theResult = [{'int'} varargin];
  else
   help ncint
end
