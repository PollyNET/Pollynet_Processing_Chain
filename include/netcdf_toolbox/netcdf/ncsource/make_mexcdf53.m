function make_mexcdf53

% make_mexcdf53 -- Make "mexcdf53" Mex-file.
%  make_mexcdf53 (no argument) builds the "mexcdf53"
%   Mex-file.  Adjust as needed.
 
% Copyright (C) 2002 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Aug-2002 14:53:49.
% Updated    17-Sep-2002 16:13:13.

try
    at(mfilename('fullpath'))
catch
end

try
    copyfile mexcdf53.mexmac mexcdf53.mexmac.old
catch
end

OPTION = '-v -g';
SOURCE = 'mexcdf53.c';
INCLUDE = '-I/USER/netcdf-3.5.0/include/';
LIBRARY = '/USER/netcdf-3.5.0/lib/libnetcdf.a';

COMMAND = ['mex ' OPTION ' ' SOURCE ' ' INCLUDE ' ' LIBRARY]
eval(COMMAND)
