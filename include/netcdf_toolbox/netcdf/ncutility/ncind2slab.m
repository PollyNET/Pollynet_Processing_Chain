function [theStarts, theCounts] = ncind2slab(theSize, theStart, theCount)

% ncind2slab -- Convert 1-d indices to NetCDF slab coordinates.
%  ncind2slab(theSize, theStart, theCount) figures out how to
%   to move elements to/from a NetCDF variable, using linear
%   base-1 indexing.  For theStart index and theCount of elements,
%   theStarts and theCounts (taken row-wise) for the equivalent
%   slabs are returned based on theSize of the targeted NetCDF array.
%   Use each slab in sequence to put/get its count of elements, then
%   offset the source index by the total count before using the next
%   slab.  On error, the routine returns the empty-matrix [].
%
%   N.B. We may need to reverse the sequence of coordinates.
%   N.B. This routine handles stride = 1 only.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 02-Sep-1997 13:24:05.

if nargin < 1, theSize = 'demo'; end

if strcmp(theSize, 'demo')
   help(mfilename)
   theSize = [3 5]
   theStart = 2
   theCount = 10
   [theStarts_, theCounts_] = ncind2slab(theSize, theStart, theCount);
   if nargout > 0
      theStarts = theStarts_;
      theCounts = theCounts_;
   else
      theStarts_, theCounts_
      total_count = sum(prod(theCounts_.'))
   end
   return
end

if nargin < 2, theStart = 1; end
if nargin < 3, theCount = 1; end

if nargout > 0, theStarts = []; theCounts = []; end

theCount = min(prod(theSize), theCount);

% Strategy: We seek the largest legal slab that
%  can accomodate the next piece of theCount,
%  iterating until theCount has been consumed.

theOriginalCount = theCount;

result = zeros(0, 2);

s = cell(size(theSize));

k = 0;
while theCount > 0
   [s{:}] = ind2sub(theSize, theStart);   % Starting corner.
   f = length(s);
   for i = 1:length(s)
      if s{i} > 1, f = i; break; end
   end
   t = s;
   for i = 1:f, t{i} = theSize(i); end         % Opposite corner.
   theChunk = sub2ind(theSize, t{:}) - sub2ind(theSize, s{:}) + 1;
   while theChunk > theCount
      for i = length(t):-1:1
         if t{i} > s{i}                        % Binary search.
            delta = 1;
            while 2*delta <= (t{i} - s{i})
               delta = 2*delta;
            end
            t_original = t{i};
            t{i} = s{i};                       % Start here.
            while delta > 0
               if t{i} + delta <= t_original   % Overflow check.
                  t{i} = t{i} + delta;
                  ch = sub2ind(theSize, t{:}) - sub2ind(theSize, s{:}) + 1;
                  if ch > theCount, t{i} = t{i} - delta; end
               end
               delta = fix(delta/2);
            end
         end
      end
      theChunk = sub2ind(theSize, t{:}) - sub2ind(theSize, s{:}) + 1;
   end
   k = k+1;
   result(k, 1) = theStart;
   result(k, 2) = theChunk;
   theStart = theStart + theChunk;
   theCount = theCount - theChunk;
end

total_count = sum(result(:, 2));
if total_count ~= theOriginalCount
   total_count, theOriginalCount
   warning(' ## Total count does not match desired count.')
   return
end

s = cell(size(theSize));
t = cell(size(theSize));
[m, n] = size(result);
starts = zeros(m, length(theSize));
counts = zeros(m, length(theSize));
for i = 1:m
   [s{:}] = ind2sub(theSize, result(i, 1));
   [t{:}] = ind2sub(theSize, result(i, 1) + result(i, 2) - 1);
   for j = 1:length(theSize)
      starts(i, j) = s{j};
      counts(i, j) = t{j} - s{j} + 1;
   end
end

if nargout > 0
   theStarts = starts;
   theCounts = counts;
else
   starts, counts
end
