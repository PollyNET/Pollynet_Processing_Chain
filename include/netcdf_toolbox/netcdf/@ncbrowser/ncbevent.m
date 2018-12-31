function theResult = ncbevent(self, theEvent)

% NCBrowser/Event -- Event handler.
%  NCBrowser/Event(self, 'theEvent') handles 'theEvent'
%   sent to self, an NCBrowser object, by the "gcbo".
%   TheEvent is usually the name of the callback.  Each
%   time this routine is called, the NetCDF file object
%   (class "netcdf") is assigned to the command-line
%   variable "nco", and the selected NetCDF item is
%   assigned to "nci".   The "ncb" variable is the
%   current "ncbrowser" object.  The "ncx" variable
%   holds the most recently extracted data.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Apr-1997 09:23:56.
% Updated    27-Jul-2000 14:44:40.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = 'Callback'; end

bluish = [0.25 1 1];
light_blue = [0.75 1 1];
yellow = [1 1 0];
yellowish = [1 1 0.5];
greenish = (bluish + yellow) ./ 2;
purplish = [0.75 0.75 1];

theFigure = self.itSelf;

busy(theFigure)

assignin('base', 'ncb', self)

% Get the current selections.

theGCBO = gcbo;
if isempty(theGCBO)
	theGCBO = findobj(theFigure, 'Type', 'uicontrol', ...
					'Style', 'pushbutton', 'Tag', 'Catalog');
end
theDimname = '';
theVarname = '';
theAttname = '';
theConceptname = '';
theTypename = '';
theNCItem = [];
theNCDim = [];
theNCVar = [];
theNCAtt = [];

theNetCDF = super(self);

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Dimensions');
theDimnames = get(f, 'String');
if ~iscell(theDimnames), theDimnames = {theDimnames}; end
theDimvalue = get(f, 'Value');
if any(theDimvalue)
   theDimname = theDimnames{theDimvalue};
   theDimPrefix = theDimname(1);
   if theDimPrefix == '*', theDimname(1) = ''; end   % Trouble with '*...'.
   if ~strcmp(theDimname, '-')
%		theNCDim = self(theDimname);
		theNCDim = ncsubsref(self, '()', {theDimname});
	end
end
theDimensions = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Variables');
theVarnames = get(f, 'String');
if ~iscell(theVarnames), theVarnames = {theVarnames}; end
theVarvalue = get(f, 'Value');
if any(theVarvalue)
   theVarname = theVarnames{theVarvalue};
   theVarPrefix = theVarname(1);
   if theVarPrefix == '*', theVarname(1) = ''; end
   if ~strcmp(theVarname, '-')
%		theNCVar = self{theVarname};   % <== Release 11 Trouble.
		theNCVar = ncsubsref(self, '{}', {theVarname});
	end
end
theVariables = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Attributes');
theAttnames = get(f, 'String');
if ~iscell(theAttnames), theAttnames = {theAttnames}; end
theAttvalue = get(f, 'Value');
if any(theAttvalue)
   theAttname = theAttnames{theAttvalue};
   theAttPrefix = theAttname(1);
   if theAttPrefix == '*', theAttname(1) = ''; end
   if strcmp(theVarname, '-') | isempty(theNCVar)
      theNCAtt = ncatt(theAttname, self);
     else
      theNCAtt = ncatt(theAttname, theNCVar);
   end
end
theAttributes = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Properties');
theProps = get(f, 'String');
if theGCBO ~= f, set(f, 'String', '-'), end
theProperties = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Concepts');
theNames = get(f, 'String');
if ~iscell(theNames), theNames = {theNames}; end
theValue = get(f, 'Value');
if any(theValue), theConceptname = theNames{theValue}; end
theConcepts = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Types');
theNames = get(f, 'String');
if ~iscell(theNames), theNames = {theNames}; end
theValue = get(f, 'Value');
if any(theValue), theTypename = theNames{theValue}; end
theTypes = f;

if ~isempty(theNCDim), theNCItem = theNCDim; end
if ~isempty(theNCVar), theNCItem = theNCVar; end
if ~isempty(theNCAtt), theNCItem = theNCAtt; end

if any(theGCBO == [theDimensions theVariables theAttributes])
   set([theDimensions theVariables theAttributes], ...
         'BackgroundColor', light_blue)
end

theValue = [];
if strcmp(get(theGCBO, 'Type'), 'uicontrol')
   theValue = get(theGCBO, 'Value');
   theOldValue = get(theGCBO, 'UserData');
end
theOldGCBO = self.itsGCBO;
theTag = get(theGCBO, 'Tag');

