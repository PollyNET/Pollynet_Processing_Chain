function theResult = NCBGraph(self, theNCItem, theKind)

% NCBGraph -- Graph data from the NetCDF browser.
%  NCBGraph(self, theNCItem, 'theKind') plots the data associated
%   with theNCItem selected in self, an "ncbrowser" object, using
%   'theKind' of graphical function: 'plot' (default), 'contour',
%   'image', 'list', 'mesh', or 'surf'.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Apr-1997 15:51:05.
% Updated    01-Jan-2000 09:13:08.

if nargin < 1, help(mfilename), return, end
if nargin < 3, theKind = 'plot'; end

% Activate the figure.

theFigure = findobj('Type', 'figure', ...
                    'Name', 'NetCDF Browser Graph');
                    
switch lower(theKind)
case 'listing'
otherwise
   if isempty(theFigure)
      theFigure = figure('Name', 'NetCDF Browser Graph', 'Visible', 'off');
      thePos = get(theFigure, 'Position');
      thePos = thePos + thePos([3:4 3:4]) .* [1 1 -2 -2] ./ 10;
      set(theFigure, 'Position', thePos, 'Visible', 'on')
   end
end

switch lower(theKind)
case 'listing'
otherwise
   figure(theFigure(1)), axes(gca)
end

if nargin < 2, return, end

switch ncclass(theNCItem)
case 'ncvar'
case 'ncatt'
   theNCItem = parent(theNCItem);
   switch ncclass(theNCItem)
   case 'ncvar'
   otherwise
      return
   end
otherwise
   return
end

% Plot.

switch lower(theKind)
case 'line'
   result = plot(theNCItem, '-');
case 'circles'
   result = plot(theNCItem, 'o');
case 'dots'
   result = plot(theNCItem, '.');
case 'degrees'   % Very crude at present.
   if exist('modplot', 'file') == 2
      y = theNCItem(:);
      x = (1:length(y)).';
      result = feval('modplot', x, y, 360);
      xlabel('Index Number')
      ylabel(labelsafe(name(theNCItem)))
   end
case 'contour'
   result = contour(theNCItem);
case 'image'
   result = image(theNCItem);
case 'listing'
   result = listing(theNCItem);
   if nargout > 0, theResult = result; end
   return
case 'mesh'
   result = mesh(theNCItem);
case 'surf'
   result = surf(theNCItem);
case 'pxline'
   if exist('pxline', 'file') == 2
      h = plot(theNCItem);
      x = get(h, 'XData'); y = get(h, 'YData'); c = get(h, 'Color');
      delete(h)
      if isa(x, 'cell')
         temp = zeros(length(x{1}), length(x));
         for j = 1:length(x)
            temp(:, j) = x{j}(:);
         end
         x = temp;
      end
      if isa(y, 'cell')
         temp = zeros(length(y{1}), length(y));
         for j = 1:length(y)
            temp(:, j) = y{j}(:);
         end
         y = temp;
      end
      if isa(c, 'cell'), c = c{1}; end
      feval('pxline', x(:), y(:), 'Color', c)
   end
   result = [];
otherwise
   result = [];
end

% Set the title.

theTitle = name(super(self));
if length(theTitle) > 0
   f = find(theTitle == filesep);
   if any(f)
      theTitle(1:f(length(f))) = '';
   end
end
title(labelsafe(theTitle))

% Make visible and zoomable.

set([gcf gca], 'Visible', 'on')

switch lower(theKind)
case 'pxline'
   eval('zoomsafe', ';')
otherwise
   eval('zoomsafe', ';')
end

if nargout > 0, theResult = result; end
