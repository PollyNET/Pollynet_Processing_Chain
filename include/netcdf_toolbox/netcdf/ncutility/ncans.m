function ncans(theAns, theName)

% ncans -- Assign a value to base-workspace.
%  ncans(theAns, 'theName') assigns theAns to 'theName'
%   (default = 'ans') in the "base" workspace.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Aug-1997 14:09:59.

if nargin < 1, help(mfilename), return, end

if nargin < 2, theName = 'ans'; end

assignin('base', theName, theAns)
