function ncexample

% ncexample.m -- "NetCDF Toolbox for Matlab-5" example.
%  ncexample (no argument) is a short example that lists
%   itself, builds a simple NetCDF file, then displays
%   its variables.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jun-1997 16:23:04.

type(mfilename)

help(mfilename)
 
% ---------------------------- DEFINE THE FILE --------------------------- %

ncquiet                                              % No NetCDF warnings.

nc = netcdf('ncexample.nc', 'clobber');              % Create NetCDF file.

nc.description = 'NetCDF Example';                   % Global attributes.
nc.author = 'Dr. Charles R. Denham';
nc.date = 'June 9, 1997';

nc('latitude') = 10;                                 % Define dimensions.
nc('longitude') = 10;

nc{'latitude'} = 'latitude';                         % Define variables.
nc{'longitude'} = 'longitude';
nc{'depth'} = {'latitude', 'longitude'};

nc{'latitude'}.units = 'degrees';                    % Attributes.
nc{'longitude'}.units = 'degrees';
nc{'depth'}.units = 'meters';

% ---------------------------- STORE THE DATA ---------------------------- %

latitude = [0 10 20 30 40 50 60 70 80 90];           % Matlab data.
longitude = [0 20 40 60 80 100 120 140 160 180];
depth = rand(length(latitude), length(longitude));

nc{'latitude'}(:) = latitude;                        % Put all the data.
nc{'longitude'}(:) = longitude;
nc{'depth'}(:) = depth;

nc = close(nc);                                      % Close the file.

% ---------------------------- RECALL THE DATA --------------------------- %

nc = netcdf('ncexample.nc', 'nowrite');              % Open NetCDF file.
description = nc.description(:)                      % Global attribute.
variables = var(nc);                                 % Get variable data.
for i = 1:length(variables)
   disp([name(variables{i}) ' =']), disp(' ')
   disp(variables{i}(:))
end
nc = close(nc);                                      % Close the file.

% --------------------------------- DONE --------------------------------- %
