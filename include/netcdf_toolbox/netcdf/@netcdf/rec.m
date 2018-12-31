function theResult = rec(self, theRecindices, theRecs)

% netcdf/rec -- Record of a netcdf object.
%  rec(self, theRecindices) returns a vector of structs
%   whose field-names are the names of record-variables
%   of self, a netcdf object.  The field-values are the
%   variable-data corresponding to each of theRecindices,
%   which range from 1 to the number of records.
%  rec(self, theRecindices, theRecs) puts the data from
%   theRecs structs into corresponding theRecindices
%   records of self, a netcdf object.  Self is returned.
%  rec(self) returns a single struct with zeroed fields.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theRecindices = 0; end

if nargin < 3
   if isequal(theRecindices, 0)
      theRecs = ncrec(self);
     else
      theVars = recvar(self);
      theFieldvalues = cell(1, length(theVars));
      theFieldnames = cell(1, length(theVars));
      for j = 1:length(theRecindices)
         for i = 1:length(theVars)
            theFieldnames{i} = name(theVars{i});
            theFieldvalues{i} = [];
            if theRecindices(j) > 0
               theFieldvalues{i} = theVars{i}(theRecindices(j));
            end
         end
         theRecs(j) = cell2struct(theFieldvalues, theFieldnames, 2);
      end
   end
   result = theRecs;
  else
   f = fields(theRecs);
   for j = 1:length(theRecindices)
      if theRecindices(j) > 0
         for i = 1:length(f)
            s = ['self{''' f{i} '''}(' ...
                 int2str(theRecindices(j)) ')' ...
                 '=theRecs(' int2str(j) ').' f{i} ';'];
            eval(s);
         end
      end
   end
   result = self;
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
