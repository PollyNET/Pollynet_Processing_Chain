% script ncclear

% ncclear -- Clear Matlab of NetCDF effects.
%  ncclear (no arguments) attempts to clear Matlab
%   so that NetCDF activities can be resumed without
%   having to quit the program.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

ncclose all
fclose('all');
clear mex
clear functions
clear all
