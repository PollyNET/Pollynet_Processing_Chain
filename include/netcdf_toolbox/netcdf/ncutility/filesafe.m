function theResult = filesafe(theFilename)

% filesafe -- Adjust file-separation-characters.
%  filesafe('theFilename') returns 'theFilename' with its
%   file-separation-characters made compatible with the
%   present computer.  Useful for portability, such as
%   when processing URL's.  Not for VMS.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Dec-1997 09:57:54.

if nargin < 1, help(mfilename), return, end

theSeparators = {'/', '\', ':'};

result = theFilename;
for i = 1:length(theSeparators)
   result = strrep(result, theSeparators{i}, filesep);
end

if nargout > 1
   theResult = result;
else
   disp(result)
end
