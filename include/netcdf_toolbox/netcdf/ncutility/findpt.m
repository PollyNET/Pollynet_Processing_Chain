function [theResult, theIndex, x, y, z] = findpt(theLine, x, y, z)

% findpt -- Find the current point.
%  findpt(theLine) installs "findpt" in theLine (a handle) if called
%   directly, rather than as the result of a callback.  In this case,
%   theLine defaults to all the lines in the current figure.  During
%   mouse-down and mouse-move, the (x, y, z) location of the nearest
%   actual point on the original mouse-down line is displayed near
%   the mouse, in the figure-name, and in the Matlab command window.
%   Note: A simple down/up mouse-click (no dragging) causes the tag
%   to remain on the plot.  It can be erased by clicking on it.
%  [theLine, theIndex, x, y, z] = findpt(theLine, x, y, z) returns the
%   actual point on theLine [default = gcbo], that is nearest (x, y, z)
%   [default = present mouse position].  The returned values are packed
%   into a single vector if only one output argument is provided.  The
%   output (x, y, z) are the actual coordinates of the point.  If no
%   output arguments are given, the (x, y) result is displayed on the
%   plot and in the figure-name while the mouse is down.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Updated    06-Jul-1998 10:02:02.

% N.B. -- The following globals are needed
%  for persistence, not for global access.

global theFigureName
global theFigureNumberTitle
global theLineHandle
global theTextHandle
global theMarkerHandle
global mouseDidMove

DIGITS = 6;

if nargin < 1, theLine = gcbo; end

% If not a callback, install "findpt"
%  in all the lines in the figure.

if isempty(gcbo)
   if isempty(theLine)
      theLine = findobj(gcf, 'Type', 'line');
   end
   if any(theLine)
      set(theLine, 'ButtonDownFcn', mfilename)
   end
   return
end

if nargin == 1
   switch theLine
   case 0   % Mouse up.
   if any(theTextHandle)
		if any(mouseDidMove)
      	delete(theTextHandle)
      	delete(theMarkerHandle)
			mouseDidMove = 0;
		end
      set(gcf, 'Name', theFigureName, 'NumberTitle', theFigureNumberTitle)
      theLineHandle = [];
      theTextHandle = [];
      theMarkerHandle = [];
      set(gcf, 'Name', theFigureName, ...
               'NumberTitle', theFigureNumberTitle, ...
               'WindowButtonMotionFcn', '', ...
               'WindowButtonUpFcn', '')
      theFigureName = '';
      theFigureNumberTitle = '';
      return
   end
case -1   % Mouse move.
      a = theFigureName;
      b = theFigureNumberTitle;
		mouseDidMove = 1;
      delete(theTextHandle)
      delete(theMarkerHandle)
      findpt(theLineHandle)
      theFigureName = a;
      theFigureNumberTitle = b;
      return
   otherwise
   end
end

switch get(theLine, 'Type')
case 'line'
otherwise
   if nargout > 0, theResult = []; end
   return
end

if nargin < 2
   theCurrentPoint = mean(get(gca, 'CurrentPoint'));   % Assume "view(2)".
   x = theCurrentPoint(1);
   y = theCurrentPoint(2);
   z = theCurrentPoint(3);
end

theXRange = diff(get(gca, 'XLim'));
theYRange = diff(get(gca, 'YLim'));
theZRange = diff(get(gca, 'ZLim'));
theZRange = 1;   % Assume "view(2)".

theXData = get(theLine, 'XData');
theYData = get(theLine, 'YData');
theZData = get(theLine, 'ZData');
emptyZ = 0;
if isempty(theZData)
	emptyZ = 1;
	theZData = zeros(size(theXData));
end

theZTemp = theZData .* 0;   % Assume "view(2)".

dx = (theXData - x) .* theYRange .* theZRange;
dy = (theYData - y) .* theXRange .* theZRange;
dz = (theZTemp - z) .* theXRange .* theYRange;

dd = dx.^2 + dy.^2 + dz.^2;

theIndex = find(dd == min(dd));
if any(theIndex), theIndex = theIndex(1); end

x = theXData(theIndex);
y = theYData(theIndex);
z = theZData(theIndex);

result = [theLine, theIndex, x, y, z];

% N.B. We need to display the z-value (see below)
%  if there is any z-data in the line.

if nargout > 1
   theResult = theLine;
elseif nargout == 1
   theResult = result;
else
   assignin('base', 'ans', result)
   theString = [num2str(x, DIGITS) ', ' num2str(y, DIGITS)];
	if ~emptyZ
		theString = [theString ', ' num2str(z, DIGITS)];
	end
	if (1), disp(theString), end
	theString = ['<' theString '>'];
   theFigureName = get(gcf, 'Name');
   theFigureNumberTitle = get(gcf, 'NumberTitle');
   set(gcf, 'Name', theString, 'NumberTitle', 'off')
   theMarker = get(theLine, 'Marker');
   theColor = get(theLine, 'Color');
   switch theMarker
   case 'o'
      theMarker = '*';
   otherwise
      theMarker = 'o';
   end
   theLineHandle = theLine;
   theMarkerHandle = line(x, y, ...
                          'Marker', theMarker, ...
                          'EraseMode', 'xor');
   theTextHandle = text(x, y, theString, ...
                        'Tag', mfilename, 'EraseMode', 'xor', ...
                        'HorizontalAlignment', 'right', ...
                        'VerticalAlignment', 'bottom');
	theButtonDownFcn = 'delete(get(gcbo, ''UserData''))';
	h = [theMarkerHandle; theTextHandle];
	set(h, 'UserData', h, 'ButtonDownFcn', theButtonDownFcn)
   set(gcf, 'WindowButtonMotionFcn', 'findpt(-1)')
   set(gcf, 'WindowButtonUpFcn', 'findpt(0)')
end
