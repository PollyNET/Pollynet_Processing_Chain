function theResult = ncsubsasgn(self, varargin)

% ncitem/ncsubsasgn -- Dispatch subsasgn() call.
%  ncsubsasgn(self, type1, subs1, ..., other) dispatches
%   a call to the subsasgn() function for self, an "ncitem"
%   object, using the sequence of "types" and "subs" to
%   prepare the required "struct".  The final argument must
%   be the right-side argument.  Multi-dimensional subscripts
%   must be embedded in a cell.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 24-Mar-1998 22:45:05.

if nargin < 1, help(mfilename), return, end

if length(varargin) < 3 | rem(length(varargin), 2) == 0
    error(' ## Requires even number of type/subs pairs.')
end

% The substruct() function is new in v.5.2.
%  Do not use here.

k = 0;
for i = 2:2:length(varargin)
    k = k+1;
    theType = varargin{i-1};
    theSubs = varargin{i};
    if ~iscell(theSubs), theSubs = {theSubs}; end
    theStruct(k).type = theType;
    theStruct(k).subs = theSubs;
end

other = varargin{length(varargin)};

theResult = subsasgn(self, theStruct, other);
