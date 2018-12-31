function theResult = plot(varargin)

% ncvar/plot -- Plot NetCDF variable.
%  plot(z, 'thePen') plots NetCDF variable z,
%   an "ncvar" object, using 'thePen'.  If z is z(x),
%   for coordinate variable x, then the function is
%   called recursively as Plot(x, z, 'thePen').
%   For z(x, y), the recursive call is Plot(x, y,
%   z, 'thePen').  The x, y, and z axes are labeled
%   with the names and units of the corresponding
%   variables.  The title is set to the name of
%   the z variable.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Apr-1997 09:44:36.

if nargin < 1, help(mfilename), return, end

if nargout > 0, theResult = []; end
result = [];

% Isolate the pen.

thePen = '-';
if isstr(varargin{length(varargin)})
   thePen = varargin{length(varargin)};
   varargin(length(varargin)) = [];
end

x = []; y = []; z = [];

theXLabel = 'Index Number';
theYLabel = 'Index Number';
theZLabel = 'Value';

if length(varargin) == 1
   z = varargin{1};
   theNetCDF = parent(z);
   theSize = ncsize(z);
   theDims = dim(z);
   if length(theDims) < 1, return, end
   if length(theSize) > 0
      x = ncvar(name(theDims{1}), theNetCDF);
      if isempty(x)
         x = (1:theSize(1)).';
         theXLabel = [name(theDims{1}) ' (Index Number)'];
      end
   end
   if length(theSize) > 1
      y = ncvar(name(theDims{2}), theNetCDF);
      if isempty(y)
         y = (1:theSize(2)).';
         theYLabel = [name(theDims{2}) ' (Index Number)'];
      end
   end
   if ~isempty(y) & 0
      result = plot3(x, y, z, thePen);
      xlabel(labelsafe(theXLabel))
      ylabel(labelsafe(theYLabel))
  else
      result = plot(x, z, thePen);
   end
  elseif length(varargin) > 1
   x = varargin{1};
   z = varargin{2};
   if length(varargin) > 2
      y = varargin{2};
      z = varargin{3};
   end
   if isa(x, 'ncvar')
      theXLabel = name(x);
      a = ncatt('units', x);
      theXUnits = labelsafe(a(:));
      if ~isempty(theXUnits), theXLabel = [theXLabel ' (' theXUnits ')']; end
      switch lower(name(x))
      case 'time'   % Epic-awareness: epic_code = 624.
         t = x;
%        x = x(:);
         x = ncsubsref(x, '()', {':'});
         t2 = ncvar('time2', parent(t));
         if ~isempty(t2)
            e = ncatt('epic_code', t);
            e2 = ncatt('epic_code', t2);
            if isequal(e(:), 624) & isequal(e2(:), 624)
               tt = ncsubsref(t, '()', ':');
               tt2 = ncsubsref(t2, '()', ':');
               x = tt + tt2 ./ (24 .* 3600 .* 1000);
               theXOffset = floor(min(min(x)));
               x = x - theXOffset;
               theXLabel = [theXLabel ' - ' int2str(theXOffset)];
           end
         end
      otherwise
%        x = x(:);
         x = ncsubsref(x, '()', {':'});
      end
   elseif isa(z, 'ncvar')
      theDims = dim(z);
      if length(theDims) > 0
         theXLabel = [name(theDims{1}) ' (Index Number)'];
      end
   end
   if isa(y, 'ncvar')
      theYLabel = name(y);
      a = ncatt('units', y);
      theYUnits = labelsafe(a(:));
      if ~isempty(theYUnits), theYLabel = [theYLabel ' (' theYUnits ')']; end
%     y = y(:);
      y = ncsubsref(y, '()', {':'});
   elseif isa(z, 'ncvar')
      theDims = dim(z);
      if length(theDims) > 1
         theYLabel = [name(theDims{2}) ' (Index Number)'];
      end
   end
   theZLabel = name(z);
   a = ncatt('units', z);
   theZUnits = labelsafe(a(:));
   if ~isempty(theZUnits), theZLabel = [theZLabel ' (' theZUnits ')']; end
   axes(gca)
   if length(varargin) < 3 | 1
      zz = ncsubsref(z, '()', {':'});
      result = stackplot(x, zz, thePen);
      xlabel(labelsafe(theXLabel))
      ylabel(labelsafe(theZLabel))
      set(result, 'ButtonDownFcn', 'findpt')
   else
      zz = ncsubsref(z, '()', {':'});
      result = plot3(x, y, zz, thePen);
      xlabel(labelsafe(theXLabel))
      ylabel(labelsafe(theYLabel))
      zlabel(labelsafe(theZLabel))
   end
   theTitle = name(z);
   title(labelsafe(theTitle))
end

if nargout > 0, theResult = result; end
