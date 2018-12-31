function theResult = numel_default(varargin)

% class/numel_default -- Default NUMEL method.
%  numel_default(...) returns a value of 1.
%   It gets called by our overloaded NUMEL
%   methods, on the hope that, up to now, we
%   have always expected SUBSREF and SUBSASGN
%   to deliver or accept just one argument.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 30-Jul-2001 15:49:47.
% Updated    30-Jul-2001 15:49:47.

theResult = 1;   % Keep fingers crossed.
