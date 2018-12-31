function self = NCBrowser(theNetCDFFile, thePermission)

% NCBrowser/NCBBrowser -- NetCDF Browser.
%  NCBBrowser'(theNetCDFFile', 'thePermission') creates a
%   browser for 'theNetCDFFile', opened with 'thePermission'
%   (default = 'nowrite').  The "uigetfile" dialog is used if
%   no file or wildcard is given.  The "netcdf" object is
%   assigned to the variable "nco" in the "base" workspace,
%   and the "nci" variable will subsequently hold the currently
%   selected NetCDF item.  The "ncb" variable is always the current
%   "ncbrowser" object.  The "ncbrowser" is assigned silently to
%   "ans" if no output argument is given.  Files are opened with
%   'nowrite' permission by default.
%  NCBrowser('thePermission') opens the selected file with
%   'thePermission', either 'nowrite' or 'write'.  Files are
%   opened with 'nowrite' permission by default.
%
%  Menus:
%   <NetCDF> Menu
%    New >>>
%     NetCDF... -- New NetCDF file via "uiputfile" dialog.
%     Dimension... -- New NetCDF dimension via dialog.
%     Variable... -- New NetCDF variable via dialogs.
%     Attribute... -- New NetCDF attribute via dialog.
%    Open... -- Open NetCDF file via "uigetfile" dialog.
%    Save -- Synchronize the NetCDF file.
%    Save As... -- Save NetCDF file via "uiputfile" dialog.
%    Done -- Close NetCDF file and delete the browser.
%   <Edit> Menu
%    Undo -- Not used.
%    Cut -- Not used.
%    Copy -- Copy current NetCDF selection(s) to clipboard.
%    Paste -- Paste clipboard contents to current NetCDF file.
%    Delete -- Not used.
%    Select All -- Select all items of the selected kind.
%    Show Clipboard -- Show clipboard in new NetCDF browser.
%   <Rename> Menu
%    Conventions >>> -- Rename to various NetCDF conventions.
%    Rename... -- Rename current selection via dialog.
%    Uppercase -- Rename current selection to all uppercase.
%    Lowercase -- Rename current selection to all lowercase.
%   <Graph> Menu
%    Line -- Line-graph of selected variable (EPIC-aware).
%    Circles -- Graph with "o" symbols only.
%    Dots -- Graph with "." symbols only.
%    Degrees -- Line-graph with mod-180 pen-up.
%    Contour -- Default contour plot of 2-d data.
%    Image -- Image of 2-d data.
%    Mesh -- Mesh plot of 2-d data.
%    Surf -- Surface plot of 2-d data.
%    PXLine -- Experimental interactive line plot.
%    Show Graph -- Bring graph window to front.
%
%  Buttons:
%   Catalog -- Show full catalog of NetCDF file.
%   Info -- Display information about selected item.
%   Listing -- Display contents of selected variable.
%   Extract -- Dialog for extracting data from selection.
%
%  Workspace Aliases:
%   ncb -- The "ncbrowser" object.
%   nco -- The "netcdf" object.
%   nci -- The selected object.
%   ncx -- The extracted data.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Apr-1997 15:33:51.
% Updated    11-Jan-2002 05:57:21.

disp(' ## NCBrowser is a work-in-progress.')
disp(' ## Not all menu items are implemented.')
disp(' ## See "help ncbrowser".')

bluish = [0.25 1 1];
light_blue = [0.75 1 1];
yellowish = [1 1 0.25];
yellowish = [1 1 0.5];
reddish = [1 0.5 0.5];
greenish = [0.5 1 0.5];

if nargin < 1, theNetCDFFile = ''; end
if nargout > 0, theResult = []; end

if isa(theNetCDFFile, 'netcdf')
	theNetCDFFile = name(theNetCDFFile);
end

if nargin < 2
   switch theNetCDFFile
   case {'nowrite', 'write'}
      thePermission = theNetCDFFile;
      theNetCDFFile = '';
   otherwise
      thePermission = 'nowrite';
   end
end

% Can use shorthand "r" or "w" if three arguments.

switch thePermission
case 'w'
	thePermission = 'write';
case 'r'
	thePermission = 'nowrite';
end

if isempty(theNetCDFFile), theNetCDFFile = '*'; end

if isstr(theNetCDFFile) & any(theNetCDFFile == '*')
   theFile = 0;
   [theFile, thePath] = ...
         uigetfile(theNetCDFFile, 'Select NetCDF File:');
   if ~any(theFile), return, end
   theNetCDFFile = [thePath theFile];
  elseif isstr(theNetCDFFile)
   theNetCDFFile = which(theNetCDFFile);
end

x = inf;

