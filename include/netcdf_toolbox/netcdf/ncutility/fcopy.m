function theResult = fcopy(theSource, theDestination, maxCharacters)

% fcopy -- Copy (duplicate) a file.
%  fcopy(theSource, theDestination, maxCharacters) copies the
%   contents of theSource file into theDestination file,
%   in increments of maxCharacters (default = 16K).  Each
%   file can be specified by its name or by an existing
%   file-pointer.
%  fcopy (no arguments) demonstrates itself by copying
%   "fcopy.m" to "junk.junk".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Jan-2000 21:24:20.
% Updated    11-Jan-2000 21:24:20.

if nargin < 1
   help fcopy
   fcopy('fcopy.m', 'junk.junk');
   return
end
if nargin < 2, return, end
if nargin < 3, maxCharacters = 1024 .* 16; end
if ischar(maxCharacters), maxCharacters = eval(maxCharacters); end

if isstr(theSource)
   src = fopen(theSource, 'r');
   if src < 0, error(' ## Source file not opened.'); end
  else
   src = theSource;
end

if isstr(theDestination)
   dst = fopen(theDestination, 'w');
   if dst < 0, error(' ## Destination file not opened.'); end
  else
   dst = theDestination;
end

while (1)
   [s, inputCount] = fread(src, [1 maxCharacters], 'char');
   if inputCount > 0, outputCount = fwrite(dst, s, 'char'); end
   if inputCount < maxCharacters | outputCount < inputCount, break, end
end

if isstr(theDestination), result = fclose(dst); end
if isstr(theSource), result = (fclose(src) | result); end

if nargout > 0, theResult = result; end
