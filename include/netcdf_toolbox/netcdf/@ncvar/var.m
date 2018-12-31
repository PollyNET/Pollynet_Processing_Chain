function theResult = var(varargin)

% ncvar/var -- Manipulate the constituent-variables.
%  var(self) returns the list of variables that contribute
%   to self, a composite "ncvar" object.  A non-composite
%   variable returns the empty-cell {}.
%  var(v1, s1, d1, v2, s2, d2, ...) returns a composite "ncvar"
%   object, based on the variables v1, ..., their respective
%   source-indices s1, ..., and their corresponding destination-
%   indices d1, ...  Each set of indices is contained in a cell;
%   use the string ':' for a standalone-colon.  The source-
%   indices refer to the participating "ncvar" objects, whereas
%   the destination-indices refer to the composite output array.
%   A composite-variable behaves much like a regular variable.
%  var(v1, v2, ...) returns an "ncvar" object representing
%   a composite-variable, whose constituents are the given
%   "ncvar" objects v1, v2, ...  Use "ncvar/subs" to set-up
%   the corresponding source and destination indices.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 29-Sep-1997 15:47:27.

if nargin < 1, help(mfilename), return, end

if nargin == 1
   self = varargin{1};
   result = self.itsVars;
   if isempty(result), result = {}; end
elseif nargin > 1 & isa(varargin{2}, 'ncvar')
   self = ncvar;
   theVars = varargin;
   if isempty(theVars), theVars = {}; end
   self.itsVars = theVars;
   result = self;
elseif nargin > 2 & ...
       rem(nargin, 3) == 0 & ...
       isa(varargin{2}, 'cell')
   self = ncvar;
   theVars = varargin(1:3:length(varargin));
   theSrcsubs = varargin(2:3:length(varargin));
   theDstsubs = varargin(3:3:length(varargin));
   self.itsVars = theVars;
   self.itsSrcsubs = theSrcsubs;
   self.itsDstsubs = theDstsubs;
   result = self;
else
   result = ncvar;
   warning(' ## Invalid syntax.')
end

if nargout > 0
   theResult = result;
else
   ncans(result)
end
