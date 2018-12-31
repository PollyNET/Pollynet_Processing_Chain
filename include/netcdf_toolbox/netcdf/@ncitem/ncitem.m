function self = ncitem(theName, theNCid, ...
   theDimid, theVarid, theAttnum, ...
   theRecnum, theRecdimid, theAutoscale, ...
   isUnsigned, isQuick, theMaxNameLen)

% ncitem/ncitem -- Constructor for ncitem class.
%  ncitem('theName', theNCid, theDimid, theVarid, ...
%   theAttnum, theRecnum, theRecdimid, theAutoscale, ...
%   isUnsigned, isQuick, theMaxNameLen) allocates a
%   container for the given information about a NetCDF
%   item.  It serves as a header class for derived NetCDF
%   classes, including netcdf, ncdim, ncvar, ncatt, ncrec,
%   and ncslice.  The result is assigned silently to "ans"
%   if no output argument is given.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 19-Jul-1999 15:04:36.
% Updated    09-Aug-1999 16:19:27.
% Touched    22-Mar-2000 09:36:07. Autoscale/autonan proposal.

global nctbx_options;


if nargin < 1 & nargout < 1
   help(mfilename)
   return
end


if nargin < 1, theName = ''; end
if nargin < 2, theNCid = -1; end
if nargin < 3, theDimid = -1; end
if nargin < 4, theVarid= -1; end
if nargin < 5, theAttnum = -1; end
if nargin < 6, theRecnum = -1; end
if nargin < 7, theRecdimid = -1; end
if nargin < 8, theAutoscale = 0; end   % ZYDECO Proposal: default = 1.
if nargin < 9, theAutoNaN = 0; end   % ZYDECO Proposal: default = 1.
if nargin < 10, isUnsigned = 0; end
if nargin < 11, isQuick = 0; end
if nargin < 12, theMaxNameLen = 0; end



if ~isempty ( nctbx_options ) 
	fnames = fieldnames ( nctbx_options );
	num_fields = length(fnames);
	for j = 1:num_fields
		current_field = fnames{j};
		switch ( current_field )
		case { 'theName' , 'theName', 'theNCid', 'theDimid', 'theVarid', 'theAttnum', 'theRecnum', 'theRecdimid', 'theAutoscale', 'theAutoNaN', 'isUnsigned', 'isQuick', 'theMaxNameLen' }
			command = sprintf ( '%s = getfield ( nctbx_options, ''%s'' );', current_field, current_field );
			eval ( command );
		otherwise
			error ( 'Unhandled field name' );
		end
	end

end

if (1)
   theStruct = struct( ...
                      'itsName', theName, ...
                      'itsNCid', theNCid, ...
                      'itsDimid', theDimid, ...
                      'itsVarid', theVarid, ...
                      'itsAttnum', theAttnum, ...
                      'itsRecnum', theRecnum, ...
                      'itsRecdimid', theRecdimid, ...
                      'itIsAutoscaling', theAutoscale, ...
                      'itIsAutoNaNing', theAutoNaN, ...
                      'itIsUnsigned', isUnsigned, ...
                      'itIsQuick', isQuick, ...
                      'itsMaxNameLen', theMaxNameLen ...
                     );
else
   theStruct.itsName = theName;
   theStruct.itsNCid = theNCid;
   theStruct.itsDimid = theDimid;
   theStruct.itsVarid = theVarid;
   theStruct.itsAttnum = theAttnum;
   theStruct.itsRecnum = theRecnum;
   theStruct.itsRecdimid = theRecdimid;
   theStruct.itIsAutoscaling = theAutoscale;
   theStruct.itIsAutoNaNing = theAutoNaN;
   theStruct.itIsUnsigned = isUnsigned;
   theStruct.itIsQuick = isQuick;
   theStruct.itsMaxNameLen = theMaxNameLen;
end

result = class(theStruct, 'ncitem');

if nargout > 0
   self = result;
else
   ncans(result)
end
