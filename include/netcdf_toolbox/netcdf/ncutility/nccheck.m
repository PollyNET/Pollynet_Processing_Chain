function [varargout] = nccheck(varargin)

% nccheck -- Are these all "ncitems"?
%  [...] = nccheck(...) posts an error-message
%   if some of its arguments are not "ncitems".
%   Input arguments are passed intact to the
%   output arguments, if any.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 29-Jun-1998 06:10:41.

okay = 1;

for i = 1:nargin
	if ~isa(varargin{i}, 'ncitem')
		okay = 0;
		theClass = class(varargin{i});
		disp([' ## ' mfilename ': argument #' int2str(i) ' is a "' theClass '".'])
	end
end

if ~okay, error(' ## One or more non-NetCDF arguments.'), end

for i = 1:min(nargin, nargout)
	varargout{i} = varargin{i};
end