% Process the event.

switch lower(theEvent)
case 'buttondownfcn'
   disp([' ## Not yet operational: ' theEvent])
case 'callback'
   switch lower(theTag)
   case 'dimensions'
      self.itsGCBO = theDimensions;
      set(theFigure, 'UserData', self)
      if strcmp(theDimname, '-')
         set(theDimensions, 'Value', theOldValue)
         idle(theFigure), return
      end
      set(theDimensions, 'UserData', theValue)
%		d = self(theDimname);   % Trouble with '*...' names.
		d = ncsubsref(self, '()', {theDimname});
      theProps = mat2str(ncsize(d));
      v = var(d);
      a = att(self);
      if theDimPrefix == '*', theDimPrefix = ''; else, theDimPrefix = '*'; end
      theDimnames{theDimvalue} = [theDimPrefix theDimname];
      theVarnames = [{'-'} ncnames(v)];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'BackgroundColor', yellowish);
      set(theDimensions, 'String', theDimnames, 'Value', theDimvalue);
      set(theVariables, 'String', theVarnames, 'Value', 1);
      set(theAttributes, 'String', theAttnames, 'Value', 1);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(d);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'dimension';
      theRecdim = recdim(self);
      if ~isempty(theRecdim) & dimid(theRecdim) == dimid(d)
         theName = 'record dimension';
      end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'variables'
      self.itsGCBO = theVariables;
      set(theFigure, 'UserData', self)
      if strcmp(theVarname, '-')
         set(theVariables, 'Value', theOldValue)
         idle(theFigure), return
      end
      set(theVariables, 'UserData', theValue)
%		v = self{theVarname};   % <== Release 11 Trouble.
		v = ncsubsref(self, '{}', {theVarname});
      theProps = mat2str(ncsize(v));
      d = dim(v);
      a = att(v);
      theDimnames = [{'-'} ncnames(d)];
      if theVarPrefix == '*', theVarPrefix = ''; else, theVarPrefix = '*'; end
      theVarnames{theVarvalue} = [theVarPrefix theVarname];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'String', theDimnames, 'Value', 1);
      set(theVariables, 'String', theVarnames, 'Value', theVarvalue);
      set(theVariables, 'BackgroundColor', yellowish);
      set(theAttributes, 'String', theAttnames, 'Value', 1);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(v);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'variable';
      if iscoord(v), theName = 'coordinate variable'; end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'attributes'
      self.itsGCBO = theAttributes;
      set(theFigure, 'UserData', self)
      if strcmp(theAttname, '-')
         set(theAttributes, 'Value', theOldValue)
         idle(theFigure), return
      end
      if theAttPrefix == '*', theAttPrefix = ''; else, theAttPrefix = '*'; end
      theAttnames{theAttvalue} = [theAttPrefix theAttname];
      set(theAttributes, 'String', theAttnames, 'Value', theAttvalue)
      set(theAttributes, 'UserData', theValue)
      if strcmp(theVarname, '-')
         v = [];
         a = ncatt(theAttname, self);
      else
%			v = self{theVarname};   % <== Release 11 Trouble.
			v = ncsubsref(self, '{}', {theVarname});
         a = ncatt(theAttname, v);
      end
      theProps = mat2str(a(:));
      set(theAttributes, 'BackgroundColor', yellowish);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(a);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'attribute';
      if isempty(v), theName = 'global attribute'; end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'concepts'
      if strcmp(theConceptname, '-')
         set(theConcepts, 'Value', get(theConcepts, 'UserData'))
         idle(theFigure), return
      end
      set(theConcepts, 'UserData', theValue)
   case 'types'
      if strcmp(theTypename, '-')
         set(theTypes, 'Value', get(theTypes, 'UserData'))
         idle(theFigure), return
      end
      set(theTypes, 'UserData', theValue)
   case 'properties'
      ncb = self;
      nco = theNetCDF;
      nci = theNCItem;
      ans = theNCItem;
      theStatement = strrep(theProps, '>> ', '');
      f = findstr(theStatement, ' <==');
      if any(f)
         theStatement(f(1):length(theStatement)) = '';
      end
      if ~any(theStatement == '=')
         result = eval(theStatement, '''## ERROR ##''');
      else
         result = [];
         evalin('base', [theStatement ';'], '''## ERROR ##''');
      end
      if isequal(result, '## ERROR ##')
         result = [theStatement ' <== Unable to evaluate.'];
      end
      switch class(result)
      case {'double', 'char'}
         result = ['>> ' mat2str(result)];
      otherwise
         disp(result)
         result = [theStatement ' <== See command window.'];
      end
      set(theProperties, 'String', result)
      idle(theFigure)
      return
   case 'catalog'
      d = dim(self);
      v = var(self);
      a = att(self);
      theDimnames = [{'-'} ncnames(d)];
      theVarnames = [{'-'} ncnames(v)];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'String', theDimnames, 'Value', 1, 'UserData', 1);
      set(theVariables, 'String', theVarnames, 'Value', 1, 'UserData', 1);
      set(theAttributes, 'String', theAttnames, 'Value', 1, 'UserData', 1);
      theSize = ncsize(super(self));
      set(theProperties, 'String', mat2str(theSize(1:3)))
      set(theConcepts, 'Value', 1, 'UserData', 1);
      set(theTypes, 'Value', 1, 'UserData', 1);
      self.itsGCBO = [];
      set(theFigure, 'UserData', self)
      theNCItem = theNetCDF;
      assignin('base', 'nci', theNCItem)
      assignin('base', 'ans', theNCItem)
   case {'listing', 'plot'}
      ncbgraph(self, theNCItem, lower(theTag))
      set(theProperties, 'String', theProps)
   case 'info'
      if isempty(theNCItem), theNCItem = theNetCDF; end
      disp(theNCItem)
      set(theProperties, 'String', theProps)
   case 'extract'
      if ~isempty(theNCItem), ncextract(theNCItem, 'ncx'), end
   otherwise
   end
