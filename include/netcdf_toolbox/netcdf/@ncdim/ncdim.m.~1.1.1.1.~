function self = ncdim(theDimname, theDimsize, theNetcdf)

% ncdim/ncdim -- Constructor for ncdim class.
%  ncdim(theDimname, theDimsize, theNetcdf) defines a new ncdim
%   object with theDimname and theDimsize in theNetcdf, a netcdf
%   object.  The equivalent redirection syntax is
%   theNetcdf < ncdim(theDimname, theDimsize).  The result is
%   assigned silently to 'ans" if no output argument is given.
%  ncdim(theDimname, theNetcdf) returns a new ncdim object
%   corresponding to theDimname in theNetcdf, a netcdf or
%   ncvar object.
%  ncdim (no argument) returns a raw "ncdim" object.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:45:48.

if nargin < 1 & nargout < 1, help(mfilename), return, end

if nargout > 0, self = []; end

% Basic structure.

theStruct.itsDimsize = [];

% Raw object.

if nargin < 1 & nargout > 0
   self = class(theStruct, 'ncdim', ncitem);
   return
end

if nargin == 2 & ...
   (isa(theDimsize, 'netcdf') | isa(theDimsize, 'ncvar'))
   result = [];
   theNetcdf = theDimsize;
   theNCid = ncid(theNetcdf);
   theDimsize = -1;
   switch class(theDimname)
   case 'char'
      [theDimid, status] = ncmex('dimid', theNCid, theDimname);
   case 'double'
      theDimid = theDimname - 1;
      status = 0;
   otherwise
      status = -1;
      ncillegal
   end
   if status >= 0
      [theDimname, theDimsize, status] = ncmex('diminq', theNCid, theDimid);
      if status >= 0
         theStruct.itsDimsize = theDimsize;
         result = class(theStruct, 'ncdim', ncitem(theDimname, theNCid, theDimid));
      end
   end
   if nargout > 0
      self = result;
   else
      ncans(result)
   end
   return
end

theNCid = -1;
if nargin > 2, theNCid = ncid(theNetcdf); end

if ~finite(theDimsize), theDimsize = 0; end

status = 0;

theDimid = -1;
if theNCid ~= -1
   switch class(theDimname)
   case 'char'
      [theDimid, status] = ncmex('dimid', theNCid, theDimname);
   otherwise
      status = -1;
      warning(' ## Illegal syntax.')
   end
   if status < 0
      theTempname = theDimname;
      theTempname(:) = '-';
      [theDimid, status] = ncmex('dimdef', theNCid, theTempname, theDimsize);
      if status < 0
         status = ncmex('redef', theNCid);
         if status >= 0
            [theDimid, status] = ...
                  ncmex('dimdef', theNCid, theTempname, theDimsize);
         end
      end
      if status >= 0
         status = ncmex('dimrename', theNCid, theDimid, theDimname);
      end
   end
   if status >= 0
      [theDimname, theDimsize, status] = ncmex('diminq', theNCid, theDimid);
   end
end

if status >= 0
   theStruct.itsDimsize = theDimsize;
   result = class(theStruct, 'ncdim', ncitem(theDimname, theNCid, theDimid));
else
   result = [];
end

if nargout > 0
    self = result;
else
    ncans(result)
end
