function theResult = modplot(x, y, modulo, varargin)

% modplot -- Plot with pen-up at modulo crossings.
%  modplot(x, y, modulo, ...) plots y(x), modulo
%   the given value.  The pen is lifted at modulo
%   crossings.
%  modplot (no argument) demonstrates itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 24-Jul-1997 16:21:10.

if nargin < 1, help(mfilename), x = 'demo'; end

if strcmp(x, 'demo'), x = 20; end

if ischar(x), x = eval(x); end

if length(x) == 1
   n = x;
   x = 0:n;
   y = 360 .* rand(size(x));
   subplot(2, 1, 1)
   plot(x, y, '-o')
   axis([0 length(x) 0 360])
   subplot(2, 1, 2)
   modplot(x, y, 360, '-o')
   axis([0 length(x)-1 0 360])
   figure(gcf)
   return
end

if nargin < 3, modulo = 1; end

% Find the crossings.

f = find(abs(diff(y)) > modulo/2);

px = x(f); py = y(f) + NaN;

kk = [(1:length(x)).'; f(:)].';
xx = [x(:); px(:)].';
yy = [y(:); py(:)].';

[ignore, indices] = sort(kk);   % Needs work.
xx = xx(indices);
yy = yy(indices);

% Interleave NaN values at the crossings.

% Plot the data.

result = plot(xx, yy, varargin{:});

if nargout > 0, theResult = result; end
