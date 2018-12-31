function [from, to] = mapsubs(src, dst, subs)

% mapsubs -- Map subscripts.
%  [from, to] = mapsubs(src, dst, subs) works as follows:
%   indices {src} map exactly to indices {dst}.  We return
%   two sets of indices that allow a source array x to be
%   sampled at positions corresponding to the subscripts
%   {subs} of a destination array y, that is, y(subs{:}).
%   The input arguments are expected to be cell-arrays,
%   all of the same length, that contain vectors of
%   numerical subscripting indices.  The results include
%   only those {subs} that lie within the bounds of the
%   actual {src} and {dst} mappings.  None of the indices
%   need be monotonic or equally-spaced.
%
%   Example: src  = [ 1  3  5  7  9];
%            dst  = [11 12 13 14 15];
%            subs = [10 12 14 16 18 20 22 24];
%
%   Results: from = [ 3  7];
%            to   = [12 14];
%
%   Usage:   y(to{:}) = x(from{:});
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Oct-2001 10:41:27.
% Updated    04-Oct-2001 11:43:03.

if nargin < 3, help(mfilename), return, end

% Convert to cells.

if ~iscell(src), src = {src}; end
if ~iscell(dst), dst = {dst}; end
if ~iscell(subs), subs = {subs}; end

% Extend if some too short.

len = max([length(src) length(dst) length(subs)]);

while length(src) < len, src{end+1} = 1; end
while length(dst) < len, dst{end+1} = 1; end
while length(subs) < len, subs{end+1} = 1; end

% Allocate result.

from = cell(size(src));
to = cell(size(dst));

% Perform the mapping, using "ismember".

bad_from = ~~0;
bad_to = ~~0;

for i = 1:length(src)
	from{i} = src{i}(ismember(dst{i}, subs{i}));
	to{i} = subs{i}(ismember(subs{i}, dst{i}));
	if isempty(from{i}), bad_from = ~~1; end
	if isempty(to{i}), bad_to = ~~1; end
end

if bad_from, from = {}; end
if bad_to, to = {}; end
