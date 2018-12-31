function h = StackPlot(varargin)

% StackPlot -- Plot of stacked curves.
%  StackPlot(x, y, 'theColor', ...) plots the columns
%   of y(x) adjacent to each other, with a small margin.
%   The syntax is exactly the same as for "plot()".  The
%   "UserData" property of each line contains its column-
%   number and the additive-offset from the original value
%   of the column.
%  StackPlot(m, n, 'theColor') demonstrates itself with a
%   random array of size [m+1 n].  The size defaults to
%   [20 5].
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.
 
% Version of 5-Jun-96 at 12:07:42.99.
% Version of 28-Aug-1997 09:07:13.

if nargin < 1, help(mfilename), varargin{1} = 20; end

if isstr(varargin{1})
   if strcmp(varargin{1}, 'demo')
      varargin{1} = 20;
   else
      varargin{1} = eval(varargin{1});
   end
end

if length(varargin{1}) == 1
   m = varargin{1}; n = fix((m+3)./4);
   if nargin > 1, n = varargin{2}; end
   x = 1:m;
   y = sin(sort(rand(m, n)) * n * pi);
   figure('Name', 'StackPlot');
   if nargin < 3
      hh = stackplot(x, y);
   else
      theColor = varargin{3};
      hh = stackplot(x, y, theColor);
   end
   if exist('findpt') == 2
      findpt(hh)
   end
   if exist('zoomsafe') == 2
      zoomsafe
   end
   if nargout > 0, h = hh; end
   return
end

theYIndex = 1;
if nargin > 1 & ~isstr(varargin{2})
   theYIndex = 2;
end

y = squeeze(varargin{theYIndex});
y = reshape(y, size(y, 1), prod(size(y))./size(y, 1));

[m, n] = size(y);
if m > 1
   theMargin = (max(max(y)) - min(min(y))) ./ (10 .* n);
   theOffset = zeros(1, n);
   for j = 2:n
      theOffset(j) = max(y(:, j-1)) - min(y(:, j))  + theMargin;
      y(:, j) = y(:, j) + theOffset(j);
   end
else
   theOffset = 0;
end

varargin{theYIndex} = y;

hh = plot(varargin{:});
for theIndex = 1:length(hh)
   set(hh(theIndex), 'UserData', [theIndex theOffset(theIndex)])
end

if nargout > 0, h = hh; end
