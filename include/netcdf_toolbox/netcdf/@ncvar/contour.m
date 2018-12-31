function theResult = contour(varargin)

% ncvar/contour -- Contour a NetCDF variable.
%  contour(z, 'thePen') meshes NetCDF variable z,
%   an "ncvar" object, using 'thePen'.  If z is z(x),
%   for coordinate variable x, then the function is
%   called recursively as NCMesh(x, z, 'thePen').
%   For z(x, y), the recursive call is NCMesh(x, y,
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
   theSize = size(z);
   theDims = dim(z);
   if length(theDims) < 1, return, end
   if length(theSize) > 0
      x = ncvar(name(theDims{1}), theNetCDF);
      if isempty(x), x = (1:theSize(1)).'; end
   end
   if length(theSize) > 1
      y = ncvar(name(theDims{2}), theNetCDF);
      if isempty(y), y = (1:theSize(2)).'; end
   end
   if ~isempty(y)
      result = contour(x, y, z, thePen);
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
      theXUnits = a(:);
      if ~isempty(theXUnits), theXLabel = [theXLabel ' ' theXUnits]; end
      x = x(:);
   end
   if isa(y, 'ncvar')
      theYLabel = name(y);
      a = ncatt('units', y);
      theYUnits = a(:);
      if ~isempty(theYUnits), theYLabel = [theYLabel ' ' theYUnits]; end
      y = y(:);
   end
   theZLabel = name(z);
   a = ncatt('units', z);
   theZUnits = a(:);
   if ~isempty(theZUnits), theZLabel = [theZLabel ' ' theZUnits]; end
   axes(gca)
   if length(varargin) > 2
      result = contour3(x, y, z(:), thePen);
      xlabel(labelsafe(theXLabel))
      ylabel(labelsafe(theYLabel))
      zlabel(labelsafe(theZLabel))
   end
   theTitle = name(z);
   title(labelsafe(theTitle))
end

if nargout > 0, theResult = result; end
