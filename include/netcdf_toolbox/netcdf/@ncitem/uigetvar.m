function theResult = uigetvar(self)

% ncitem/uigetvar -- Get a NetCDF variable via dialog.
%  uigetvar(self) returns one variable from the NetCDF file
%   associated with self, an "ncitem" object, selected from
%   a list-dialog.  The returned item is an "ncvar" object,
%   or the empty-matrix [] if no variable is selected.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Dec-1997 13:20:58.

if nargin < 1, help(mfilename), return, end

result = [];

theParent = parent(parent(self));
theFilename = name(theParent);
f = find(theFilename == filesep);
if any(f)
   theFilename(1:f(length(f))) = '';
end

theVars = var(self);
theVarnames = ncnames(theVars);
if ~isempty(theVarnames)
   thePrompt = {'Select Variable From', 'NetCDF File', ['"' theFilename '"']};
   theSelection = listdlg('ListString', theVarnames, ...
                          'SelectionMode', 'single', ...
                          'PromptString', thePrompt);
   if any(theSelection)
      result = theVars{theSelection};
   end
else
   disp(' ## No variables available.')
end

if nargout > 0
   theResult = result;
else
   ncans(result)
end