case 'createfcn'
   disp([' ## Not yet operational: ' theEvent])
case 'deletefcn'
   assignin('base', 'nco', [])
   assignin('base', 'nci', [])
   assignin('base', 'ans', [])
   close(self)
case 'menucallback'
   theTag = get(gcbo, 'Tag');
   s = abs(lower(theTag));
   f = find((s >= abs('0') & s <= abs('9')) | ...
            (s >= abs('a') & s <= abs('z')));
   theTag = theTag(f);
   set(gcbo, 'Tag', theTag);
   switch lower(theTag)
	case 'aboutncbrowser'
		help ncbrowser
   case 'netcdf'
      theFile = 0;
      [theFile, thePath] = uiputfile('unnamed.nc', 'Save New NetCDF As:');
      if any(theFile)
         theNCItem = netcdf([thePath theFile], 'clobber');
         if ~isempty(theNCItem), theNCItem = close(theNCItem); end
      end
   case 'dimension'
      thePrompts = {'Dimension Name', 'Dimension Size'};
      theName = 'unnamedDimension';
      theSize = '0';
      theInfo = inputdlg(thePrompts, ...
                         'New NetCDF Dimension', [1], {theName, theSize});
      if length(theInfo) > 1
         theDimname = theInfo{1};
         theDimsize = eval(theInfo{2});
         if ~isempty(theDimname) & ~isempty(theDimsize)