theLayout = [ 99  99  99  99  99  99  99  99  99   % Title.
               1   1   1   2   2   2   3   3   3   % Labels.
               4   4   4   5   5   5   6   6   6
               4   4   4   5   5   5   6   6   6
               4   4   4   5   5   5   6   6   6
               4   4   4   5   5   5   6   6   6
               4   4   4   5   5   5   6   6   6
               4   4   4   5   5   5   6   6   6
               7   7   7   7   7   7   7   7   7   % Edit.
               8   8   8   9   9   x   x   x   x;
              10  10  11  11   x  12  12  13  13]; % Catalog, info, listing, extract.

theStyles = {'text'; 'text'; 'text';
             'listbox'; 'listbox'; 'listbox';
             'edit';
             'popupmenu'; 'popupmenu';
             'pushbutton'; 'pushbutton'; 'pushbutton'; 'pushbutton';
             'text'};

theStrings = {'Dimensions'; 'Variables'; 'Attributes';
              'Dimensions'; 'Variables'; 'Attributes';
              'Properties';
              {'-'; 'Dimension'; 'Record Dimension'; '-';
               'Variable'; 'Coordinate Variable'; '-';
               'Attribute'; 'Global Attribute'};
              {'-'; 'Double'; 'Float'; '-'; 'Long'; 'Short';
               '-'; 'Char'; 'Byte'};
               'Catalog'; 'Info'; 'Listing'; 'Extract';
               'NetCDF File'};
            
theTags = {'DimLabel'; 'VarLabel'; 'AttLabel';
           'Dimensions'; 'Variables'; 'Attributes';
           'Properties'; 'Concepts'; 'Types';
           'Catalog'; 'Info'; 'Listing'; 'Extract';
           'Filename'};
           
theFigure = figure('Name', 'NetCDF Browser', ...
                   'Color', bluish, 'Visible', 'off', ...
                   'DeleteFcn', 'ncbevent(''DeleteFcn'')');

switch thePermission
case 'nowrite'
   set(theFigure, 'Name', [get(gcf, 'Name') ' -- Read Only'])
otherwise
   set(theFigure, 'Name', [get(gcf, 'Name') ' -- Read/Write'])
end

theFrame = uicontrol('Style', 'frame', ...
                     'Units', 'normalized', ...
                     'Position', [0 0 1 1], ...
                     'Tag', 'Frame', ...
                     'BackgroundColor', [0.25 1 1]);
             
theControls = zeros(length(theStyles), 1);

theFontSize = get(0, 'DefaultUIControlFontSize');
theFontWeight = get(0, 'DefaultUIControlFontWeight');

theFontWeight = 'bold';

for i = 1:length(theStyles)
   theControls(i) = uicontrol('Style', theStyles{i}, ...
                              'String', theStrings{i}, ...
							  'FontSize', theFontSize, ...
							  'FontWeight', theFontWeight, ...
                              'Tag', theTags{i}, ...
                              'Callback', 'ncbevent(''Callback'')');
end

thePosition = [2 2 96 96] ./ 100;

uilayout(theControls, theLayout, thePosition)

theStruct.itSelf = theFigure;
theStruct.itsGCBO = [];
theStruct.itIsClipboard = [];
switch class(theNetCDFFile)
case 'char'
   theNetCDF = netcdf(theNetCDFFile, thePermission);
   isClipboard = 0;
case 'netcdf'
   theNetCDF = theNetCDFFile;
   isClipboard = 1;
otherwise
end
if ~isempty(theNetCDF)
   result = class(theStruct, 'ncbrowser', theNetCDF);
   result.itIsClipboard = isClipboard;
   set(theFigure, 'UserData', result)
  else
   delete(theFigure)
   result = [];
   if nargout > 0
      self = result;
     else
      assignin('base', 'ans', result)
   end
   return
end

ncbmenu(result)
set(theFigure, 'MenuBar', 'none')

theDims = dim(theNetCDF);
theVars = var(theNetCDF);
theAtts = att(theNetCDF);

theDimnames = [{'-'} ncnames(theDims)];
theVarnames = [{'-'} ncnames(theVars)];
theAttnames = [{'-'} ncnames(theAtts)];

set(theControls(4), 'String', theDimnames)
set(theControls(5), 'String', theVarnames)
set(theControls(6), 'String', theAttnames)
theSize = ncsize(super(result));
set(theControls(7), 'String', mat2str(theSize(1:3)))
set(theControls(14), 'String', theNetCDFFile);

set(theControls([4 5 6 8 9]), 'Value', 1, 'UserData', 1)

set(theControls(7), 'HorizontalAlignment', 'left')

set(theControls([1:3 13]), 'BackgroundColor', bluish);
set(theControls([4 5 6]), 'BackgroundColor', light_blue);
set(theControls([7 8 9]), 'BackgroundColor', yellowish);
set(theControls(10:13), 'BackgroundColor', yellowish);

set(theFigure, 'Visible', 'on')

assignin('base', 'ncb', result)
assignin('base', 'nco', theNetCDF)
assignin('base', 'nci', theNetCDF)
assignin('base', 'ncx', [])

if nargout > 0
   self = result;
else
   ncans(result)
end
