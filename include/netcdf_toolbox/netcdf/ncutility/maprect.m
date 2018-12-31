function rect4 = MapRect(rect1, rect2, rect3)

% MapRect -- Map rectangles.
%  MapRect(rect1, rect2, rect3) returns the rectangle
%   that is to rect3 what rect1 is to rect2.  Each
%   rectangle is given as [x1 y1 x2 y2].
%  MapRect('demo') demonstrates itself by showing
%   that maprect(r1, r2, r1) ==> r2.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jun-1997 08:33:39.

if nargin < 1, help(mfilename), rect1 = 'demo'; end

if strcmp(rect1, 'demo')
   rect1 = [0 0 3 3];
   rect2 = [1 1 2 2];
   rect3 = rect1;
   r4 = maprect(rect1, rect2, rect3);
   begets('MapRect', 3, rect1, rect2, rect3, r4)
   return
end

if nargin < 3, help(mfilename), return, end

r4 = zeros(1, 4);
i = [1 3];
for k = 1:2
   r4(i) = polyval(polyfit(rect1(i), rect2(i), 1), rect3(i));
   i = i + 1;
end

if nargout > 0
   rect4 = r4;
  else
   disp(r4)
end
