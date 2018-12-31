function theResult = ncbyte(varargin)

% ncbyte -- Courier for constructing NetCDF 'byte' entities.
%  ncbyte('dim1', 'dim2', ...) prepends 'byte' to the input
%   argument-list, for use by ncvar and ncatt constructors.
%
%  Also see: nc... for other numeric types.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargout > 0
%  theResult = ncvar('', 'byte', varargin);
   theResult = [{'byte'} varargin];
  else
   help ncbyte
end
