function theResult = uigetdim(self)

% ncitem/uigetdim -- Get a NetCDF dimension via dialog.
%  uigetdim(self) returns one dimension associated with
%   self, an "ncitem" object, selected from a list-dialog.
%   The returned item is an "ncdim" object, or the
%   empty-matrix [] if no dimension is selected.
 
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

theDims = dim(self);
theDimnames = ncnames(theDims);
if ~isempty(theDimnames)
   thePrompt = {'Select Dimension From', 'NetCDF File', ['"' theFilename '"']};
   theSelection = listdlg('ListString', theDimnames, ...
                          'SelectionMode', 'single', ...
                          'PromptString', thePrompt);
   if any(theSelection)
      result = theDims{theSelection};
   end
else
   disp(' ## No dimensions available.')
end

if nargout > 0
   theResult = result;
else
   ncans(result)
end
