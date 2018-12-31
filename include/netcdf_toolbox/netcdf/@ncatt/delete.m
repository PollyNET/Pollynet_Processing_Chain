function theResult = delete(varargin)

% ncatt/delete -- Delete a NetCDF attribute.
%  delete(self) deletes the NetCDF attribute associated
%   with self, an "ncatt" object, and returns [] if
%   successful.  Otherwise, it returns self.
%  delete(att1, att2, ...) deletes the given attributes
%   and the results in a list.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:43:32.

if nargin < 1, help(mfilename), return, end

% If not all arguments are "ncatt" objects,
%  let the the "netcdf" parent inherit.

if nargin > 1
   all_ncatt = 1;
   for i = 1:length(varargin)
      switch ncclass(varargin{i})
      case 'ncatt'
      otherwise
         all_ncatt = 0; break
      end
   end
   if ~all_ncatt
      self = varargin{1};
      theParent = parent(parent(self));
      result = delete(theParent, varargin{:});
      if nargout > 0, theResult = result; end
      return
   end
end

self = varargin;
status = zeros(size(varargin));

for i = 1:length(varargin)
   theAtt = varargin{i};
   status(i) = ncmex('attdel', ncid(theAtt), varid(theAtt), name(theAtt));
   if status(i) < 0
      theParent = parent(parent(theAtt));
      theParent = redef(theParent);
      if ~isempty(theParent)
         status(i) = ncmex('attdel', ncid(theAtt), varid(theAtt), name(theAtt));
      end
   end
   if status(i) > 0, self{i} = []; end
end

if length(varargin) == 1, self = self{1}; end

if all(status >= 0)
   result = [];
  else
   result = self;
end

if nargout > 0
   theResult = result;
end
