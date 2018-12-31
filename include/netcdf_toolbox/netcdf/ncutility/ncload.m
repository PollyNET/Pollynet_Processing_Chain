function theResult = ncload(theNetCDFFile, varargin)

% ncload -- Load NetCDF variables.
%  ncload('theNetCDFFile', 'var1', 'var2', ...) loads the
%   given variables of 'theNetCDFFile' into the Matlab
%   workspace of the "caller" of this routine.  If no names
%   are given, all variables are loaded.  The names of the
%   loaded variables are returned or assigned to "ans".
%   No attributes are loaded.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Aug-1997 10:13:57.

if nargin < 1, help(mfilename), return, end

result = [];
if nargout > 0, theResult = result; end

f = netcdf(theNetCDFFile, 'nowrite');
if isempty(f), return, end

if isempty(varargin), varargin = ncnames(var(f)); end

for i = 1:length(varargin)
   if ~isstr(varargin{i}), varargin{i} = inputname(i+1); end
   assignin('caller', varargin{i}, f{varargin{i}}(:))
end

result = varargin;

close(f)

if nargout > 0
   theResult = result
else
   ncans(result)
end
