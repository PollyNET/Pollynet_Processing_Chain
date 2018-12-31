function varargout = feval(varargin)

% ncitem/feval -- feval() for an ncitem object.
%  [...] = feval('theFcn', ...) applies 'theFcn' function to the
%   argument list.  All "ncitem" arguments are dereferenced to
%   their corresponding numerical contents.  The stored NetCDF
%   contents themselves are not affected.

% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:48:11.

if nargin < 1, help(mfilename), return, end

% De-reference the ncitem data.

for i = 2:length(varargin)
   switch ncclass(varargin{i})
   case {'ncdim', 'ncvar', 'ncatt', 'ncrec'}
      varargin{i} = varargin{i}(:);   % Whole data.
   otherwise
   end
end

% Allocate output objects.

varargout = cell(1, min(nargout, 1));
for i = 1:length(varargout), varargout{i} = []; end

% Evaluate the function.

theFcn = varargin{1};
trystr = 'varargout{:} = feval(varargin{:});';
catchstr = ['disp('' ## ' mfilename ' failure while trying: ' ...
         theFcn '(...)'')'];
eval(trystr, catchstr);
