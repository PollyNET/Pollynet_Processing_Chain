function tncdotted(whichOne)

% tncdotted -- Test of dotted and dashed NetCDF names.
%  tncdotted('whichOne') exercizes dotted and/or dashed
%   NetCDF names.  If this function fails, then no such
%   names can be created on the present system, though
%   it may still be possible to read or write to them.
%   It is best to avoid such names altogether.
%
%   The 'whichOne' is one of: 'dotted', '.', 'dashed',
%   '-', or 'both'.  By default, whichOne = 'both'.
%
%   Statements using names with dots, dashes or other
%   Matlab operators must not violate Matlab syntax.
%   The Matlab parser does its work first, then the
%   NetCDF language is invoked if deemed appropriate.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Feb-1998 09:33:14.

if nargin < 1, whichOne = 'both'; end
if isempty(whichOne), whichOne = 'both'; end

help(mfilename)

theNetCDFFile = 'tncdashed.nc';

USE_OLD = 0;

% Test dashed names: fails on some systems.

switch whichOne
case {'dotted', '.', 'both'}
    disp(' ')
    disp(' ## Testing dotted NetCDF names.')
    disp(' ## If this fails, then dotted names are not allowed.')
    f = netcdf(theNetCDFFile, 'clobber');
    f.a.dotted.name = 'a dotted global attribute name';
    f('a.dotted.name') = length('a dotted variable name');
    f{'a.dotted.name'} = ncchar('a.dotted.name');
    f{'a.dotted.name'}.a.dotted.name = 'a dotted variable attribute name';
    f{'a.dotted.name'}(:) = 'a dotted variable name';
    disp(' ## Test of dotted names SUCCESSFUL.')
    close(f)
    USE_OLD = 1;
end

% Test dashed names: fails on some systems.

switch whichOne
case {'dashed', '-', 'both'}
    disp(' ')
    disp(' ## Testing dashed NetCDF names.')
    disp(' ## If this fails, then dashed names are not allowed.')
    if USE_OLD
        f = netcdf(theNetCDFFile, 'write');
    else
        f = netcdf(theNetCDFFile, 'clobber');
    end
    ncatt('a-dashed-name', 'a dashed global attribute name', f)
    f('a-dashed-name') = length('a dashed variable name');
    f{'a-dashed-name'} = ncchar('a-dashed-name');
    v = f{'a-dashed-name'};
    ncatt('a-dashed-name', 'a dashed global attribute name', v)
    f{'a-dashed-name'}(:) = 'a dashed variable name';
    close(f)
    disp(' ## Test of dashed names SUCCESSFUL.')
end

ncdump(theNetCDFFile)
