function theResult = UILayout(theControls, theLayout, thePosition)

% UILayout -- Layout for ui controls.
%  UILayout(theControls, theLayout) positions theControls
%   according to theLayout, an array whose entries, taken
%   in sorted order, define the rectangular extents occupied
%   by each control.  TheLayout defaults to a simple vertical
%   arrangement of theControls.  A one-percent margin is
%   imposed between controls.  To define a layout region
%   containing no control, use Inf.
%  UILayout(..., thePosition) confines the controls to the
%   given normalized position of the figure.  This syntax
%   is useful for embedding controls within a frame.
%  UILayout (no argument) demonstrates itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Apr-1997 08:07:54.

if nargin < 1, theControls = 'demo'; help(mfilename), end

if strcmp(theControls, 'demo')
   theLayout = [1 2;
                3 4;
                5 Inf;
                5 6;
                5 Inf;
                7 8;
                9 10;
                11 12;
                13 14];
   [m, n] = size(theLayout);
   thePos = get(0, 'DefaultUIControlPosition');
   theSize = [n+2 m+2] .* thePos(3:4);
   theFigure = figure('Name', 'UILayout', ...
                      'NumberTitle', 'off', ...
                      'Resize', 'off', ...
                      'Units', 'pixels');
   thePos = get(theFigure, 'Position');
   theTop = thePos(2) + thePos(4);
   thePos = thePos .* [1 1 0 0] + [0 0 theSize];
   thePos(2) = theTop - (thePos(2) + thePos(4));
   set(theFigure, 'Position', thePos);
   theFrame = uicontrol('Style', 'frame', ...
                        'Units', 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'BackgroundColor', [0.5 1 1]);
   theStyles = {'checkbox'; 'text'; ...
                'edit'; 'text'; ...
                'listbox'; 'text'; ...
                'popupmenu'; 'text'; ...
                'pushbutton'; 'text'; ...
                'radiobutton'; 'text'; ...
                'text'; 'text'};
   theStrings = {'Anchovies?', '<-- CheckBox --', ...
                 'Hello World!', '<-- Edit --', ...
                 {'Now', 'Is', 'The' 'Time' 'For' 'All' 'Good', ...
                  'Men', 'To', 'Come' 'To' 'The' 'Aid' 'Of', ...
                  'Their' 'Country'}, ...
                 '<-- ListBox --', ...
                 {'Cheetah', 'Leopard', 'Lion', 'Tiger', 'Wildcat'}, ...
                 '<-- PopupMenu --', ...
                 'Okay', '<-- PushButton --', ...
                 'Cream?', '<-- RadioButton --', ...
                 'UILayout', '<-- Text --'};
   theControls = zeros(size(theStyles));
   for i = 1:length(theStyles)
      theControls(i) = uicontrol('Style', theStyles{i}, ...
                                 'String', theStrings{i}, ...
                                 'Callback', ...
                                 'disp(int2str(get(gcbo, ''Value'')))');
   end
   set(theControls(1:2:length(theControls)), 'BackGroundColor', [1 1 0.5])
   set(theControls(2:2:length(theControls)), 'BackGroundColor', [0.5 1 1])
   thePosition = [1 1 98 98] ./ 100;
   uilayout(theControls, theLayout, thePosition)
   set(theFrame, 'UserData', theControls)
   theStyles, theLayout, thePosition
   if nargout > 0, theResult = theFrame; end
   return
end

if nargin < 2, theLayout = (1:length(theControls)).'; end
if nargin < 3, thePosition = [0 0 1 1]; end

a = theLayout(:);
a = a(isfinite(a));
a = sort(a);
a(diff(a) == 0) = [];

b = zeros(size(theLayout));

for k = 1:length(a)
   b(theLayout == a(k)) = k;
end

[m, n] = size(theLayout);

set(theControls, 'Units', 'Normalized')
theMargin = [1 1 -2 -2] ./ 100;
for k = 1:min(length(theControls), length(a))
   [i, j] = find(b == k);
   xmin = (min(j) - 1) ./ n;
   xmax = max(j) ./ n;
   ymin = 1 - max(i) ./ m;
   ymax = 1 - (min(i) - 1) ./ m;
   thePos = [xmin ymin (xmax-xmin) (ymax-ymin)] + theMargin;
if (1)
   thePos = thePos .* thePosition([3 4 3 4]);
   thePos(1:2) = thePos(1:2) + thePosition(1:2);
end
   set(theControls(k), 'Position', thePos);
end

if nargout > 0, theResult = theControls; end
