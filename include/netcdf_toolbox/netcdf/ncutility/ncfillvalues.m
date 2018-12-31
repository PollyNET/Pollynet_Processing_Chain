function theResult = ncfillvalues

% ncfillvalues -- Create a NetCDF file containing default fill-values.
%  ncfillvalues (no arguments) creates 'ncfillvalues.nc', containing
%   variables with the default NetCDF fill-values.  Use "ncdump" to
%   see the exact NetCDF file structure.  This routine returns a
%   Matlab "struct" of fill-values if an output argument is given.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Apr-1999 10:02:09.
% Updated    17-Jun-2002 16:45:44.

if nargout < 1, help(mfilename), end

theNames = {'ncbyte', 'ncchar', 'ncshort', 'nclong', 'ncfloat', 'ncdouble'};

f = netcdf('ncfillvalues.nc', 'clobber');

f.CreatedOn = datestr(now);
f.CreatedBy = mfilename;
f.MatlabVersion = version;
f.Computer = computer;

f('index') = 1;

for i = 1:length(theNames)
	f{theNames{i}} = feval(theNames{i}, 'index');
end

endef(f)

result = [];
for i = 1:length(theNames)
	theFillValue = f{theNames{i}}(1);
	result = setfield(result, theNames{i}, theFillValue);
	f{theNames{i}}.FillValue_ = theFillValue;
end

close(f)

if nargout > 0
	theResult = result;
else
	disp(result)
end
