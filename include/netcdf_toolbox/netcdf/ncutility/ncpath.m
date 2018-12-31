function ncpath

% ncpath -- Check NetCDF Toolbox paths.
%  ncpath (no arguments) checks the existing Matlab path
%   for essential files and directories.  The "mexcdf53"
%   function must be a "Mex-file", whereas the others
%   refer to "M-files".
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Dec-2000 11:58:17.
% Updated    28-Dec-2000 14:48:07.

help(mfilename)

f = {
		'mexcdf53'
		'ncmex'
		'netcdf'
		'ncitem'
		'ncatt'
		'ncdim'
		'ncvar'
		'ncrec'
		'ncbrowser'
		'ncutility'
		'nctype'
		'listpick'
	};
	
oldPWD = pwd;
setdef(mfilename)
cd .., cd ..

some_missing = 0;
for i = 1:length(f)
	w = which(f{i});
	if i == 1 & ~isempty(w) & exist(f{i}, 'file') ~= 3
		disp([' ## Warning: "' f{1} '"appears not to be a Mex-file.'])
	end
	if isempty(w), w = '(none found)'; some_missing = 1; end
	disp([' ## Path to "' f{i} '": ' w])
end

if some_missing
	disp(' ')
	disp([' ## Please locate the missing files,'])
	disp([' ##  adjust the Matlab path accordingly,'])
	disp([' ##  then run "ncpath" again.'])
end

cd(oldPWD)
disp([' ## ' pwd])
