function theResult = datatype(self, theNewDatatype)

% ncvar/datatype -- Numeric type of an ncatt object.
%  datatype(self) returns the numeric type of self,
%   an "ncvar" object.  The allowed datatypes are:
%   {'byte', 'char', 'short', 'long', 'float', 'double'}.
%  datatype(self, 'theNewDatatype') changes the datatype
%   of self to 'theNewDatatype'.  The NetCDF file itself
%   must be writeable.  The function will also reset the
%   datatype of the associated "_FillValue" (if any) to
%   the same new type.  The new self is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:42:59.

if nargin < 1, help(mfilename), return, end

result = '';

theTypes = {'byte', 'char', 'short', 'long', 'float', 'double'};

theNCid = ncid(self);

% Get the existing datatype.

if theNCid >= 0
   theVarid = varid(self);
   [theName, theType, theNdims, theDimids, theNatts, status] = ...
      ncmex('varinq', theNCid, theVarid);
   if status >= 0 & ~isstr(theType)
      theType = theTypes{theType};
   end
else
    theType = self.itsVartype;
end

result = theType;

% Change the datatype.

if nargin > 1
    theNetCDF = parent(self);
    switch lower(permission(theNetCDF))
    case {'nowrite'}
        disp([' ## No "' mfilename '" action taken; ' ...
              'file "' name(theNetCDF) '" permission is "nowrite".'])
        if nargout > 0
            theResult = self;
        else
            disp(self)
        end
        return
    end
    theVarname = name(self);
    theTempname = theVarname;
    theTempname(:) = '_';
    self = name(self, theTempname);
    theDimnames = ncnames(dim(self));
    theNetCDF{theVarname} = feval(['nc' theNewDatatype], theDimnames{:});
    theVar = theNetCDF{theVarname};
    theAtts = att(self);
    for i = 1:length(theAtts)
        copy(theAtts{i}, theVar)
    end
    if ~isempty(fillval(self))
        fillval(theVar, fillval(self));
    end
    theData = self(:);
    if ~isempty(theData)
        theVar(:) = theData;
    end
    theChangedNetCDF = delete(self);
    result = theChangedNetCDF{theVarname};
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
