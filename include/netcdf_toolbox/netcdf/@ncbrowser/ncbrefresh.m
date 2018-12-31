function theResult = NCBRefresh(self, theNCItem)

% NCBRefresh -- Refresh NCBrowser entries.
%  NCBRefresh(self, theNCItem) refreshes the NCBrowser,
%   assuming the NCItem is the selected item.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 24-Apr-1997 16:13:42.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theNCItem = []; end

if isempty(theNCItem), theNCItem = super(self); end

h = self.itSelf;

theDimensions = findobj(h, 'Type', 'uicontrol', ...
                           'Style', 'listbox', ...
                           'Tag', 'Dimensions');

theVariables = findobj(h, 'Type', 'uicontrol', ...
                           'Style', 'listbox', ...
                           'Tag', 'Variables');

theAttributes = findobj(h, 'Type', 'uicontrol', ...
                           'Style', 'listbox', ...
                           'Tag', 'Attributes');
   
theDimvalue = get(theDimensions, 'Value');
theVarvalue = get(theVariables, 'Value');
theAttvalue = get(theAttributes, 'Value');

theDimnames = ncnames(dim(self));
theVarnames = ncnames(var(self));
theAttnames = ncnames(att(self));

theName = name(theNCItem);

switch lower(class(theNCItem))
case 'netcdf'
case 'ncdim'
theVarnames = ncnames(var(theNCItem));
case 'ncvar'
theDimnames = ncnames(dim(theNCItem));
theAttnames = ncnames(att(theNCItem));
case 'ncatt'
theAttnames = ncnames(att(parent(theNCItem)));
otherwise
end

theDimnames = [{'-'} theDimnames];
theVarnames = [{'-'} theVarnames];
theAttnames = [{'-'} theAttnames];

switch lower(class(theNCItem))
case 'netcdf'
case 'ncdim'
   theDimnames{theDimvalue} = ['*' theDimnames{theDimvalue}];
case 'ncvar'
   theVarnames{theVarvalue} = ['*' theVarnames{theVarvalue}];
case 'ncatt'
   theAttnames{theAttvalue} = ['*' theAttnames{theAttvalue}];
otherwise
end

set(theDimensions, 'String', theDimnames, 'Value', theDimvalue)
set(theVariables, 'String', theVarnames, 'Value', theVarvalue)
set(theAttributes, 'String', theAttnames, 'Value', theAttvalue)

if nargout > 0, theResult = theNCItem; end
