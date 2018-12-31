function theResult = rbrect(onMouseUp, onMouseMove, onMouseDown)

% rbrect -- Rubber rectangle tracking (Matlab-4 and Matlab-5).
%  rbrect('demo') demonstrates itself.
%  rbrect('onMouseUp', 'onMouseMove', 'onMouseDown') conducts interactive
%   rubber-rectangle tracking, presumably because of a mouse button press
%   on the current-callback-object (gcbo).  The 'on...' callbacks are
%   automatically invoked with: "feval(theCallback, theInitiator, theRect)"
%   after each window-button event, using the object that started this
%   process, plus theRect as [xStart yStart xEnd yEnd] for the current
%   rubber-rect.  The callbacks default to ''.  The coordinates of the
%   rectangle are returned as [xStart yStart xEnd yEnd].

% Private interface:
%  rbrect(1) is automatically called on window-button-motions.
%  rbrect(2) is automatically called on window-button-up.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Jun-1997 15:54:39.
% Version of 11-Jun-1997 15:17:22.
% Version of 17-Jun-1997 16:52:46.

global RBRECT_HANDLE
global RBRECT_INITIATOR
global RBRECT_ON_MOUSE_MOVE

if nargin < 1, onMouseUp = 0; end

if strcmp(onMouseUp, 'demo')
   help rbrect
   x = cumsum(rand(200, 1) - 0.45);
   y = cumsum(rand(200, 1) - 0.25);
   h = plot(x, y, '-r');
   set(h, 'ButtonDownFcn', 'disp(rbrect)')
   figure(gcf), set(gcf, 'Name', 'RBRECT Demo')
   return
  elseif isstr(onMouseUp)
   theMode = 0;
  else
   theMode = onMouseUp;
   onMouseUp = '';
end


if theMode == 0   % Mouse down.
   if nargin < 3, onMouseDown = ''; end
   if nargin < 2, onMouseMove = ''; end
   if nargin < 1, onMouseUp = ''; end
   theVersion = version;
   isVersion5 = (theVersion(1) == '5');
   if isVersion5
      theCurrentObject = 'gcbo';
     else
      theCurrentObject = 'gco';
   end
   RBRECT_INITIATOR = eval(theCurrentObject);
   switch get(RBRECT_INITIATOR, 'Type')
   case 'line'
      theColor = get(RBRECT_INITIATOR, 'Color');
   otherwise
      theColor = 'black';
   end
   RBRECT_ON_MOUSE_MOVE = onMouseMove;
   pt = mean(get(gca, 'CurrentPoint'));
   x = [pt(1) pt(1)]; y = [pt(2) pt(2)];
   RBRECT_HANDLE = line(x, y, ...
                        'EraseMode', 'xor', ...
                        'LineStyle', '--', ...
                        'LineWidth', 2.5, ...
                        'Color', theColor, ...
                        'Marker', '+', 'MarkerSize', 13, ...
                        'UserData', 1);
   set(gcf, 'WindowButtonMotionFcn', 'rbrect(1);')
   set(gcf, 'WindowButtonUpFcn', 'rbrect(2);')
   theRBRect = [x(1) y(1) x(2) y(2)];
   if ~isempty(onMouseDown)
      feval(onMouseDown, RBRECT_INITIATOR, theRBRect)
   end
   thePointer = get(gcf, 'Pointer');
   set(gcf, 'Pointer', 'circle');
   if isVersion5 & 0   % Disable for rbrect()..
      eval('waitfor(RBRECT_HANDLE, ''UserData'', [])')
     else
      set(RBRECT_HANDLE, 'Visible', 'off')   % Invisible.
      eval('rbbox')   % No "waitfor" in Matlab-4.
   end
   set(gcf, 'Pointer', thePointer);
   set(gcf, 'WindowButtonMotionFcn', '')
   set(gcf, 'WindowButtonUpFcn', '')
   x = get(RBRECT_HANDLE, 'XData');
   y = get(RBRECT_HANDLE, 'YData');
   delete(RBRECT_HANDLE)
   theRBRect = [x(1) y(1) x(2) y(2)];   % Scientific.
   if ~isempty(onMouseUp)
      feval(onMouseUp, RBRECT_INITIATOR, theRBRect)
   end
elseif theMode == 1   % Mouse move.
   pt2 = mean(get(gca, 'CurrentPoint'));
   x = get(RBRECT_HANDLE, 'XData');
   y = get(RBRECT_HANDLE, 'YData');
   x(2) = pt2(1); y(2) = pt2(2);
   set(RBRECT_HANDLE, 'XData', x, 'YData', y)
   theRBRect = [x(1) y(1) x(2) y(2)];
   if ~isempty(RBRECT_ON_MOUSE_MOVE)
      feval(RBRECT_ON_MOUSE_MOVE, RBRECT_INITIATOR, theRBRect)
   end
elseif theMode == 2   % Mouse up.
   pt2 = mean(get(gca, 'CurrentPoint'));
   x = get(RBRECT_HANDLE, 'XData');
   y = get(RBRECT_HANDLE, 'YData');
   x(2) = pt2(1); y(2) = pt2(2);
   set(RBRECT_HANDLE, 'XData', x, 'YData', y, 'UserData', [])
else
end

if nargout > 0, theResult = theRBRect; end
