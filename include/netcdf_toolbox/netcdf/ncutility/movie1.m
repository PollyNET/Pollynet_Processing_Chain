function theResult = Movie1(x1, x2, x3, x4, x5)

% Movie1 -- Show a movie.
%  Movie1(...) uses the movie() syntax to show a movie.
%   It avoids the unpleasant behavior of the Matlab movie()
%   routine, which shows the film first during loading, then
%   again at the requested speed, or as fast as possible,
%   whichever is slower.
%  Movie1(nFrames) demonstrates itself with nFrames (default = 16),
%   at four frames per second.
%  theResult = Movie1(nFrames) returns a demonstration movie
%   of nFrames.  To show theResult, use "movie1(theResult)".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-May-1997 10:24:44.
% Updated    09-Nov-1999 23:35:45.

% Note: this routine needs to be updated
%  to Matlab-5 syntax, using "varargin".

if nargin < 1, help movie1, x1 = 16, end
if isstr(x1), x1 = eval(x1); end

if nargin < 2 & length(x1) == 1
   help movie1
   nFrames = x1;
   disp(' ## Create the movie.')
   f = figure('Name', ['Movie1(' int2str(nFrames) ')']);
   tic
   theMovie = moviein(nFrames);
   k = ceil(sqrt(nFrames));
   theFrame = zeros(k, k) + 24;
   theImage = image(theFrame);
   for j = 1:nFrames
      theFrame = zeros(k, k) + 24;
      theFrame(j) = 40;
      set(theImage, 'CData', theFrame);
      set(gca, 'Visible', 'off')
      theText = text(1, 1, int2str(j), ...
         'HorizontalAlignment', 'center');
      theMovie(:, j) = getframe;
      delete(theText)
   end
   toc
   if nargout < 1
      disp(' ## Show the movie at 4 frames/second.')
      t0 = clock;
	  speed = 4;   % frames-per-second.
      movie1(theMovie, 1, speed)
      elapsed_time = etime(clock, t0);
      average_frames_per_second = nFrames ./ elapsed_time
     else
      theResult = theMovie;
   end
   return
end

theHandle = [];

len = length(x1);
if len > 1
   theMovie = x1;
  else
   theHandle = x1;
   theMovie = x2;
end

nin = nargin;
if nargin < 3, x3 = 4; nin = nin+1; end
fps = x3;

v = '';
for i = 1:nargin
   if i > 1, v = [v ' ,']; end
   v = [v 'x' int2str(i)];
end
v = ['movie(' v ')'];

if isempty(theHandle), figure(gcf), end

[m, nFrames] = size(theMovie);

fps = x3;   % Desired speed.
x3 = 1.5*x3;   % First frame is usually slow.

tic   % Start the clock.
for j = 1:nFrames
   if isempty(theHandle)
      x1 = theMovie(:, j);
	  x2 = 1;
     else
      x2 = theMovie(:, j);
   end
   eval(v)   % Show the frame.
   t = toc;   % Get elapsed time.
   tic   % Restart the clock.
   speed = 1/t;
%  disp(num2str(speed))
   x3 = x3 * fps / speed;   % Adjust speed.
end
