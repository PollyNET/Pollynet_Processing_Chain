function theResult = NCNames(theNCItems)

% NCNames -- List of ncitem names.
%  NCNames(theNCItems) returns the list
%   of names corresponding to theNCItems,
%   a cell-array of NetCDF objects derived
%   from the "ncitem" class.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Apr-1997 09:23:56.

if nargin < 1, help(mfilename), return, end

if ~iscell(theNCItems), theNCItems = {theNCItems}; end

theNCNames = cell(size(theNCItems));

for i = 1:length(theNCItems)
   if isa(theNCItems{i}, 'ncitem')
      theNCNames{i} = name(theNCItems{i});
   end
end

if nargin > 0
   theResult = theNCNames;
  else
   disp(theNCNames)
end
