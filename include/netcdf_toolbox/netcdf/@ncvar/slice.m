function theResult = slice(self, theSliceDim)

% ncvar/slice -- Set/get slice-dimension.
%  slice(self, theSliceDim) sets the slice information of self,
%   an ncvar object, to theSliceDim, which can be specified by
%   the dimension name, a logical-vector with the value one (1)
%   in the sequence of dimensions, or an ncdim object.  The
%   self is returned.
%  slice(self) returns a logical-vector with the value one (1)
%   in the position of the slice-dimension.  All other elements
%   are zero (0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1, help(mfilename), return, end

if nargin < 2
   result = self.itsSlice;
  else
   theDims = dim(self);
   theSlice = zeros(1, length(theDims));
   switch class(theSliceDim)
   case 'char'
      for i = 1:length(theDims)
         if strcmp(name(theDims{i}), theSliceDim)
            theSlice(i) = 1;
            break;
         end
      end
   case 'double'
      for i = 1:min(length(theSliceDim), s)
         if theDim(i)
            theSlice(i) = 1;
            break
         end
      end
   case 'ncdim'
      for i = 1:length(theDims)
         if isequal(theDims{i}, theSliceDim)
            theSlice(i) = 1;
            break
         end
      end
   otherwise
      illegal ncvar/slice
   end
   self.itsSlice = theSlice;
   result = self;
end

if nargout > 0
   theResult = result;
  elseif nargin < 2
   disp(result)
end
