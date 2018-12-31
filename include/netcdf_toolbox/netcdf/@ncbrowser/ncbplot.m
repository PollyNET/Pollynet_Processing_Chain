function theResult = NCBPlot(self, theNCItem)

% NCBPlot -- Plot data via the NetCDF browser.
%  NCBPlot(self, theNCItem) plots the data associated
%   with theNCItem selected in self, an "ncbrowser"
%   object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Apr-1997 15:51:05.

if nargin < 2, help(mfilename), return, end

% Activate the figure.

theFigure = findobj('Type', 'figure', ...
                    'Name', 'NetCDF Browser Graph');
                    
if isempty(theFigure)
   theFigure = figure('Name', 'NetCDF Browser Graph', 'Visible', 'off');
   thePos = get(theFigure, 'Position');
   thePos = thePos + thePos([3:4 3:4]) .* [1 1 -2 -2] ./ 10;
   set(theFigure, 'Position', thePos, 'Visible', 'on')
end

figure(theFigure(1)), axes(gca)

% Plot.

result = plot(theNCItem);

% Make visible.

set([gcf gca], 'Visible', 'on')

if nargout > 0, theResult = result; end

if nargout > 0
   theResult = theHandles;
end
