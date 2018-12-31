function theResult = isepic(self)

% netcdf/isepic -- Is this an epic file?
%  isepic(self) returns TRUE (1) if self, a "netcdf"
%   object, appears to represent a NOAA epic file.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-May-1997 10:43:30.

if nargin < 1, help(mfilename), return, end

result = 0;
if (0)   % Matlab pre-5.3 syntax.
	theTime = self{'time'};
	theTime2 = self{'time2'};
else   % Matlab 5.3.
	s.type = '{}';
	s.subs = {'time'};
	theTime = subsref(self, s);
	s.subs = {'time2'};
	theTime2 = subsref(self, s);
end

if ~isempty(theTime) & ~isempty(theTime2)
   theEpicCode = theTime.epic_code;
   theEpicCode2 = theTime2.epic_code;
   if ~isempty(theEpicCode) & ~isempty(theEpicCode2)
      result = 1;
   end
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
