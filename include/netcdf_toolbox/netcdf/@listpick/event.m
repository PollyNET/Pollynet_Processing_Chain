function theResult = Event(self, theMode)

% ListMove/Event -- Event handler.
%  Event(self) handles mouse events associated
%   with self, a "listpick" object.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theMode = 'normal'; end

theFigure = self.itSelf;

theSource = findobj(theFigure, 'Tag', 'Source');
theDestination = findobj(theFigure, 'Tag', 'Destination');
theOkay = findobj(theFigure, 'Tag', 'Okay');

theSourceString = get(theSource, 'String');
theDestinationString = get(theDestination, 'String');

theTag = get(gcbo, 'Tag');
theValue = get(gcbo, 'Value');
theOldValue = get(gcbo, 'UserData');

switch lower(theTag)
case {'source', 'destination'}
   if theValue == 1 & 0
      set(gcbo, 'Value', theOldValue)
      return
   end
otherwise
end

switch lower(theTag)
case 'source'
   theSrc = theSource;
   theDst = theDestination;
   theTag = 'Move';
case 'destination'
   theSrc = theDestination;
   theDst = theSource;
   theTag = 'Move';
otherwise
end

switch lower(theTag)
case 'move'
   theSrcList = get(theSrc, 'String');
   theDstList = get(theDst, 'String');
   theSrcValue = get(theSrc, 'Value');
   theDstValue = get(theDst, 'Value');
   s = theSrcList{theSrcValue};
   switch lower(theMode)
   case 'unique'
      theDstList = [theDstList; {s}];
      theSrcList(theSrcValue) = [];
      theSrcValue = min(theSrcValue, length(theSrcList));
      theDstValue = length(theDstList);
   case 'multiple'
      if theDst == theDestination
         theDstList = [theDstList; {s}];
         theDstValue = length(theDstList);
      elseif theDst == theSource
         theSrcList(theSrcValue) = [];
         theSrcValue = min(theSrcValue, length(theSrcList));
      end
   otherwise
   end
   set(theSrc, 'String', theSrcList, 'UserData', theSrcValue)
   set(theDst, 'String', theDstList, 'UserData', theDstValue)
   if length(theSrcList) > 0, set(theSrc, 'Value', theSrcValue), end
   if length(theDstList) > 0, set(theDst, 'Value', theDstValue), end
   set(theOkay, 'UserData', get(theDestination, 'String'))
case {'cancel', 'okay'}
   set(theFigure, 'UserData', [])
otherwise
end
