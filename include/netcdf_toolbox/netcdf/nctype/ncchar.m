function theResult = ncchar(varargin)

% ncchar -- Courier for constructing NetCDF 'char' entities.
%  ncchar('dim1', 'dim2', ...) prepends 'char' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'char', varargin);
   theResult = [{'char'} varargin];
  else
   help ncchar
end