%				self(theDimname) = theDimsize;
% Note "self1" below.  Why not "self"?
%				self1 = ncsubsasgn(self, '()', theDimname, theDimsize);
				self = ncsubsasgn(self, '()', theDimname, theDimsize);
            ncbrefresh(self, super(self))
         end
      end
      set(theProperties, 'String', theProps)
   case 'variable'
      if any(exist('listpick') == [2 3 6])   % M-, MEX-, or P-file.
         thePrompt = {'Enter New Variable Name'};
         theVarname = 'unnamedVariable';
         theInfo = inputdlg(thePrompt, ...
               'New NetCDF Variable', [1], {theVarname});
         if length(theInfo) > 0 & ~isempty(theInfo{1})
            theVarname = theInfo{1};
            thePrompt = {['Select Dimensions For Variable "' theVarname '"']};
            theDimnames = [];
            theDimnames = feval('listpick', ncnames(dim(theNetCDF)), ...
                  thePrompt, 'New NetCDF Variable', 'multiple');
            if iscell(theDimnames)
               if strcmp(theTypename, '-'), theTypename = 'double'; end
               theNetCDF{theVarname} = eval(['nc' lower(theTypename) '(theDimnames)']);
               ncbrefresh(self, super(self));
            end
         end
         set(theProperties, 'String', theProps)
      end
   case 'attribute'
      theNCParent = theNCItem;
		if isempty(theNCParent)
			theNCParent = super(self);
			theNCItem = theNCParent;
		end
      switch class(theNCParent)
      case {'ncdim', 'ncatt'}
         theNCParent = parent(theNCParent);
			theNCItem = theNCParent;
      end
      switch class(theNCParent)
		case {'ncbrowser'}
			theNCParent = super(self);
			theNCItem = theNCParent;
      end
      thePrompts = {'Attribute Name', 'Attribute Data'};
      theName = '';
      theData = '''''';
      theInfo = inputdlg(thePrompts, ...
                         'New NetCDF Attribute', [1], {theName, theData});
      if length(theInfo) > 1 & ~isempty(theInfo{1})
         theName = theInfo{1};
         theData = eval(theInfo{2});
         if strcmp(theTypename, '-') | isstr(theData)
            eval(['theNCParent.' theName ' = theData;'])
           else
            eval(['theNCParent.' theName ' = nc' lower(theTypename) '(theData);'])
         end
         ncbrefresh(self, theNCItem)
      end
      set(theProperties, 'String', theProps)
   case 'open'
      theNCItem = ncbrowser;
   case 'save'
      sync(theNetCDF)
   case 'saveas'   % Save-As, but do not open new file.
      sync(theNetCDF)
      theFile = 0;
      [theFile, thePath] = uiputfile('unnamed.nc', 'Save NetCDF As');
      if any(theFile)
         theNewNetCDF = netcdf([thePath theFile], 'clobber');
         if ~isempty(theNewNetCDF)
            theNewNetCDF < super(self);
            theNewNetCDF = close(theNewNetCDF);
            if isempty(theNewNetCDF) & 0
               theOldBrowser = self.itSelf;
               theNewBrowser = ncbrowser([thePath theFile], 'write');
               if ~isempty(theNewBrowser)
                  delete(theOldBrowser)
                  theNCItem = theNewBrowser;
               end
            end
         end
      end
   case 'done'
      delete(theFigure)
		return
   case 'undo'
      disp([' ## Not yet operational: ' theEvent])
   case 'cut'
      disp([' ## Not yet operational: ' theEvent])
   case 'copy'
      if ~self.itIsClipboard
         theClipboard = netcdf(ncbclipboard(self), 'clobber');
         if ~isempty(theClipboard)
            for i = 2:length(theDimnames)
               d = theDimnames{i};
               if d(1) == '*'
                  d(1) = '';
                  d = ncdim(d, theNetCDF);
                  theClipboard < d;
               end
            end
            for i = 2:length(theVarnames)
               v = theVarnames{i};
               if v(1) == '*'
                  v(1) = '';
                  v = ncvar(v, theNetCDF);
                  d = dim(v);
                  for j = 1:length(d)
                     theClipboard < d{j};
                  end
                  theClipboard < v;
                  a = att(v);
                  for j = 1:length(a)
                     theClipboard < a{j};
                  end
%                 copy(ncvar(v, theNetCDF), theClipboard)
               end
            end
            for i = 2:length(theAttnames)
               a = theAttnames{i};
               if a(1) == '*'
                  a(1) = '';
                  if theVarname(1) ~= '-'
                     theClipboard < ncatt(a, theNCVar);
                    else
                     theClipboard < ncatt(a, theNetCDF);
                  end
               end
            end
            close(theClipboard)
         end
      end
   case 'paste'   % This copies structure, but not data.
      if ~self.itIsClipboard
         theClipboard = netcdf(ncbclipboard(self), 'nowrite');
         if ~isempty(theClipboard)
            theNetCDF < theClipboard;
            ncbrefresh(self, super(self))
            close(theClipboard)
         end
      end
   case 'delete'
      disp([' ## Not yet operational: ' theEvent])
   case 'showclipboard'
      isClipboard = self.itIsClipboard;
      if ~self.itIsClipboard
         theNCItem = ncbrowser(ncbclipboard(self), 'nowrite');
      end
   case 'selectall'
      switch lower(class(theNCItem))
      case 'ncdim'
         theCount = 0;
         for i = 2:length(theDimnames)
            theCount = theCount + (theDimnames{i}(1) == '*');
         end
         for i = 2:length(theDimnames)
            theDimPrefix = theDimnames{i}(1);
            if theDimPrefix ~= '*' & theCount < length(theDimnames)-1
               theDimnames{i} = ['*' theDimnames{i}];
              elseif theDimPrefix == '*' & theCount == length(theDimnames)-1
               theDimnames{i}(1) = '';
            end
         end
         set(theDimensions, 'String', theDimnames, 'Value', theDimvalue)
      case 'ncvar'
         theCount = 0;
         for i = 2:length(theVarnames)
            theCount = theCount + (theVarnames{i}(1) == '*');
         end
         for i = 2:length(theVarnames)
            theVarPrefix = theVarnames{i}(1);
            if theVarPrefix ~= '*' & theCount < length(theVarnames)-1
               theVarnames{i} = ['*' theVarnames{i}];
              elseif theVarPrefix == '*' & theCount == length(theVarnames)-1
               theVarnames{i}(1) = '';
            end
         end
         set(theVariables, 'String', theVarnames, 'Value', theVarvalue)
      case 'ncatt'
         theCount = 0;
         for i = 2:length(theAttnames)
            theCount = theCount + (theAttnames{i}(1) == '*');
         end
         for i = 2:length(theAttnames)
            theAttPrefix = theAttnames{i}(1);
            if theAttPrefix ~= '*' & theCount < length(theAttnames)-1
               theAttnames{i} = ['*' theAttnames{i}];
              elseif theAttPrefix == '*' & theCount == length(theAttnames)-1
               theAttnames{i}(1) = '';
            end
         end
         set(theAttributes, 'String', theAttnames, 'Value', theAttvalue)
      otherwise
      end
   case {'fillvalue', 'missingvalue', ...
         'addoffset', 'scalefactor', ...
         'units', ...
         'fortranformat', 'cformat', ...
         'epiccode', 'comment', ...
         'genericname', 'longname', 'shortname'}
      if isa(theNCItem, 'ncatt')
         a = theNCItem;
         theLabel = get(gcbo, 'Label');
         result = name(a, theLabel);
         if strcmp(theVarname, '-')
            a = att(self);
         else
