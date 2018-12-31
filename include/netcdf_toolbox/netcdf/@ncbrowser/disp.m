function disp(self)

% disp -- Display self.
%  disp(self) displays self, an "ncbrowser" object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-May-1997 13:39:24.

if nargin < 1, help(mfilename), return, end

disp(struct(self))
