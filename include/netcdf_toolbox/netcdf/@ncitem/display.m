function display(self)

% ncitem/display -- Display an ncitem object.
%  display(self) displays self, an ncitem object.
%
% Also see: ncitem/disp, ncitem/desc.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:44:53.

if nargin < 1, help(mfilename), return, end

theName = inputname(1);
disp(' '), disp([theName ' =']), disp(' ')
disp(self)
