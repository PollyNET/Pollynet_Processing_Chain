function tnc4ml5

% tnc4ml5 -- Test nc4ml5 installation.
%  tnc4ml5 (no argument) exercizes some of the
%   components of "NetCDF for Matlab-5".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Apr-1997 09:50:05.

if isempty(which('mexcdf53')) | (exist('mexcdf53') ~= 3)
   disp(' ## Unable to find "mexcdf53" Mex-file gateway.')
   disp(' ## Please check your Matlab path:')
   path
   return
end

clear mexcdf53
clear mexcdf ncmex
clear tmexcdf tncmex tnetcdf

mexcdf53
mexcdf, ncmex
tmexcdf, tncmex, tnetcdf

disp('## Testing done.')

help netcdf
