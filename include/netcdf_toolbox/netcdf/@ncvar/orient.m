function theResult = orient(self, theOrientation)

% ncvar/orient -- Orientation of get/put data.
%  orient(self) returns the current orientation of self,
%   an "ncvar" object.  The orientation is a vector that
%   controls the application of "flipdim" and "permute"
%   to the data when they are extracted from self.  For
%   example, if  [1 -3 2] were specified, the data in
%   the third dimension would be flipped, and then they
%   would be permuted to the [1 3 2] arrangement, where
%   1..3 are indices of the dimensions of the original
%   stored variable.  During restoration, the inverse
%   actions are taken.
%  orient(self, theOrientation) sets the orientation of
%   self to theOrientation, a vector of indices that
%   depicts the sequence of dimensions for output.
%   Negative indices cause the corresponding dimensions
%   to be flipped before the data are permuted.  The
%   unchanged orientation [1:nDims] can also be given
%   as the empty-matrix [].  The self is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 23-Sep-1997 10:00:40.

if nargin < 1, help(mfilename), return, end

if nargin > 1
   if isempty(theOrientation)
      theOrientation = 1:length(ncsize(self));
   end
   self.itsOrientation = theOrientation;
   result = self;
  else
   result = self.itsOrientation;
   if isempty(result)
      result = 1:length(ncsize(self));
   end
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
