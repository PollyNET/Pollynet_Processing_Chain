function [theResult, nvars, ngatts, recdim] = size(self, index)

% ncvar/ncsize -- Sizes of an "ncvar" object.
%  ncsize(self) returns the ncsize of self, an "ncvar"
%   object.  One-dimensional and scalar variables
%   return a size with just one element.  The ncsize
%   of a virtual variable is given in the reoriented
%   sequence.
%  ncsize(self, index) returns the size-component at
%   the given index.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Nov-1997 08:57:49.
% Updated    10-Oct-2001 11:29:01.

if nargin < 1, help(mfilename), return, end

theNCid = ncid(self);
theVarid = varid(self);

theSize = [];
if theVarid >= 0
   [theVarname, theVartype, theVarndims, ...
         theVardimids, theVarnatts, status] = ...
         ncmex('varinq', theNCid, theVarid);
   if status >= 0
      theSize = -ones(1, length(theVardimids));
      for i = 1:length(theVardimids)
         [theDimname, theSize(i), status] = ...
               ncmex('diminq', theNCid, theVardimids(i));
         if status < 0, break, end
      end
   end
end

theOrientation = self.itsOrientation;
if ~isempty(theOrientation)
   theSize = theSize(abs(theOrientation));
end

if nargin > 1 & all(index <= length(theSize))
   theSize = theSize(index);
end

if nargout > 0
   theResult = theSize;
else
   disp(theSize)
end
