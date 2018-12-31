function theResult = ListPick(theSourceList, thePrompt, ...
                                theName, theMode, varargin)

% ListPick/ListPick -- Move items from one listbox to another.
%  ListPick({theSourceList}, 'thePrompt', 'theName', 'theMode') creates
%   a modal dialog with {theSourceList} strings in a listbox, whose items
%   can be moved to and from the adjacent listbox by clicking on them.
%   The "Okay" button causes the destination list to be returned.
%   Otherwise, the empty-list is returned.  'ThePrompt' appears at the
%   top of the dialog, and 'theName' is the dialog's figure name.
%   'TheMode' is 'unique' (default) or 'multiple'.  In 'unique' mode,
%   the clicked item moves from one list to the other, whereas in 'multiple'
%   mode, the SourceList remains intact and only copies of its items move
%   to and from the destination list.
%  ListPick (no argument) demonstrates itself.

%  N.B. Multiple-selections in a listbox can be enabled by setting
%   the "Max" property to the maximum number of selections allowed.
%   Do not try to set "Value" to 0.  If the "String" is set to an
%   empty cell array, leave the "Value" as is.
%
%  N.B. With an "edit" control, use the "Max" property to specify
%   the number of allowed lines, separated by newlines.

if nargin < 1, help(mfilename), theSourceList = 'demo'; end

if isstr(theSourceList) & strcmp(theSourceList, 'demo')
   theSourceList = {'fum'; 'fi'; 'fee'; 'fo'};
   thePrompt = 'Rearrange' ;
   theMode = 'Unique';
   theName = ['ListPick -- ' theMode];
   theList = listpick(theSourceList, thePrompt, theName, theMode)
   theNotes = {'do', 'do_', 're', 'mi', 'mi_', 'fa', 'fa_', 'so', 'la', 'la_', 'ti', 'ti_', ...
               'Do', 'Do_', 'Re', 'Mi', 'Mi_', 'Fa', 'Fa_', 'So', 'La', 'La_', 'Ti', 'Ti_', ...
               'DO', 'DO_', 'RE', 'MI', 'MI_', 'FA', 'FA_', 'SO', 'LA', 'LA_', 'TI', 'TI_', ...
               'rest'};
   theSourceList = theNotes;
   thePrompt = 'Compose Music' ;
   theMode = 'Multiple';
   theName = ['ListPick -- ' theMode];
   theSampleRate = 8192;
   t = 2 .* pi .* (0:theSampleRate/2) ./ theSampleRate;
   theFundamental = 220;   % A below middle-C (264 Hz).
   theFrequencies = theFundamental .* (2 .^ (1/12)) .^ (0:length(theNotes)-1);
   theFrequencies(length(theFrequencies)) = 0;
% Frequencies from John Pierce's book.
   theFrequencies = [220.00, 233.08, 246.94, 261.63, 277.18, 293.66, ...
                     311.13, 329.63, 349.23, 369.99, 392.00, 415.30].';
   theFrequencies = theFrequencies * [1 2 4];
   theFrequencies = [theFrequencies(:).', 0];
%
   theSounds = [];
   for i = 1:length(theNotes)
      theSounds = setfield(theSounds, theNotes{i}, theFrequencies(i));
   end
   theSounds;
   thePlayedNotes = listpick(theSourceList, thePrompt, theName, theMode)
   for i = 1:length(thePlayedNotes)
      f = getfield(theSounds, thePlayedNotes{i});
      sound(sin(f .* t), theSampleRate)
   end
   return
end

if nargin < 2, thePrompt = '<== Pick Items ==>'; end
if nargin < 3, theName = ''; end
if nargin < 4, theMode = 'unique'; end

% N.B. We should use the prompt as follows:
%         {thePrompt, from_label, to_label}.

if ~iscell(thePrompt), thePrompt = {thePrompt}; end
if length(thePrompt) < 2, thePrompt{2} = 'From'; end
if length(thePrompt) < 3, thePrompt{3} = 'To'; end

theSourceList = [theSourceList(:)];
theDestinationList = cell(0, 1);

if nargout > 1, theResult = cell(0, 1); end

theFigure = figure('Name', theName, 'NumberTitle', 'off', ...
   'WindowStyle', 'modal', 'Visible', 'off', 'Resize', 'off');
thePosition = get(theFigure, 'Position');
thePosition(2) = thePosition(2) + 0.10 .* thePosition(4);
thePosition(3) = 0.5 .* thePosition(3);
thePosition(4) = 0.80 .* thePosition(4);
set(theFigure, 'Position', thePosition)

theStruct.itSelf = theFigure;
self = class(theStruct, 'listpick');
set(theFigure, 'UserData', self)

if isempty(self), return, end

theFrame = uicontrol('Style', 'frame', 'Visible', 'on', ...
   'Units', 'normalized', 'Position', [0 0 1 1], ...
   'BackgroundColor', [0.5 1 1]);

theControls = zeros(7, 1);
theControls(1) = uicontrol('Style', 'text', 'Tag', 'Label', ...
   'String', thePrompt{1});
theControls(2) = uicontrol('Style', 'text', 'Tag', 'Label', ...
   'String', thePrompt{2});
theControls(3) = uicontrol('Style', 'text', 'Tag', 'Label', ...
   'String', thePrompt{3});
theControls(4) = uicontrol('Style', 'listbox', 'Tag', 'Source', ...
   'String', theSourceList);
theControls(5) = uicontrol('Style', 'listbox', 'Tag', 'Destination', ...
   'String', theDestinationList);
theControls(6) = uicontrol('Style', 'pushbutton', 'Tag', 'Cancel', ...
   'String', 'Cancel', 'UserData', []);
theControls(7) = uicontrol('Style', 'pushbutton', 'Tag', 'Okay', ...
   'String', 'Okay', 'UserData', theDestinationList);

theLayout = [  10   10   10   10   10   10   10   10
               20   20   20   20   30   30   30   30
               40   40   40   40   50   50   50   50
               40   40   40   40   50   50   50   50
               40   40   40   40   50   50   50   50
               40   40   40   40   50   50   50   50
               40   40   40   40   50   50   50   50
               40   40   40   40   50   50   50   50
              Inf   60   60  Inf  Inf   70   70  Inf];

uilayout(theControls, theLayout, [2 2 96 92]./100)
set(theFrame, 'UserData', theControls)

theCallback = ['event(get(gcf, ''UserData''), ''' theMode ''')'];
set(theControls(4:7), 'Callback', theCallback)
set(theControls(1:3), 'BackgroundColor', [0.5 1 1]);

if any(findstr(computer, 'MAC'))
    set(theControls(4:5),   'FontName', 'Monaco', ...
                            'FontSize', 12, ...
                            'FontAngle', 'normal', ...
                            'FontWeight', 'normal')
end

if length(varargin) > 0
    set(theControls(4:5), varargin{:})
end

set(theFigure, 'Visible', 'on')
waitfor(theFigure, 'UserData', [])

result = get(gco, 'UserData');

delete(theFigure)

if nargout > 0
   theResult = result;
else
   disp(result)
end
