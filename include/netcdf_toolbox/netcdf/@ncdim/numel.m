function theResult = numel(varargin)

% class/numel -- Overloaded NUMEL.
%  numel(varargin) is called by Matlab 6.1+ during SUBSREF
%   and SUBSASGN operations to figure out how many output
%   and input arguments to expect, respectively.  We
%   believe the answer should always be 1, in keeping
%   with the way we have traditionally programmed.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 30-Jul-2001 15:45:20.
% Updated    30-Jul-2001 15:45:20.

theResult = numel_default(varargin{:});
