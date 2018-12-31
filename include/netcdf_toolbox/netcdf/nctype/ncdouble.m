function theResult = ncdouble(varargin)

% ncdouble -- Courier for constructing NetCDF 'double' entities.
%  ncdouble('dim1', 'dim2', ...) prepends 'double' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'double', varargin);
   theResult = [{'double'} varargin];
  else
   help ncdouble
end
