function self = ncvar(theVarname, theVartype, theDimnames, theNetcdf)

% ncvar/ncvar -- Constructor for ncvar class.
%  ncvar('theVarname', 'theVartype', {theDimnames}, theNetcdf) allocates
%   an "ncvar" object with 'theVarname', 'theVartype', and {theDimnames},
%   in theNetcdf, a netcdf object.  The re-direction syntax is
%   theNetcdf < ncvar('theVarname', 'theVartype', {theDimnames}).
%   The result is assigned silently to "ans" if no output argument
%   is given.
%  ncvar('theVarname', theNetcdf) returns an ncvar object that
%   represents the existing variable named 'theVarName' in theNetcdf.
%  ncvar('', 'theVartype', {theDimnames}) returns an ncvar object for:
%   theNetcdf{'theVarname'} = ncvar('theVartype', {theDimnames}).
%  ncvar (no argument) returns a generic "ncvar" object, suitable
%   for use as a composite variable.
%  ncvar (no argument) returns a raw "ncvar" object.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.
% Updated    14-Jan-2002 13:05:12.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Name$
% $Id: ncvar.m 2529 2008-11-03 23:08:42Z johnevans007 $
% AUTHOR:  Charles Denham
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1 & nargout < 1
    help(mfilename)
    return
end

if nargout > 0, self = []; end

% Basic structure.

theStruct.itsVartype = '';
theStruct.itsDimnames = {''};
theStruct.itsOrientation = [];
theStruct.itsSubset = [];
theStruct.itsOffset = [];
theStruct.itsOrigin = [];
theStruct.itsVars = {};
theStruct.itsSrcsubs = {};
theStruct.itsDstsubs = {};
theStruct.itsSlice = [];

% Raw "ncvar" object.

if nargin < 1 & nargout > 0
   self = class(theStruct, 'ncvar', ncitem);
   return
end
    
if nargin == 1 & isa(theVarname, 'ncitem')
   theNCItem = theVarname;
   if varid(theNCItem) >= 0
      result = ncvar(name(theNCItem), netcdf(ncid(theNCItem)));
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

if nargin == 2
   theNetcdf = theVartype;
   theNCid = ncid(theNetcdf);
   switch class(theVarname)
   case 'char'
      [theVarid, status] = ncmex('varid', theNCid, theVarname);
   case 'double'
      theVarindex = theVarname;
      theVarid = theVarindex-1;
      [theVarname, theVartype, theVarndims, theVardimids, theVarnatts, status] = ...
            ncmex('varinq', theNCid, theVarid);
   otherwise
      status = -1;
      warning(' ## Illegal syntax')
   end
   if status >= 0
      theStruct.itsVartype = theVartype;
      result = class(theStruct, 'ncvar', ...
            ncitem(theVarname, theNCid, -1, theVarid));
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

theNCid = -1;
if nargin > 3, theNCid = ncid(theNetcdf); end

if strcmp(theVartype, 'int'), theVartype = 'long'; end

if isa(theDimnames, 'cell')
   if length(theDimnames) == 1
      theDimnames = theDimnames{1};
   end
end
if isstr(theDimnames), theDimnames = {theDimnames}; end

theDimids = zeros(1, length(theDimnames)) - 1;
for i = 1:length(theDimnames)
   theDimids(i) = ncmex('dimid', theNCid, theDimnames{i});
end

status = 0;
theVarid = -1;
if theNCid ~= -1
   [theVarid, status] = ncmex('varid', theNCid, theVarname);
   if status < 0

      	%
	% It is possible that "theDimids" is [].  That's kind of dangerous.
	% How about setting the number of dimensions to zero instead?
	if isempty(theDimids)
		[theVarid, status] = ncmex('vardef', theNCid, theVarname, ...
			theVartype, 0, 0);
	else
		[theVarid, status] = ncmex('vardef', theNCid, theVarname, ...
			theVartype, -1, theDimids);
	end

      if status < 0
         status = ncmex('redef', theNCid);
         if status >= 0
            [theVarid, status] = ncmex('vardef', theNCid, theVarname, ...
                  theVartype, -1, theDimids);
         end
      end
   end
end

if status >= 0
   theStruct.itsVartype = theVartype;
   theStruct.itsDimnames = theDimnames;
   theStruct.itsSlice = zeros(1, length(theDimnames));
   result = class(theStruct, 'ncvar', ...
      ncitem(theVarname, theNCid, -1, theVarid));
  else
   result = [];
end

if nargout > 0
   self = result;
else
   ncans(result)
end
