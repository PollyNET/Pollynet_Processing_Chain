function theResult = recdim(self, theRecdim)

% ncitem/recdim -- Record-dimension of an ncitem.
%  recdim(self) returns an "ncdim" object corresponding
%   to the current record-dimension (actual or artificial)
%   of self, a "netcdf" or "ncvar" object.
%  recdim(self, theRecdim) sets the recdimid field
%   of self to the id of theRecdim and returns self.
%   TheRecdim may be given as a dimension name, a
%   dimension id, or an "ncdim" object.  This usage
%   allows an artificial record-dimension to be set.
 
% Version of 07-Aug-1997 09:59:52.
% Updated    05-Oct-1999 17:59:09.

if nargin < 1, help(mfilename), return, end

result = [];

if isa(self, 'netcdf') | isa(self, 'ncvar')
   if nargin < 2
      if ncid(self) >= 0
         theRecdimid = recdimid(self);
         status = 0;
         if theRecdimid < 0
            [ndims, nvars, ngatts, theRecdimid, status] = ...
                  ncmex('inquire', ncid(self));
         end
         if status >= 0
            [theName, theLength, status] = ...
                  ncmex('diminq', ncid(self), theRecdimid);
            if status >= 0
               self = recdimid(self, theRecdimid);
					if (0)   % Matlab 5.3 trouble below!
               	result = self(theName);
					else
						theStruct.type = '()';
						theStruct.subs = {theName};
						result = subsref(self, theStruct);
					end
            end
         end
      end
   elseif isa(theRecdim, 'ncdim')
      theRecdimid = dimid(theRecdim);
      result = recdim(self, theRecdimid);
   elseif isa(theRecdim, 'double')
      if ~isempty(theRecdim)
         theRecdimid = theRecdim;
      else
         theRecdimid = -1;
      end
      result = recdimid(self, theRecdimid);
   elseif isa(theRecdim, 'char')
      if ~isempty(theRecdim)
         theRecdimname = theRecdim;
			if (0)   % Matlab 5.3 trouble below!
         	theRecdimid = dimid(self(theRecdimname));
			else
				theStruct.type = '()';
				theStruct.subs = {theRecdimname};
				theRecdimid = dimid(subsref(self, theStruct));
			end
      else
         theRecdimid = -1;
      end
      result = recdim(self, theRecdimid);
   end
   if isa(result, 'netcdf')
      ncregister(result)
      result = ncregister(result);
   end
end

if nargout > 0
   theResult = result;
else
   ncans(result)
end
