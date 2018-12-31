function varargout = op(varargin)

% op -- Apply a function or operator.
%  op(self, other, ...) applies the operator or function
%   derived from the name of this M-file to the arguments.
%   the "self" argument is an "ncitem".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 11:46:29.

fcn = mfilename;
f = find(fcn == '/');
if any(f), fcn(1:f(length(f))) = ''; end

varargin = [{fcn} varargin];
varargout = cell(1, nargout);

[varargout{:}] = feval(varargin{:});
