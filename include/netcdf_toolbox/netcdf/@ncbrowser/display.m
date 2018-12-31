function display(self)

% display -- Display an ncbrowser object.
%  display(self) displays self, an ncbrowser object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-May-1997 13:43:20.

if nargin < 1, help(mfilename), return, end

theName = inputname(1);
disp(' '), disp([theName ' =']), disp(' ')
disp(self)
