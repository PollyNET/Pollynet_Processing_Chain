function self = ncatt(theAttname, theAtttype, theAttvalue, theParent)

% ncatt/ncatt -- Constructor for ncatt class.
%  ncatt(theAttname, theAtttype, theAttvalue, theParent) allocates
%   an ncatt object with theAttname, theAtttype, and theAttvalue in
%   theParent, a netcdf or an ncvar object.  The redirection syntax
%   is theParent < ncatt(theAttname, theAtttype, theAttvalue).
%   The result is assigned silently to 'ans" if no output
%   argument is given.
%  ncatt(theAttname, theAttvalue, theParent) uses the class of
%   theAttvalue as theAtttype ('char' or 'double').
%  ncatt(theAttname, theParent) returns an ncatt object corresponding
%   to the attribute of theAttname in theParent.
%  ncatt (no argument) returns a raw "ncatt" object.
%
%  N.B. To put/get the conventional '_FillValue' attribute of a variable,
%   use 'FillValue_'.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.
% Revised    19-Mar-1998 09:37:02.

if nargin < 1 & nargout < 1, help(mfilename), return, end

% Basic structure.

theStruct.itsAtttype = '';
theStruct.itsAttvalue = '';

% Raw object.

if nargin < 1 & nargout > 0
   self = class(theStruct, 'ncatt', ncitem);
   return
end

if strcmp(theAttname, 'FillValue_'), theAttname = '_FillValue'; end

if nargin == 2
   theParent = theAtttype;
   theNCid = ncid(theParent);
   theVarid = varid(theParent);
   theAttnum = 0;
   [theAtttype, theAttlen, status] = ...
      ncmex('attinq', theNCid, theVarid, theAttname);
   if status >= 0
      theStruct.itsAtttype = '';
      theStruct.itsAttvalue = '';
      theItem = ncitem(theAttname, theNCid, -1, theVarid, theAttnum);
      result = class(theStruct, 'ncatt', theItem);
   else
      result = [];
   end
   if nargout > 0
      self = result;
   else
      ncans(result)
   end
   return
end

if nargin == 3
   switch ncclass(theAttvalue)
   case {'netcdf', 'ncvar'}
      theParent = theAttvalue;
      theAttvalue = theAtttype;
      theAtttype = ncclass(theAttvalue);
      if isa(theParent, 'ncvar')
         switch theAttname
         case {'_FillValue'}
            theAtttype = datatype(theParent);
         case {'scale_factor', 'add_offset'}
         otherwise
         end
      end
      result = ncatt(theAttname, theAtttype, theAttvalue, theParent);
      if nargout > 0
          self = result;
      else
         ncans(result)
      end
      return
   otherwise
   end
end

if strcmp(theAtttype, 'int'), theAtttype = 'long'; end
   
status = 0;
if nargin < 4
   theNCid = -1;
   theVarid = -1;
   theAttnum = -1;
else
   theNCid = ncid(theParent);
   theVarid = varid(theParent);
   theAttnum = 0;
   if isa(theParent, 'ncvar')
      switch theAttname
      case {'_FillValue'}
         theAtttype = datatype(theParent);
      case {'scale_factor', 'add_offset'}
      otherwise
      end
   end
   if isstr(theAttvalue)
      theAttvalue = strrep(theAttvalue, '\0', setstr(0));
   end
   theTempname = theAttname;
   if (0)
      theTempname(:) = '-';   % Is this necessary any longer?
   end
   status = 0;
   [theType, theLen, theStatus] = ...
         ncmex('attinq', theNCid, theVarid, theAttname);
   if theStatus >= 0 & ~strcmp(theAttname, theTempname)
      status = ncmex('attrename', theNCid, theVarid, ...
                     theAttname, theTempname);
   end
   if status >= 0
      status = ncmex('attput', theNCid, theVarid, ...
                     theTempname, theAtttype, -1, theAttvalue);
   end
   if status < 0
      theNetCDF = redef(parent(theParent));
      if ~isempty(theNetCDF), status = 0; end
      if status >= 0
         status = ncmex('attput', theNCid, theVarid, ...
                        theTempname, theAtttype, -1, theAttvalue);
      end
   end
   if status >= 0 & ~strcmp(theAttname, theTempname)
      status = ncmex('attrename', theNCid, theVarid, ...
                     theTempname, theAttname);
   end
end

if status >= 0
   theStruct.itsAtttype = theAtttype;
   theStruct.itsAttvalue = theAttvalue;
   result = class(theStruct, 'ncatt', ...
      ncitem(theAttname, theNCid, -1, theVarid, theAttnum));
else
   result = [];
end

if nargout > 0
   self = result;
else
   ncans(result)
end