%				v = self{theVarname};   % <== Release 11 Trouble.
				v = ncsubsref(self, '{}', {theVarname});
            a = att(v);
         end
         theAttnames = [{'-'} ncnames(a)];
         set(theAttributes, 'String', theAttnames);
      end
   case 'rename'
      thePrompt = ['Rename NetCDF ' theConceptname ' "' ...
            name(theNCItem) '" To:'];
      theName = {name(theNCItem)};
      theNewname = inputdlg(thePrompt, ...
                            'NetCDF Rename', 1, theName);
      theNewname = theNewname{1};
      if ~isempty(theNewname) & ~strcmp(theNewname, theName)
         name(theNCItem, theNewname)
         ncbrefresh(self, theNCItem)
      end
      set(theProperties, 'String', theProps)
   case 'resize'
		if isa(theNCItem, 'ncvar') | isa(theNCItem, 'ncdim')
	      theName = name(theNCItem);
			theSize = ncsize(theNCItem);
			sz = mat2str(theSize);
	      thePrompt = ['Resize NetCDF ' theConceptname ' "' ...
	            theName '" From ' mat2str(theSize) ' To:'];
	      theNewSize = inputdlg(thePrompt, ...
						'NetCDF Resize', 1, {mat2str(theSize)});
			if ~isempty(theNewSize)
		      theNewSize = eval(['[' theNewSize{1} ']'], '[]');
		      if isequal(size(theSize), size(theNewSize))
					busy
					result = resize(theNCItem, theNewSize);
					idle
					if ~isempty(result)
						theNCItem = result;
						self.netcdf = parent(theNCItem);   % Very important.
		         	ncbevent(self)   % Re-catalog.
					end
				else
					warndlg('Requested size is incompatible.', ...
								'NCBrowser Warning')
		      end
	      end
		end
	   set(theProperties, 'String', theProps)
   case 'lowercase'
      name(theNCItem, lower(name(theNCItem)))
      ncbrefresh(self, theNCItem)
   case 'uppercase'
      name(theNCItem, upper(name(theNCItem)))
      ncbrefresh(self, theNCItem)
   case {'line', 'circles', 'dots', 'degrees', ...
         'contour', 'image', 'listing', ...
         'mesh', 'surf', 'pxline'}
      switch ncclass(theNCItem)
      case 'ncatt'
         theNCItem = parent(theNCItem);
      otherwise
      end
      switch ncclass(theNCItem)
      case 'ncvar'
         ncbgraph(self, theNCItem, lower(theTag))
      otherwise
      end
      set(theProperties, 'String', theProps)
   case 'showgraph'
      ncbgraph(self)
   otherwise
      disp([theEvent ':' theTag])
   end
   idle(theFigure)
case 'refresh'
   ncbrefresh(self, theNCItem)
   set(theProperties, 'String', theProps)
otherwise
   disp([' ## Unknown event: ' theEvent ':' theTag])
end

assignin('base', 'ncb', self)
assignin('base', 'nco', theNetCDF)
assignin('base', 'nci', theNCItem)
assignin('base', 'ans', theNCItem)

idle(theFigure)

if nargout > 0, theResult = theNCItem; end
