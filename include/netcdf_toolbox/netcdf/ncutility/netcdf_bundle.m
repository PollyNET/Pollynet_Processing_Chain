function netcdf_bundle

% netcdf_bundle -- Bundle the NetCDF Toolbox.
%  netcdf_bundle (no argument) bundles the NetCDF Toolbox
%   to produce the installer "nc_install.m".
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Jun-2001 16:56:19.
% Updated    25-Apr-2003 11:58:00.

theClasses = {
	'listpick'
	'ncatt'
	'ncbrowser'
	'ncdim'
	'ncitem'
	'ncrec'
	'ncvar'
	'netcdf'
};

for i = 1:length(theClasses)
    newversion(theClasses{i})
end

theDirs = cell(size(theClasses));

theDirs = {
	'netcdf'
	'netcdf:ncfiles'
	'netcdf:nctype'
	'netcdf:ncutility'
};
for i = 1:size(theClasses)
	theDirs{end+1} = ['netcdf:@' theClasses{i}];
end

theTypes = {
	'ncbyte'
	'ncchar'
	'ncshort'
	'nclong'
	'ncint'
	'ncfloat'
	'ncdouble'
	'nctype'
	'ncsetstr'
};

theUtilities = {
	mfilename
	'begets'
	'busy'
	'fcopy'
	'filesafe'
	'findpt'
	'getinfo'
	'geturl'
	'geturl.mac'
	'guido'
	'idle.m'
	'labelsafe'
	'maprect'
	'mapsubs'
	'mat2nc'
	'mexcdf.m'
	'modplot'
	'movie1'
    'nc2cdl'
	'nc2mat'
	'ncans'
	'ncbevent'
	'nccat'
	'nccheck'
	'ncclass'
	'ncclear'
	'ncclose'
	'ncdimadd'
	'ncdim2rec'
	'ncdump'
	'ncdumpd'
	'ncdumph'
	'ncexample'
	'ncextract'
	'ncfillvalues'
	'ncillegal'
	'ncind2slab'
	'ncind2sub'
	'ncload'
	'ncmemory'
	'ncmex'
	'ncmkmask'
	'ncmovie'
	'ncnames'
	'ncpath'
	'ncquiet'
	'ncrecget'
	'ncrecinq'
	'ncrecput'
	'ncrectest'
	'ncsave'
	'ncsize'
	'ncstartup'
	'ncswap'
	'nctrim'
	'ncutility'
	'ncverbose'
	'ncversion'
	'ncweb'
	'ncwhatsnew'
	'numel_default'
	'rbrect'
	'setinfo'
	'stackplot'
    'switchsafe'
	'super'
	'tmexcdf'
	'tnc4ml5'
	'tncbig'
	'tncdotted'
    'tncorder'
	'tncmex'
	'tnetcdf'
	'tscalar'
	'uilayout'
	'var2str'
	'vargstr'
	'zoomsafe'
};

theSources = {
    'mexcdf.h'
    'mexcdf53.c'
    'make_mexcdf53.m'
};

theMessages = {
	' '
	' ## Adjust the Matlab path to include, relative to Current Directory:'
	' ##    "netcdf"'
	' ##    "netcdf:ncfiles"'
	' ##    "netcdf:nctype"'
	' ##    "netcdf:ncutility"'
	' ## Make sure the Matlab path knows where the'
	' ##    "mexcdf53" Mex-file and (PCWIN only)'
	' ##    "netcdf.dll" are located.'
	' ## Restart Matlab.'
	' ## Execute "rehash toolboxcache", then'
	' ##    "tnetcdf" at the Matlab prompt.'
};

theClasses = sort(theClasses);
theTypes = sort(theTypes);
theUtilities = sort(theUtilities);
theSources = sort(theSources);

at(mfilename)

oldPWD = pwd;

bund new netcdf

bund setdir netcdf

bund('class', theClasses)

bund setdir ncutility
bund('mfile', theUtilities)
bund cd ..

bund setdir nctype
bund('mfile', theTypes)
bund cd ..

tempPWD = pwd;
cd ..
cd ncsource
bund setdir ncsource
bund('text', theSources)
bund cd ..
cd(tempPWD)

bund setdir ncfiles
bund cd ..

bund cd ..

bund('message', theMessages)

bund close

cd(oldPWD)
