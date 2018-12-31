function ncbevent(theEvent)

% ncbevent -- Dispatch an NCBrowser event.
%  ncbevent('theEvent') dispatches theEvent to
%   the "ncbevent" method of the NCBrowser that
%   owns the current window.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Apr-1997 09:23:56.

self = get(gcf, 'UserData');

if isa(self, 'ncbrowser')
   if nargin < 1
      ncbevent(self)
   else
      ncbevent(self, theEvent)
   end
end
