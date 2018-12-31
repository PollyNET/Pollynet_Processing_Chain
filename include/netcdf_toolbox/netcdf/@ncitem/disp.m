function disp(self)

% ncitem/disp -- Display the contents of an ncitem object.
%  disp(self) displays the contents of self, an object
%   derived from the ncitem class.
%
% Also see: ncitem/display, ncitem/desc.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:44:53.

if nargin < 1, help(mfilename), return, end

theClass = ncclass(self);
switch theClass
case {'ncitem'}
   disp(struct(self))
case 'netcdf'
   self = ncregister(self);
   s = ncsize(self);
   t.NetCDF_File = name(self);
   t.nDimensions = s(1);
   t.nVariables = s(2);
   t.nGlobalAttributes = s(3);
   t.RecordDimension = '';
   t.nRecords = 0;
   if ~isempty(recdim(self))
      t.RecordDimension = name(recdim(self));
      t.nRecords = ncsize(recdim(self));
   end
   t.Permission = permission(self);
   t.DefineMode = mode(self);
   t.FillMode = setfill(self);
   t.MaxNameLen = fatnames(self);
   disp(t)
case {'ncdim'}
   t.NetCDF_Dimension = name(self);
   t.itsLength = ncsize(self);
   disp(t)
case {'ncvar'}
   t.NetCDF_Variable = name(self);
   t.itsType = datatype(self);
   theOrientation = orient(self);
   theAutoscale = autoscale(self);
   theAutonan = autonan(self);
   isUnsigned = unsigned(self);
   IsQuick = quick(self);
   d = dim(self);
   if ~isempty(d), d = d(abs(theOrientation)); end
   t.itsDimensions = '';
   for i = 1:length(d)
      if i > 1, t.itsDimensions = [t.itsDimensions ', ']; end
      t.itsDimensions = [t.itsDimensions name(d{i})];
   end
   t.itsLengths = ncsize(self);
   t.itsOrientation = theOrientation;
%  t.itsSubset = subset(self);
%  t.itsOffset = offset(self);
%  t.itsOrigin = origin(self);
   t.itsVars = var(self);
   [theSrcsubs, theDstsubs] = subs(self);
   t.itsSrcsubs = theSrcsubs;
   t.itsDstsubs = theDstsubs;
   t.nAttributes = length(att(self));
   t.itIsAutoscaling = theAutoscale;
   t.itIsAutoNaNing = theAutonan;
   t.itIsUnsigned = isUnsigned;
   t.itIsQuick = IsQuick;
   disp(t)
case {'ncatt'}
   t.NetCDF_Attribute = name(self);
   t.itsType = datatype(self);
   t.itsLength = ncsize(self);
   t.itIsUnsigned = unsigned(self);
   disp(t)
case {'ncrec'}
   disp(self(:))
otherwise
   warning(' ## Illegal syntax.')
end
